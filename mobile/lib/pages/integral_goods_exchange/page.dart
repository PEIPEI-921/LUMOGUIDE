import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/address.dart';
import 'widgets/goods_info.dart';

class IntegralGoodsExchangePage extends StatelessWidget with UserStoreMixin {
  const IntegralGoodsExchangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegralGoodsExchangeController());
    return IScaffold(
      title: '確認訂單'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            children: const [
              IntegralGoodsExchangeAddressWidget(),
              GoodsInfoWidget(),
            ],
          ).expanded(),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '應付:',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14.sp,
                        ),
                      ),
                      4.w.horizontalSpace,
                      Text(
                        controller.goods?.price.toString() ?? '',
                        style: TextStyle(
                          color: const Color(0xFFFF9600),
                          fontSize: 14.sp,
                        ),
                      ),
                      2.w.horizontalSpace,
                      Image.asset(
                        Assets.iconIntegralYellow,
                        width: 12.w,
                      ),
                    ],
                  ),
                  4.w.verticalSpace,
                  Row(
                    children: [
                      Text(
                        '剩餘積分:',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11.sp,
                        ),
                      ),
                      4.w.horizontalSpace,
                      Text(
                        controller.remainingIntegral,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SubmitButton(
                title: '確認兌換'.tr,
                onPressed: controller.onSubmit,
              ).width(195.w),
            ],
          ).padding(all: 14.w).safeArea().decorated(color: Colors.white),
        ],
      ),
    );
  }
}
