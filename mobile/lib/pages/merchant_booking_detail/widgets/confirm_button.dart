import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class ConfirmButtonWidget extends StatelessWidget {
  const ConfirmButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantBookingDetailController>();

    return Obx(() {
      if (controller.merchantInfo == null) return const SizedBox.shrink();

      if (controller.merchantInfo!.status == 3) {
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
            controller.merchantInfo!.status == 1 ? '確認預約'.tr : '完成預約'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ).gestures(
        onTap: controller.confirmReservation,
      );
    });
  }
}
