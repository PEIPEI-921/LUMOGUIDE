import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class GoodsCard extends StatelessWidget {
  const GoodsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralExchangeOrderController>();
    final goods = controller.orderInfo?.goodsInfo;
    if (goods == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetImageCached(goods.picture ?? '', width: 84.w, height: 84.w),
            12.w.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goods.name ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14.sp,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      goods.price.toString(),
                      style: TextStyle(
                        color: AppColors.assistantText,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.w.horizontalSpace,
                    Text(
                      '積分'.tr,
                      style: TextStyle(
                        color: AppColors.assistantText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ).padding(bottom: 10.w),
              ],
            ).expanded(),
          ],
        ).height(84.w),
        Divider(color: AppColors.primaryText.withValues(alpha: 0.1)),
        const PriceRow(),
      ],
    )
        .padding(horizontal: 10.w, vertical: 15.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
        )
        .padding(top: 10.w);
  }
}
