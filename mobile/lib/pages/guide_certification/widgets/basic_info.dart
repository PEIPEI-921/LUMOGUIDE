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
    // isReadOnly 只在进入/退出编辑模式时变化，由页面级 Obx 处理重建
    final isReadOnly = controller.isReadOnly;
    return SingleChildScrollView(
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
                    isReadOnly: isReadOnly,
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.nameEnController,
                    hintText: '請輸入英文姓名/拼音'.tr,
                    labelText: '英文姓名/拼音'.tr,
                    isRequired: true,
                    isReadOnly: isReadOnly,
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.phoneController,
                    hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
                    hintFontSize: 12.sp,
                    labelText: '聯繫電話'.tr,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    isReadOnly: isReadOnly,
                    inputFormatters: [LeadingPlusPhoneFormatter()],
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.emailController,
                    hintText: '請輸入郵箱地址'.tr,
                    labelText: '郵箱地址'.tr,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    isReadOnly: isReadOnly,
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.billAddressController,
                    hintText: '請輸入賬單地址(請輸入英文)'.tr,
                    labelText: '賬單地址'.tr,
                    isRequired: true,
                    keyboardType: TextInputType.streetAddress,
                    isReadOnly: isReadOnly,
                  ),
                  10.w.verticalSpace,
                  const _ResidentCityWidget(),
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
                    isReadOnly: isReadOnly,
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.whatsappController,
                    hintText: '請輸入'.tr,
                    labelText: 'WhatsApp'.tr,
                    isReadOnly: isReadOnly,
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.lineController,
                    hintText: '請輸入'.tr,
                    labelText: 'Line'.tr,
                    isReadOnly: isReadOnly,
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.otherContactController,
                    hintText: '請輸入'.tr,
                    labelText: '其他'.tr,
                    isReadOnly: isReadOnly,
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
    );
  }
}

/// 常駐城市選擇
class _ResidentCityWidget extends StatelessWidget {
  const _ResidentCityWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('*').fontSize(14.sp).textColor(Colors.red),
            Text('我的常駐城市'.tr)
                .fontSize(14.sp)
                .textColor(AppColors.primaryText),
          ],
        ),
        8.w.verticalSpace,
        Obx(() {
          // 已有城市選擇模式
          if (!controller.isNewCityMode.value) {
            return Column(
              children: [
                // 城市選擇行
                Row(
                  children: [
                    LabelSelectField(
                      label: '',
                      value: controller.certification.residentCityName ?? '',
                      hintText: '請選擇常駐城市'.tr,
                      onTap: controller.onSelectResidentCity,
                      isRightArrow: !controller.isReadOnly,
                    ).expanded(),
                    10.w.horizontalSpace,
                    Text(
                      '添加新城'.tr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13.sp,
                      ),
                    ).gestures(onTap: controller.onToggleNewCityMode),
                  ],
                ),
              ],
            );
          }
          // 新城市模式
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Text(
                      '新增城市'.tr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '選擇現有城市'.tr,
                    style: TextStyle(
                      color: AppColors.assistantText,
                      fontSize: 13.sp,
                    ),
                  ).gestures(onTap: controller.onToggleNewCityMode),
                ],
              ),
              10.w.verticalSpace,
              CustomTextField(
                controller: controller.newCityNameController,
                hintText: '請輸入城市中文名'.tr,
                labelText: '城市名稱（中文名）'.tr,
                isRequired: true,
                isReadOnly: controller.isReadOnly,
              ),
              10.w.verticalSpace,
              CustomTextField(
                controller: controller.newCityNameEnController,
                hintText: '請輸入城市英文名'.tr,
                labelText: '城市名稱（英文名）'.tr,
                isRequired: true,
                isReadOnly: controller.isReadOnly,
              ),
              10.w.verticalSpace,
              LabelSelectField(
                label: '所在大洲'.tr,
                value: controller.certification.newCityContinentsName ?? '',
                hintText: '請選擇'.tr,
                isRequired: true,
                onTap: controller.onSelectNewCityContinent,
                isRightArrow: !controller.isReadOnly,
              ),
              10.w.verticalSpace,
              LabelSelectField(
                label: '所屬地區'.tr,
                value: controller.certification.newCityAreaName ?? '',
                hintText: '請選擇'.tr,
                isRequired: true,
                onTap: controller.onSelectNewCityArea,
                isRightArrow: !controller.isReadOnly,
              ),
              10.w.verticalSpace,
              LabelSelectField(
                label: '所屬國家'.tr,
                value: controller.certification.newCityCountryName ?? '',
                hintText: '請選擇'.tr,
                isRequired: true,
                onTap: controller.onSelectNewCityCountry,
                isRightArrow: !controller.isReadOnly,
              ),
            ],
          );
        }),
      ],
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
