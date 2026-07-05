import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class IntegralGoodsExchangeAddressWidget extends StatelessWidget {
  const IntegralGoodsExchangeAddressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralGoodsExchangeController>();

    return Obx(() => controller.goods?.goodsType == 2
        ? const SizedBox.shrink()
        : controller.address == null
            ? const _EmptyView()
            : Column(
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
                                    controller.address?.name ?? '',
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 14.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ).flexible(),
                                  10.w.horizontalSpace,
                                  Text(
                                    controller.address?.phone ?? '',
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                controller.address?.address ?? '',
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
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.assistantText,
                        size: 14.w,
                      ),
                    ],
                  ).padding(vertical: 20.w, horizontal: 10.w),
                  Image.asset(
                    Assets.iconDotted,
                    height: 2.w,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ],
              )
                .decorated(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.w),
                )
                .gestures(
                  onTap: controller.onSelectAddress,
                  behavior: HitTestBehavior.opaque,
                ));
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralGoodsExchangeController>();

    return Row(
      children: [
        Text(
          '請選擇收貨地址',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14.sp,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios,
          color: AppColors.assistantText,
          size: 14.w,
        ),
      ],
    )
        .padding(vertical: 20.w, horizontal: 10.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.w),
        )
        .gestures(
          onTap: controller.onSelectAddress,
          behavior: HitTestBehavior.opaque,
        );
  }
}
