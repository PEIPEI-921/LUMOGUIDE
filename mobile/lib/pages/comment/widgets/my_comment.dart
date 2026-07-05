import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MyCommentItemWidget extends StatelessWidget {
  const MyCommentItemWidget({super.key, required this.item});
  final Comment item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommentController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(item: item),
        12.w.verticalSpace,
        Text(
          item.content ?? '',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        10.w.verticalSpace,
        _Quote(item: item),
      ],
    )
        .padding(all: 12.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        )
        .gestures(
          onTap: () {
            controller.onTapMyComment(item);
          },
          behavior: HitTestBehavior.opaque,
        );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.item});
  final Comment item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleNetworkImage(
          imageUrl: item.myAvatar ?? '',
          radius: 20.w,
        ),
        8.w.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.myNickname ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
            Text(
              item.formatDate ?? '',
              style: TextStyle(
                color: AppColors.primaryText.withOpacity(0.6),
                fontSize: 12.sp,
              ),
            ),
          ],
        ).expanded(),
      ],
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.item});
  final Comment item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (item.contentPicture.isNotEmpty)
          NetImageCached(
            item.contentPicture ?? '',
            width: 70.w,
            height: 52.w,
            borderRadius: BorderRadius.circular(8.w),
          ).padding(right: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '@${item.contentUser ?? ''}',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 12.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            4.w.verticalSpace,
            Text(
              item.title ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 12.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ).expanded(),
      ],
    ).constrained(height: 52.w).decorated(
          color: AppColors.primaryText.withOpacity(0.03),
          borderRadius: BorderRadius.circular(4.w),
        );
  }
}
