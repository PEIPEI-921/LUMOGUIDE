import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class ModifyPhoneController extends GetxController
    with ApiMixin, UserStoreMixin {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  // 倒計時相關
  final countDown = 60.obs;
  final _isCountingDown = false.obs;
  bool get isCountingDown => _isCountingDown.value;
  Timer? _timer;

  onSubmit() async {
    if (phoneController.text.isEmpty) {
      Loading.toast('請輸入手機號'.tr);
      return;
    }
    if (codeController.text.isEmpty) {
      Loading.toast('請輸入驗證碼'.tr);
      return;
    }

    Loading.show();
    final res = await post(ApiUrl.bindPhone, data: {
      'phone': phoneController.text,
      'phone_code': codeController.text,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('綁定成功'.tr);
    reloadUserInfo();
    await Future.delayed(const Duration(seconds: 1));
    Get.back();
  }

  @override
  void onClose() {
    phoneController.dispose();
    codeController.dispose();
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  sendCode() async {
    if (phoneController.text.isEmpty) {
      Loading.toast('請輸入手機號'.tr);
      return;
    }
    Loading.show();
    final res = await post(ApiUrl.sendPhoneCode, data: {
      'phone': phoneController.text,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('驗證碼發送成功'.tr);
    startCountDown();
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
