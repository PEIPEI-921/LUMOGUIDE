import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralExchangeOrderController>();
    final info = controller.orderInfo;
    if (info == null) return const SizedBox.shrink();

    return Column(
      children: [
        10.w.verticalSpace,
        Image.asset(
          Assets.iconExchangeCheck,
          width: 40.w,
        ),
        16.w.verticalSpace,
        Text(
          info.statusStr ?? '',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16.sp,
          ),
        ),
        16.w.verticalSpace,
      ],
    );
  }
}
