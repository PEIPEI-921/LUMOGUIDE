import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/pages/index.dart';

import '../../common/index.dart';
import 'index.dart';
import 'value.dart';

class MerchantEntryController extends GetxController
    with ApiMixin, UserStoreMixin {
  final _merchantEntry = MerchantEntry().obs;
  MerchantEntry get merchantEntry => _merchantEntry.value;

  /// 草稿防抖定時器
  Timer? _draftTimer;

  /// 提交成功標記（防止 onClose 重複保存草稿）
  bool _submitted = false;

  /// 草稿恢復標記
  bool _restoring = false;

  // 页面控制
  final currentPageIndex = 0.obs;
  final pageController = PageController();

  // 表单控制器
  final nameController = TextEditingController();
  final nameEnController = TextEditingController();
  final addressController = TextEditingController();
  final taxIdController = TextEditingController();
  final introductionController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final otherContactController = TextEditingController();
  final wechatController = TextEditingController();
  final whatsAppController = TextEditingController();
  final lineController = TextEditingController();

  // 图片控制
  final documentsPicture = Rxn<File>();

  /// 商家图片（本地路径或网络url）
  final merchantPictures = <String>[].obs;

  String get selectedCityName =>
      cities.firstWhereOrNull((e) => e.id == merchantEntry.cityId)?.name ?? '';
  final cities = <CityList>[].obs;

  bool get isReadOnly =>
      merchantEntry.auditStatus == 0 || merchantEntry.auditStatus == 1;

  @override
  void onInit() {
    super.onInit();
    _setupDraftListeners();
    fetchCity();
    _fetchMerchantEntry();
  }

  @override
  void onClose() {
    _draftTimer?.cancel();
    if (!isReadOnly && !_submitted) _saveDraft();
    nameController.dispose();
    nameEnController.dispose();
    addressController.dispose();
    taxIdController.dispose();
    introductionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    otherContactController.dispose();
    wechatController.dispose();
    whatsAppController.dispose();
    lineController.dispose();
    pageController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.onClose();
  }

  onEdit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _merchantEntry.update((val) {
      val?.auditStatus = null;
    });
    currentPageIndex.value = 0;
    pageController.jumpTo(currentPageIndex.value.toDouble());
  }

  // 页面导航方法
  void nextPage() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!validateCurrentPage()) {
      return;
    }
    if (currentPageIndex.value < 3) {
      updateMerchantEntry();
      currentPageIndex.value++;
      pageController.animateToPage(
        currentPageIndex.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      submitMerchantEntry();
    }
  }

  void previousPage() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
      pageController.animateToPage(
        currentPageIndex.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  void goToPage(int index) {
    if (index <= currentPageIndex.value) {
      currentPageIndex.value = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 表单验证方法
  bool validateCurrentPage() {
    if (isReadOnly) {
      return true;
    }
    switch (currentPageIndex.value) {
      case 0:
        return validateBasicInfo();
      case 1:
        return validateBusinessType();
      case 2:
        return validateContactInfo();
      case 3:
        return validatePhotoUpload();
      default:
        return true;
    }
  }

  bool validateBasicInfo() {
    if (nameController.text.isEmpty) {
      Loading.toast('請輸入公司名稱'.tr);
      return false;
    }
    if (nameEnController.text.isEmpty) {
      Loading.toast('請輸入英文公司名稱'.tr);
      return false;
    }
    if (merchantEntry.cityId == null) {
      Loading.toast('請選擇所在城市'.tr);
      return false;
    }
    if (addressController.text.isEmpty) {
      Loading.toast('請輸入公司地址'.tr);
      return false;
    }
    if (taxIdController.text.isEmpty) {
      Loading.toast('請輸入公司稅號'.tr);
      return false;
    }
    return true;
  }

  bool validateBusinessType() {
    if (merchantEntry.businessType == null || merchantEntry.businessType!.isEmpty) {
      Loading.toast('請選擇經營類型'.tr);
      return false;
    }
    if (introductionController.text.isEmpty) {
      Loading.toast('請輸入簡介'.tr);
      return false;
    }
    return true;
  }

  bool validateContactInfo() {
    if (emailController.text.isEmpty) {
      Loading.toast('請輸入郵箱地址'.tr);
      return false;
    }
    if (phoneController.text.isEmpty) {
      Loading.toast('請輸入聯繫電話'.tr);
      return false;
    }
    if (wechatController.text.isEmpty) {
      Loading.toast('請輸入微信/Wechat'.tr);
      return false;
    }
    return true;
  }

  bool validatePhotoUpload() {
    // if (documentsPicture.value == null &&
    //     merchantEntry.documentsPicture.isEmpty) {
    //   Loading.toast('請上傳相關證件圖片'.tr);
    //   return false;
    // }
    return true;
  }

  // 更新商家入驻信息
  void updateMerchantEntry() {
    switch (currentPageIndex.value) {
      case 0:
        _merchantEntry.update((val) {
          val?.name = nameController.text;
          val?.nameEn = nameEnController.text;
          val?.address = addressController.text;
          val?.taxId = taxIdController.text;
        });
        break;
      case 1:
        _merchantEntry.update((val) {
          val?.introduction = introductionController.text;
        });
        break;
      case 2:
        _merchantEntry.update((val) {
          val?.email = emailController.text;
          val?.phone = phoneController.text;
          val?.website = websiteController.text;
          val?.otherContact = otherContactController.text;
          val?.wechat = wechatController.text;
          val?.whatsApp = whatsAppController.text;
          val?.line = lineController.text;
        });
        break;
    }
  }

  /// 同步所有 TextEditingController 的值到 model（提交前调用，确保数据完整）
  void _syncAllFields() {
    _merchantEntry.update((val) {
      val?.name = nameController.text;
      val?.nameEn = nameEnController.text;
      val?.address = addressController.text;
      val?.taxId = taxIdController.text;
      val?.introduction = introductionController.text;
      val?.email = emailController.text;
      val?.phone = phoneController.text;
      val?.website = websiteController.text;
      val?.otherContact = otherContactController.text;
      val?.wechat = wechatController.text;
      val?.whatsApp = whatsAppController.text;
      val?.line = lineController.text;
    });
  }

  // 提交商家入驻信息
  void submitMerchantEntry() async {
    // 在提交前同步所有 TextEditingController 的值到 model
    _syncAllFields();
    Loading.show();
    if (!await _uploadImages()) {
      Loading.dismiss();
      return;
    }
    final res = await post(ApiUrl.applyCompany, data: merchantEntry.toJson());
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    reloadUserInfo();
    await _clearDraft();
    _submitted = true;
    await AlertUtils.customAlert(
      assets: Assets.iconReview,
      imageSize: Size(50.w, 50.w),
      title: '企業入駐資料提交成功'.tr,
      content: '请等待管理员审核~'.tr,
      confirmText: '關閉'.tr,
    );
    Get.back();
  }

  Future<bool> _uploadImages() async {
    // 上傳證件圖片
    String? documentsPictureUrl;
    if (documentsPicture.value != null) {
      try {
        final url = await ConfigService.to.uploadFile(documentsPicture.value!.path);
        if (url.isEmpty) {
          final serverError = ConfigService.to.lastUploadError;
          final msg = serverError.isNotEmpty
              ? '${'證件圖片上傳失敗'.tr}：$serverError'
              : '證件圖片上傳失敗'.tr;
          AlertUtils.error(msg);
          return false;
        }
        documentsPictureUrl = url;
      } catch (_) {
        final serverError = ConfigService.to.lastUploadError;
        final msg = serverError.isNotEmpty
            ? '${'證件圖片上傳失敗'.tr}：$serverError'
            : '證件圖片上傳失敗'.tr;
        AlertUtils.error(msg);
        return false;
      }
    } else {
      documentsPictureUrl = merchantEntry.documentsPicture;
    }
    _merchantEntry.update((val) {
      val?.documentsPicture = documentsPictureUrl;
    });

    // 逐文件上傳商家圖片（單文件失敗不影響其他）
    final uploadedPics = <String>[];
    for (final e in merchantPictures) {
      if (e.startsWith('http://') || e.startsWith('https://')) {
        uploadedPics.add(e);
      } else {
        try {
          final url = await ConfigService.to.uploadFile(e);
          if (url.isNotEmpty) uploadedPics.add(url);
        } catch (_) {
          // 單文件上傳失敗，跳過繼續
        }
      }
    }
    if (merchantPictures.isNotEmpty && uploadedPics.isEmpty) {
      final serverError = ConfigService.to.lastUploadError;
      final msg = serverError.isNotEmpty
          ? '${'商家圖片上傳失敗'.tr}：$serverError'
          : '商家圖片上傳失敗'.tr;
      AlertUtils.error(msg);
      return false;
    }
    _merchantEntry.update((val) {
      val?.picture = uploadedPics;
    });
    log(merchantEntry.toJson().toString());
    return true;
  }
}

extension MerchantEntrySelection on MerchantEntryController {
  // 选择城市
  void selectCity() async {
    if (isReadOnly) {
      return;
    }
    final picked = await CityPickerSheet.show(
      title: '請選擇所在城市'.tr,
      cities: cities,
      selectedCityId: merchantEntry.cityId,
    );
    if (picked != null) {
      _merchantEntry.update((val) {
        val?.cityId = picked.id;
      });
    }
    _scheduleDraftSave();
  }

  // 选择经营类型
  void selectBusinessType() async {
    if (isReadOnly) {
      return;
    }
    final businessTypes = ConfigService.to.systemConfig.businessType;
    final res = await ValuePicker.show(
      title: '請選擇企業經營類型'.tr,
      datas: businessTypes,
      selectedDatas: [merchantEntry.businessType ?? ''],
    );
    if (res != null && res.isNotEmpty) {
      _merchantEntry.update((val) {
        val?.businessType = res.first;
      });
      _scheduleDraftSave();
    }
  }

  selectImage(MerchantPhotoType type, {int? index}) async {
    if (isReadOnly) {
      return;
    }
    final path = await ImagePickerUtil.selectImage(Get.context!);
    if (path.isEmpty) {
      return;
    }
    switch (type) {
      case MerchantPhotoType.documents:
        documentsPicture.value = File(path);
        break;
      case MerchantPhotoType.merchantPictures:
        if (index != null && index < merchantPictures.length) {
          merchantPictures[index] = path;
        } else {
          merchantPictures.add(path);
        }
        break;
    }
    _scheduleDraftSave();
  }

  removeMerchantPicture(int index) {
    if (isReadOnly) {
      return;
    }
    final path = merchantPictures[index];
    merchantPictures.removeAt(index);
    if (path.startsWith('http')) {
      _merchantEntry.update((val) {
        val?.picture.remove(path);
      });
    }
    _scheduleDraftSave();
  }
}

extension on MerchantEntryController {
  fetchCity() async {
    final res = await get(
      ApiUrl.cityList,
      parameters: {'limit': 1000, 'page': 1},
    );
    if (!res.isSuccess) return;
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    cities.value = data.map((e) => CityList.fromJson(e)).toList();
  }

  // ========== 草稿系統 ==========

  void _setupDraftListeners() {
    final controllers = <TextEditingController>[
      nameController, nameEnController, addressController, taxIdController,
      introductionController, emailController, phoneController,
      websiteController, otherContactController, wechatController,
      whatsAppController, lineController,
    ];
    for (final c in controllers) {
      c.addListener(_scheduleDraftSave);
    }
  }

  void _scheduleDraftSave() {
    if (isReadOnly || _submitted || _restoring) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 400), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (isReadOnly || _submitted) return;
    final map = _buildDraftJson();
    if (!_hasDraftContent(map)) return;
    await StorageService.to.setString('merchant_entry_draft', jsonEncode(map));
  }

  Map<String, dynamic> _buildDraftJson() {
    return {
      'form': {
        'name': nameController.text,
        'name_en': nameEnController.text,
        'contact_name': '',
        'phone': phoneController.text,
        'email': emailController.text,
        'country': '',
        'address': addressController.text,
        'introduction': introductionController.text,
        'city_id': merchantEntry.cityId?.toString() ?? '',
        'tax_id': taxIdController.text,
        'website': websiteController.text,
        'wechat': wechatController.text,
        'whats_app': whatsAppController.text,
        'line': lineController.text,
        'other_contact': otherContactController.text,
        'contact_phone': '',
        'contact_email': '',
        'photo': merchantEntry.documentsPicture ?? '',
        'license': '',
        'id_card_front': '',
        'id_card_back': '',
      },
      'selectedTypes': [merchantEntry.businessType ?? ''],
      'storePics': merchantPictures.where((e) => e.startsWith('http')).toList(),
    };
  }

  bool _hasDraftContent(Map<String, dynamic> map) {
    final form = map['form'] as Map<String, dynamic>?;
    if (form == null) return false;
    for (final v in form.values) {
      if (v is String && v.isNotEmpty) return true;
    }
    final storePics = map['storePics'] as List?;
    if (storePics != null && storePics.isNotEmpty) return true;
    final types = map['selectedTypes'] as List?;
    if (types != null && types.isNotEmpty && types.first.toString().isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> _clearDraft() async {
    await StorageService.to.remove('merchant_entry_draft');
  }

  Future<void> checkDraftAndPrompt() async {
    if (isReadOnly) return;
    final json = StorageService.to.getString('merchant_entry_draft');
    if (json.isEmpty) return;
    Map<String, dynamic>? draft;
    try {
      draft = jsonDecode(json) as Map<String, dynamic>?;
    } catch (_) {
      return;
    }
    if (draft == null || !_hasDraftContent(draft)) return;

    final use = await AlertUtils.show(
      title: '提示'.tr,
      content: '偵測到未完成的入駐資料，是否繼續編輯？'.tr,
      cancelText: '重新填寫'.tr,
      confirmText: '繼續編輯'.tr,
    );
    if (use == true) {
      _restoreFromDraft(draft);
    } else {
      await _clearDraft();
    }
  }

  void _restoreFromDraft(Map<String, dynamic> draft) {
    _restoring = true;
    final form = draft['form'] as Map<String, dynamic>? ?? {};

    nameController.text = form['name'] as String? ?? '';
    nameEnController.text = form['name_en'] as String? ?? '';
    addressController.text = form['address'] as String? ?? '';
    taxIdController.text = form['tax_id'] as String? ?? '';
    introductionController.text = form['introduction'] as String? ?? '';
    emailController.text = form['email'] as String? ?? '';
    phoneController.text = form['phone'] as String? ?? '';
    websiteController.text = form['website'] as String? ?? '';
    otherContactController.text = form['other_contact'] as String? ?? '';
    wechatController.text = form['wechat'] as String? ?? '';
    whatsAppController.text = form['whats_app'] as String? ?? '';
    lineController.text = form['line'] as String? ?? '';

    _merchantEntry.update((val) {
      val?.documentsPicture = form['photo'] as String? ?? '';
      val?.businessType = ((draft['selectedTypes'] as List?)?.isNotEmpty == true)
          ? (draft['selectedTypes'] as List).first as String?
          : null;
      // 恢復城市選擇
      final cityIdStr = form['city_id'] as String?;
      if (cityIdStr != null && cityIdStr.isNotEmpty) {
        val?.cityId = int.tryParse(cityIdStr);
      }
    });

    merchantPictures.value = (draft['storePics'] as List?)?.cast<String>() ?? [];

    Future.delayed(const Duration(milliseconds: 100), () {
      _restoring = false;
    });
  }

  _fetchMerchantEntry() async {
    if (userInfo.companyAuditStatus == 9) {
      checkDraftAndPrompt();
      return;
    }
    Loading.show();
    final res = await get(ApiUrl.companyApplyInfo);
    Loading.dismiss();
    if (!res.isSuccess) {
      checkDraftAndPrompt();
      return;
    }
    _merchantEntry.value = MerchantEntry.fromJson(res.dataJson);
    nameController.text = merchantEntry.name ?? '';
    nameEnController.text = merchantEntry.nameEn ?? '';
    addressController.text = merchantEntry.address ?? '';
    taxIdController.text = merchantEntry.taxId ?? '';
    introductionController.text = merchantEntry.introduction ?? '';
    emailController.text = merchantEntry.email ?? '';
    phoneController.text = merchantEntry.phone ?? '';
    websiteController.text = merchantEntry.website ?? '';
    otherContactController.text = merchantEntry.otherContact ?? '';
    wechatController.text = merchantEntry.wechat ?? '';
    whatsAppController.text = merchantEntry.whatsApp ?? '';
    lineController.text = merchantEntry.line ?? '';
    merchantPictures.value = merchantEntry.picture;
  }
}
