import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'common/index.dart';

class Global {
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await ScreenUtil.ensureScreenSize();

    /// 使用 Android 13 相册
    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }

    Loading();

    await getPutServices();
    getPut();
  }

  static getPutServices() async {
    await Get.putAsync<StorageService>(() => StorageService().init());
    await Get.putAsync<ImageCacheService>(() => ImageCacheService().init());
    await Get.putAsync<ConfigService>(() => ConfigService().init());
    await Get.putAsync<LocalizationService>(() => LocalizationService().init());
  }

  static getPut() {
    Get.put<TIMStore>(TIMStore());
    Get.put<UserStore>(UserStore());
    Get.put<CityHistoryStore>(CityHistoryStore());
    Get.put<CityListStore>(CityListStore());
  }

  static void setSystemUi() {
    if (GetPlatform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }
}
