import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'index.dart';

class GuideCertificationController extends GetxController
    with ApiMixin, UserStoreMixin {
  static const _draftKey = 'guide_certify_draft';

  final _certification = GuideCertification().obs;
  GuideCertification get certification => _certification.value;

  /// 草稿防抖定時器
  Timer? _draftTimer;

  /// 提交成功標記（防止 onClose 重複保存草稿）
  bool _submitted = false;

  /// 草稿恢復標記（防止恢復時觸發保存）
  bool _restoring = false;

  /// 从业类型
  List<Category> get guideTypes => ConfigService.to.guideCategories;
  final selectedGuideTypes = <Category>[].obs;

  /// 语言
  List<String> get languages => ConfigService.to.systemConfig.languages;

  /// 城市列表（現有平台城市）
  final cities = <CityList>[].obs;

  /// 是否為新增城市模式
  final isNewCityMode = false.obs;

  /// 新城市大洲/地區/國家級聯數據
  final continents = <Category>[].obs;
  final subContinents = <Category>[].obs;
  final countries = <Category>[].obs;

  // 页面控制
  final currentPageIndex = 0.obs;
  final pageController = PageController();

  // 表单控制器
  final nameController = TextEditingController();
  final nameEnController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final billAddressController = TextEditingController();
  final otherContactController = TextEditingController();
  final inviteCodeController = TextEditingController();
  final introductionController = TextEditingController();
  final businessContactController = TextEditingController();
  final vehicleInfoController = TextEditingController();
  final otherIndustryTypeController = TextEditingController();

  final wechatController = TextEditingController();
  final whatsappController = TextEditingController();
  final lineController = TextEditingController();
  final newCityNameController = TextEditingController();
  final newCityNameEnController = TextEditingController();

  // 图片控制
  final photo = Rxn<File>();
  final certificatePicture = Rxn<File>();
  final passportPicture = Rxn<File>();
  final driverLicenseFront = Rxn<File>();
  final driverLicenseBack = Rxn<File>();

  /// 车辆图片（本地路径或网络url）
  final carPictures = <String>[].obs;

  bool get isReadOnly =>
      certification.auditStatus == 0 || certification.auditStatus == 1;

  @override
  void onInit() {
    super.onInit();
    inviteCodeController.text = userInfo.inviterCode ?? '';
    _setupDraftListeners();
    fetchCityList();
    _fetchGuideApplyInfo();
  }

  @override
  void onClose() {
    _draftTimer?.cancel();
    if (!isReadOnly && !_submitted) _saveDraft();
    nameController.dispose();
    nameEnController.dispose();
    phoneController.dispose();
    emailController.dispose();
    billAddressController.dispose();
    otherContactController.dispose();
    inviteCodeController.dispose();
    introductionController.dispose();
    businessContactController.dispose();
    vehicleInfoController.dispose();
    otherIndustryTypeController.dispose();
    pageController.dispose();
    wechatController.dispose();
    whatsappController.dispose();
    lineController.dispose();
    newCityNameController.dispose();
    newCityNameEnController.dispose();
    super.onClose();
  }

  onEdit() async {
    _certification.update((val) {
      val?.auditStatus = null;
    });
    currentPageIndex.value = 0;
    pageController.jumpTo(currentPageIndex.value.toDouble());
  }

  // 页面导航方法
  void nextPage() {
    if (!validateCurrentPage()) {
      return;
    }
    if (currentPageIndex.value < 2) {
      updateCertification();
      currentPageIndex.value++;
      pageController.jumpToPage(currentPageIndex.value);
    } else {
      submitCertification();
    }
  }

  void previousPage() {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
      pageController.jumpToPage(currentPageIndex.value);
    } else {
      Get.back();
    }
  }

  void goToPage(int index) {
    if (index <= currentPageIndex.value) {
      currentPageIndex.value = index;
      pageController.jumpToPage(index);
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
        return validateProfessionalInfo();
      case 2:
        return validateCertificateInfo();
      default:
        return true;
    }
  }

  bool validateBasicInfo() {
    if (photo.value == null && certification.photo.isEmpty) {
      Loading.toast('請上傳照片或logo'.tr);
      return false;
    }
    if (nameController.text.isEmpty) {
      Loading.toast('請輸入真實姓名'.tr);
      return false;
    }
    if (nameEnController.text.isEmpty) {
      Loading.toast('請輸入英文姓名/拼音'.tr);
      return false;
    }
    if (phoneController.text.isEmpty) {
      Loading.toast('請輸入聯繫電話'.tr);
      return false;
    }
    if (emailController.text.isEmpty) {
      Loading.toast('請輸入郵箱地址'.tr);
      return false;
    }
    if (billAddressController.text.isEmpty) {
      Loading.toast('請輸入賬單地址'.tr);
      return false;
    }
    // 常駐城市驗證
    if (isNewCityMode.value) {
      if (newCityNameController.text.isEmpty) {
        Loading.toast('請輸入新城市中文名'.tr);
        return false;
      }
      if (newCityNameEnController.text.isEmpty) {
        Loading.toast('請輸入新城市英文名'.tr);
        return false;
      }
      if (certification.newCityContinentsId == null) {
        Loading.toast('請選擇新城市所屬大洲'.tr);
        return false;
      }
      if (certification.newCityAreaId == null) {
        Loading.toast('請選擇新城市所屬地區'.tr);
        return false;
      }
      if (certification.newCityCountryId == null) {
        Loading.toast('請選擇新城市所屬國家'.tr);
        return false;
      }
    } else {
      if (certification.residentCityId == null) {
        Loading.toast('請選擇常駐城市'.tr);
        return false;
      }
    }
    return true;
  }

  bool validateProfessionalInfo() {
    if (certification.language.isEmpty) {
      Loading.toast('請選擇語言'.tr);
      return false;
    }
    if (certification.year == null) {
      Loading.toast('請選擇從業年份'.tr);
      return false;
    }
    if (certification.industryType.isEmpty) {
      Loading.toast('請選擇從業類型'.tr);
      return false;
    }
    if (certification.identityType == null) {
      Loading.toast('請選擇展示身份類型'.tr);
      return false;
    }
    if (certification.industryType.contains('Other')) {
      if (otherIndustryTypeController.text.isEmpty) {
        Loading.toast('請輸入其他從業類型'.tr);
        return false;
      }
    }
    if (introductionController.text.isEmpty) {
      Loading.toast('請輸入簡介'.tr);
      return false;
    }
    if (businessContactController.text.isEmpty) {
      Loading.toast('請輸入從業聯繫人'.tr);
      return false;
    }
    if (certification.haveVehicle == 1 && vehicleInfoController.text.isEmpty) {
      Loading.toast('請輸入車輛信息'.tr);
      return false;
    }
    return true;
  }

  bool validateCertificateInfo() {
    // 證件信息是可選的，所以這裡不做強制驗證
    // if (certificatePicture.value == null &&
    //     certification.certificatePicture.isEmpty) {
    //   Loading.toast('請上傳證件照片'.tr);
    //   return false;
    // }
    return true;
  }

  // 更新认证信息
  void updateCertification() {
    switch (currentPageIndex.value) {
      case 0:
        _certification.update((val) {
          val?.name = nameController.text;
          val?.nameEn = nameEnController.text;
          val?.phone = phoneController.text;
          val?.email = emailController.text;
          val?.billAddress = billAddressController.text;
          val?.wechat = wechatController.text;
          val?.whatsApp = whatsappController.text;
          val?.line = lineController.text;
          val?.otherContact = otherContactController.text;
          // 新城市名稱同步
          if (isNewCityMode.value) {
            val?.newCityName = newCityNameController.text;
            val?.newCityNameEn = newCityNameEnController.text;
          }
        });
        break;
      case 1:
        _certification.update((val) {
          val?.introduction = introductionController.text;
          val?.businessContact = businessContactController.text;
          val?.vehicleInfo = vehicleInfoController.text;
          val?.otherType = otherIndustryTypeController.text;
        });
        break;
    }
  }

  /// 同步所有 TextEditingController 的值到 model（提交前调用，确保数据完整）
  void _syncAllFields() {
    _certification.update((val) {
      val?.name = nameController.text;
      val?.nameEn = nameEnController.text;
      val?.phone = phoneController.text;
      val?.email = emailController.text;
      val?.billAddress = billAddressController.text;
      val?.wechat = wechatController.text;
      val?.whatsApp = whatsappController.text;
      val?.line = lineController.text;
      val?.otherContact = otherContactController.text;
      val?.introduction = introductionController.text;
      val?.businessContact = businessContactController.text;
      val?.vehicleInfo = vehicleInfoController.text;
      val?.otherType = otherIndustryTypeController.text;
      if (isNewCityMode.value) {
        val?.newCityName = newCityNameController.text;
        val?.newCityNameEn = newCityNameEnController.text;
      }
    });
  }

  // 提交认证信息
  void submitCertification() async {
    // 在提交前同步所有 TextEditingController 的值到 model
    _syncAllFields();
    Loading.show();
    if (!await _uploadImages()) {
      Loading.dismiss();
      final serverError = ConfigService.to.lastUploadError;
      final msg = serverError.isNotEmpty
          ? '${'圖片上傳失敗'.tr}：$serverError'
          : '圖片上傳失敗，請稍後重試'.tr;
      AlertUtils.error(msg);
      return;
    }
    log(certification.toJson().toString());
    final result = await post(ApiUrl.applyGuide, data: certification.toJson());
    Loading.dismiss();
    if (!result.isSuccess) {
      AlertUtils.error(result.message);
      return;
    }
    reloadUserInfo();
    await _clearDraft();
    _submitted = true;
    await AlertUtils.customAlert(
      assets: Assets.iconReview,
      imageSize: Size(50.w, 50.w),
      title: '導遊認證資料提交成功 '.tr,
      content: '请等待管理员审核~'.tr,
      confirmText: '關閉'.tr,
    );
    Get.back();
  }

  Future<bool> _uploadImages() async {
    int failCount = 0;

    // 逐文件上传主图片（单文件失败不影响其他，保留已有 URL）
    if (photo.value != null) {
      try {
        final url = await ConfigService.to.uploadFile(photo.value!.path);
        if (url.isNotEmpty) {
          _certification.update((val) => val?.photo = url);
        } else {
          failCount++;
          log('[GuideCert] photo upload returned empty URL', name: 'GuideCert');
        }
      } catch (e) {
        failCount++;
        log('[GuideCert] photo upload exception: $e', name: 'GuideCert');
      }
    }
    if (certificatePicture.value != null) {
      try {
        final url = await ConfigService.to.uploadFile(certificatePicture.value!.path);
        if (url.isNotEmpty) {
          _certification.update((val) => val?.certificatePicture = url);
        } else {
          failCount++;
          log('[GuideCert] certificatePicture upload returned empty URL', name: 'GuideCert');
        }
      } catch (e) {
        failCount++;
        log('[GuideCert] certificatePicture upload exception: $e', name: 'GuideCert');
      }
    }
    if (passportPicture.value != null) {
      try {
        final url = await ConfigService.to.uploadFile(passportPicture.value!.path);
        if (url.isNotEmpty) {
          _certification.update((val) => val?.passportPicture = url);
        } else {
          failCount++;
          log('[GuideCert] passportPicture upload returned empty URL', name: 'GuideCert');
        }
      } catch (e) {
        failCount++;
        log('[GuideCert] passportPicture upload exception: $e', name: 'GuideCert');
      }
    }
    if (driverLicenseFront.value != null) {
      try {
        final url = await ConfigService.to.uploadFile(driverLicenseFront.value!.path);
        if (url.isNotEmpty) {
          _certification.update((val) => val?.driverLicenseFront = url);
        } else {
          failCount++;
          log('[GuideCert] driverLicenseFront upload returned empty URL', name: 'GuideCert');
        }
      } catch (e) {
        failCount++;
        log('[GuideCert] driverLicenseFront upload exception: $e', name: 'GuideCert');
      }
    }
    if (driverLicenseBack.value != null) {
      try {
        final url = await ConfigService.to.uploadFile(driverLicenseBack.value!.path);
        if (url.isNotEmpty) {
          _certification.update((val) => val?.driverLicenseBack = url);
        } else {
          failCount++;
          log('[GuideCert] driverLicenseBack upload returned empty URL', name: 'GuideCert');
        }
      } catch (e) {
        failCount++;
        log('[GuideCert] driverLicenseBack upload exception: $e', name: 'GuideCert');
      }
    }

    // 逐文件上传车辆图片（已是 http URL 的跳过，失败跳过）
    final uploadedCarPics = <String>[];
    for (final e in carPictures) {
      if (e.startsWith('http://') || e.startsWith('https://')) {
        uploadedCarPics.add(e);
      } else {
        try {
          final url = await ConfigService.to.uploadFile(e);
          if (url.isNotEmpty) {
            uploadedCarPics.add(url);
          } else {
            failCount++;
            log('[GuideCert] carPicture upload returned empty URL: $e', name: 'GuideCert');
          }
        } catch (e) {
          failCount++;
          log('[GuideCert] carPicture upload exception: $e', name: 'GuideCert');
        }
      }
    }
    _certification.update((val) {
      val?.carPictures = uploadedCarPics;
    });

    // 只有全部文件都上传失败时才报错
    final newPhotos = [
      photo.value,
      certificatePicture.value,
      passportPicture.value,
      driverLicenseFront.value,
      driverLicenseBack.value,
    ].where((f) => f != null);
    final newCarPicsCount = carPictures.where((e) => !e.startsWith('http')).length;
    final attemptedCount = newPhotos.length + newCarPicsCount;

    if (attemptedCount > 0 && failCount >= attemptedCount) {
      log('[GuideCert] ALL uploads failed: $failCount / $attemptedCount', name: 'GuideCert');
      return false;
    }

    log('[GuideCert] Uploads: $failCount failures out of $attemptedCount attempts', name: 'GuideCert');
    return true;
  }

  /// 載入平台城市列表
  fetchCityList() async {
    final res = await get(ApiUrl.cityList, parameters: {
      'limit': 1000,
      'page': 1,
    });
    if (!res.isSuccess) return;
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    cities.value = data.map((e) => CityList.fromJson(e)).toList();
  }

  /// 選擇常駐城市（現有城市）
  onSelectResidentCity() async {
    if (isReadOnly) return;
    if (cities.isEmpty) {
      await fetchCityList();
    }
    if (cities.isEmpty) {
      Loading.toast('暫無可選城市'.tr);
      return;
    }
    final picked = await CityPickerSheet.show(
      title: '請選擇常駐城市'.tr,
      cities: cities,
      selectedCityId: certification.residentCityId,
    );
    if (picked != null) {
      _certification.update((val) {
        val?.residentCityId = picked.id;
        val?.residentCityName = picked.name;
        val?.isNewCity = 0;
      });
      isNewCityMode.value = false;
      _scheduleDraftSave();
    }
  }

  /// 切換新增城市模式
  onToggleNewCityMode() {
    if (isReadOnly) return;
    isNewCityMode.toggle();
    if (isNewCityMode.value) {
      // 清除現有城市選擇
      _certification.update((val) {
        val?.residentCityId = null;
        val?.residentCityName = null;
        val?.isNewCity = 1;
      });
      _fetchContinents();
    } else {
      _certification.update((val) {
        val?.isNewCity = 0;
        val?.newCityName = null;
        val?.newCityNameEn = null;
        val?.newCityContinentsId = null;
        val?.newCityContinentsName = null;
        val?.newCityAreaId = null;
        val?.newCityAreaName = null;
        val?.newCityCountryId = null;
        val?.newCityCountryName = null;
      });
      newCityNameController.clear();
      newCityNameEnController.clear();
    }
    _scheduleDraftSave();
  }

  /// 新城市 — 選擇大洲
  onSelectNewCityContinent() async {
    if (isReadOnly) return;
    if (continents.isEmpty) {
      Loading.toast('暫無數據'.tr);
      return;
    }
    final res = await ValuePicker.show(
      title: '請選擇所在大洲'.tr,
      datas: continents.map((e) => e.name ?? '').toList(),
      selectedDatas: [certification.newCityContinentsName ?? ''],
    );
    if (res == null || res.isEmpty) return;
    final continent = continents.firstWhere((e) => e.name == res.first);
    _certification.update((val) {
      val?.newCityContinentsId = continent.id;
      val?.newCityContinentsName = continent.name;
      // 清除下級選擇
      val?.newCityAreaId = null;
      val?.newCityAreaName = null;
      val?.newCityCountryId = null;
      val?.newCityCountryName = null;
    });
    _fetchSubContinents(continent.id ?? 0);
    _scheduleDraftSave();
  }

  /// 新城市 — 選擇地區
  onSelectNewCityArea() async {
    if (isReadOnly) return;
    if (certification.newCityContinentsId == null) {
      Loading.toast('請先選擇所在大洲'.tr);
      return;
    }
    if (subContinents.isEmpty) {
      Loading.toast('暫無數據'.tr);
      return;
    }
    final res = await ValuePicker.show(
      title: '請選擇城市所屬地區'.tr,
      datas: subContinents.map((e) => e.name ?? '').toList(),
      selectedDatas: [certification.newCityAreaName ?? ''],
    );
    if (res == null || res.isEmpty) return;
    final area = subContinents.firstWhere((e) => e.name == res.first);
    _certification.update((val) {
      val?.newCityAreaId = area.id;
      val?.newCityAreaName = area.name;
      val?.newCityCountryId = null;
      val?.newCityCountryName = null;
    });
    _fetchCountries(area.id ?? 0);
    _scheduleDraftSave();
  }

  /// 新城市 — 選擇國家
  onSelectNewCityCountry() async {
    if (isReadOnly) return;
    if (certification.newCityAreaId == null) {
      Loading.toast('請先選擇城市所屬地區'.tr);
      return;
    }
    if (countries.isEmpty) {
      Loading.toast('暫無數據'.tr);
      return;
    }
    final res = await ValuePicker.show(
      title: '請選擇城市所屬國家'.tr,
      datas: countries.map((e) => e.name ?? '').toList(),
      selectedDatas: [certification.newCityCountryName ?? ''],
    );
    if (res == null || res.isEmpty) return;
    final country = countries.firstWhere((e) => e.name == res.first);
    _certification.update((val) {
      val?.newCityCountryId = country.id;
      val?.newCityCountryName = country.name;
    });
    _scheduleDraftSave();
  }

  // ========== 草稿系統 ==========

  /// 設定所有文本控制器的監聽器
  void _setupDraftListeners() {
    final controllers = <TextEditingController>[
      nameController, nameEnController, phoneController, emailController,
      billAddressController, wechatController, whatsappController,
      lineController, otherContactController, inviteCodeController,
      introductionController, businessContactController,
      vehicleInfoController, otherIndustryTypeController,
      newCityNameController, newCityNameEnController,
    ];
    for (final c in controllers) {
      c.addListener(_scheduleDraftSave);
    }
  }

  /// 400ms 防抖排程保存
  void _scheduleDraftSave() {
    if (isReadOnly || _submitted || _restoring) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 400), _saveDraft);
  }

  /// 保存草稿到本地存儲
  Future<void> _saveDraft() async {
    if (isReadOnly || _submitted) return;
    final map = _buildDraftJson();
    if (!_hasDraftContent(map)) return;
    await StorageService.to.setString(_draftKey, jsonEncode(map));
  }

  /// 構建草稿 JSON
  Map<String, dynamic> _buildDraftJson() {
    return {
      'form': {
        'name': nameController.text,
        'name_en': nameEnController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'bill_address': billAddressController.text,
        'wechat': wechatController.text,
        'whats_app': whatsappController.text,
        'line': lineController.text,
        'other_contact': otherContactController.text,
        'invite_code': inviteCodeController.text,
        'photo': certification.photo?.isNotEmpty == true ? certification.photo : (photo.value != null ? '' : ''),
        'year': certification.year ?? '',
        'identity_type': certification.identityType ?? '',
        'introduction': introductionController.text,
        'business_contact': businessContactController.text,
        'have_vehicle': certification.haveVehicle ?? 0,
        'vehicle_rent': certification.vehicleRent ?? 0,
        'vehicle_info': vehicleInfoController.text,
        'other_type': otherIndustryTypeController.text,
        'certificate_picture': certification.certificatePicture ?? '',
        'passport_picture': certification.passportPicture ?? '',
        'driver_license_front': certification.driverLicenseFront ?? '',
        'driver_license_back': certification.driverLicenseBack ?? '',
        // 常駐城市
        'resident_city_id': certification.residentCityId,
        'resident_city_name': certification.residentCityName,
        'is_new_city': certification.isNewCity ?? 0,
        'new_city_name': newCityNameController.text,
        'new_city_name_en': newCityNameEnController.text,
        'new_city_continents_id': certification.newCityContinentsId,
        'new_city_continents_name': certification.newCityContinentsName,
        'new_city_area_id': certification.newCityAreaId,
        'new_city_area_name': certification.newCityAreaName,
        'new_city_country_id': certification.newCityCountryId,
        'new_city_country_name': certification.newCityCountryName,
      },
      'selectedLangs': certification.language,
      'selectedTypes': certification.industryType,
      'photoPreview': certification.photo?.isNotEmpty == true ? certification.photo : '',
      'carPics': carPictures.where((e) => e.startsWith('http')).toList(),
    };
  }

  /// 檢查草稿是否有內容
  bool _hasDraftContent(Map<String, dynamic> map) {
    final form = map['form'] as Map<String, dynamic>?;
    if (form == null) return false;
    for (final v in form.values) {
      if (v is String && v.isNotEmpty) return true;
      if (v is int && v != 0) return true;
    }
    final langs = map['selectedLangs'] as List?;
    if (langs != null && langs.isNotEmpty) return true;
    final types = map['selectedTypes'] as List?;
    if (types != null && types.isNotEmpty) return true;
    final carPics = map['carPics'] as List?;
    if (carPics != null && carPics.isNotEmpty) return true;
    return false;
  }

  /// 清除草稿
  Future<void> _clearDraft() async {
    await StorageService.to.remove(_draftKey);
  }

  /// 進入頁面時檢測草稿並彈窗提示
  Future<void> checkDraftAndPrompt() async {
    if (isReadOnly) return;
    final json = StorageService.to.getString(_draftKey);
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
      content: '偵測到未完成的認證資料，是否繼續編輯？'.tr,
      cancelText: '重新填寫'.tr,
      confirmText: '繼續編輯'.tr,
    );
    if (use == true) {
      _restoreFromDraft(draft);
    } else {
      await _clearDraft();
    }
  }

  /// 從草稿恢復表單數據
  void _restoreFromDraft(Map<String, dynamic> draft) {
    _restoring = true;
    final form = draft['form'] as Map<String, dynamic>? ?? {};

    nameController.text = form['name'] as String? ?? '';
    nameEnController.text = form['name_en'] as String? ?? '';
    phoneController.text = form['phone'] as String? ?? '';
    emailController.text = form['email'] as String? ?? '';
    billAddressController.text = form['bill_address'] as String? ?? '';
    wechatController.text = form['wechat'] as String? ?? '';
    whatsappController.text = form['whats_app'] as String? ?? '';
    lineController.text = form['line'] as String? ?? '';
    otherContactController.text = form['other_contact'] as String? ?? '';
    inviteCodeController.text = form['invite_code'] as String? ?? '';
    introductionController.text = form['introduction'] as String? ?? '';
    businessContactController.text = form['business_contact'] as String? ?? '';
    vehicleInfoController.text = form['vehicle_info'] as String? ?? '';
    otherIndustryTypeController.text = form['other_type'] as String? ?? '';

    _certification.update((val) {
      val?.photo = form['photo'] as String? ?? '';
      val?.year = form['year'] as String?;
      val?.identityType = form['identity_type'] as String?;
      val?.haveVehicle = form['have_vehicle'] as int? ?? 0;
      val?.vehicleRent = form['vehicle_rent'] as int? ?? 0;
      val?.certificatePicture = form['certificate_picture'] as String? ?? '';
      val?.passportPicture = form['passport_picture'] as String? ?? '';
      val?.driverLicenseFront = form['driver_license_front'] as String? ?? '';
      val?.driverLicenseBack = form['driver_license_back'] as String? ?? '';
      val?.language = (draft['selectedLangs'] as List?)?.cast<String>() ?? [];
      val?.industryType = (draft['selectedTypes'] as List?)?.cast<String>() ?? [];
      // 常駐城市
      val?.residentCityId = form['resident_city_id'] as int?;
      val?.residentCityName = form['resident_city_name'] as String?;
      val?.isNewCity = form['is_new_city'] as int? ?? 0;
      val?.newCityName = form['new_city_name'] as String?;
      val?.newCityNameEn = form['new_city_name_en'] as String?;
      val?.newCityContinentsId = form['new_city_continents_id'] as int?;
      val?.newCityContinentsName = form['new_city_continents_name'] as String?;
      val?.newCityAreaId = form['new_city_area_id'] as int?;
      val?.newCityAreaName = form['new_city_area_name'] as String?;
      val?.newCityCountryId = form['new_city_country_id'] as int?;
      val?.newCityCountryName = form['new_city_country_name'] as String?;
    });

    selectedGuideTypes.value = certification.industryType
        .map((e) => guideTypes.firstWhereOrNull((element) => element.name == e))
        .where((e) => e != null)
        .map((e) => e!)
        .toList();

    final photoUrl = form['photo'] as String? ?? '';
    if (photoUrl.isNotEmpty) {
      _certification.update((val) {
        val?.photo = photoUrl;
      });
    }

    carPictures.value = (draft['carPics'] as List?)?.cast<String>() ?? [];

    // 恢復新城市模式
    if (certification.isNewCity == 1) {
      isNewCityMode.value = true;
      newCityNameController.text = certification.newCityName ?? '';
      newCityNameEnController.text = certification.newCityNameEn ?? '';
      if (certification.newCityContinentsId != null) {
        _fetchContinents();
        _fetchSubContinents(certification.newCityContinentsId!);
        if (certification.newCityAreaId != null) {
          _fetchCountries(certification.newCityAreaId!);
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _restoring = false;
    });
  }

  _fetchGuideApplyInfo() async {
    if (userInfo.guideAuditStatus == 9) {
      // 未提交過 → 檢測草稿
      checkDraftAndPrompt();
      return;
    }
    Loading.show();
    final res = await get(ApiUrl.guideApplyInfo);
    Loading.dismiss();
    if (!res.isSuccess) {
      checkDraftAndPrompt();
      return;
    }
    _certification.value = GuideCertification.fromJson(res.dataJson);
    nameController.text = certification.name ?? '';
    nameEnController.text = certification.nameEn ?? '';
    phoneController.text = certification.phone ?? '';
    emailController.text = certification.email ?? '';
    billAddressController.text = certification.billAddress ?? '';
    otherContactController.text = certification.otherContact ?? '';
    wechatController.text = certification.wechat ?? '';
    whatsappController.text = certification.whatsApp ?? '';
    lineController.text = certification.line ?? '';
    introductionController.text = certification.introduction ?? '';
    businessContactController.text = certification.businessContact ?? '';
    vehicleInfoController.text = certification.vehicleInfo ?? '';
    otherIndustryTypeController.text = certification.otherType ?? '';
    selectedGuideTypes.value = certification.industryType
        .map((e) => guideTypes.firstWhereOrNull((element) => element.name == e))
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    carPictures.value = certification.carPictures;
    // 恢復常駐城市
    if (certification.isNewCity == 1) {
      isNewCityMode.value = true;
      newCityNameController.text = certification.newCityName ?? '';
      newCityNameEnController.text = certification.newCityNameEn ?? '';
      if (certification.newCityContinentsId != null) {
        _fetchContinents();
        _fetchSubContinents(certification.newCityContinentsId!);
        if (certification.newCityAreaId != null) {
          _fetchCountries(certification.newCityAreaId!);
        }
      }
    }
  }
}

