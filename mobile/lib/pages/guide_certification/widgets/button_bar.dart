import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class ButtonBarWidget extends StatelessWidget {
  const ButtonBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Obx(
      () => Row(
        children: [
          if (controller.currentPageIndex.value > 0)
            TextButton(
              onPressed: controller.previousPage,
              style: TextButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
              child: Text(
                '上一步'.tr,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ).expanded(),
          if (controller.currentPageIndex.value > 0) 10.w.horizontalSpace,
          if (!controller.isReadOnly || controller.currentPageIndex.value != 2)
            SubmitButton(
              onPressed: controller.nextPage,
              title:
                  controller.currentPageIndex.value < 2 ? '下一步'.tr : '確定提交'.tr,
            ).expanded(),
        ],
      )
          .padding(
            horizontal: 14.w,
            bottom: 12.w,
            top: 20.w,
          )
          .safeArea(),
    );
  }
}
