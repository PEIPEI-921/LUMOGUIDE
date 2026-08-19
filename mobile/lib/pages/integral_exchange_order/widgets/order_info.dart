import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralExchangeOrderController>();
    final info = controller.orderInfo;
    if (info == null) return const SizedBox.shrink();

    Widget row(String left, Widget right) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left.tr,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
          right,
        ],
      ).padding(vertical: 8.w);
    }

    return Column(
      children: [
        row(
          '訂單編號',
          Row(
            children: [
              Text(
                info.orderSn ?? '',
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              ),
              8.w.horizontalSpace,
              Text(
                '複製'.tr,
                style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
              ).gestures(onTap: controller.copyOrderSn),
            ],
          ),
        ),
        row(
          '下單時間',
          Text(
            info.createdAt ?? '',
            style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
          ),
        ),
        row(
          '支付時間',
          Text(
            info.payTime ?? '',
            style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
          ),
        ),
      ],
    )
        .padding(horizontal: 10.w, vertical: 16.w)
        .decorated(
            color: Colors.white, borderRadius: BorderRadius.circular(10.w))
        .padding(top: 10.w);
  }
}
