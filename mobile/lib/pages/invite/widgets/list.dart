import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class InviteListWidget extends StatelessWidget {
  const InviteListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InviteController>();

    return Obx(
      () => Column(
        children: [
          Text(
            '我的邀請'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryText,
            ),
          ).padding(top: 15.w, bottom: 10.w),
          if (controller.inviteList.isEmpty)
            const EmptyWidget()
          else
            ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              itemBuilder: (context, index) {
                return _ItemWidget(item: controller.inviteList[index]);
              },
              separatorBuilder: (context, index) {
                return 5.w.verticalSpace;
              },
              itemCount: controller.inviteList.length,
            ).expanded()
        ],
      )
          .constrained(width: double.infinity, height: 350.h)
          .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          )
          .padding(horizontal: 32.w, top: 10.w),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({required this.item});
  final Invite item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleNetworkImage(imageUrl: item.inviteesAvatar, radius: 13.w),
        10.w.horizontalSpace,
        Text(
          item.inviteesNickname ?? '',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryText,
          ),
          maxLines: 1,
        ).expanded(),
        Text(
          item.createdAt ?? '',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    ).height(45.w).padding(horizontal: 10.w).decorated(
          color: AppColors.primaryText.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.w),
        );
  }
}
