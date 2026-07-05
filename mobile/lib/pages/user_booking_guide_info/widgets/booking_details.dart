import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class BookingDetailsWidget extends StatelessWidget {
  const BookingDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingGuideInfoController>();

    return Obx(() {
      if (controller.guideInfo == null) return const SizedBox.shrink();

      return Column(
        children: [
          _DetailItem(
            label: '預約城市'.tr,
            value: controller.guideInfo!.cityName ?? '',
          ),
          _DetailItem(
            label: '預計到達時間'.tr,
            value: controller.guideInfo!.arrivalTime ?? '',
          ),
          _DetailItem(
            label: '人數'.tr,
            value: controller.guideInfo!.number ?? '',
          ),
          _DetailItem(
            label: '行程/備注說明'.tr,
            value: controller.guideInfo!.remark ?? '',
          ),
        ],
      ).padding(all: 10.w).decorated(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(10.w),
          );
    });
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText,
            ),
          ),
          20.w.horizontalSpace,
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.right,
          ).expanded(),
        ],
      ),
    );
  }
}
