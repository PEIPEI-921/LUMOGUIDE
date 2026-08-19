import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../index.dart';

class CertificateInfoWidget extends StatelessWidget {
  const CertificateInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('證件信息'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          const ImageTipWidget(),
          15.w.verticalSpace,
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CertificateUploadWidget(),
                  15.w.verticalSpace,
                  const _PassportUploadWidget(),
                  15.w.verticalSpace,
                  const _DriverLicenseWidget(),
                  15.w.verticalSpace,
                  const _CarPicturesWidget(),
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

class _CertificateUploadWidget extends StatelessWidget {
  const _CertificateUploadWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // const Text('*').fontSize(14.sp).textColor(AppColors.red),
            Text(
              '專業資格證書圖片'.tr,
            ).fontSize(14.sp).textColor(AppColors.primaryText),
            Text(
              '（此內容不會公開，僅供內部審核）'.tr,
              style: TextStyle(color: AppColors.assistantText, fontSize: 12.sp),
            ).padding(left: 2).flexible(),
          ],
        ),
        10.w.verticalSpace,
        Obx(
          () => controller.certificatePicture.value != null
              ? Image.file(
                  File(controller.certificatePicture.value!.path),
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 4.w)
              : controller.certification.certificatePicture.isNotEmpty
              ? NetImageCached(
                  controller.certification.certificatePicture,
                  width: 90.w,
                  height: 90.w,
                  borderRadius: BorderRadius.circular(4.w),
                )
              : Image.asset(
                  Assets.iconPhotoAdd,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ),
        ).gestures(
          onTap: () => controller.selectImage(GuidePhotoType.certificate),
        ),
        Text(
          '例如導遊證，國際領隊證，營業執照等'.tr,
        ).fontSize(12.sp).textColor(AppColors.assistantText).padding(top: 8.w),
      ],
    );
  }
}

class _PassportUploadWidget extends StatelessWidget {
  const _PassportUploadWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('護照證件圖片'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            Text(
              '（此內容不會公開，僅供內部審核）'.tr,
              style: TextStyle(color: AppColors.assistantText, fontSize: 12.sp),
            ).padding(left: 2).flexible(),
          ],
        ),
        10.w.verticalSpace,
        Obx(
          () => controller.passportPicture.value != null
              ? Image.file(
                  File(controller.passportPicture.value!.path),
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 4.w)
              : controller.certification.passportPicture.isNotEmpty
              ? NetImageCached(
                  controller.certification.passportPicture,
                  width: 90.w,
                  height: 90.w,
                  borderRadius: BorderRadius.circular(4.w),
                )
              : Image.asset(
                  Assets.iconPhotoAdd,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ),
        ).gestures(
          onTap: () => controller.selectImage(GuidePhotoType.passport),
        ),
      ],
    );
  }
}

class _DriverLicenseWidget extends StatelessWidget {
  const _DriverLicenseWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('駕駛執照圖片'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            Text(
              '（此內容不會公開，僅供內部審核）'.tr,
              style: TextStyle(color: AppColors.assistantText, fontSize: 12.sp),
            ).padding(left: 2).flexible(),
          ],
        ),
        10.w.verticalSpace,
        Row(
          children: [
            Column(
              children: [
                Obx(
                  () => controller.driverLicenseFront.value != null
                      ? Image.file(
                          File(controller.driverLicenseFront.value!.path),
                          width: 90.w,
                          height: 90.w,
                          fit: BoxFit.cover,
                        ).clipRRect(all: 4.w)
                      : controller.certification.driverLicenseFront.isNotEmpty
                      ? NetImageCached(
                          controller.certification.driverLicenseFront,
                          width: 90.w,
                          height: 90.w,
                          borderRadius: BorderRadius.circular(4.w),
                        )
                      : Image.asset(
                          Assets.iconPhotoAdd,
                          width: 90.w,
                          height: 90.w,
                          fit: BoxFit.cover,
                        ),
                ).gestures(
                  onTap: () =>
                      controller.selectImage(GuidePhotoType.driverLicenseFront),
                ),
                5.w.verticalSpace,
                Text('正面'.tr).fontSize(12.sp).textColor(AppColors.primaryText),
              ],
            ),
            20.w.horizontalSpace,
            Column(
              children: [
                Obx(
                  () => controller.driverLicenseBack.value != null
                      ? Image.file(
                          File(controller.driverLicenseBack.value!.path),
                          width: 90.w,
                          height: 90.w,
                          fit: BoxFit.cover,
                        ).clipRRect(all: 4.w)
                      : controller.certification.driverLicenseBack.isNotEmpty
                      ? NetImageCached(
                          controller.certification.driverLicenseBack,
                          width: 90.w,
                          height: 90.w,
                          borderRadius: BorderRadius.circular(4.w),
                        )
                      : Image.asset(
                          Assets.iconPhotoAdd,
                          width: 90.w,
                          height: 90.w,
                          fit: BoxFit.cover,
                        ),
                ).gestures(
                  onTap: () =>
                      controller.selectImage(GuidePhotoType.driverLicenseBack),
                ),
                5.w.verticalSpace,
                Text('反面'.tr).fontSize(12.sp).textColor(AppColors.primaryText),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CarPicturesWidget extends StatelessWidget {
  const _CarPicturesWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideCertificationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('車輛照片'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
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
            itemCount: controller.carPictures.length >= 5
                ? 5
                : controller.carPictures.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.carPictures.length &&
                  controller.carPictures.length < 5) {
                return Obx(
                  () => controller.isReadOnly
                      ? const SizedBox.shrink()
                      : Image.asset(
                          Assets.iconPhotoAdd,
                          width: 90.w,
                          height: 90.w,
                          fit: BoxFit.cover,
                        ).gestures(
                          onTap: () => controller.selectImage(
                            GuidePhotoType.carPictures,
                            index: index,
                          ),
                        ),
                );
              }
              final image = controller.carPictures[index];
              if (image.startsWith('http')) {
                return _buildCarImageItem(image, index, isLocal: false);
              }
              return _buildCarImageItem(image, index, isLocal: true);
            },
          ),
        ),
        controller.isReadOnly
            ? const SizedBox.shrink()
            : Text('請上傳車輛照片，最多5張'.tr)
                  .fontSize(12.sp)
                  .textColor(AppColors.assistantText)
                  .padding(top: 8.w),
      ],
    );
  }

  Widget _buildCarImageItem(dynamic image, int index, {required bool isLocal}) {
    final controller = Get.find<GuideCertificationController>();

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
          child: controller.isReadOnly
              ? const SizedBox.shrink()
              : Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 14.w, color: Colors.white),
                ).gestures(
                  onTap: () {
                    controller.removeCarPicture(index);
                  },
                ),
        ),
      ],
    );
  }
}
