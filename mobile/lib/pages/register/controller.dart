import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';

class RegisterController extends GetxController with ApiMixin {
  final inviteCode = ''.obs;
  final email = ''.obs;

  // 表單控制器
  final inviteCodeController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    inviteCodeController
        .addListener(() => inviteCode.value = inviteCodeController.text);
    emailController.addListener(() => email.value = emailController.text);
  }

  @override
  void onClose() {
    inviteCodeController.dispose();
    emailController.dispose();
    super.onClose();
  }

  // 下一步方法
  void nextStep() async {
    if (inviteCode.value.isEmpty) {
      Loading.toast('請輸入您的邀請碼'.tr);
      return;
    }

    if (email.value.isEmpty) {
      Loading.toast('請輸入郵箱'.tr);
      return;
    }

    if (!email.value.isEmail) {
      Loading.toast('請輸入正確的郵箱'.tr);
      return;
    }

    Loading.show();
    final res = await post(ApiUrl.sendEmailCode, data: {
      'email': email.value,
      'type': 'reg',
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }

    Get.toNamed(AppRoutes.VERIFY_CODE, arguments: {
      'type': PasswordCodeInputType.register,
      'email': email.value,
      'invite_code': inviteCode.value,
    });
  }
}
