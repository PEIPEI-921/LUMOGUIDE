import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class FeedbackController extends GetxController with ApiMixin {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final _file = Rxn<File>();
  File? get file => _file.value;

  onSubmit() async {
    if (titleController.text.isEmpty) {
      Loading.toast('請輸入標題'.tr);
      return;
    }
    if (contentController.text.isEmpty) {
      Loading.toast('請輸入內容'.tr);
      return;
    }

    Loading.show();
    final fileUrl = await _uploadFile();
    final res = await post(ApiUrl.feedback, data: {
      'title': titleController.text,
      'content': contentController.text,
      if (fileUrl.isNotEmpty) 'pictures': fileUrl,
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

  _uploadFile() async {
    if (file == null) {
      return '';
    }
    final url = await ConfigService.to.uploadFile(file!.path);
    return url;
  }

  onAddImage() async {
    final file = await ImagePickerUtil.selectImage(Get.context!);
    if (file.isNotEmpty) {
      _file.value = File(file);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
