import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class ContactInfoWidget extends StatelessWidget {
  const ContactInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantBookingDetailController>();

    return Obx(() {
      if (controller.merchantInfo == null) return const SizedBox.shrink();

      return Column(
        children: [
          _ContactItem(
            label: '聯繫人'.tr,
            value: controller.merchantInfo!.contact ?? '',
          ),
          _ContactItem(
            label: '聯繫人郵箱'.tr,
            value: controller.merchantInfo!.email ?? '',
          ),
          _ContactItem(
            label: '聯繫人電話'.tr,
            value: controller.merchantInfo!.phone ?? '',
          ),
          _ContactItem(
            label: '其他聯繫方式'.tr,
            value: controller.merchantInfo!.other ?? '',
          ),
        ],
      ).padding(all: 10.w).decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          );
    });
  }
}

class _ContactItem extends StatelessWidget {
  final String label;
  final String value;

  const _ContactItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.w),
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
