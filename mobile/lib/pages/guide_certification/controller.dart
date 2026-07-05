import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'index.dart';

class GuideCertificationController extends GetxController
    with ApiMixin, UserStoreMixin {
  final _certification = GuideCertification().obs;
  GuideCertification get certification => _certification.value;

  /// 从业类型
  List<Category> get guideTypes => ConfigService.to.guideCategories;
  final selectedGuideTypes = <Category>[].obs;

  /// 语言
  List<String> get languages => ConfigService.to.systemConfig.languages;

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
    _fetchGuideApplyInfo();
  }

  @override
  void onClose() {
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
      pageController.animateToPage(
        currentPageIndex.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      submitCertification();
    }
  }

  void previousPage() {
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

  // 提交认证信息
  void submitCertification() async {
    Loading.show();
    if (!await _uploadImages()) {
      Loading.dismiss();
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
    final res = await Future.wait([
      photo.value != null
          ? ConfigService.to.uploadFile(photo.value!.path)
          : Future.value(null),
      certificatePicture.value != null
          ? ConfigService.to.uploadFile(certificatePicture.value!.path)
          : Future.value(null),
      passportPicture.value != null
          ? ConfigService.to.uploadFile(passportPicture.value!.path)
          : Future.value(null),
      driverLicenseFront.value != null
          ? ConfigService.to.uploadFile(driverLicenseFront.value!.path)
          : Future.value(null),
      driverLicenseBack.value != null
          ? ConfigService.to.uploadFile(driverLicenseBack.value!.path)
          : Future.value(null),
    ]);

    if (res.any((e) => e.isEmpty && e != null)) {
      AlertUtils.error('圖片上傳失敗'.tr);
      return false;
    }

    _certification.update((val) {
      if (res[0] != null) {
        val?.photo = res[0];
      }
      if (res[1] != null) {
        val?.certificatePicture = res[1];
      }
      if (res[2] != null) {
        val?.passportPicture = res[2];
      }
      if (res[3] != null) {
        val?.driverLicenseFront = res[3];
      }
      if (res[4] != null) {
        val?.driverLicenseBack = res[4];
      }
    });

    final carPicturesRes = await Future.wait(
      carPictures
          .map(
            (e) => e.startsWith('http')
                ? Future.value(e)
                : ConfigService.to.uploadFile(e),
          )
          .toList(),
    );
    if (carPicturesRes.any((e) => e.isEmpty)) {
      AlertUtils.error('圖片上傳失敗'.tr);
      return false;
    }
    _certification.update((val) {
      val?.carPictures = carPicturesRes.toList();
    });
    return true;
  }

  _fetchGuideApplyInfo() async {
    if (userInfo.guideAuditStatus == 9) {
      return;
    }
    Loading.show();
    final res = await get(ApiUrl.guideApplyInfo);
    Loading.dismiss();
    if (!res.isSuccess) {
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
  }

  onSelectIdentityType(Category type) {
    if (isReadOnly) {
      return;
    }
    _certification.update((val) {
      val?.identityType = type.name ?? '';
    });
  }

  onChangeHaveVehicle(int value) {
    if (isReadOnly) {
      return;
    }
    _certification.update((val) {
      val?.haveVehicle = value;
    });
  }

  onChangeVehicleRent(int value) {
    if (isReadOnly) {
      return;
    }
    _certification.update((val) {
      val?.vehicleRent = value;
    });
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
  }
}
