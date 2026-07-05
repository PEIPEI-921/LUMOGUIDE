import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class GuideDetailIntroWidget extends StatelessWidget {
  const GuideDetailIntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '簡介'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        12.w.verticalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.guideInfo!.introduction ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryText,
                height: 1.6,
              ),
            ),
          ],
        )
            .padding(horizontal: 10.w, vertical: 14.w)
            .width(double.infinity)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
      ],
    );
  }
}
