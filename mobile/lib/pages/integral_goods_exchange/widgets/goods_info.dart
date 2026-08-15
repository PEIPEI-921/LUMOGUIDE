import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class GoodsInfoWidget extends StatelessWidget {
  const GoodsInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralGoodsExchangeController>();

    return controller.goods == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetImageCached(
                    controller.goods?.picture ?? '',
                    width: 84.w,
                    height: 84.w,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  10.w.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.goods?.name ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            (controller.goods?.price ?? 0).toString(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14.sp,
                            ),
                          ),
                          3.w.horizontalSpace,
                          Image.asset(
                            Assets.iconIntegral,
                            color: AppColors.primary,
                            width: 14.w,
                          ),
                          const Spacer(),
                          Text(
                            'x 1',
                            style: TextStyle(
                              color: AppColors.assistantText,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).padding(top: 4.w).expanded(),
                ],
              ).height(84.w),
              Divider(
                height: 30.w,
                thickness: 1,
                color: AppColors.primaryText.withValues(alpha: 0.1),
              ),
              Row(
                children: [
                  Text(
                    '郵費',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    controller.goods?.freeShipping ?? '',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          )
            .padding(all: 10.w)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.w),
            )
            .padding(top: 10.w);
  }
}
