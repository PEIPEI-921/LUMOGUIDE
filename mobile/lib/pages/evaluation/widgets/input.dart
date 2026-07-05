import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class EvaluationInputWidget extends StatelessWidget {
  const EvaluationInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EvaluationController>();

    return Column(
      children: [
        CustomTextField(
          controller: controller.textController,
          hintText: '說點什麼吧～'.tr,
          maxLines: 8,
          backgroundColor: Colors.white,
        ),
        Divider(
          height: 20,
          thickness: 1,
          color: AppColors.primaryText.withOpacity(0.05),
        ),
        Obx(
          () => GridView.builder(
            padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.w),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index == controller.files.length &&
                  controller.files.length < 9) {
                return const _EmptyItem();
              }
              return _Item(file: controller.files[index]);
            },
            itemCount: controller.files.length == 9
                ? 9
                : controller.files.length + 1,
          ),
        ),
        const ImageTipWidget().padding(left: 10.w, bottom: 10.w),
      ],
    ).decorated(color: Colors.white, borderRadius: BorderRadius.circular(8));
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EvaluationController>();
    return Stack(
      children: [
        Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ).clipRRect(all: 6.w),
        Icon(Icons.close, size: 12.w, color: Colors.white)
            .padding(all: 3)
            .decorated(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(6.w),
                bottomLeft: Radius.circular(6.w),
              ),
            )
            .gestures(
              onTap: () {
                controller.onRemoveImage(file);
              },
              behavior: HitTestBehavior.opaque,
            )
            .positioned(top: 0, right: 0),
      ],
    );
  }
}

class _EmptyItem extends StatelessWidget {
  const _EmptyItem();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EvaluationController>();
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 25.w,
              color: AppColors.primaryText.withOpacity(0.8),
            ),
            Text(
              '上傳圖片'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.primaryText.withOpacity(0.8),
              ),
            ),
          ],
        )
        .center()
        .decorated(
          color: AppColors.primaryText.withOpacity(0.03),
          borderRadius: BorderRadius.circular(6),
        )
        .gestures(
          onTap: () {
            controller.onAddImage();
          },
          behavior: HitTestBehavior.opaque,
        );
  }
}
