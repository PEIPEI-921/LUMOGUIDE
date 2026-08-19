import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

/// 头像区最大宽度占屏宽比例，超出后横向滚动，保证搜索框始终可用
const double _avatarAreaMaxWidthFraction = 0.4;

class SelectedHeader extends StatelessWidget {
  const SelectedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelectMembersController>();
    final maxAvatarWidth =
        MediaQuery.of(context).size.width * _avatarAreaMaxWidthFraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.assistantText.withValues(alpha: 0.2),
              ),
              bottom: BorderSide(
                color: AppColors.assistantText.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 22.w, color: AppColors.assistantText),
              8.w.horizontalSpace,
              Obx(() {
                if (controller.selected.isEmpty) return const SizedBox.shrink();
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxAvatarWidth),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: controller.selected
                          .map(
                            (user) => Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: GestureDetector(
                                onTap: () => controller.removeSelected(user),
                                behavior: HitTestBehavior.opaque,
                                child: CircleNetworkImage(
                                  imageUrl: user.userAvatar ?? '',
                                  radius: 15.w,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              }),
              8.w.horizontalSpace,
              Expanded(
                child: TextField(
                  controller: controller.searchTc,
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '搜索'.tr,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.assistantText,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.w),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          '只有关注的您的人才可以被邀请'.tr,
          style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
        ).padding(horizontal: 14.w, vertical: 6.w),
      ],
    );
  }
}
