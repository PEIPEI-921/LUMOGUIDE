import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class IntegralExchangeResultPage extends StatelessWidget {
  const IntegralExchangeResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegralExchangeResultController());
    return IScaffold(
      title: '',
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          10.w.verticalSpace,
          Image.asset(
            Assets.iconExchangeCheck,
            width: 40.w,
          ),
          16.w.verticalSpace,
          Text(
            '兌換成功，等待平台確認處理'.tr,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
            ),
          ),
          16.w.verticalSpace,
          Column(
            children: [
              Row(
                children: [
                  Text(
                    '訂單編號'.tr,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  10.w.horizontalSpace,
                  Text(
                    controller.orderSn,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14.sp,
                    ),
                  ).expanded(),
                ],
              ),
              10.w.verticalSpace,
              Row(
                children: [
                  Text(
                    '下單時間'.tr,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  10.w.horizontalSpace,
                  Text(
                    controller.createTime,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14.sp,
                    ),
                  ).expanded(),
                ],
              ),
              10.w.verticalSpace,
              Row(
                children: [
                  Text(
                    '支付時間'.tr,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  10.w.horizontalSpace,
                  Text(
                    controller.payTime,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14.sp,
                    ),
                  ).expanded(),
                ],
              ),
            ],
          ).padding(all: 10.w).decorated(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.w),
              ),
          20.w.verticalSpace,
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(
                      color: AppColors.assistantText,
                    ),
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  '返回'.tr,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14.sp,
                  ),
                ),
              ).expanded(),
              15.w.horizontalSpace,
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  side: const BorderSide(
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () {
                  controller.onOrderDetail();
                },
                child: Text(
                  '查看訂單'.tr,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                  ),
                ),
              ).expanded(),
            ],
          ),
        ],
      ).padding(horizontal: 15.w),
    );
  }
}
