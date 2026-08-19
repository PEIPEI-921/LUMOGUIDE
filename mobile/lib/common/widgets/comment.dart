import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({super.key, required this.item, this.showStar = true});

  final EvaluateList item;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleNetworkImage(imageUrl: item.user?.avatar ?? '', radius: 16.w),
            5.w.horizontalSpace,
            Text(
              item.user?.nickname ?? '',
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
            ),
            const Spacer(),
            Text(
              item.createdAt ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Column(
          children: [
            if (showStar)
              Row(
                children: [
                  ...List.generate(
                    item.star ?? 0,
                    (index) => Icon(
                      Icons.star,
                      size: 16.w,
                      color: const Color(0xFFF2A200),
                    ),
                  ),
                ],
              ).padding(bottom: 10.w),
            Text(
              item.content ?? '',
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            ).alignment(Alignment.centerLeft),
            if (item.pictures.isNotEmpty)
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.04,
                  mainAxisSpacing: 7,
                  crossAxisSpacing: 7,
                ),
                itemBuilder: (context, index) {
                  return NetImageCached(
                    item.pictures[index],
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(4.w),
                  );
                },
                itemCount: item.pictures.length,
              ).paddingOnly(top: 12.w),
          ],
        ).padding(left: 37.w),
      ],
    ).padding(horizontal: 14.w, vertical: 14.w).decorated(color: Colors.white);
  }
}
