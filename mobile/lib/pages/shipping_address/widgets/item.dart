import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class ShippingAddressItemWidget extends StatelessWidget {
  const ShippingAddressItemWidget({super.key, required this.item});
  final ShippingAddress item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShippingAddressController>();

    return Column(
      children: [
        Row(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name ?? '',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ).flexible(),
                        10.w.horizontalSpace,
                        Text(
                          item.phone ?? '',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14.sp,
                          ),
                        ),
                        8.w.horizontalSpace,
                        if (item.isDefault == 1)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.5.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: Text(
                              '默認'.tr,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    8.w.verticalSpace,
                    Text(
                      item.address ?? '',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ).expanded(),
              ],
            ).expanded(),
            10.w.horizontalSpace,
            Row(
              children: [
                Image.asset(
                  Assets.iconAccountEdit,
                  width: 12.w,
                  color: AppColors.primaryText,
                ),
                4.w.horizontalSpace,
                Text(
                  '編輯'.tr,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ).padding(vertical: 5).gestures(
                  onTap: () {
                    controller.onEditAddress(item);
                  },
                  behavior: HitTestBehavior.opaque,
                ),
          ],
        ).padding(horizontal: 10.w, vertical: 14.w),
      ],
    )
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        )
        .gestures(
          onTap: () {
            controller.onSelectAddress(item);
          },
          behavior: HitTestBehavior.opaque,
        );
  }
}
