import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class IntegralOrderItem extends StatelessWidget {
  const IntegralOrderItem({super.key, required this.item});
  final IntegralOrderList item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralExchangeRecordController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '兌換時間: @time'.trParams({'time': item.createdAt ?? ''}),
          style: TextStyle(
            color: AppColors.assistantText,
            fontSize: 12.sp,
          ),
        ),
        13.w.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetImageCached(item.goodsPicture ?? '', width: 84.w, height: 84.w),
            12.w.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item.goodsName ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14.sp,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      item.price.toString(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Image.asset(
                      Assets.iconIntegral,
                      color: AppColors.primary,
                      width: 14.w,
                    ).padding(left: 3.w),
                  ],
                ).padding(bottom: 10.w),
              ],
            ).expanded(),
          ],
        ).height(84.w)
      ],
    )
        .padding(horizontal: 10.w, vertical: 15.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
        )
        .gestures(
          onTap: () => controller.onTapItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
