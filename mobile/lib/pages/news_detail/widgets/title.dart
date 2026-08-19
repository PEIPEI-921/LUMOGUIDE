import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class NewsDetailTitleWidget extends StatelessWidget {
  const NewsDetailTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsDetailController>();

    return Obx(
      () => controller.news.id == null
          ? const SizedBox.shrink()
          : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.news.title ?? '',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    15.w.verticalSpace,
                    Row(
                      children: [
                        Row(
                          children: [
                            CircleNetworkImage(
                              imageUrl: controller.news.user?.photo ?? '',
                              radius: 15.w,
                            ).gestures(
                              onTap: () => controller.onUserTap(),
                              behavior: HitTestBehavior.opaque,
                            ),
                            5.w.horizontalSpace,
                            Text(
                                  controller.news.user?.name ?? '',
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                                .gestures(
                                  onTap: () => controller.onUserTap(),
                                  behavior: HitTestBehavior.opaque,
                                )
                                .flexible(),
                            if (controller.news.user?.cityName != null) ...[
                              4.w.horizontalSpace,
                              Text(
                                    controller.news.user?.cityName ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                    ),
                                  )
                                  .padding(horizontal: 4.w, vertical: 2.w)
                                  .decorated(
                                    borderRadius: BorderRadius.circular(100),
                                    color: AppColors.primary,
                                  )
                                  .gestures(
                                    onTap: () => controller.onCityTap(),
                                    behavior: HitTestBehavior.opaque,
                                  ),
                            ],
                            5.w.horizontalSpace,
                            Text(
                                  controller.news.user?.identityType ?? '',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10.sp,
                                  ),
                                )
                                .padding(horizontal: 7.w, vertical: 4.w)
                                .decorated(
                                  borderRadius: BorderRadius.circular(100),
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                ),
                          ],
                        ).expanded(),
                        10.w.horizontalSpace,
                      ],
                    ),
                    Text(
                      '${controller.news.view ?? 0}${'次瀏覽'.tr} | ${controller.news.createdAt ?? ''}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryText.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.right,
                    ).padding(top: 10.w),
                    Divider(
                      height: 20,
                      thickness: 1,
                      color: AppColors.primaryText.withValues(alpha: 0.05),
                    ),
                  ],
                )
                .padding(horizontal: 14.w, top: 15.w)
                .width(double.infinity)
                .backgroundColor(Colors.white),
    );
  }
}
