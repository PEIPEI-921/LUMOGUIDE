import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class ProfessionalInfoWidget extends StatelessWidget {
  const ProfessionalInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();
    // isReadOnly 只在进入/退出编辑模式时变化，由页面级 Obx 处理重建
    final isReadOnly = controller.isReadOnly;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('專業信息'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          // 响应式判断：语言或从业类型未加载时显示重试入口
          Obx(() {
            final langsEmpty = controller.languages.isEmpty;
            final typesEmpty = controller.guideTypes.isEmpty;
            if (!langsEmpty && !typesEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                8.w.verticalSpace,
                Row(
                  children: [
                    Text(
                      '選項加載失敗'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.red,
                      ),
                    ),
                    4.w.horizontalSpace,
                    Text(
                      '點擊重試'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ).gestures(
                  onTap: () => controller.retryLoadOptions(),
                ),
              ],
            );
          }),
          10.w.verticalSpace,
          Column(
            children: [
              // 语言选择器 — 标签需要响应 certification 变化
              Obx(() => LabelSelectField(
                    isRequired: true,
                    label: '您熟練掌握的語言(可多選)'.tr,
                    hintText: '請選擇語言'.tr,
                    value: controller.certification.language.join(','),
                    onTap: () => controller.onSelectLanguage(),
                    isRightArrow: !isReadOnly,
                  )),
              10.w.verticalSpace,
              // 从业年份 — 标签需要响应 certification 变化
              Obx(() => LabelSelectField(
                    isRequired: true,
                    label: '從業年份'.tr,
                    value: controller.certification.year ?? '',
                    hintText: '請選擇從業年份'.tr,
                    onTap: () => controller.onSelectYear(),
                    isRightArrow: !isReadOnly,
                  )),
              15.w.verticalSpace,
              const _IndustryTypeWidget(),
              15.w.verticalSpace,
              const _IdentityTypeWidget(),
              15.w.verticalSpace,
              CustomTextField(
                controller: controller.introductionController,
                hintText: '請輸入個人或公司簡介(比如經歷，專長，特色，擅長領域，收費標準等)'.tr,
                labelText: '個人或公司簡介'.tr,
                isRequired: true,
                maxLines: 5,
                isReadOnly: isReadOnly,
              ),
              10.w.verticalSpace,
              CustomTextField(
                controller: controller.businessContactController,
                hintText: '請輸入業務聯繫人'.tr,
                labelText: '業務聯繫人'.tr,
                isRequired: true,
                isReadOnly: isReadOnly,
              ),
              10.w.verticalSpace,
              const _VehicleWidget(),
            ],
          ).padding(all: 10.w).decorated(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.w),
              ),
        ],
      ).padding(horizontal: 14.w),
    );
  }
}

class _IndustryTypeWidget extends StatelessWidget {
  const _IndustryTypeWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('*').fontSize(14.sp).textColor(AppColors.red),
            Text('從事旅遊行業的類型'.tr)
                .fontSize(14.sp)
                .textColor(AppColors.primaryText),
            Text('(可多選)'.tr).fontSize(14.sp).textColor(
                  AppColors.primaryText,
                ),
          ],
        ),
        10.w.verticalSpace,
        Obx(() => Wrap(
              spacing: 20.w,
              runSpacing: 5.w,
              children: [
                ...controller.guideTypes
                    .map((e) => _buildIndustryTypeCheckbox(e)),
                if (controller.certification.industryType.contains('Other'))
                  CustomTextField(
                    controller: controller.otherIndustryTypeController,
                    hintText: '請輸入'.tr,
                    isRequired: true,
                    isReadOnly: controller.isReadOnly,
                  ),
              ],
            )),
      ],
    );
  }

  Widget _buildIndustryTypeCheckbox(Category type) {
    final controller = Get.find<GuideCertificationController>();
    final isSelected =
        controller.certification.industryType.any((e) => e == type.name);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? AppColors.primary : AppColors.assistantText,
          size: 18.w,
        ),
        5.w.horizontalSpace,
        Text(type.name ?? '').fontSize(14.sp).textColor(AppColors.primaryText),
      ],
    ).padding(vertical: 4.w).gestures(onTap: () {
      controller.onSelectGuideType(type);
    });
  }
}

