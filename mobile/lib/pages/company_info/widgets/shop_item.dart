import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class ShopItemWidget extends StatelessWidget {
  const ShopItemWidget({super.key, required this.shop});

  final MerchantShop shop;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanyInfoController>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShopImage(shop: shop),
          _ShopInfo(shop: shop),
        ],
      ),
    ).gestures(
      onTap: () => controller.onTapShop(shop),
      behavior: HitTestBehavior.opaque,
    );
  }
}

class _ShopImage extends StatelessWidget {
  const _ShopImage({required this.shop});

  final MerchantShop shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.w,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.w),
          topRight: Radius.circular(8.w),
        ),
      ),
      child: shop.firstPicture != null && shop.firstPicture!.isNotEmpty
          ? NetImageCached(
              shop.firstPicture!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.w),
                topRight: Radius.circular(8.w),
              ),
            )
          : Center(
              child: Icon(
                Icons.store,
                size: 40.w,
                color: AppColors.assistantText.withOpacity(0.5),
              ),
            ),
    );
  }
}

class _ShopInfo extends StatelessWidget {
  const _ShopInfo({required this.shop});

  final MerchantShop shop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                shop.name ?? '',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).expanded(),
              Text(
                    shop.type ?? '',
                    style: TextStyle(
                      color: const Color(0xFFFF8A00),
                      fontSize: 11.sp,
                    ),
                  )
                  .padding(horizontal: 10.w, vertical: 4.w)
                  .decorated(
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(
                      color: const Color(0xFFFF8A00),
                      width: 1.w,
                    ),
                  ),
            ],
          ),
          8.w.verticalSpace,
          if (shop.phone.isNotEmpty) ...[
            Row(
              children: [
                Image.asset(
                  Assets.iconTel,
                  width: 12.w,
                  color: AppColors.assistantText,
                ),
                4.w.horizontalSpace,
                Text(
                  '${'電話'.tr}：${shop.phone ?? ''}',
                  style: TextStyle(
                    color: AppColors.assistantText,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).expanded(),
              ],
            ),
            2.w.verticalSpace,
          ],
          Row(
            children: [
              Image.asset(
                Assets.iconLocation,
                width: 12.w,
                color: AppColors.assistantText,
              ),
              4.w.horizontalSpace,
              Text(
                '${'地址'.tr}：${shop.address ?? ''}',
                style: TextStyle(
                  color: AppColors.assistantText,
                  fontSize: 12.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).expanded(),
            ],
          ).gestures(
            onTap: () => openAddressMap(
              name: shop.name,
              address: shop.address,
              latitude: shop.latitude,
              longitude: shop.longitude,
            ),
            behavior: HitTestBehavior.opaque,
          ),
        ],
      ),
    );
  }
}
