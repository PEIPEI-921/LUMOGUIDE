import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class CommentMeItemWidget extends StatelessWidget {
  const CommentMeItemWidget({super.key, required this.item});

  final Comment item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommentController>();

    return Row(
      children: [
        CircleNetworkImage(
          imageUrl: item.userAvatar ?? '',
          radius: 24.w,
        ),
        8.w.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  item.userNickname ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).flexible(),
                Text(
                  item.title ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                ).padding(horizontal: 4.w),
              ],
            ),
            2.w.verticalSpace,
            Text(
              item.content ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 12.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            2.w.verticalSpace,
            Text(
              item.formatDate ?? '',
              style: TextStyle(
                color: AppColors.primaryText.withValues(alpha: 0.6),
                fontSize: 12.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ).expanded(),
        if (item.contentPicture.isNotEmpty)
          NetImageCached(
            item.contentPicture ?? '',
            width: 76.w,
            height: 52.w,
            borderRadius: BorderRadius.circular(5.w),
          ),
      ],
    ).padding(horizontal: 12.w).constrained(height: 82.w).decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        ).gestures(
          onTap: () {
            controller.onTapCommentMe(item);
          },
          behavior: HitTestBehavior.opaque,
        );
  }
}
