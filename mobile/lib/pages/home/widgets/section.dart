import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class HomeSectionWidget extends StatelessWidget {
  const HomeSectionWidget({super.key, required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              section.subTitle,
              style: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
            ),
          ],
        ).expanded(),
        Text(
              '查看全部'.tr,
              style: TextStyle(color: AppColors.primary, fontSize: 12.sp),
            )
            .padding(vertical: 5)
            .gestures(
              onTap: () => controller.onSectionTap(section),
              behavior: HitTestBehavior.opaque,
            ),
      ],
    );
  }
}
