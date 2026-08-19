import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'index.dart';

class ShippingAddressEditorController extends GetxController with ApiMixin {
  AddressEditorType type = AddressEditorType.add;

  final _address = ShippingAddress().obs;
  ShippingAddress get address => _address.value;

  final countries = <Category>[].obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final streetController = TextEditingController();

  bool get isDefault => address.isDefault == 1;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      type =
          Get.arguments['type'] as AddressEditorType? ?? AddressEditorType.add;
      _address.value =
          Get.arguments['item'] as ShippingAddress? ?? ShippingAddress();
    }

    nameController.text = address.name ?? '';
    phoneController.text = address.phone ?? '';
    postalCodeController.text = address.postCode ?? '';
    streetController.text = address.address ?? '';

    _fetchCountries();
  }

  onSelectCountry() async {}

  onTapDefault() {
    _address.update((val) {
      val?.isDefault = val.isDefault == 1 ? 0 : 1;
    });
  }

  onSubmit() async {
    _address.update((val) {
      val?.name = nameController.text;
      val?.phone = phoneController.text;
      val?.postCode = postalCodeController.text;
      val?.address = streetController.text;
    });

    if (address.name.isEmpty) {
      Loading.toast('請輸入姓名'.tr);
      return;
    }

    if (address.phone.isEmpty) {
      Loading.toast('請輸入聯繫電話'.tr);
      return;
    }

    if (address.address.isEmpty) {
      Loading.toast('請填寫詳細地址'.tr);
      return;
    }

    if (address.postCode.isEmpty) {
      Loading.toast('請填寫郵編'.tr);
      return;
    }
    Loading.show();
    final res = await post(
        type == AddressEditorType.add ? ApiUrl.addressAdd : ApiUrl.addressEdit,
        data: address.toJson());
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('保存成功'.tr);
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.back(result: true);
  }

  onDeleteAddress() async {
    final flag = await AlertUtils.show(
      title: '確定要刪除當前地址麼？'.tr,
      cancelText: '取消'.tr,
      confirmText: '確定'.tr,
    );
    if (!flag) {
      return;
    }
    final res = await post(ApiUrl.addressDelete, data: {'id': address.id});
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('刪除成功'.tr);
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.back(result: true);
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    postalCodeController.dispose();
    streetController.dispose();
    super.onClose();
  }
}

extension on ShippingAddressEditorController {
  _fetchCountries() async {
    final res = await get(ApiUrl.getArea, parameters: {'parent_id': 0});
    if (!res.isSuccess) {
      return;
    }
    countries.value = res.dataList.map((e) => Category.fromJson(e)).toList();
  }
}
