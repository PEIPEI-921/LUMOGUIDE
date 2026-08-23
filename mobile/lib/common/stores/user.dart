import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../apis/mixin.dart';
import '../apis/urls.dart';
import '../models/user.dart';
import '../routers/names.dart';
import '../services/deep_link.dart';
import '../utils/loading.dart';
import 'chat.dart';
import 'storage.dart';
import '../services/push.dart';

class UserStore extends GetxController with ApiMixin {
  static UserStore get to => Get.find();

  final _isLogin = false.obs;
  String token = '';
  final _profile = UserInfo().obs;

  bool get isLogin => _isLogin.value;
  UserInfo get profile => _profile.value;

  @override
  void onInit() {
    super.onInit();
    token = StorageStone.token;
    _isLogin.value = token.isNotEmpty;
    var profileOffline = StorageStone.userInfo;
    if (profileOffline.isNotEmpty) {
      try {
        _profile(UserInfo.fromJson(jsonDecode(profileOffline)));
      } catch (e) {
        // 本地緩存損壞時不能阻塞啟動，重置並清理壞緩存
        log('UserStore: 解析本地 user_info 失敗: $e', name: 'UserStore');
        _profile(UserInfo());
        StorageStone.setUserInfo('');
      }
    }
    if (_isLogin.value) {
      getProfile();
      _uploadUserRecord();
    }
    // 版本升級檢測：版本變化（含舊版本首次升級）時自動清除登錄態，
    // 強制重新登錄，讓聊天/推送等依賴登錄初始化的新功能自動生效。
    checkVersionUpgrade();
  }

  /// 版本升級檢測。
  ///
  /// 邏輯：本地記錄的上次運行版本與當前版本不同（首次升級時上次版本為空）
  /// 且當前有登錄態 → 清除登錄態（token/IM 憑證/資料）+ 斷開 IM + 跳登錄頁。
  /// 首次安裝（無登錄態）不受影響。
  Future<void> checkVersionUpgrade() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = '${info.version}+${info.buildNumber}';
      final last = StorageStone.appVersion;
      await StorageStone.setAppVersion(current);
      if (last != current && _isLogin.value) {
        log(
          '版本升級 $last → $current：自動登出，請重新登錄',
          name: 'UserStore',
        );
        await StorageStone.logout();
        _isLogin.value = false;
        _profile.value = UserInfo();
        token = '';
        try {
          await ChatStore.to.logout();
        } catch (e) {
          log('UserStore: 升級登出 IM 失敗: $e', name: 'UserStore');
        }
        // 啟動早期（welcome 頁）不主動跳轉，welcome 會按未登錄流程進登錄頁；
        // 已進入主界面則直接跳登錄頁。
        if (Get.currentRoute != AppRoutes.LOGIN &&
            Get.currentRoute != AppRoutes.WELCOME) {
          Get.offAllNamed(AppRoutes.LOGIN);
        }
      }
    } catch (e) {
      log('checkVersionUpgrade error: $e', name: 'UserStore');
    }
  }

  Future<bool> getProfile() async {
    // if (!isLogin) return false;
    final res = await get(ApiUrl.userIndex);
    if (!res.isSuccess) return false;
    final user = UserInfo.fromJson(res.dataJson);
    _profile(user);
    StorageStone.setUserInfo(jsonEncode(user));
    return true;
  }

  Future<bool> modifyProfile(Map<String, dynamic> value) async {
    final res = await post(ApiUrl.editUserInfo, data: value);
    if (!res.isSuccess) return false;
    getProfile();
    return true;
  }

  /// 登錄。返回是否成功（token 有效）。
  Future<bool> login(Map<String, dynamic> value) async {
    try {
      final newToken = value['token'];
      if (newToken is! String || newToken.isEmpty) {
        // 後端未返回 token：不能誤報登錄成功
        log('UserStore: 登錄響應缺少 token', name: 'UserStore');
        return false;
      }
      token = newToken;
      StorageStone.setToken(token);
      final userNumber = value['user_number'] as String? ?? '';
      final lumoChatToken = value['lumo_chat_token'] as String? ?? '';
      StorageStone.setUserNumber(userNumber);
      StorageStone.setLumoChatToken(lumoChatToken);
      if (userNumber.isNotEmpty && lumoChatToken.isNotEmpty) {
        // 初始化 LUMO-Chat：建立实时连接并拉取会话
        ChatStore.to.init(token: lumoChatToken, userId: userNumber);
      }
      _isLogin.value = true;
      await getProfile();

      // 登錄後恢復未處理的深鏈（綁定邀請 + 跳轉內容頁）
      DeepLinkService.checkPendingDeepLink();
      // 登錄後重試緩存的推送點擊（冷啟動/未登錄時點擊通知）
      try {
        PushService.to.retryPendingTap();
      } catch (_) {}
      _uploadUserRecord();
      return true;
    } catch (e) {
      Loading.dismiss();
      log(e.toString(), name: 'UserStore');
      return false;
    }
  }

  /// 註銷帳號。僅在 API 成功時登出；失敗時保留登錄態並提示。
  Future<bool> deleteAccount() async {
    final res = await post(ApiUrl.deleteUser, data: {});
    if (!res.isSuccess) {
      Loading.toast(res.message ?? '註銷失敗');
      return false;
    }
    await StorageStone.logout();
    // 註銷帳號：連同記住的帳號/密碼一起清除
    await StorageStone.setAccount('');
    await StorageStone.setPassword('');
    await StorageStone.setRememberMe(false);
    return true;
  }

  Future logout() async {
    await StorageStone.logout();
    _isLogin.value = false;
    _profile.value = UserInfo();
    token = '';
    try {
      await ChatStore.to.logout();
    } catch (e) {
      log('UserStore: IM 登出失敗: $e', name: 'UserStore');
    }
    // Get.offAllNamed(AppRoutes.ROOT);

    // Get.until((route) => route.isFirst);
    // HomeController.to.fetchData();
    // RootController.to.handlePageChanged(0);
    if (Get.currentRoute != AppRoutes.LOGIN) {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  showLogin() async {
    Get.toNamed(AppRoutes.LOGIN);
  }

  _uploadUserRecord() async {
    if (!isLogin) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastRecordDate = StorageStone.lastLoginRecordDate;

    // 如果今天已经上报过，直接返回
    if (lastRecordDate == today) {
      return;
    }

    try {
      final res = await get(ApiUrl.userRecord);
      if (res.isSuccess) {
        // 上报成功，保存今天的日期
        await StorageStone.setLastLoginRecordDate(today);
      }
    } catch (e) {
      // 静默处理错误，不影响用户体验
      log('每日登录上报失败: $e', name: 'UserStore');
    }
  }
}

mixin UserStoreMixin {
  String get accessToken => UserStore.to.token;

  UserInfo get userInfo => UserStore.to.profile;

  bool get isLogin => UserStore.to.isLogin;

  reloadUserInfo() => UserStore.to.getProfile();
}
