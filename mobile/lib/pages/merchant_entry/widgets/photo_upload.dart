import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';
import '../value.dart';

class PhotoUploadWidget extends StatelessWidget {
  const PhotoUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('上傳圖片'.tr).fontSize(16.sp).textColor(AppColors.primaryText),
          const ImageTipWidget().padding(top: 10.w),
          15.w.verticalSpace,
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DocumentsUploadWidget(),
                  15.w.verticalSpace,
                  const _MerchantPhotosWidget(),
                ],
              )
              .padding(all: 10.w)
              .decorated(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.w),
              ),
        ],
      ).padding(horizontal: 12.w),
    );
  }
}

class _DocumentsUploadWidget extends StatelessWidget {
  const _DocumentsUploadWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantEntryController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // const Text('*').fontSize(14.sp).textColor(AppColors.red),
            Text('相關證件圖片'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          ],
        ),
        10.w.verticalSpace,
        Obx(
          () => controller.documentsPicture.value != null
              ? Image.file(
                      File(controller.documentsPicture.value!.path),
                      width: 90.w,
                      height: 90.w,
                      fit: BoxFit.cover,
                    )
                    .clipRRect(all: 4.w)
                    .gestures(
                      onTap: () =>
                          controller.selectImage(MerchantPhotoType.documents),
                    )
              : controller.merchantEntry.documentsPicture != null
              ? NetImageCached(
                  controller.merchantEntry.documentsPicture,
                  width: 90.w,
                  height: 90.w,
                  borderRadius: BorderRadius.circular(4.w),
                  fit: BoxFit.cover,
                ).gestures(
                  onTap: () =>
                      controller.selectImage(MerchantPhotoType.documents),
                )
              : Image.asset(
                  Assets.iconPhotoAdd,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ).gestures(
                  onTap: () =>
                      controller.selectImage(MerchantPhotoType.documents),
                ),
        ),
        Text(
          '例如營業執照等'.tr,
        ).fontSize(12.sp).textColor(AppColors.assistantText).padding(top: 8.w),
      ],
    );
  }
}

class _MerchantPhotosWidget extends StatelessWidget {
  const _MerchantPhotosWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantEntryController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('商家圖片'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
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
            itemCount: controller.merchantPictures.length >= 5
                ? 5
                : controller.merchantPictures.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.merchantPictures.length &&
                  controller.merchantPictures.length < 5) {
                return controller.isReadOnly
                    ? const SizedBox.shrink()
                    : Image.asset(
                        Assets.iconPhotoAdd,
                        width: 90.w,
                        height: 90.w,
                        fit: BoxFit.cover,
                      ).gestures(
                        onTap: () => controller.selectImage(
                          MerchantPhotoType.merchantPictures,
                          index: index,
                        ),
                      );
              }
              final image = controller.merchantPictures[index];
              if (image.startsWith('http')) {
                return _buildMerchantImageItem(image, index, isLocal: false);
              }
              return _buildMerchantImageItem(image, index, isLocal: true);
            },
          ),
        ),
        controller.isReadOnly
            ? const SizedBox.shrink()
            : Text('請上傳商家照片，最多5張'.tr)
                  .fontSize(12.sp)
                  .textColor(AppColors.assistantText)
                  .padding(top: 8.w),
      ],
    );
  }

  Widget _buildMerchantImageItem(
    dynamic image,
    int index, {
    required bool isLocal,
  }) {
    final controller = Get.find<MerchantEntryController>();

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
                  controller.removeMerchantPicture(index);
                },
              ),
        ),
      ],
    );
  }
}
