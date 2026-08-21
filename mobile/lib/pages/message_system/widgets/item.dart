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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题 + 日期时间（同行，标题左侧、时间右侧）
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  model.title ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).expanded(),
                if ((model.formatDate ?? '').isNotEmpty) ...[
                  8.w.horizontalSpace,
                  Text(
                    model.formatDate ?? '',
                    style: TextStyle(
                      color: AppColors.primaryText.withValues(alpha: 0.4),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ],
            ),
            10.w.verticalSpace,
            Text(
              (model.desc ?? '').replaceAll(RegExp(r'[（）]'), ''),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryText.withValues(alpha: 0.8),
              ),
            ),
            10.w.verticalSpace,
            Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.primaryText.withValues(alpha: 0.01),
            ),
            // Row(
            //   children: [
            //     Text(
            //       '查看詳情'.tr,
            //       style: TextStyle(
            //         color: AppColors.primaryText.withValues(alpha: 0.8),
            //         fontSize: 12.sp,
            //       ),
            //     ),
            //     const Spacer(),
            //     Icon(
            //       Icons.arrow_forward_ios,
            //       color: AppColors.primaryText.withValues(alpha: 0.6),
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
