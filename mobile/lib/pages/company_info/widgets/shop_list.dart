import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'shop_item.dart';

class ShopListWidget extends StatelessWidget {
  const ShopListWidget({super.key, required this.shops});

  final List<MerchantShop> shops;

  @override
  Widget build(BuildContext context) {
    if (shops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Text(
            '店鋪列表'.tr,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        8.w.verticalSpace,
        ...shops.map((shop) => ShopItemWidget(shop: shop)),
      ],
    );
  }
}
