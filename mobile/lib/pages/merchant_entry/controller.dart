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
    fetchCity();
    _fetchMerchantEntry();
  }

  @override
  void onClose() {
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
    if (nameEnController.text.isEmpty) {
      Loading.toast('請輸入英文公司名稱'.tr);
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
    // if (merchantEntry.businessType == null) {
    //   Loading.toast('請選擇經營類型'.tr);
    //   return false;
    // }
    // if (introductionController.text.isEmpty) {
    //   Loading.toast('請輸入簡介'.tr);
    //   return false;
    // }
    return true;
  }

  bool validateContactInfo() {
    // if (emailController.text.isEmpty) {
    //   Loading.toast('請輸入郵箱地址'.tr);
    //   return false;
    // }
    // if (phoneController.text.isEmpty) {
    //   Loading.toast('請輸入聯繫電話'.tr);
    //   return false;
    // }
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

  // 提交商家入驻信息
  void submitMerchantEntry() async {
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
    // final res = await Future.wait([
    //   documentsPicture.value != null
    //       ? ConfigService.to.uploadFile(documentsPicture.value!.path)
    //       : Future.value(null),
    // ]);
    // if (documentsPicture.value != null && res[0] == null) {
    //   AlertUtils.error('圖片上傳失敗'.tr);
    //   return false;
    // }
    // _merchantEntry.update((val) {
    //   if (res[0] != null) {
    //     val?.documentsPicture = res[0];
    //   }
    // });
    String? documentsPictureUrl;
    if (documentsPicture.value != null) {
      final url = await ConfigService.to.uploadFile(
        documentsPicture.value!.path,
      );
      if (url.isEmpty) {
        AlertUtils.error('圖片上傳失敗'.tr);
        return false;
      }
      documentsPictureUrl = url;
    } else {
      documentsPictureUrl = merchantEntry.documentsPicture;
    }
    _merchantEntry.update((val) {
      val?.documentsPicture = documentsPictureUrl;
    });

    final merchantPicturesRes = await Future.wait(
      merchantPictures
          .map(
            (e) => e.startsWith('http')
                ? Future.value(e)
                : ConfigService.to.uploadFile(e),
          )
          .toList(),
    );
    if (merchantPicturesRes.any((e) => e.isEmpty)) {
      AlertUtils.error('圖片上傳失敗'.tr);
      return false;
    }
    _merchantEntry.update((val) {
      val?.picture = merchantPicturesRes.toList();
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

  _fetchMerchantEntry() async {
    if (userInfo.companyAuditStatus == 9) {
      return;
    }
    Loading.show();
    final res = await get(ApiUrl.companyApplyInfo);
    Loading.dismiss();
    if (!res.isSuccess) return;
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
