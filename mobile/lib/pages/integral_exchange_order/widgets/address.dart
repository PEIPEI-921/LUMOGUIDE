import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralExchangeOrderController>();
    final address = controller.orderInfo?.address;
    if (address == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  Assets.iconAddress,
                  width: 14.w,
                ).padding(top: 3.w),
                10.w.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.name ?? '',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ).flexible(),
                        10.w.horizontalSpace,
                        Text(
                          address.phone ?? '',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      address.address ?? '',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ).expanded(),
              ],
            ).expanded(),
          ],
        ).padding(vertical: 20.w, horizontal: 10.w),
      ],
    ).decorated(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4.w),
    );
  }
}
