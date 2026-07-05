import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class LoginAgreementWidget extends StatelessWidget {
  const LoginAgreementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Obx(
              () => Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: controller.isAgree.value
                      ? null
                      : Border.all(color: Colors.grey),
                  color: controller.isAgree.value
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                child: controller.isAgree.value
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ).gestures(onTap: controller.toggleAgree).padding(right: 4.w),
            ),
          ),
          TextSpan(
            text: '我已閲讀并同意'.tr,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                controller.toggleAgree();
              },
          ),
          TextSpan(
            text: '《用戶協議》'.tr,
            style: const TextStyle(color: AppColors.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                controller.goToUserAgreement();
              },
          ),
          TextSpan(text: '和'.tr),
          TextSpan(
            text: '《隱私政策》'.tr,
            style: const TextStyle(color: AppColors.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                controller.goToUserAgreement();
              },
          ),
        ],
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.primaryText.withOpacity(0.6),
        ),
      ),
    ).padding(horizontal: 15.w);
  }
}
