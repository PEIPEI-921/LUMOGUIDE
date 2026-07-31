import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';

class PublishActivityController extends GetxController with ApiMixin {
  static const String _draftKey = 'publish_activity_draft';

  final nameController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  final introController = TextEditingController();

  final pictures = <String>[].obs;

  final cities = <CityList>[].obs;
  List<Category> get categories => ConfigService.to.activityCategories;

  GuidePublishEditor editor = GuidePublishEditor.add;
  int id = 0;
  bool _submitSuccess = false;
  int cityId = 0;

  final _publish = GuidePublishActivity().obs;
  GuidePublishActivity get publish => _publish.value;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      editor = Get.arguments['type'] as GuidePublishEditor? ??
          GuidePublishEditor.add;
      id = Get.arguments['id'] as int? ?? 0;
      cityId = Get.arguments['city_id'] as int? ?? 0;
    }

    fetchCity();
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
    nameController.dispose();
    websiteController.dispose();
    addressController.dispose();
    introController.dispose();
    super.onClose();
  }

  onSelectCity() async {
    if (cities.isEmpty) {
      Loading.toast('無可選城市'.tr);
      return;
    }
    final picked = await CityPickerSheet.show(
      title: '請選擇所屬城市'.tr,
      cities: cities,
      selectedCityId: publish.cityId,
    );
    if (picked != null) {
      _publish.update((val) {
        val?.cityId = picked.id;
        val?.cityName = picked.name;
      });
    }
  }

  onSelectCategory() async {
    final data = categories.map((e) => e.name ?? '').toList();
    final res = await ValuePicker.show(
      title: '活動類型'.tr,
      datas: data,
      selectedDatas: [publish.typeClassName ?? ''],
    );
    if (res == null) return;
    final category = categories.firstWhere((e) => e.name == res.first);
    _publish.update((val) {
      val?.typeClassId = category.id ?? 0;
      val?.typeClassName = category.name ?? '';
    });
  }

  onSelectStartTime() async {
    final selected = publish.startTime != null
        ? DateTime.tryParse(publish.startTime!) ?? DateTime.now()
        : DateTime.now();
    final res = await DatePicker.show(
      title: '請選擇開始時間'.tr,
      selected: selected,
      mode: CupertinoDatePickerMode.date,
    );
    if (res == null) return;
    _publish.update((val) {
      val?.startTime = DateFormat('yyyy-MM-dd').format(res);
    });
  }

  onSelectEndTime() async {
    final selected = publish.endTime != null
        ? DateTime.tryParse(publish.endTime!) ?? DateTime.now()
        : DateTime.now();
    final res = await DatePicker.show(
      title: '請選擇結束時間'.tr,
      selected: selected,
      mode: CupertinoDatePickerMode.date,
    );
    if (res == null) return;
    _publish.update((val) {
      val?.endTime = DateFormat('yyyy-MM-dd').format(res);
    });
  }

  Future<void> selectImage({int? index}) async {
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

  void removeImage(int index) {
    if (index >= 0 && index < pictures.length) pictures.removeAt(index);
  }

  /// 上传本地图片，已是远程 URL 的跳过。单文件失败不影响其他文件
  Future<List<String>> _uploadFiles() async {
    if (pictures.isEmpty) return [];
    final results = <String>[];
    for (final e in pictures) {
      if (e.startsWith('http://') || e.startsWith('https://')) {
        results.add(e);
      } else {
        try {
          final url = await ConfigService.to.uploadFile(e);
          if (url.isNotEmpty) results.add(url);
        } catch (_) {
          // 单个文件上传失败，跳过继续
        }
      }
    }
    return results;
  }

  onSubmit() async {
    Loading.show();
    final uploadedUrls = await _uploadFiles();

    // 同步文本输入框 + 图片到 model
    _publish.update((val) {
      val?.name = nameController.text;
      val?.website = websiteController.text;
      val?.address = addressController.text;
      val?.introduce = introController.text;
      val?.pictures = uploadedUrls;
    });

    final url = editor == GuidePublishEditor.add
        ? ApiUrl.guideActivityAdd
        : ApiUrl.guideActivityEdit;
    final payload = publish.toJson();
    debugPrint('[PublishActivity] POST $url payload keys: ${payload.keys}, name: ${payload['name']}');
    final res = await post(url, data: payload);
    Loading.dismiss();
    if (!res.isSuccess) {
      debugPrint('[PublishActivity] Submit failed: code=${res.code}, message=${res.message}');
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
    if ((map['name'] as String? ?? '').trim().isNotEmpty) return true;
    if ((map['address'] as String? ?? '').trim().isNotEmpty) return true;
    if ((map['pictures'] as List<dynamic>?)?.isNotEmpty == true) return true;
    return false;
  }

  Map<String, dynamic> _buildDraftMap() {
    _publish.update((val) {
      val?.name = nameController.text.trim();
      val?.website = websiteController.text.trim();
      val?.address = addressController.text.trim();
      val?.introduce = introController.text.trim();
    });
    return {
      'name': publish.name,
      'website': publish.website,
      'address': publish.address,
      'introduce': publish.introduce,
      'city_id': publish.cityId,
      'city_name': publish.cityName,
      'type_class_id': publish.typeClassId,
      'type_class_name': publish.typeClassName,
      'start_time': publish.startTime,
      'end_time': publish.endTime,
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
    nameController.text = draft['name'] as String? ?? '';
    websiteController.text = draft['website'] as String? ?? '';
    addressController.text = draft['address'] as String? ?? '';
    introController.text = draft['introduce'] as String? ?? '';
    _publish.update((val) {
      val?.cityId = draft['city_id'] as int?;
      val?.cityName = draft['city_name'] as String?;
      val?.typeClassId = draft['type_class_id'] as int?;
      val?.typeClassName = draft['type_class_name'] as String?;
      val?.startTime = draft['start_time'] as String?;
      val?.endTime = draft['end_time'] as String?;
    });
    final pics = draft['pictures'];
    if (pics is List<dynamic>) {
      pictures.value = pics.map((e) => e.toString()).toList();
    }
  }
}

extension on PublishActivityController {
  fetchCity() async {
    final res = await get(ApiUrl.cityList, parameters: {
      'limit': 1000,
      'page': 1,
    });
    if (!res.isSuccess) return;
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    cities.value = data.map((e) => CityList.fromJson(e)).toList();
    if (editor == GuidePublishEditor.edit) {
      fillData();
    }
    if (cityId != 0) {
      _publish.update((val) {
        val?.cityId = cityId;
        val?.cityName = cities.firstWhereOrNull((e) => e.id == cityId)?.name;
      });
    }
  }

  fetchInfo() async {
    if (id == 0) return;
    Loading.show();
    final res = await get(ApiUrl.guideActivityInfo, parameters: {
      'id': id,
    });
    Loading.dismiss();
    if (!res.isSuccess) return;
    _publish.value = GuidePublishActivity.fromJson(res.dataJson);
    fillData();
  }

  fillData() {
    if (publish.id == null) return;
    _publish.update((val) {
      val?.cityName = cities.firstWhereOrNull((e) => e.id == val.cityId)?.name;
      val?.typeClassName =
          categories.firstWhereOrNull((e) => e.id == val.typeClassId)?.name;
    });
    nameController.text = publish.name ?? '';
    websiteController.text = publish.website ?? '';
    addressController.text = publish.address ?? '';
    introController.text = publish.introduce ?? '';
    pictures.value = publish.pictures;
  }
}
