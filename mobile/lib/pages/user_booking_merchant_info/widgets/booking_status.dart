import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../../user_booking_manager/widgets/status.dart';
import '../controller.dart';

class BookingStatusWidget extends StatelessWidget {
  const BookingStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingMerchantInfoController>();

    return Obx(() {
      if (controller.merchantInfo == null) return const SizedBox.shrink();

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              10.w.verticalSpace,
              Icon(
                Icons.access_time,
                size: 30.w,
                color: AppColors.primary,
              ),
              6.w.horizontalSpace,
              Text(
                '預約時間'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: controller.merchantInfo!.isGrey
                      ? AppColors.assistantText
                      : AppColors.primaryText,
                ),
              ),
              4.w.verticalSpace,
              Text(
                controller.merchantInfo!.arrivalTime ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: controller.merchantInfo!.isGrey
                      ? AppColors.assistantText
                      : AppColors.primaryText,
                ),
              ),
            ],
          ).width(double.infinity),
          StatusWidget(status: controller.merchantInfo!.status)
              .positioned(top: 0.w, right: 0),
        ],
      );
    });
  }
}
