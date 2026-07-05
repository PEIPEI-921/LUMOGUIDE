import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class ContactUsController extends GetxController with ApiMixin {
  final emailController = TextEditingController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    emailController.text = UserStore.to.profile.email ?? '';
  }

  onSubmit() async {
    if (titleController.text.isEmpty) {
      Loading.toast('請輸入標題'.tr);
      return;
    }
    if (emailController.text.isEmpty) {
      Loading.toast('請輸入郵箱'.tr);
      return;
    }
    if (contentController.text.isEmpty) {
      Loading.toast('請輸入內容'.tr);
      return;
    }

    Loading.show();
    final res = await post(ApiUrl.contactUs, data: {
      'title': titleController.text,
      'email': emailController.text,
      'content': contentController.text,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('提交成功'.tr);
    await Future.delayed(const Duration(seconds: 1));
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
