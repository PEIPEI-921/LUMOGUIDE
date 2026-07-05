import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class UserBookingGuideInfoOperateWidget extends StatelessWidget {
  const UserBookingGuideInfoOperateWidget({super.key});

  Widget _buildButton({
    String? icon,
    required String text,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text.tr,
              style: TextStyle(
                color: color ?? AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
          ],
        )
        .height(double.infinity)
        .gestures(onTap: onTap, behavior: HitTestBehavior.opaque)
        .expanded();
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20.w,
      color: AppColors.assistantText.withOpacity(0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingGuideInfoController>();

    return Obx(() {
      final canEdit = controller.canEdit;
      final canCancel = controller.canCancel;
      final canDelete = controller.canDelete;

      final buttons = <Widget>[];

      if (canEdit) {
        buttons.add(
          _buildButton(
            icon: Assets.iconPublishEdit,
            text: '編輯',
            onTap: controller.onEdit,
            color: AppColors.primaryText,
          ),
        );
        if (canCancel || canDelete) {
          buttons.add(_buildDivider());
        }
      }

      if (canCancel) {
        buttons.add(
          _buildButton(
            text: '取消',
            onTap: controller.onCancel,
            color: AppColors.primaryText,
          ),
        );
        if (canDelete) {
          buttons.add(_buildDivider());
        }
      }

      if (canDelete) {
        buttons.add(
          _buildButton(
            icon: Assets.iconPublishDelete,
            text: '刪除'.tr,
            onTap: controller.onDeleteReservation,
            color: AppColors.red,
          ),
        );
      }

      if (buttons.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(children: buttons)
          .height(40.w)
          .backgroundColor(Colors.white.withOpacity(0.6))
          .padding(horizontal: 14.w);
    });
  }
}
