import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MessageSystemItemWidget extends StatelessWidget {
  const MessageSystemItemWidget({super.key, required this.model});
  final MessageSystemModel model;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageSystemController>();

    return Column(
      children: [
        Text(
          model.formatDate ?? '',
          style: TextStyle(
            color: AppColors.primaryText.withOpacity(0.6),
            fontSize: 12.sp,
          ),
        ).padding(bottom: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.title ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            10.w.verticalSpace,
            Text(
              model.desc ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryText.withOpacity(0.8),
              ),
            ),
            10.w.verticalSpace,
            Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.primaryText.withOpacity(0.01),
            ),
            // Row(
            //   children: [
            //     Text(
            //       '查看詳情'.tr,
            //       style: TextStyle(
            //         color: AppColors.primaryText.withOpacity(0.8),
            //         fontSize: 12.sp,
            //       ),
            //     ),
            //     const Spacer(),
            //     Icon(
            //       Icons.arrow_forward_ios,
            //       color: AppColors.primaryText.withOpacity(0.6),
            //       size: 14,
            //     ),
            //   ],
            // ).height(35.w)
          ],
        ).padding(horizontal: 14.w, top: 10.w).decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.w),
            )
      ],
    ).gestures(
      onTap: () => controller.onTapItem(model),
      behavior: HitTestBehavior.opaque,
    );
  }
}
