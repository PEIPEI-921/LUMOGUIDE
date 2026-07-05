import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class GuideInfoWidget extends StatelessWidget {
  const GuideInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingGuideInfoController>();

    return Obx(() {
      if (controller.guideInfo == null) return const SizedBox.shrink();

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetImageCached(
            controller.guideInfo!.guide?.photo ?? '',
            width: 80.w,
            height: 100.w,
            fit: BoxFit.cover,
          ).clipRRect(all: 8.w),
          12.w.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              4.w.verticalSpace,
              Row(
                children: [
                  Text(
                    controller.guideInfo!.guide?.name ?? '--',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: controller.guideInfo!.isGrey
                          ? AppColors.assistantText
                          : AppColors.primaryText,
                    ),
                  ),
                  8.w.horizontalSpace,
                  Text(
                    controller.guideInfo!.guide?.identityType ?? '',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primary,
                    ),
                  ).padding(horizontal: 8.w, vertical: 2.w).decorated(
                        borderRadius: BorderRadius.circular(12.w),
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                ],
              ),
              12.w.verticalSpace,
              Row(
                children: [
                  Image.asset(
                    Assets.iconLan,
                    width: 14.w,
                  ),
                  6.w.horizontalSpace,
                  Text(
                    '${'語言'.tr}：${controller.guideInfo!.guide?.language?.join(',') ?? ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: controller.guideInfo!.isGrey
                          ? AppColors.assistantText
                          : AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).expanded(),
                ],
              ),
              6.w.verticalSpace,
              Row(
                children: [
                  Image.asset(
                    Assets.iconAddress,
                    width: 14.w,
                  ),
                  6.w.horizontalSpace,
                  Text(
                    '${'所在地'.tr}：${controller.guideInfo!.guide?.cityName ?? ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: controller.guideInfo!.isGrey
                          ? AppColors.assistantText
                          : AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).expanded(),
                ],
              ),
            ],
          ).expanded(),
        ],
      );
    });
  }
}
