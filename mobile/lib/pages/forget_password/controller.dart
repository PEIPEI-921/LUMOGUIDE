import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';

class ForgetPasswordController extends GetxController with ApiMixin {
  final email = ''.obs;

  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(() => email.value = emailController.text);
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void nextStep() async {
    if (email.value.isEmpty) {
      Loading.toast('請輸入郵箱'.tr);
      return;
    }

    if (!email.value.isEmail) {
      Loading.toast('請輸入正確的郵箱'.tr);
      return;
    }

    Loading.show();
    final res = await post(ApiUrl.sendEmailCode, data: {'email': email.value});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Get.toNamed(
      AppRoutes.VERIFY_CODE,
      arguments: {'type': PasswordCodeInputType.retrieve, 'email': email.value},
    );
  }
}
