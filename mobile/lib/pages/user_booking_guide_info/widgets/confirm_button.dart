import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class ConfirmButtonWidget extends StatelessWidget {
  const ConfirmButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingGuideInfoController>();

    return Obx(() {
      if (controller.guideInfo == null) return const SizedBox.shrink();

      if (controller.guideInfo!.status == 3) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        height: 40.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.w),
          borderRadius: BorderRadius.circular(100.w),
        ),
        child: Center(
          child: Text(
            controller.guideInfo?.infoButtonText ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ).gestures(
        onTap: () {
          Loading.success('預約已確認'.tr);
        },
      );
    });
  }
}
