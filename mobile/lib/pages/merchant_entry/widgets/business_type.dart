import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class BusinessTypeWidget extends StatelessWidget {
  const BusinessTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantEntryController>();
    final isReadOnly = controller.isReadOnly;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('商家類型'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          15.w.verticalSpace,
          Column(
            children: [
              // 经营类型（一级）
              Obx(() => LabelSelectField(
                    label: '經營類型'.tr,
                    hintText: '請選擇企業經營類型'.tr,
                    value: controller.typeTitle,
                    isRequired: true,
                    onTap: controller.selectBusinessType,
                    isRightArrow: !isReadOnly,
                  )),
              15.w.verticalSpace,
              // 具体分类（二级，选择经营类型后出现）
              Obx(() {
                if (controller.merchantEntry.typeId == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    LabelSelectField(
                      label: '具體分類'.tr,
                      hintText: '請選擇具體經營分類'.tr,
                      value: controller.merchantEntry.typeClassName ?? '',
                      isRequired: true,
                      onTap: controller.selectBusinessSubtype,
                      isRightArrow: !isReadOnly,
                    ),
                    15.w.verticalSpace,
                  ],
                );
              }),
              CustomTextField(
                controller: controller.introductionController,
                hintText: '請輸入企業簡介'.tr,
                labelText: '簡介'.tr,
                maxLines: 8,
                isRequired: true,
                isReadOnly: isReadOnly,
              ),
              20.w.verticalSpace,
            ],
          )
              .padding(all: 10.w)
              .decorated(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.w),
              ),
        ],
      ).padding(horizontal: 12.w),
    );
  }
}
