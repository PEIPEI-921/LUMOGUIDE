import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantEntryController>();
    return Obx(
      () => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基礎信息'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            15.w.verticalSpace,
            Column(
                  children: [
                    CustomTextField(
                      controller: controller.nameController,
                      hintText: '請輸入公司名稱'.tr,
                      labelText: '公司名稱'.tr,
                      isRequired: true,
                      isReadOnly: controller.isReadOnly,
                    ),
                    15.w.verticalSpace,
                    CustomTextField(
                      controller: controller.nameEnController,
                      hintText: '請輸入英文公司名稱'.tr,
                      labelText: '英文公司名稱'.tr,
                      isRequired: true,
                      isReadOnly: controller.isReadOnly,
                    ),
                    15.w.verticalSpace,
                    LabelSelectField(
                      label: '所在城市'.tr,
                      hintText: '請選擇所在城市'.tr,
                      value: controller.selectedCityName,
                      onTap: controller.selectCity,
                      isRightArrow: !controller.isReadOnly,
                    ),
                    15.w.verticalSpace,
                    CustomTextField(
                      controller: controller.addressController,
                      hintText: '請輸入公司地址'.tr,
                      labelText: '公司地址'.tr,
                      isRequired: true,
                      keyboardType: TextInputType.streetAddress,
                      isReadOnly: controller.isReadOnly,
                    ),
                    15.w.verticalSpace,
                    CustomTextField(
                      controller: controller.taxIdController,
                      hintText: '請輸入公司稅號'.tr,
                      labelText: '公司稅號'.tr,
                      isRequired: true,
                      isReadOnly: controller.isReadOnly,
                    ),
                  ],
                )
                .padding(all: 10.w)
                .decorated(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.w),
                ),
          ],
        ).padding(horizontal: 12.w),
      ),
    );
  }
}
