import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class MerchantInfoWidget extends StatelessWidget {
  const MerchantInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingMerchantController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '預約${controller.shopType.title}信息'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.assistantText,
          ),
        ),
        10.w.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetImageCached(
              controller.merchantInfo.pictures.isNotEmpty
                  ? controller.merchantInfo.pictures.first
                  : '',
              width: 125.w,
              height: 70.w,
              fit: BoxFit.cover,
            ).clipRRect(all: 8.w),
            12.w.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.merchantInfo.name ?? '--',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                8.w.verticalSpace,
                Row(
                  children: [
                    Image.asset(
                      Assets.iconTel2,
                      width: 14.w,
                    ),
                    6.w.horizontalSpace,
                    Text(
                      '${'電話'.tr}：${controller.merchantInfo.phone ?? ''}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                6.w.verticalSpace,
                Row(
                  children: [
                    Image.asset(
                      Assets.iconAddress,
                      width: 14.w,
                    ),
                    6.w.horizontalSpace,
                    Text(
                      '${'地址'.tr}：${controller.merchantInfo.address ?? ''}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).expanded(),
                  ],
                ).gestures(
                  onTap: () => openAddressMap(
                    name: controller.merchantInfo.name,
                    address: controller.merchantInfo.address,
                    latitude: controller.merchantInfo.latitude,
                    longitude: controller.merchantInfo.longitude,
                  ),
                  behavior: HitTestBehavior.opaque,
                ),
              ],
            ).expanded(),
          ],
        ),
      ],
    ).padding(all: 10.w).decorated(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(color: Colors.white),
        );
  }
}
