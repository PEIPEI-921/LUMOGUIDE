import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class GuideDetailInfoWidget extends StatelessWidget {
  const GuideDetailInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideDetailController>();

    return Column(
          children: [
            _InfoItem(
              title: '聯繫電話'.tr,
              content: controller.guideInfo!.phone ?? '',
              hasAction: true,
              onTap: controller.makePhoneCall,
            ),
            _InfoItem(
              title: '郵箱地址'.tr,
              content: controller.guideInfo!.email ?? '',
            ),
            if (controller.guideInfo!.wechat.isNotEmpty)
              _InfoItem(
                title: '微信/Wechat'.tr,
                content: controller.guideInfo!.wechat ?? '',
              ),
            if (controller.guideInfo!.whatsApp.isNotEmpty)
              _InfoItem(
                title: 'WhatsApp'.tr,
                content: controller.guideInfo!.whatsApp ?? '',
              ),
            if (controller.guideInfo!.line.isNotEmpty)
              _InfoItem(
                title: 'Line'.tr,
                content: controller.guideInfo!.line ?? '',
              ),
            if (controller.guideInfo!.otherContact.isNotEmpty)
              _InfoItem(
                title: '其他聯繫方式'.tr,
                content: controller.guideInfo!.otherContact ?? '',
              ),
            _IdentityItem(identity: controller.guideInfo!.industryType ?? ''),
            _InfoItem(
              title: '是否有車輛資源'.tr,
              content: controller.guideInfo!.haveVehicle ?? '',
            ),
            _InfoItem(
              title: '車輛可否出租'.tr,
              content: controller.guideInfo!.vehicleRent ?? '',
            ),
            if (controller.guideInfo!.haveVehicle == '是')
              _VehicleImages(images: controller.guideInfo!.carPictures),
          ],
        )
        .padding(horizontal: 10.w, bottom: 15.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String content;
  final bool hasAction;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.title,
    required this.content,
    this.hasAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, color: AppColors.assistantText),
            ).constrained(width: 120.w),
            Row(
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryText,
                  ),
                  textAlign: TextAlign.right,
                ).expanded(),
                if (hasAction) ...[
                  8.w.horizontalSpace,
                  Image.asset(Assets.iconTelFill, width: 16.w),
                ],
              ],
            ).expanded(),
          ],
        )
        .padding(vertical: 8.w)
        .gestures(onTap: onTap, behavior: HitTestBehavior.opaque);
  }
}

class _IdentityItem extends StatelessWidget {
  final String identity;

  const _IdentityItem({required this.identity});

  @override
  Widget build(BuildContext context) {
    return identity.isEmpty
        ? const SizedBox.shrink()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '可從事工作類型'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.assistantText,
                ),
              ).constrained(width: 120.w),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10.w,
                runSpacing: 5.w,
                children: identity.split(',').map((e) {
                  return Text(
                        e,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.primary,
                        ),
                      )
                      .padding(horizontal: 8.w, vertical: 2.w)
                      .decorated(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.w),
                      );
                }).toList(),
              ).expanded(),
            ],
          ).padding(vertical: 8.w);
  }
}

class _VehicleImages extends StatelessWidget {
  final List<String> images;

  const _VehicleImages({required this.images});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.w.verticalSpace,
        Text(
          '車輛圖片顯示'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.assistantText),
        ),
        12.w.verticalSpace,
        Row(
          children: images.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;
            return GestureDetector(
              onTap: () {
                if (images.isEmpty) return;
                Get.toNamed(
                  AppRoutes.PHOTO_VIEW,
                  arguments: {'pictures': images, 'index': index},
                );
              },
              child:
                  NetImageCached(
                        image,
                        width: 120.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                      )
                      .clipRRect(all: 8.w)
                      .decorated(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8.w),
                      )
                      .padding(right: 12.w),
            );
          }).toList(),
        ).scrollable(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
        ),
      ],
    ).alignment(Alignment.centerLeft);
  }
}