extension GuideCertificationCityCascade on GuideCertificationController {
  /// 載入大洲列表
  _fetchContinents([int parentId = 0]) async {
    final res = await get(
      ApiUrl.getContinentsList,
      parameters: {'parent_id': parentId},
    );
    if (!res.isSuccess) return;
    final data = res.dataList;
    if (parentId == 0) {
      continents.value = data.map((e) => Category.fromJson(e)).toList();
      subContinents.value = [];
      countries.value = [];
    }
  }

  /// 載入子地區
  _fetchSubContinents(int parentId) async {
    final res = await get(
      ApiUrl.getContinentsList,
      parameters: {'parent_id': parentId},
    );
    if (!res.isSuccess) return;
    final data = res.dataList;
    subContinents.value = data.map((e) => Category.fromJson(e)).toList();
    countries.value = [];
  }

  /// 載入國家
  _fetchCountries(int parentId) async {
    final res = await get(
      ApiUrl.getContinentsList,
      parameters: {'parent_id': parentId},
    );
    if (!res.isSuccess) return;
    final data = res.dataList;
    countries.value = data.map((e) => Category.fromJson(e)).toList();
  }
}

extension GuideCertificationSelection on GuideCertificationController {
  onSelectGuideType(Category type) {
    if (isReadOnly) {
      return;
    }
    if (selectedGuideTypes.any((e) => e.id == type.id)) {
      selectedGuideTypes.removeWhere((e) => e.id == type.id);
    } else {
      selectedGuideTypes.add(type);
    }
    selectedGuideTypes.sort((a, b) {
      final aIndex = guideTypes.indexWhere((e) => e.id == a.id);
      final bIndex = guideTypes.indexWhere((e) => e.id == b.id);
      return aIndex.compareTo(bIndex);
    });
    _certification.update((val) {
      val?.industryType = selectedGuideTypes
          .map((e) => e.name ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    });
    _scheduleDraftSave();
  }

  onSelectIdentityType(Category type) {
    if (isReadOnly) {
      return;
    }
    _certification.update((val) {
      val?.identityType = type.name ?? '';
    });
    _scheduleDraftSave();
  }

  onChangeHaveVehicle(int value) {
    if (isReadOnly) {
      return;
    }
    _certification.update((val) {
      val?.haveVehicle = value;
    });
    _scheduleDraftSave();
  }

  onChangeVehicleRent(int value) {
    if (isReadOnly) {
      return;
    }
    _certification.update((val) {
      val?.vehicleRent = value;
    });
    _scheduleDraftSave();
  }

  onSelectLanguage() async {
    if (isReadOnly) {
      return;
    }
    final selected = certification.language;
    final res = await ValuePicker.show(
      title: '請選擇語言'.tr,
      datas: languages,
      isMultiSelect: true,
      selectedDatas: selected,
    );
    if (res == null) {
      return;
    }
    _certification.update((val) {
      val?.language = res;
    });
    _scheduleDraftSave();
  }

  onSelectYear() async {
    if (isReadOnly) {
      return;
    }
    final years = List.generate(
      50,
      (index) => (DateTime.now().year - index).toString(),
    );
    final res = await ValuePicker.show(
      title: '請選擇從業年份'.tr,
      datas: years,
      selectedDatas: [certification.year ?? ''],
    );
    if (res == null) {
      return;
    }
    _certification.update((val) {
      val?.year = res.first;
    });
    _scheduleDraftSave();
  }

  selectImage(GuidePhotoType type, {int? index}) async {
    if (isReadOnly) {
      return;
    }
    final path = await ImagePickerUtil.selectImage(Get.context!);
    if (path.isEmpty) {
      return;
    }
    switch (type) {
      case GuidePhotoType.photo:
        photo.value = File(path);
        break;
      case GuidePhotoType.certificate:
        certificatePicture.value = File(path);
        break;
      case GuidePhotoType.passport:
        passportPicture.value = File(path);
        break;
      case GuidePhotoType.driverLicenseFront:
        driverLicenseFront.value = File(path);
        break;
      case GuidePhotoType.driverLicenseBack:
        driverLicenseBack.value = File(path);
        break;
      case GuidePhotoType.carPictures:
        if (index != null && index < carPictures.length) {
          carPictures[index] = path;
        } else {
          carPictures.add(path);
        }
        break;
    }
    _scheduleDraftSave();
  }

  removeCarPicture(int index) {
    if (isReadOnly) {
      return;
    }
    final path = carPictures[index];
    carPictures.removeAt(index);
    if (path.startsWith('http')) {
      _certification.update((val) {
        val?.carPictures.remove(path);
      });
    }
    _scheduleDraftSave();
  }
}
