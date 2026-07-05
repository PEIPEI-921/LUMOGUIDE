import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepItem(
              index: 0,
              title: '基礎信息'.tr,
              isUnActive: controller.currentPageIndex.value < 0,
              isActive: controller.currentPageIndex.value == 0,
              isCompleted: controller.currentPageIndex.value > 0,
            ),
            _StepLine(isActive: controller.currentPageIndex.value > 0),
            _StepItem(
              index: 1,
              title: '專業信息'.tr,
              isUnActive: controller.currentPageIndex.value < 1,
              isActive: controller.currentPageIndex.value == 1,
              isCompleted: controller.currentPageIndex.value > 1,
            ),
            _StepLine(isActive: controller.currentPageIndex.value > 1),
            _StepItem(
              index: 2,
              title: '證件信息'.tr,
              isUnActive: controller.currentPageIndex.value < 2,
              isActive: controller.currentPageIndex.value == 2,
              isCompleted: controller.currentPageIndex.value > 2,
            ),
          ],
        )).padding(vertical: 20.w);
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final bool isUnActive;

  const _StepItem({
    required this.index,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.isUnActive,
  });

  String get imageName {
    if (isActive) {
      return Assets.iconStepIn;
    } else if (isCompleted) {
      return Assets.iconStepDone;
    } else if (isUnActive) {
      return Assets.iconStepNone;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imageName, width: 28.w, height: 28.w),
        5.w.verticalSpace,
        Text(
          title,
          style: TextStyle(
            color: isUnActive ? AppColors.assistantText : AppColors.primary,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 14.w),
      width: 85.w,
      height: 1,
      color:
          isActive ? AppColors.primary : AppColors.primaryText.withOpacity(0.1),
    );
  }
}
