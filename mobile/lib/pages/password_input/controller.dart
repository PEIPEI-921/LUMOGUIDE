import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';

class PasswordInputController extends GetxController with ApiMixin {
  var type = PasswordCodeInputType.register;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String get title =>
      type == PasswordCodeInputType.register ? '註冊'.tr : '找回密碼'.tr;

  var email = '';
  var inviteCode = '';
  var code = '';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      type = Get.arguments['type'] ?? PasswordCodeInputType.register;
      email = Get.arguments['email'] ?? '';
      inviteCode = Get.arguments['invite_code'] ?? '';
      code = Get.arguments['code'] ?? '';
    }
    passwordController.addListener(
      () => password.value = passwordController.text,
    );
    confirmPasswordController.addListener(
      () => confirmPassword.value = confirmPasswordController.text,
    );
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  bool _validatePassword(String password) {
    if (password.length < 6) {
      return false;
    }

    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasLetter = password.contains(RegExp(r'[a-zA-Z]'));

    return hasDigit && hasLetter;
  }

  void submit() async {
    if (password.isEmpty) {
      Loading.error('請輸入密碼'.tr);
      return;
    }

    if (!_validatePassword(password.value)) {
      Loading.error('密碼格式不正確，請輸入至少6位密碼，包含數字和字母'.tr);
      return;
    }

    if (confirmPassword.isEmpty) {
      Loading.error('請輸入確認密碼'.tr);
      return;
    }

    if (password.value != confirmPassword.value) {
      Loading.error('兩次輸入密碼不一致'.tr);
      return;
    }

    if (type == PasswordCodeInputType.register) {
      Loading.show();

      final res = await post(
        ApiUrl.register,
        data: {
          'email': email,
          'inviter_code': inviteCode,
          'password': password.value,
          'password_confirmation': confirmPassword.value,
        },
      );
      Loading.dismiss();
      if (!res.isSuccess) {
        AlertUtils.error(res.message ?? '註冊失敗'.tr);
        return;
      }
      await UserStore.to.login(res.data);
      Loading.success('註冊成功'.tr);
      await Future.delayed(const Duration(seconds: 1));
      await Get.offAllNamed(AppRoutes.ROOT);
      // 主導航完成後再處理深鏈：註冊/登錄前掃碼的待處理參數在此恢復
      DeepLinkService.checkPendingDeepLink();
      // Get.back();
      return;
    }

    Loading.show();
    final res = await post(
      ApiUrl.resetPassword,
      data: {
        'email': email,
        'verify_code': code,
        'password': password.value,
        'password_confirmation': confirmPassword.value,
      },
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('密碼修改成功'.tr);
    await Future.delayed(const Duration(seconds: 1));
    Get.until((route) => route.settings.name == AppRoutes.LOGIN);
  }
}
