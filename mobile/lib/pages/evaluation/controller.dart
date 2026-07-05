import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/index.dart';

class EvaluationController extends GetxController with ApiMixin {
  EvaluationType type = EvaluationType.news;
  int id = 0;
  String title = '';

  final files = <File>[].obs;
  final rating = 5.obs;

  String get backTitle {
    switch (type) {
      case EvaluationType.news:
        return '資訊評論'.tr;
      case EvaluationType.merchant:
        return title;
    }
  }

  String get ratingText {
    switch (rating.value) {
      case 1:
        return '很差';
      case 2:
        return '差';
      case 3:
        return '一般';
      case 4:
        return '好';
      case 5:
        return '極好';
      default:
        return '';
    }
  }

  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      type = Get.arguments['type'] ?? EvaluationType.news;
      id = Get.arguments['id'] ?? 0;
      title = Get.arguments['title'] ?? '';
    }
  }

  onAddImage() async {
    final path = await ImagePickerUtil.selectImages(
      Get.context!,
      limit: 9 - files.length,
      canEdit: false,
    );
    files.addAll(path.map((e) => File(e)).toList());
  }

  onRemoveImage(File file) {
    files.remove(file);
  }

  updateRating(int value) {
    rating.value = value;
  }

  onSubmit() async {
    if (type == EvaluationType.news) {
      _submitNewsEvaluate();
    } else {
      _submitMerchantEvaluate();
    }
  }

  _submitNewsEvaluate() async {
    if (textController.text.isEmpty) {
      Loading.error('請輸入評論'.tr);
      return;
    }
    Loading.show();
    final files = await _uploadFiles();
    final res = await post(ApiUrl.addInformationEvaluate, data: {
      'content_id': id,
      'content': textController.text,
      'pictures': files,
      'star': rating.value,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('評論成功'.tr);
    Get.back();
  }

  _submitMerchantEvaluate() async {
    if (textController.text.isEmpty) {
      Loading.error('請輸入評論'.tr);
      return;
    }
    Loading.show();
    final files = await _uploadFiles();
    final res = await post(ApiUrl.addContentEvaluate, data: {
      'content_id': id,
      'content': textController.text,
      if (files.isNotEmpty) 'pictures': files,
      'star': rating.value,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('評論成功'.tr);
    await Future.delayed(const Duration(seconds: 1));
    Get.back();
  }

  _uploadFiles() async {
    final futures = files.map((e) => ConfigService.to.uploadFile(e.path));
    final res = await Future.wait(futures);
    return res.map((e) => e).toList();
  }
}
