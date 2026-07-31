import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'index.dart';

class MerchantEditorController extends GetxController with ApiMixin {
  static const String _draftKey = 'merchant_editor_draft';

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  final introController = TextEditingController();
  final startTimeController = TextEditingController();
  final capacityController = TextEditingController();
  final priceController = TextEditingController();
  final otherContactController = TextEditingController();
  final arriveController = TextEditingController();
  final pictures = <String>[].obs;

  final cities = <CityList>[].obs;
  List<Category> get categories =>
      ConfigService.to.getCategories(merchantShop.typeId ?? 0);

  MerchantEditorType type = MerchantEditorType.add;
  int id = 0;
  bool _submitSuccess = false;

  final _merchantShop = MerchantShop().obs;
  MerchantShop get merchantShop => _merchantShop.value;

  MerchantShopType get shopType =>
      MerchantShopTypeExt.fromId(merchantShop.typeId ?? 0);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      type =
          Get.arguments['type'] as MerchantEditorType? ??
          MerchantEditorType.add;
      id = Get.arguments['id'] as int? ?? 0;
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
    emailController.dispose();
    websiteController.dispose();
    addressController.dispose();
    introController.dispose();
    startTimeController.dispose();
    capacityController.dispose();
    priceController.dispose();
    otherContactController.dispose();
    arriveController.dispose();
    super.onClose();
  }

  onSelectShopType() async {
    final data = MerchantShopType.values.map((e) => e.title).toList();
    final res = await ValuePicker.show(
      title: '請選擇商家類型'.tr,
      datas: data,
      selectedDatas: [shopType.title],
    );
    if (res == null || res.isEmpty) return;
    final updateShopType = MerchantShopType.values.firstWhere(
      (e) => e.title == res.first,
    );
    _merchantShop.update((val) {
      val?.typeId = updateShopType.id;
      val?.typeClassId = null;
      val?.typeClassName = null;
    });
    // 清空类型相关字段
    _clearTypeSpecificFields();
  }

  _clearTypeSpecificFields() {
    startTimeController.clear();
    capacityController.clear();
    priceController.clear();
    otherContactController.clear();
    arriveController.clear();
    _merchantShop.update((val) {
      val?.ticketsFree = 1;
      val?.orderFood = null;
    });
  }

  onSelectCity() async {
    if (cities.isEmpty) {
      Loading.toast('無可選城市'.tr);
      return;
    }
    final picked = await CityPickerSheet.show(
      title: '請選擇所屬城市'.tr,
      cities: cities,
      selectedCityId: merchantShop.cityId,
    );
    if (picked != null) {
      _merchantShop.update((val) {
        val?.cityId = picked.id;
        val?.cityName = picked.name;
      });
    }
  }

  onSelectCategory() async {
    var data = categories.map((e) => e.name ?? '').toList();
    if (data.isEmpty) {
      Loading.show();
      final res = await get(
        ApiUrl.typeClass,
        parameters: {'type_id': merchantShop.typeId},
      );
      Loading.dismiss();
      if (!res.isSuccess) {
        Loading.toast('error'.tr);
        return;
      }
      final temp = res.dataList;
      data = temp.map((e) => Category.fromJson(e).name ?? '').toList();
    }
    final res = await ValuePicker.show(
      title: '分類'.tr,
      datas: data,
      selectedDatas: [merchantShop.typeClassName ?? ''],
    );
    if (res == null) return;
    final category = categories.firstWhere((e) => e.name == res.first);
    _merchantShop.update((val) {
      val?.typeClassId = category.id ?? 0;
      val?.typeClassName = category.name ?? '';
    });
  }

  onToggleOrderFood(bool value) {
    _merchantShop.update((val) {
      val?.orderFood = value ? 1 : 0;
    });
  }

  onToggleTicketsFree(bool value) {
    _merchantShop.update((val) {
      val?.ticketsFree = value ? 1 : 0;
      if (value) {
        val?.price = '';
        priceController.clear();
      }
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
    if (merchantShop.cityId == null) {
      Loading.toast('請選擇所屬城市'.tr);
      return;
    }
    if (merchantShop.typeClassId == null) {
      Loading.toast('請選擇分類'.tr);
      return;
    }
    if (nameController.text.trim().isEmpty) {
      Loading.toast('請輸入名稱'.tr);
      return;
    }
    if (startTimeController.text.trim().isEmpty) {
      switch (shopType) {
        case MerchantShopType.restaurant:
        case MerchantShopType.shopping:
          Loading.toast('請輸入營業時間'.tr);
          return;
        case MerchantShopType.scenic:
          Loading.toast('請輸入開放時間'.tr);
          return;
        default:
          break;
      }
    }
    if (merchantShop.ticketsFree == 0 &&
        priceController.text.trim().isEmpty &&
        shopType == MerchantShopType.scenic) {
      Loading.toast('請輸入票價'.tr);
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      Loading.toast('請輸入電話'.tr);
      return;
    }
    if (shopType == MerchantShopType.ticket &&
        priceController.text.trim().isEmpty) {
      Loading.toast('請輸入價格'.tr);
      return;
    }
    if (addressController.text.trim().isEmpty) {
      Loading.toast('請輸入地址'.tr);
      return;
    }
    if (pictures.isEmpty) {
      Loading.toast('請上傳最少一張圖片'.tr);
      return;
    }

    _merchantShop.update((val) {
      val?.name = nameController.text.trim();
      val?.phone = phoneController.text.trim();
      val?.email = emailController.text.trim();
      val?.website = websiteController.text.trim();
      val?.address = addressController.text.trim();
      val?.introduce = introController.text.trim();
      val?.startTime = startTimeController.text.trim();
      val?.capacity = capacityController.text.trim();
      val?.price = priceController.text.trim();
      val?.howArrive = arriveController.text.trim();
      val?.otherPhone = otherContactController.text.trim();
    });

    Loading.show();
    if (!await _uploadImages()) {
      Loading.dismiss();
      return;
    }
    final url = type == MerchantEditorType.add
        ? ApiUrl.companyShopAdd
        : ApiUrl.companyShopEdit;
    final res = await post(url, data: merchantShop.toJson());
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
    _merchantShop.update((val) {
      val?.name = nameController.text.trim();
      val?.phone = phoneController.text.trim();
      val?.email = emailController.text.trim();
      val?.website = websiteController.text.trim();
      val?.address = addressController.text.trim();
      val?.introduce = introController.text.trim();
      val?.startTime = startTimeController.text.trim();
      val?.capacity = capacityController.text.trim();
      val?.price = priceController.text.trim();
      val?.howArrive = arriveController.text.trim();
      val?.otherPhone = otherContactController.text.trim();
    });
    return {
      'name': merchantShop.name,
      'phone': merchantShop.phone,
      'email': merchantShop.email,
      'website': merchantShop.website,
      'address': merchantShop.address,
      'introduce': merchantShop.introduce,
      'start_time': merchantShop.startTime,
      'capacity': merchantShop.capacity,
      'price': merchantShop.price,
      'how_arrive': merchantShop.howArrive,
      'other_phone': merchantShop.otherPhone,
      'city_id': merchantShop.cityId,
      'city_name': merchantShop.cityName,
      'type_id': merchantShop.typeId,
      'type_class_id': merchantShop.typeClassId,
      'type_class_name': merchantShop.typeClassName,
      'tickets_free': merchantShop.ticketsFree,
      'order_food': merchantShop.orderFood,
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
    emailController.text = draft['email'] as String? ?? '';
    websiteController.text = draft['website'] as String? ?? '';
    addressController.text = draft['address'] as String? ?? '';
    introController.text = draft['introduce'] as String? ?? '';
    startTimeController.text = draft['start_time'] as String? ?? '';
    capacityController.text = draft['capacity'] as String? ?? '';
    priceController.text = draft['price'] as String? ?? '';
    arriveController.text = draft['how_arrive'] as String? ?? '';
    otherContactController.text = draft['other_phone'] as String? ?? '';
    _merchantShop.update((val) {
      val?.cityId = draft['city_id'] as int?;
      val?.cityName = draft['city_name'] as String?;
      val?.typeId = draft['type_id'] as int?;
      val?.typeClassId = draft['type_class_id'] as int?;
      val?.typeClassName = draft['type_class_name'] as String?;
      val?.ticketsFree = draft['tickets_free'] as int? ?? 1;
      val?.orderFood = draft['order_food'] as int?;
    });
    final pics = draft['pictures'];
    if (pics is List<dynamic>) {
      pictures.value = pics.map((e) => e.toString()).toList();
    }
  }

  Future<bool> _uploadImages() async {
    // 逐文件串行上传（单文件失败不影响其他）
    final uploadedPics = <String>[];
    for (final e in pictures) {
      if (e.startsWith('http://') || e.startsWith('https://')) {
        uploadedPics.add(e);
      } else {
        try {
          final url = await ConfigService.to.uploadFile(e);
          if (url.isNotEmpty) uploadedPics.add(url);
        } catch (_) {
          // 单文件上传失败，跳过继续
        }
      }
    }
    if (pictures.isNotEmpty && uploadedPics.isEmpty) {
      AlertUtils.error('圖片上傳失敗'.tr);
      return false;
    }

    _merchantShop.update((val) {
      val?.pictures = uploadedPics;
    });
    return true;
  }
}

extension on MerchantEditorController {
  fetchCity() async {
    final res = await get(
      ApiUrl.cityList,
      parameters: {'limit': 1000, 'page': 1},
    );
    if (!res.isSuccess) return;
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    cities.value = data.map((e) => CityList.fromJson(e)).toList();
    if (type == MerchantEditorType.edit) {
      fillData();
    }
  }

  fetchInfo() async {
    if (id == 0) return;
    Loading.show();
    final res = await get(ApiUrl.companyShopInfo, parameters: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) return;
    _merchantShop.value = MerchantShop.fromJson(res.dataJson);
    fillData();
  }

  fillData() {
    if (merchantShop.id == null) return;
    _merchantShop.update((val) {
      val?.cityName = cities.firstWhereOrNull((e) => e.id == val.cityId)?.name;
      val?.typeClassName = categories
          .firstWhereOrNull((e) => e.id == val.typeClassId)
          ?.name;
    });
    nameController.text = merchantShop.name ?? '';
    phoneController.text = merchantShop.phone ?? '';
    emailController.text = merchantShop.email ?? '';
    websiteController.text = merchantShop.website ?? '';
    addressController.text = merchantShop.address ?? '';
    introController.text = merchantShop.introduce ?? '';
    startTimeController.text = merchantShop.startTime ?? '';
    capacityController.text = merchantShop.capacity ?? '';
    priceController.text = merchantShop.price ?? '';
    arriveController.text = merchantShop.howArrive ?? '';
    otherContactController.text = merchantShop.otherPhone ?? '';
    pictures.value = merchantShop.pictures;
  }
}
