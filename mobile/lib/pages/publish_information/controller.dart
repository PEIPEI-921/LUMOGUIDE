import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class PublishInformationController extends GetxController with ApiMixin {
  static const String _draftKey = 'publish_information_draft';

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  GuidePublishEditor editor = GuidePublishEditor.add;
  int id = 0;
  bool _submitSuccess = false;

  final _pictures = <String>[].obs;
  List<String> get pictures => _pictures;

  final _categories = <Category>[].obs;
  List<Category> get categories => _categories;

  final _guidePublish = GuidePublishInformation().obs;
  GuidePublishInformation get guidePublish => _guidePublish.value;

  bool get isPublic => guidePublish.look == 2;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      editor = Get.arguments['type'] as GuidePublishEditor? ??
          GuidePublishEditor.add;
      id = Get.arguments['id'] as int? ?? 0;
    }

    _fetchNewsCategory();
    fetchInfo();
  }

  @override
  void onReady() {
    super.onReady();
    if (id == 0) _checkDraftAndPrompt();
  }

  @override
  void onClose() {
    if (id == 0 && !_submitSuccess) _saveDraft();
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  onSelectCategory() async {
    final data = categories.map((e) => e.name ?? '').toList();
    final res = await ValuePicker.show(
      title: '請選擇資訊分類'.tr,
      datas: data,
      selectedDatas: [guidePublish.className ?? ''],
    );
    if (res == null) {
      return;
    }
    _guidePublish.update((val) {
      val?.classId = categories.firstWhere((e) => e.name == res.first).id;
      val?.className = res.first;
    });
  }

  selectImage({int? index}) async {
    final path = await ImagePickerUtil.selectImage(Get.context!);
    if (path.isEmpty) {
      return;
    }
    if (index != null && index < pictures.length) {
      pictures[index] = path;
    } else {
      pictures.add(path);
    }
  }

  removeImage(int index) {
    if (index >= 0 && index < pictures.length) {
      pictures.removeAt(index);
    }
  }

  onVisibilityChanged(bool value) {
    _guidePublish.update((val) {
      val?.look = value ? 2 : 1;
    });
  }

  onSubmit() async {
    _guidePublish.update((val) {
      val?.title = titleController.text.trim();
      val?.content = contentController.text.trim();
    });
    Loading.show();
    final url = editor == GuidePublishEditor.add
        ? ApiUrl.guideInformationAdd
        : ApiUrl.guideInformationEdit;
    final res = await post(url, data: guidePublish.toJson());
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }

    await AlertUtils.customAlert(
      assets: Assets.iconReview,
      imageSize: Size(50.w, 50.w),
      title: '發布成功，請等待管理員審核~'.tr,
      confirmText: '關閉'.tr,
    );
    await _clearDraft();
    _submitSuccess = true;
    Get.back(result: true);
  }

  Future<void> _saveDraft() async {
    if (id != 0) return;
    final map = _buildDraftMap();
    if (!_draftHasContent(map)) return;
    await StorageService.to.setString(_draftKey, jsonEncode(map));
  }

  bool _draftHasContent(Map<String, dynamic> map) {
    if ((map['title'] as String? ?? '').trim().isNotEmpty) return true;
    if ((map['content'] as String? ?? '').trim().isNotEmpty) return true;
    if ((map['pictures'] as List<dynamic>?)?.isNotEmpty == true) return true;
    return false;
  }

  Map<String, dynamic> _buildDraftMap() {
    _guidePublish.update((val) {
      val?.title = titleController.text.trim();
      val?.content = contentController.text.trim();
    });
    return {
      'title': guidePublish.title,
      'content': guidePublish.content,
      'class_id': guidePublish.classId,
      'class_name': guidePublish.className,
      'look': guidePublish.look,
      'pictures': pictures.toList(),
    };
  }

  Future<void> _clearDraft() async {
    await StorageService.to.remove(_draftKey);
  }

  Map<String, dynamic>? _getDraftMap() {
    final s = StorageService.to.getString(_draftKey);
    if (s.isEmpty) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkDraftAndPrompt() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final draft = _getDraftMap();
    if (draft == null) return;
    final use = await AlertUtils.show(
      title: '提示'.tr,
      content: '檢測到上次未提交的填寫數據，是否使用？'.tr,
      cancelText: '不使用'.tr,
      confirmText: '使用'.tr,
    );
    if (use) {
      _fillFromDraft(draft);
    } else {
      await _clearDraft();
    }
  }

  void _fillFromDraft(Map<String, dynamic> draft) {
    titleController.text = draft['title'] as String? ?? '';
    contentController.text = draft['content'] as String? ?? '';
    _guidePublish.update((val) {
      val?.classId = draft['class_id'] as int?;
      val?.className = draft['class_name'] as String?;
      val?.look = draft['look'] as int? ?? 1;
    });
    final pics = draft['pictures'];
    if (pics is List<dynamic>) {
      _pictures.value = pics.map((e) => e.toString()).toList();
    }
  }

}

extension on PublishInformationController {
  _fetchNewsCategory() async {
    final res = await get(ApiUrl.informationClass);
    if (!res.isSuccess) return;
    final data = res.dataList;
    final categories = data.map((e) => Category.fromJson(e)).toList();
    _categories.value = categories;
    if (editor == GuidePublishEditor.edit) {
      fillData();
    }
  }

  fetchInfo() async {
    if (id == 0) return;
    Loading.show();
    final res = await get(ApiUrl.guideInformationInfo, parameters: {
      'id': id,
    });
    Loading.dismiss();
    if (!res.isSuccess) return;
    _guidePublish.value = GuidePublishInformation.fromJson(res.dataJson);
    fillData();
  }

  fillData() {
    if (guidePublish.id == null) return;
    _guidePublish.update((val) {
      val?.className =
          categories.firstWhereOrNull((e) => e.id == val.classId)?.name;
    });
    titleController.text = guidePublish.title ?? '';
    contentController.text = guidePublish.content ?? '';
    _pictures.value = guidePublish.pictures;
  }
}
