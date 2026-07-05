import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class ContactInfoWidget extends StatelessWidget {
  const ContactInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingGuideController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.contactNameController,
          hintText: '請輸入聯繫人姓名'.tr,
          labelText: '聯繫人'.tr,
          isRequired: true,
        ),
        12.w.verticalSpace,
        CustomTextField(
          controller: controller.contactEmailController,
          hintText: '請輸入聯繫人郵箱'.tr,
          labelText: '聯繫人郵箱'.tr,
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
        ),
        12.w.verticalSpace,
        CustomTextField(
          controller: controller.contactPhoneController,
          hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
          hintFontSize: 12.sp,
          labelText: '聯繫電話'.tr,
          isRequired: true,
          keyboardType: TextInputType.phone,
          inputFormatters: [LeadingPlusPhoneFormatter()],
        ),
        12.w.verticalSpace,
        CustomTextField(
          controller: controller.otherContactController,
          hintText: '請輸入其他聯繫方式,例如:微信:1231231'.tr,
          labelText: '其他聯繫方式'.tr,
        ),
      ],
    ).padding(all: 16.w).decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        );
  }
}
