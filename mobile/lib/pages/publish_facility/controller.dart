import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class PublishFacilityController extends GetxController with ApiMixin {
  static const String _draftKey = 'publish_facility_draft';

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final introController = TextEditingController();

  final pictures = <String>[].obs;

  final cities = <CityList>[].obs;
  List<Category> get categories => ConfigService.to.facilityCategories;

  GuidePublishEditor editor = GuidePublishEditor.add;
  int id = 0;
  int cityId = 0;
  bool _submitSuccess = false;

  final _publish = GuidePublishFacility().obs;
  GuidePublishFacility get publish => _publish.value;

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
    phoneController.dispose();
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
      title: '分類'.tr,
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

  onSubmit() async {
    
    Loading.show();
    final url = editor == GuidePublishEditor.add
        ? ApiUrl.guideFacilityAdd
        : ApiUrl.guideFacilityEdit;
    final res = await post(url, data: publish.toJson());
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
    if ((map['name'] as String? ?? '').trim().isNotEmpty) return true;
    if ((map['address'] as String? ?? '').trim().isNotEmpty) return true;
    if ((map['pictures'] as List<dynamic>?)?.isNotEmpty == true) return true;
    return false;
  }

  Map<String, dynamic> _buildDraftMap() {
    _publish.update((val) {
      val?.name = nameController.text.trim();
      val?.phone = phoneController.text.trim();
      val?.address = addressController.text.trim();
      val?.introduce = introController.text.trim();
    });
    return {
      'name': publish.name,
      'phone': publish.phone,
      'address': publish.address,
      'introduce': publish.introduce,
      'city_id': publish.cityId,
      'city_name': publish.cityName,
      'type_class_id': publish.typeClassId,
      'type_class_name': publish.typeClassName,
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
    phoneController.text = draft['phone'] as String? ?? '';
    addressController.text = draft['address'] as String? ?? '';
    introController.text = draft['introduce'] as String? ?? '';
    _publish.update((val) {
      val?.cityId = draft['city_id'] as int?;
      val?.cityName = draft['city_name'] as String?;
      val?.typeClassId = draft['type_class_id'] as int?;
      val?.typeClassName = draft['type_class_name'] as String?;
    });
    final pics = draft['pictures'];
    if (pics is List<dynamic>) {
      pictures.value = pics.map((e) => e.toString()).toList();
    }
  }
}

extension on PublishFacilityController {
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
    final res = await get(ApiUrl.guideFacilityInfo, parameters: {
      'id': id,
    });
    Loading.dismiss();
    if (!res.isSuccess) return;
    _publish.value = GuidePublishFacility.fromJson(res.dataJson);
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
    phoneController.text = publish.phone ?? '';
    addressController.text = publish.address ?? '';
    introController.text = publish.introduce ?? '';
    pictures.value = publish.pictures;
  }
}
