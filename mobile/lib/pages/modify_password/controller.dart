import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class ModifyPasswordController extends GetxController with ApiMixin {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 倒計時相關
  final countDown = 60.obs;
  final _isCountingDown = false.obs;
  bool get isCountingDown => _isCountingDown.value;
  Timer? _timer;

  onSubmit() async {
    if (emailController.text.isEmpty) {
      Loading.toast('請輸入注册时填写的邮箱'.tr);
      return;
    }
    if (codeController.text.isEmpty) {
      Loading.toast('請輸入郵箱驗證碼'.tr);
      return;
    }
    if (passwordController.text.isEmpty) {
      Loading.toast('請輸入新密碼'.tr);
      return;
    }
    if (!passwordController.text.isValidPassword) {
      Loading.toast('密碼格式不正確，請輸入至少6位密碼，包含數字和字母'.tr);
      return;
    }
    if (confirmPasswordController.text.isEmpty) {
      Loading.toast('請輸入確認密碼'.tr);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Loading.toast('兩次輸入密碼不一致'.tr);
      return;
    }
    Loading.show();
    final res = await post(
      ApiUrl.resetPassword,
      data: {
        'email': emailController.text,
        'verify_code': codeController.text,
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
      },
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('密碼修改成功'.tr);
    await Future.delayed(const Duration(seconds: 1));
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  sendCode() async {
    if (emailController.text.isEmpty) {
      Loading.toast('請輸入注册时填写的邮箱'.tr);
      return;
    }
    if (!emailController.text.isEmail) {
      Loading.toast('請輸入正確的郵箱'.tr);
      return;
    }
    Loading.show();
    final res = await post(
      ApiUrl.sendEmailCode,
      data: {'email': emailController.text},
    );
    Loading.dismiss();
    if (res.isSuccess) {
      Loading.success('驗證碼已發送'.tr);
      startCountDown();
    } else {
      Loading.error(res.message ?? '驗證碼發送失敗'.tr);
      stopCountDown();
    }
  }

  // 開始倒計時
  void startCountDown() {
    _isCountingDown.value = true;
    countDown.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countDown.value--;
      if (countDown.value <= 0) {
        stopCountDown();
      }
    });
  }

  // 停止倒計時
  void stopCountDown() {
    _timer?.cancel();
    _timer = null;
    _isCountingDown.value = false;
  }
}
