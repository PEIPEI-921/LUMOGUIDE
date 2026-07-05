import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class VisibilitySelectorWidget extends StatelessWidget {
  const VisibilitySelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PublishInformationController>();

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('選擇誰可見'.tr).fontSize(15.sp).textColor(AppColors.primaryText),
            8.w.verticalSpace,
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      !controller.isPublic
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: !controller.isPublic
                          ? AppColors.primary
                          : AppColors.assistantText,
                      size: 18.w,
                    ),
                    5.w.horizontalSpace,
                    Text('僅 LuMo Guide'.tr)
                        .fontSize(14.sp)
                        .textColor(AppColors.primaryText),
                  ],
                ).padding(vertical: 4.w).gestures(
                      onTap: () {
                        controller.onVisibilityChanged(false);
                      },
                      behavior: HitTestBehavior.opaque,
                    ),
                20.w.horizontalSpace,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.isPublic
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: controller.isPublic
                          ? AppColors.primary
                          : AppColors.assistantText,
                      size: 18.w,
                    ),
                    5.w.horizontalSpace,
                    Text('所有人'.tr)
                        .fontSize(14.sp)
                        .textColor(AppColors.primaryText),
                  ],
                ).padding(vertical: 4.w).gestures(
                      onTap: () {
                        controller.onVisibilityChanged(true);
                      },
                      behavior: HitTestBehavior.opaque,
                    ),
              ],
            )
          ],
        ));
  }
}
