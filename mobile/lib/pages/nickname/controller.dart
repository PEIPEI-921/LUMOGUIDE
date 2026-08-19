import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class NicknameController extends GetxController {
  final nicknameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nicknameController.text = UserStore.to.profile.nickname ?? '';
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }

  onSubmit() async {
    if (nicknameController.text.isEmpty) {
      Loading.toast('請輸入暱稱'.tr);
      return;
    }
    if (nicknameController.text.length > 8) {
      Loading.toast('暱稱最多10個字'.tr);
      return;
    }
    Loading.show();
    final res =
        await UserStore.to.modifyProfile({'nickname': nicknameController.text});
    Loading.dismiss();
    if (!res) {
      AlertUtils.error('修改失敗'.tr);
      return;
    }
    Get.back();
  }
}
