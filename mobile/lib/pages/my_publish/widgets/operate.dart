import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class OperateWidget extends StatelessWidget {
  const OperateWidget({
    super.key,
    this.onEdit,
    this.onDelete,
    this.canDelete = true,
  });
  final Function()? onEdit;
  final Function()? onDelete;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            .gestures(onTap: onEdit, behavior: HitTestBehavior.opaque)
            .expanded(),
        if (canDelete) ...[
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
              .gestures(onTap: onDelete, behavior: HitTestBehavior.opaque)
              .expanded(),
        ],
      ],
    ).height(40.w).backgroundColor(Colors.white.withValues(alpha: 0.6));
  }
}