class _IdentityTypeWidget extends StatelessWidget {
  const _IdentityTypeWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('*').fontSize(14.sp).textColor(AppColors.red),
            Text('在APP中展示的身份類型'.tr)
                .fontSize(14.sp)
                .textColor(AppColors.primaryText),
          ],
        ),
        10.w.verticalSpace,
        Obx(() => controller.selectedGuideTypes.isEmpty
            ? const SizedBox.shrink()
            : Wrap(
                spacing: 20.w,
                runSpacing: 5.w,
                children: [
                  ...controller.selectedGuideTypes
                      .map((e) => _buildIdentityTypeRadio(e)),
                ],
              )),
      ],
    );
  }

  Widget _buildIdentityTypeRadio(Category type) {
    final controller = Get.find<GuideCertificationController>();
    final isSelected = controller.certification.identityType == type.name;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? AppColors.primary : AppColors.assistantText,
          size: 18.w,
        ),
        5.w.horizontalSpace,
        Text(type.name ?? '').fontSize(14.sp).textColor(AppColors.primaryText),
      ],
    ).padding(vertical: 4.w).gestures(onTap: () {
      controller.onSelectIdentityType(type);
    });
  }
}

class _VehicleWidget extends StatelessWidget {
  const _VehicleWidget();

  // 使用 Icon 選擇器替代 RadioGroup —— 跨 Flutter 版本兼容（3.32 前的 SDK 無 RadioGroup）
  Widget _buildRadioOption(String label, bool isSelected, VoidCallback onTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? AppColors.primary : AppColors.assistantText,
          size: 18.w,
        ),
        5.w.horizontalSpace,
        Text(label).fontSize(14.sp).textColor(AppColors.primaryText),
      ],
    ).padding(vertical: 4.w).gestures(onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('*').fontSize(14.sp).textColor(AppColors.red),
            Text('是否有車輛資源'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          ],
        ),
        10.w.verticalSpace,
        Obx(() => Row(
              children: [
                _buildRadioOption(
                  '是'.tr,
                  controller.certification.haveVehicle == 1,
                  () => controller.onChangeHaveVehicle(1),
                ),
                20.w.horizontalSpace,
                _buildRadioOption(
                  '否'.tr,
                  controller.certification.haveVehicle == 0,
                  () => controller.onChangeHaveVehicle(0),
                ),
              ],
            )),
        Obx(() => controller.certification.haveVehicle == 1
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.vehicleInfoController,
                    hintText: '${'請輸入車輛類型和數量'.tr}\n${'例如: 五座車 (2輛)'.tr}',
                    labelText: '車輛類型/數量'.tr,
                    isRequired: true,
                    maxLines: 5,
                    isReadOnly: controller.isReadOnly,
                  ),
                  10.w.verticalSpace,
                  Row(
                    children: [
                      const Text('*').fontSize(14.sp).textColor(Colors.red),
                      Text('車輛可否出租'.tr)
                          .fontSize(14.sp)
                          .textColor(AppColors.primaryText),
                    ],
                  ),
                  10.w.verticalSpace,
                  Obx(() => Row(
                        children: [
                          _buildRadioOption(
                            '是'.tr,
                            controller.certification.vehicleRent == 1,
                            () => controller.onChangeVehicleRent(1),
                          ),
                          20.w.horizontalSpace,
                          _buildRadioOption(
                            '否'.tr,
                            controller.certification.vehicleRent == 0,
                            () => controller.onChangeVehicleRent(0),
                          ),
                        ],
                      )),
                ],
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}
