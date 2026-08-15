import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MemberCenterProductsWidget extends StatelessWidget {
  const MemberCenterProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberCenterController>();

    return Obx(() => Column(
          children: [
            10.w.verticalSpace,
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: controller.isGuide ? 2 : 3,
                mainAxisExtent: controller.isGuide ? 105.w : 90.w,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.w,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) =>
                  _Item(controller.products[index]),
            ),
          ],
        ).padding(horizontal: 14.w));
  }
}

class _Item extends StatelessWidget {
  const _Item(this.product);
  final MemberProduct product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberCenterController>();

    return Obx(() {
      if (controller.products.isEmpty) {
        return Container();
      }

      final isSelected = controller.selectedProductId.value == product.id;
      final isIntegral = product.buyType == 2; // 2=积分购买
      final isMonth = product.timeType == 1; // 1=月

      return Stack(
        children: [
          Column(
            children: [
              Text(
                product.name ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected ? selectedColor : AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ).padding(top: 20.w),
              _buildPrice(product, isIntegral, isSelected),
              if (isIntegral) _buildIntegralBalance(),
            ],
          ).decorated(
            color: isSelected ? selectedColor.withValues(alpha: 0.03) : Colors.white,
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(
              color: isSelected
                  ? selectedColor
                  : AppColors.primaryText.withValues(alpha: 0.1),
              width: isSelected ? 3 : 2,
            ),
          ),
          _buildTag(isMonth, isSelected),
        ],
      ).gestures(
        onTap: () => controller.selectProduct(product.id ?? 0),
        behavior: HitTestBehavior.opaque,
      );
    });
  }

  Widget _buildTag(bool isMonth, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : const Color(0xFFEAECFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.w),
          bottomRight: Radius.circular(8.w),
        ),
      ),
      child: Text(
        isMonth ? '月'.tr : '年'.tr,
        style: TextStyle(
          fontSize: 11.sp,
          color: isSelected ? Colors.white : AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildPrice(MemberProduct product, bool isIntegral, bool isSelected) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isIntegral)
          Image.asset(
            Assets.iconIntegral,
            width: 13.w,
            height: 13.w,
            color: isSelected ? selectedColor : AppColors.primaryText,
          ).padding(bottom: 2.w)
        else
          Text(
            product.icon ?? '',
            style: TextStyle(
              fontSize: 11.sp,
              color: isSelected ? selectedColor : AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        4.w.horizontalSpace,
        Text(
          product.price ?? '0',
          style: TextStyle(
            fontSize: 20.sp,
            color: isSelected ? selectedColor : AppColors.primaryText,
            fontWeight: FontWeight.w700,
            fontFamily: 'Bebas',
          ),
        ).translate(offset: Offset(0, 5.w)),
        2.w.horizontalSpace,
        Text(
          '/${product.timeTypeStr ?? ''}',
          style: TextStyle(
            fontSize: 10.sp,
            color: isSelected ? selectedColor : AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildIntegralBalance() {
    final controller = Get.find<MemberCenterController>();
    return Text(
      '${'我的積分'.tr}: ${controller.userInfo.integral ?? 0}',
      style: TextStyle(
        fontSize: 11.sp,
        color: AppColors.assistantText,
      ),
    ).padding(top: 6.w);
  }
}

Color get selectedColor {
  return UserStore.to.profile.isGuide
      ? AppColors.primary
      : const Color(0xFFFF9000);
}
