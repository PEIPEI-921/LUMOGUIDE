import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class PriceRow extends StatelessWidget {
  const PriceRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralExchangeOrderController>();
    final info = controller.orderInfo;
    if (info == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '運費'.tr,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
            Text(
              '¥ 0.00',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
          ],
        ).padding(vertical: 16.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '需付款/實付款'.tr,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
            Row(
              children: [
                Text(
                  info.price?.toString() ?? '',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                  ),
                ),
                4.w.horizontalSpace,
                Image.asset(
                  Assets.iconIntegral,
                  color: AppColors.primary,
                  width: 14.w,
                ),
              ],
            ),
          ],
        ),
      ],
    ).padding(horizontal: 10.w);
  }
}
