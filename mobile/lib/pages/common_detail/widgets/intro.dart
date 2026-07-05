import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class CommonDetailIntroWidget extends StatelessWidget {
  const CommonDetailIntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommonDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              width: 20.w,
              height: 3.w,
              color: AppColors.primary,
            ).positioned(bottom: 2),
            Text(
              controller.type.introTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        12.w.verticalSpace,
        Obx(() => Text(
              controller.merchantInfo.introduce ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryText,
                height: 1.6,
              ),
            )),
      ],
    ).width(double.infinity).padding(all: 14.w).decorated(
          color: Colors.white,
        );
  }
}
