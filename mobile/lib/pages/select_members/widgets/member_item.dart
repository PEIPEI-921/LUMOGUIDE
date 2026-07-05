import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class SelectMemberItem extends StatelessWidget {
  const SelectMemberItem({super.key, required this.user});

  final FollowUser user;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<SelectMembersController>();
      final selected = controller.isSelected(user);
      final canSelect = controller.canSelectMore || selected;
      return Row(
            children: [
              GestureDetector(
                onTap: canSelect ? () => controller.toggleSelect(user) : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.assistantText.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check, size: 14.w, color: Colors.white)
                      : null,
                ),
              ),
              12.w.horizontalSpace,
              CircleNetworkImage(imageUrl: user.userAvatar ?? '', radius: 24.w),
              12.w.horizontalSpace,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.userNickname ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (user.userCityName != null) ...[
                        Text(
                              user.userCityName ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            )
                            .padding(horizontal: 6.w, vertical: 2.w)
                            .decorated(
                              borderRadius: BorderRadius.circular(100),
                              color: AppColors.primary,
                            ),
                      ],
                      if (user.userIdentityTag != null) ...[
                        8.w.horizontalSpace,
                        Text(
                              user.userIdentityTag ?? '',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.sp,
                              ),
                            )
                            .padding(horizontal: 8.w, vertical: 2.w)
                            .decorated(
                              borderRadius: BorderRadius.circular(100),
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                      ],
                    ],
                  ).padding(top: 5.w),
                ],
              ).expanded(),
            ],
          )
          .padding(vertical: 10.w, horizontal: 10.w)
          .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          )
          .gestures(
            onTap: canSelect ? () => controller.toggleSelect(user) : null,
            behavior: HitTestBehavior.opaque,
          );
    });
  }
}
