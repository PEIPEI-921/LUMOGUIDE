import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class GuideDetailHeaderWidget extends StatelessWidget with UserStoreMixin {
  const GuideDetailHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideDetailController>();

    return Stack(
      children: [
        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    final photo = controller.guideInfo!.photo;
                    if (photo == null || photo.isEmpty) return;
                    Get.toNamed(
                      AppRoutes.PHOTO_VIEW,
                      arguments: {
                        'pictures': [photo],
                        'index': 0,
                      },
                    );
                  },
                  child: NetImageCached(
                    controller.guideInfo!.photo,
                    width: 108.w,
                    height: 140.w,
                    fit: BoxFit.cover,
                  ).clipRRect(all: 8.w),
                ),
                16.w.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    4.w.verticalSpace,
                    Text(
                      controller.guideInfo!.name ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (controller.guideInfo!.nameEn?.isNotEmpty ?? false) ...[
                      2.w.verticalSpace,
                      Text(
                        controller.guideInfo!.nameEn ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.assistantText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    5.w.verticalSpace,
                    Text(
                          controller.guideInfo!.identityTypeName ?? '',
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
                    12.w.verticalSpace,
                    Row(
                      children: [
                        Image.asset(Assets.iconLan, width: 14.w),
                        8.w.horizontalSpace,
                        Text(
                          '${'語  言'.tr}：${controller.guideInfo!.language?.join(',')}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).flexible(),
                      ],
                    ),
                    10.w.verticalSpace,
                    Row(
                      children: [
                        Image.asset(Assets.iconAddress, width: 14.w),
                        8.w.horizontalSpace,
                        Text(
                          '${'所在地'.tr}：${controller.guideInfo!.cityName.isNotEmpty ? controller.guideInfo!.cityName : '--'}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).flexible(),
                      ],
                    ),
                  ],
                ).expanded(),
              ],
            )
            .padding(all: 16.w)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
        Obx(
          () => controller.guideInfo?.canFollow == 0
              ? const SizedBox.shrink()
              : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isFollowed ? Icons.check : Icons.add,
                          size: 14.w,
                          color: AppColors.primary,
                        ),
                        4.w.horizontalSpace,
                        Text(
                          controller.isFollowed ? '已關注'.tr : '關注'.tr,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    )
                    .padding(horizontal: 10.w, vertical: 6.w)
                    .decorated(
                      border: Border.all(color: AppColors.primary, width: 1.w),
                      borderRadius: BorderRadius.circular(5.w),
                    )
                    .gestures(onTap: controller.toggleFollow),
        ).positioned(bottom: 10.w, right: 10.w),
      ],
    );
  }
}
