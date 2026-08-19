import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class ContactInfoWidget extends StatelessWidget {
  const ContactInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingGuideInfoController>();

    return Obx(() {
      if (controller.guideInfo == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactItem(
            label: '聯繫人'.tr,
            value: controller.guideInfo!.contact ?? '',
          ),
          _ContactItem(
            label: '聯繫電話'.tr,
            value: controller.guideInfo!.phone ?? '',
          ),
          _ContactItem(
            label: '聯繫人郵箱'.tr,
            value: controller.guideInfo!.email ?? '',
          ),
          _ContactItem(
            label: '其他聯繫方式'.tr,
            value: controller.guideInfo!.other ?? '',
          ),
        ],
      ).padding(all: 10.w).decorated(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(10.w),
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
