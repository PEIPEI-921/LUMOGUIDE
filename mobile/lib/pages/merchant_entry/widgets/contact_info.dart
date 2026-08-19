import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class ContactInfoWidget extends StatelessWidget {
  const ContactInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantEntryController>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('聯繫信息'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          15.w.verticalSpace,
          Column(
                children: [
                  CustomTextField(
                    controller: controller.emailController,
                    hintText: '請輸入Email'.tr,
                    labelText: 'Email'.tr,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    isReadOnly: controller.isReadOnly,
                  ),
                  15.w.verticalSpace,
                  CustomTextField(
                    controller: controller.phoneController,
                    hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
                    labelText: '聯繫電話'.tr,
                    hintFontSize: 12.sp,
                    keyboardType: TextInputType.phone,
                    isRequired: true,
                    isReadOnly: controller.isReadOnly,
                    inputFormatters: [LeadingPlusPhoneFormatter()],
                  ),
                  15.w.verticalSpace,
                  CustomTextField(
                    controller: controller.websiteController,
                    hintText: '請輸入公司網站'.tr,
                    labelText: '公司網站'.tr,
                    keyboardType: TextInputType.url,
                    isReadOnly: controller.isReadOnly,
                  ),
                  15.w.verticalSpace,
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
                    isRequired: true,
                  ),
                  10.w.verticalSpace,
                  CustomTextField(
                    controller: controller.whatsAppController,
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
                    labelText: '其他聯係方式'.tr,
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
    );
  }
}
