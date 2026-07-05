import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class ExpressCard extends StatelessWidget {
  const ExpressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralExchangeOrderController>();
    final info = controller.orderInfo;
    if (info == null ||
        (info.expressDeliveryCompany == null &&
            info.expressDeliveryNumber == null)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '快遞名稱'.tr,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
            ),
            Text(
              info.expressDeliveryCompany ?? '',
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            ),
          ],
        ),
        12.w.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '快遞單號'.tr,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
            ),
            Row(
              children: [
                Text(
                  info.expressDeliveryNumber ?? '',
                  style:
                      TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
                ),
                8.w.horizontalSpace,
                Text(
                  '複製'.tr,
                  style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
                ).gestures(onTap: controller.copyExpressNo),
              ],
            )
          ],
        ),
      ],
    )
        .padding(horizontal: 10.w, vertical: 16.w)
        .decorated(
            color: Colors.white, borderRadius: BorderRadius.circular(10.w))
        .padding(top: 10.w, bottom: 10.w);
  }
}
