import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class GuideCertificationAuditStatusWidget extends StatelessWidget {
  const GuideCertificationAuditStatusWidget({super.key});

  String get auditStatusText {
    final controller = Get.find<GuideCertificationController>();
    switch (controller.certification.auditStatus) {
      case 0:
        return '審核中'.tr;
      case 1:
        return '審核通過'.tr;
      case 2:
        return '審核未通過'.tr;
      default:
        return '';
    }
  }

  Color get auditStatusColor {
    final controller = Get.find<GuideCertificationController>();
    switch (controller.certification.auditStatus) {
      case 0:
        return AppColors.orange;
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.red;
      default:
        return AppColors.primaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Obx(() => controller.certification.auditStatus == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${'審核狀態'.tr}: ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primaryText,
                      )),
                  Text(auditStatusText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: auditStatusColor,
                      )),
                ],
              ),
              if (controller.certification.auditStatus == 2 &&
                  controller.certification.auditFeedback != null)
                Text(
                  controller.certification.auditFeedback ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.red,
                  ),
                ),
            ],
          )
            .padding(all: 10.w)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.w),
            )
            .padding(horizontal: 14.w, bottom: 10.w));
  }
}
