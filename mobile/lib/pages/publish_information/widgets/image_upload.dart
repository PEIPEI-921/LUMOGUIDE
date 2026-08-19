import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class ImageUploadWidget extends StatelessWidget {
  const ImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PublishInformationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('上传圖片'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          ],
        ),
        10.w.verticalSpace,
        Obx(
          () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.w,
              childAspectRatio: 1,
            ),
            itemCount: controller.pictures.length >= 6
                ? 6
                : controller.pictures.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.pictures.length &&
                  controller.pictures.length < 6) {
                return Image.asset(
                  Assets.iconPhotoAdd,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ).gestures(onTap: () => controller.selectImage(index: index));
              }
              final image = controller.pictures[index];
              if (image.startsWith('http')) {
                return _buildMerchantImageItem(image, index, isLocal: false);
              }
              return _buildMerchantImageItem(image, index, isLocal: true);
            },
          ),
        ),
        const ImageTipWidget().padding(vertical: 10.w),
      ],
    );
  }

  Widget _buildMerchantImageItem(
    dynamic image,
    int index, {
    required bool isLocal,
  }) {
    final controller = Get.find<PublishInformationController>();

    return Stack(
      children: [
        isLocal
            ? Image.file(
                File(image),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ).clipRRect(all: 4.w)
            : NetImageCached(
                image,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(4.w),
                fit: BoxFit.cover,
              ),
        Positioned(
          top: 5.w,
          right: 5.w,
          child:
              Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14.w, color: Colors.white),
              ).gestures(
                onTap: () {
                  controller.removeImage(index);
                },
              ),
        ),
      ],
    );
  }
}
