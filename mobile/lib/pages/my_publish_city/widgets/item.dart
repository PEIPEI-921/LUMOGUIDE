import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../../my_publish/widgets/status.dart';
import '../index.dart';

class MyPublishCityItemWidget extends StatelessWidget {
  const MyPublishCityItemWidget({super.key, required this.item});
  final GuidePublishCity item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyPublishCityController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.isRead == 0)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    margin: EdgeInsets.only(right: 4.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  '${'發佈時間'.tr}: ${item.createdAt}',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                StatusWidget(status: item.auditStatus),
              ],
            ),
            10.w.verticalSpace,
            Stack(
              children: [
                NetImageCached(
                  item.firstPicture,
                  width: double.infinity,
                  height: 180.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 6.w),
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.name ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).constrained(maxWidth: 100.w),
                            if (item.isCapital == 1)
                              Text(
                                    '首都'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                    ),
                                  )
                                  .padding(all: 3.w)
                                  .decorated(
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4.w),
                                  )
                                  .padding(left: 8.w),
                          ],
                        ),
                        Text(
                          item.nameEn ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ).constrained(maxWidth: 120.w),
                      ],
                    )
                    .padding(horizontal: 14.w, vertical: 10.w)
                    .constrained(minWidth: 150.w)
                    .decorated(
                      borderRadius: BorderRadius.circular(8.w),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.primary, Colors.transparent],
                      ),
                    )
                    .positioned(left: 14.w, top: 15.w),
              ],
            ),
            if (item.auditFeedback.isNotEmpty && item.auditStatus == 2)
              Text(
                '${'駁回原因'.tr}: ${item.auditFeedback ?? ''}',
                style: const TextStyle(color: Color(0xFFDD0000)),
              ).padding(top: 10.w),
          ],
        ).padding(all: 10.w).decorated(color: Colors.white),
        Row(
          children: [
            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.iconPublishEdit,
                      width: 12.w,
                      color: AppColors.primaryText,
                    ),
                    5.w.horizontalSpace,
                    Text(
                      '編輯'.tr,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                )
                .height(double.infinity)
                .gestures(
                  onTap: () {
                    controller.onEditCity(item);
                  },
                  behavior: HitTestBehavior.opaque,
                )
                .expanded(),
            if (item.auditStatus == 2) ...[
              Container(
                width: 1,
                height: 20.w,
                color: AppColors.assistantText.withValues(alpha: 0.3),
              ),
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.iconPublishDelete,
                        width: 12.w,
                        color: AppColors.primaryText,
                      ),
                      5.w.horizontalSpace,
                      Text(
                        '刪除'.tr,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  )
                  .height(double.infinity)
                  .gestures(
                    onTap: () {
                      controller.onDeleteCity(item);
                    },
                    behavior: HitTestBehavior.opaque,
                  )
                  .expanded(),
            ],
          ],
        ).height(40.w),
      ],
    ).decorated(color: Colors.white).clipRRect(all: 8.w);
  }
}
