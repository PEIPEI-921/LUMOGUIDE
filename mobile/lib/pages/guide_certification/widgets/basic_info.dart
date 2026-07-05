import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/pages/index.dart';
import '../../../common/index.dart';

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();
    return Obx(
      () => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基礎信息'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            10.w.verticalSpace,
            Column(
                  children: [
                    const _PhotoUploadWidget(),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.nameController,
                      hintText: '請輸入真實姓名'.tr,
                      labelText: '真實姓名'.tr,
                      isRequired: true,
                      isReadOnly: controller.isReadOnly,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.nameEnController,
                      hintText: '請輸入英文姓名/拼音'.tr,
                      labelText: '英文姓名/拼音'.tr,
                      isRequired: true,
                      isReadOnly: controller.isReadOnly,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.phoneController,
                      hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
                      hintFontSize: 12.sp,
                      labelText: '聯繫電話'.tr,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      isReadOnly: controller.isReadOnly,
                      inputFormatters: [LeadingPlusPhoneFormatter()],
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.emailController,
                      hintText: '請輸入郵箱地址'.tr,
                      labelText: '郵箱地址'.tr,
                      isRequired: true,
                      keyboardType: TextInputType.emailAddress,
                      isReadOnly: controller.isReadOnly,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.billAddressController,
                      hintText: '請輸入賬單地址(請輸入英文)'.tr,
                      labelText: '賬單地址'.tr,
                      isRequired: true,
                      keyboardType: TextInputType.streetAddress,
                      isReadOnly: controller.isReadOnly,
                    ),
                    10.w.verticalSpace,
                    Text(
                      '其他聯繫方式'.tr,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14.sp,
                      ),
                    ).alignment(Alignment.centerLeft),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.wechatController,
                      hintText: '請輸入'.tr,
                      labelText: '微信/Wechat'.tr,
                      isReadOnly: controller.isReadOnly,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.whatsappController,
                      hintText: '請輸入'.tr,
                      labelText: 'WhatsApp'.tr,
                      isReadOnly: controller.isReadOnly,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.lineController,
                      hintText: '請輸入'.tr,
                      labelText: 'Line'.tr,
                      isReadOnly: controller.isReadOnly,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.otherContactController,
                      hintText: '請輸入'.tr,
                      labelText: '其他'.tr,
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
        ).padding(horizontal: 14.w),
      ),
    );
  }
}

class _PhotoUploadWidget extends StatelessWidget {
  const _PhotoUploadWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('*').fontSize(14.sp).textColor(Colors.red),
            Text(
              '上傳照片或logo'.tr,
            ).fontSize(14.sp).textColor(AppColors.primaryText),
          ],
        ),
        10.w.verticalSpace,
        Obx(
          () => controller.photo.value != null
              ? Image.file(
                  File(controller.photo.value!.path),
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 4.w)
              : controller.certification.photo.isNotEmpty
              ? NetImageCached(
                  controller.certification.photo,
                  width: 90.w,
                  height: 90.w,
                  borderRadius: BorderRadius.circular(4.w),
                )
              : Image.asset(
                  Assets.iconPhotoAdd,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ),
        ).gestures(onTap: () => controller.selectImage(GuidePhotoType.photo)),
        Text(
          '人像需正式照片，可能會在頁面中展示'.tr,
        ).fontSize(12.sp).textColor(AppColors.assistantText).padding(top: 8.w),
        const ImageTipWidget(),
      ],
    );
  }
}
