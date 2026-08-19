import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';

class VerifyCodeController extends GetxController with ApiMixin {
  var type = PasswordCodeInputType.register;

  String get title =>
      type == PasswordCodeInputType.register ? '註冊'.tr : '找回密碼'.tr;

  // 驗證碼控制器
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  // 倒計時相關
  final countDown = 60.obs;
  final isCountingDown = false.obs;
  Timer? _timer;

  // 郵箱
  var email = '';

  // 邀請碼
  var inviteCode = '';

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      email = Get.arguments['email'] ?? '';
      inviteCode = Get.arguments['invite_code'] ?? '';
      type = Get.arguments['type'] ?? PasswordCodeInputType.register;
    }

    startCountDown();
  }

  // 開始倒計時
  void startCountDown() {
    isCountingDown.value = true;
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
    isCountingDown.value = false;
  }

  // 重新發送驗證碼
  void resendCode() {
    if (isCountingDown.value) {
      return;
    }
    _sendCode();

    // if (type == PasswordCodeInputType.register) {
    //   // 註冊
    // } else {
    //   // 找回密碼
    // }
  }

  _sendCode() async {
    Loading.show();
    final res = await post(ApiUrl.sendEmailCode, data: {
      'email': email,
    });
    Loading.dismiss();
    if (res.isSuccess) {
      Loading.success('驗證碼已發送'.tr);
      startCountDown();
    } else {
      Loading.error(res.message ?? '驗證碼發送失敗'.tr);
      stopCountDown();
    }
  }

  // 提交驗證碼
  void submitCode() async {
    if (pinController.text.length != 6) {
      Loading.toast('請輸入6位驗證碼'.tr);
      return;
    }

    // Loading.show();
    // final res = await post(ApiUrl.verifyCode, data: {
    //   'email': email,
    //   'code': pinController.text,
    // });
    // Loading.dismiss();
    // if (!res.isSuccess) {
    //   AlertUtils.error(res.message);
    //   return;
    // }

    Get.toNamed(AppRoutes.PASSWORD_INPUT, arguments: {
      'type': type,
      'email': email,
      'invite_code': inviteCode,
      'code': pinController.text,
    });
  }

  @override
  void onClose() {
    pinController.dispose();
    focusNode.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
