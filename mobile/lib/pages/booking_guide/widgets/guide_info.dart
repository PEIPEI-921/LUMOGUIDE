import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class GuideInfoWidget extends StatelessWidget {
  const GuideInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingGuideController>();

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '預約導遊信息'.tr,
              style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
            ),
            10.w.verticalSpace,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetImageCached(
                  controller.guideInfo.photo ?? '',
                  width: 77.w,
                  height: 100.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 8.w),
                12.w.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          controller.guideInfo.name ?? '--',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).flexible(),
                        8.w.horizontalSpace,
                        Text(
                              controller.guideInfo.identityTypeName ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.primary,
                              ),
                            )
                            .padding(horizontal: 8.w, vertical: 2.w)
                            .decorated(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12.w),
                            ),
                      ],
                    ),
                    8.w.verticalSpace,
                    Row(
                      children: [
                        Image.asset(Assets.iconLan, width: 14.w),
                        6.w.horizontalSpace,
                        Text(
                          '${'語言'.tr}：${controller.guideInfo.language?.join(',') ?? ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primaryText,
                          ),
                        ).expanded(),
                      ],
                    ),
                    6.w.verticalSpace,
                    Row(
                      children: [
                        Image.asset(Assets.iconAddress, width: 14.w),
                        6.w.horizontalSpace,
                        Text(
                          '${'所在地'.tr}：${controller.guideInfo.cityName ?? ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).expanded(),
                      ],
                    ),
                  ],
                ).expanded(),
              ],
            ),
          ],
        )
        .padding(all: 10.w)
        .decorated(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(color: Colors.white),
        );
  }
}
