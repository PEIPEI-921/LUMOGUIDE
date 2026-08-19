import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class CommentBar extends StatelessWidget {
  const CommentBar({
    super.key,
    this.showSafeArea = true,
    this.showShadow = true,
    this.onTap,
    this.count,
  });

  final bool showSafeArea;
  final bool showShadow;
  final int? count;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '我來講兩句'.tr,
          style: TextStyle(
            color: const Color(0xFFC3C3C3),
            fontSize: 14.sp,
          ),
        )
            .alignment(Alignment.centerLeft)
            .padding(left: 20.w)
            .decorated(
                color: AppColors.primaryText.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(100))
            .height(40.w)
            .expanded(),
        15.w.horizontalSpace,
        Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            Image.asset(Assets.iconCommentBig, width: 20.w),
            if (count != null && count! > 0)
              Text(
                count?.toString() ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                ),
              )
                  .padding(horizontal: 4.w, vertical: 1.w)
                  .decorated(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(100),
                  )
                  .positioned(top: -8, right: -15),
          ],
        ),
      ],
    )
        .padding(vertical: 9.w, left: 14.w, right: 30.w)
        .gestures(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
        )
        .safeArea(top: showSafeArea, bottom: showSafeArea)
        .decorated(
          color: Colors.white,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -1),
                  ),
                ]
              : null,
        );
  }
}
