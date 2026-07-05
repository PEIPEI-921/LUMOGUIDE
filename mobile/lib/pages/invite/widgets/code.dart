import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class InviteCodeWidget extends StatelessWidget with UserStoreMixin {
  const InviteCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InviteController>();

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                10.w.verticalSpace,
                Text(
                  userInfo.inviterCode ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                          '複製'.tr,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                          ),
                        )
                        .padding(horizontal: 15.w, vertical: 5.w)
                        .gestures(
                          onTap: controller.onCopyInviteCode,
                          behavior: HitTestBehavior.opaque,
                        ),
                    Text(
                          '分享'.tr,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                          ),
                        )
                        .padding(horizontal: 15.w, vertical: 5.w)
                        .gestures(
                          onTap: controller.shareInviteCard,
                          behavior: HitTestBehavior.opaque,
                        ),
                  ],
                ),
              ],
            )
            .constrained(width: double.infinity, height: 100.w)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            )
            .padding(horizontal: 32.w),
        Text(
              '我的邀請碼'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            )
            .padding(horizontal: 30.w, vertical: 5.w)
            .decorated(
              color: const Color(0xFFF63338),
              borderRadius: BorderRadius.circular(100),
            )
            .positioned(top: -15.w),
      ],
    ).padding(top: 180.w);
  }
}
