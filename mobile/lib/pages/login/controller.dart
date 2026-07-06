import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';

class LoginController extends GetxController with ApiMixin {
  final email = ''.obs;
  final password = ''.obs;
  final rememberPassword = false.obs;
  final isObscure = true.obs;
  final isAgree = false.obs;
  // 用于表单控制
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // 监听文本变化
    emailController.addListener(() => email.value = emailController.text);
    passwordController.addListener(
      () => password.value = passwordController.text,
    );

    rememberPassword.value = StorageStone.rememberMe;
    email.value = StorageStone.account;
    password.value = StorageStone.password;
    emailController.text = email.value;
    passwordController.text = password.value;

    if (kDebugMode) {
      /// 2096037421@qq.com
      /// arilks@qq.com
      /// zhouguanpei@gmail.com
      /// business@lumoguide.com
      /// zhouguanpei@hotmail.com
      email.value = 'zhouguanpei@hotmail.com';
      password.value = 'zhou123';
      emailController.text = email.value;
      passwordController.text = password.value;
      rememberPassword.value = true;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // 切换记住密码状态
  void toggleRememberPassword() =>
      rememberPassword.value = !rememberPassword.value;

  // 切换密码可见状态
  void togglePasswordVisible() => isObscure.value = !isObscure.value;

  // 切换同意状态
  void toggleAgree() => isAgree.value = !isAgree.value;

  // 登录方法
  void login() async {
    if (email.value.isEmpty) {
      Loading.toast('請輸入郵箱'.tr);
      return;
    }

    if (!email.value.isEmail) {
      Loading.toast('請輸入正確的郵箱'.tr);
      return;
    }

    if (password.value.isEmpty) {
      Loading.toast('請輸入密碼'.tr);
      return;
    }

    if (!isAgree.value) {
      Loading.toast('請先閱讀並同意用戶協議和隱私政策'.tr);
      return;
    }

    Loading.show();

    final res = await post(
      ApiUrl.login,
      data: {'email': email.value, 'password': password.value},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    if (rememberPassword.value) {
      StorageStone.setPassword(password.value);
      StorageStone.setAccount(email.value);
      StorageStone.setRememberMe(true);
    } else {
      StorageStone.setPassword('');
      StorageStone.setAccount('');
      StorageStone.setRememberMe(false);
    }
    await UserStore.to.login(res.data);
    Loading.success('登錄成功'.tr);
    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed(AppRoutes.ROOT);
    // Get.back();
  }

  // 忘记密码
  void forgotPassword() {
    Get.toNamed(AppRoutes.FORGET_PASSWORD);
  }

  // 前往注册页面
  void goToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }

  // 前往用户协议页面
  void goToUserAgreement() {
    Get.toNamed(
      AppRoutes.WEB,
      arguments: {
        'url': ConfigService.to.systemConfig.userProtocol,
        'title': '用戶協議'.tr,
      },
    );
  }

  // 前往隐私政策页面
  void goToPrivacyPolicy() {
    Get.toNamed(
      AppRoutes.WEB,
      arguments: {
        'url': ConfigService.to.systemConfig.privacyProtocol,
        'title': '隱私政策'.tr,
      },
    );
  }
}
