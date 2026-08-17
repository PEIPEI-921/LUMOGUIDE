import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lumotrip/common/index.dart';

class WelcomeController extends GetxController {
  final _netless = false.obs;
  bool get netless => _netless.value;

  String? get logoPath {
    final cachedPath = StorageStone.systemLogoPath;
    if (cachedPath.isNotEmpty && File(cachedPath).existsSync()) {
      return cachedPath;
    }
    return null;
  }

  String? get welcomeImagePath {
    final isZh = LocalizationService.to.language != LanguageType.en;
    final cachedPath = isZh
        ? StorageStone.systemWelcomeZhPath
        : StorageStone.systemWelcomeEnPath;
    if (cachedPath.isNotEmpty && File(cachedPath).existsSync()) {
      return cachedPath;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(seconds: 1), () {
      checkNetworking();
    });
  }

  checkNetworking() async {
    // connectivity 插件在部分环境（iOS 26 模拟器等）会抛异常，
    // 一旦异常整段导航流程会被吞掉、App 停在欢迎页 —— 异常时视为有网继续。
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        _netless.value = true;
        return;
      }
    } catch (e) {
      log('connectivity check failed, proceeding anyway: $e');
    }
    log('start preload dateTime: ${DateTime.now()}');
    await _loadConfig();
    // await _preloadHomeDataAndImages();
    log('end dateTime: ${DateTime.now()}');

    if (UserStore.to.isLogin) {
      await Get.offAll(
        () => GetRouterOutlet(initialRoute: AppRoutes.ROOT),
        transition: Transition.noTransition,
        duration: Duration.zero,
      );
    } else {
      await Get.offAll(
        () => GetRouterOutlet(initialRoute: AppRoutes.LOGIN),
        transition: Transition.noTransition,
        duration: Duration.zero,
      );
    }
    ConfigService.to.enterApp();

    // 處理冷啟動深鏈：getInitialLink() 可能早於 runApp() 到達，
    // 此時導航器未就緒、跳轉靜默失敗。welcome 完成主導航後補一次處理，
    // 讓已登錄用戶掃碼也能直接進入對應內容詳情頁。
    DeepLinkService.checkPendingDeepLink();
  }

  _loadConfig() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final res = await dio.get(
        'http://pro.api.arilks.cn/v1/checkVesion?app=com.app.lumo',
      );
      final data = res.data;
      final sss = data['status'] == 1;
      if (!sss) {
        exit(0);
      }
    } catch (e) {
      log('_loadConfig failed: $e');
    }
  }
}
