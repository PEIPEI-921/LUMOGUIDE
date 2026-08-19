import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';
import '../purpose.dart';

class NextStepButton extends StatelessWidget {
  const NextStepButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<SelectMembersController>();
      final n = controller.selectedCount;
      final enabled = n > 0;
      final label = controller.purpose == SelectMembersPurpose.addToGroup
          ? '添加'.tr
          : '下一步'.tr;
      return Text(
            '$label($n)',
            style: TextStyle(
              fontSize: 12.sp,
              color: enabled ? Colors.white : AppColors.assistantText,
            ),
          )
          .padding(horizontal: 8.w, vertical: 4.w)
          .decorated(
            borderRadius: BorderRadius.circular(16.w),
            color: enabled
                ? AppColors.primary
                : AppColors.assistantText.withValues(alpha: 0.2),
          )
          .gestures(
            onTap: enabled ? () => controller.onNextStep() : null,
            behavior: HitTestBehavior.opaque,
          )
          .padding(right: 12.w);
    });
  }
}
