import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class BusinessTypeWidget extends StatelessWidget {
  const BusinessTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantEntryController>();
    return Obx(
      () => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商家類型'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            15.w.verticalSpace,
            Column(
                  children: [
                    LabelSelectField(
                      label: '經營類型'.tr,
                      hintText: '請選擇企業經營類型'.tr,
                      value: controller.merchantEntry.businessType ?? '',
                      onTap: controller.selectBusinessType,
                      isRightArrow: !controller.isReadOnly,
                    ),
                    15.w.verticalSpace,
                    CustomTextField(
                      controller: controller.introductionController,
                      hintText: '請輸入企業簡介'.tr,
                      labelText: '簡介'.tr,
                      maxLines: 8,
                      isReadOnly: controller.isReadOnly,
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
      ),
    );
  }
}
