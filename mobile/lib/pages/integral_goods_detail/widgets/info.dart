import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class IntegralGoodsInfoWidget extends StatelessWidget {
  const IntegralGoodsInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralGoodsDetailController>();

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  (controller.goods?.price ?? 0).toString(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                4.w.horizontalSpace,
                Image.asset(
                  Assets.iconIntegral,
                  color: AppColors.primary,
                  width: 14.w,
                ).padding(top: 4.w),
              ],
            ),
            Text(
              controller.goods?.name ?? '',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            10.w.verticalSpace,
            Row(
              children: [
                Row(
                  children: [
                    Text(
                      '運費：'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      controller.goods?.freeShipping ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ).expanded(flex: 1),
                Row(
                  children: [
                    Text(
                      '已兌換：'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      '${controller.goods?.sales ?? 0}${'件'.tr}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ).expanded(flex: 1),
              ],
            ),
            10.w.verticalSpace,
          ],
        )
            .padding(all: 10.w)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            )
            .padding(top: 10.w));
  }
}
