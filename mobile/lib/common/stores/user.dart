import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../apis/mixin.dart';
import '../apis/urls.dart';
import '../models/user.dart';
import '../routers/names.dart';
import '../services/deep_link.dart';
import '../utils/loading.dart';
import 'storage.dart';
import 't_im.dart';

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
      _profile(UserInfo.fromJson(jsonDecode(profileOffline)));
    }
    if (_isLogin.value) {
      getProfile();
      _uploadUserRecord();
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

  Future login(Map<String, dynamic> value) async {
    try {
      token = value['token'];
      StorageStone.setToken(token);
      StorageStone.setUserNumber(value['user_number']);
      StorageStone.setUserSig(value['user_sig']);
      TIMStore.to.login(StorageStone.userNumber, StorageStone.userSig);
      _isLogin.value = true;
      await getProfile();

      // 登錄後恢復未處理的深鏈（綁定邀請 + 跳轉內容頁）
      DeepLinkService.checkPendingDeepLink();
      _uploadUserRecord();
    } catch (e) {
      Loading.dismiss();
      log(e.toString(), name: 'UserStore');
    }
  }

  deleteAccount() async {
    await post(ApiUrl.deleteUser, data: {});
    await StorageStone.logout();
  }

  Future logout() async {
    await StorageStone.logout();
    _isLogin.value = false;
    _profile.value = UserInfo();
    token = '';
    TIMStore.to.logout();
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
