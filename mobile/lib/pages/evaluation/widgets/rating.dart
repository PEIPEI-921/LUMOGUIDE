import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class EvaluationRatingWidget extends StatelessWidget {
  const EvaluationRatingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EvaluationController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '評分'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryText,
          ),
        ),
        const Spacer(),
        Obx(() => Text(
              controller.ratingText,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.assistantText,
              ),
            )),
        10.w.horizontalSpace,
        const _StarRating(),
      ],
    )
        .height(50.w)
        .padding(left: 10.w, right: 15.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        )
        .padding(top: 13.w);
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EvaluationController>();

    return Obx(() => Row(
          children: List.generate(5, (index) {
            final isSelected = index < controller.rating.value;
            return Icon(
              isSelected ? Icons.star : Icons.star_outline,
              size: 20.w,
              color: isSelected ? AppColors.orange : AppColors.assistantText,
            ).gestures(
              onTap: () => controller.updateRating(index + 1),
              behavior: HitTestBehavior.opaque,
            );
          }),
        ));
  }
}
