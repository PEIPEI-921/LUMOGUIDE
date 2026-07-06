import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../index.dart';
import 'section.dart';

class HomeMerchantWidget extends StatelessWidget {
  const HomeMerchantWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final shops = controller.home?.shop ?? [];
      if (shops.isEmpty) return const SizedBox.shrink();

      // 预计算所有分类的最大内容量，用于占位防止页面跳动
      final hasAnyBanner = shops.any((s) => s.banner.isNotEmpty);
      final maxBannerCount = shops
          .map((s) => s.banner.length)
          .reduce((a, b) => a > b ? a : b);
      final maxListCount = shops
          .map((s) => s.list.length)
          .reduce((a, b) => a > b ? a : b);

      // 轮播区域固定高度：banner + 指示器圆点 + 底部间距
      final carouselHeight = hasAnyBanner
          ? 265.w + (maxBannerCount > 1 ? 22.w : 0) + 10.w
          : 0.0;

      // 网格区域固定高度：按最大行数预留
      final maxRows = (maxListCount / 2).ceil();
      final gridHeight = maxListCount > 0
          ? maxRows * 180.w + (maxRows - 1) * 10.w
          : 0.0;

      final currentBanners =
          shops[controller.merchantCategoryIndex.value].banner;
      final currentList =
          shops[controller.merchantCategoryIndex.value].list;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionWidget(section: HomeSection.merchant),
          13.w.verticalSpace,
          const _Category(),
          14.w.verticalSpace,
          // 轮播区域：始终占位，防止切换分类时高度跳动
          if (hasAnyBanner)
            SizedBox(
              height: carouselHeight,
              child: currentBanners.isNotEmpty
                  ? const _Carousel().padding(bottom: 10.w)
                  : null,
            ),
          // 网格区域：始终占位，防止切换分类时高度跳动
          if (maxListCount > 0)
            SizedBox(
              height: gridHeight,
              child: currentList.isNotEmpty ? const _GirdDataWidget() : null,
            ),
        ],
      ).padding(horizontal: 14.w, top: 20.w);
    });
  }
}

class _Category extends StatelessWidget {
  const _Category();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final categories =
          controller.home?.shop.map((e) => e.name).toList() ?? [];
      return Row(
        children: [
          ...categories.map(
            (e) => Obx(
              () =>
                  Text(
                        e ?? '',
                        style: TextStyle(
                          color:
                              controller.merchantCategoryIndex.value ==
                                  categories.indexOf(e)
                              ? Colors.white
                              : AppColors.primaryText.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                      )
                      .padding(horizontal: 10.w, vertical: 7.w)
                      .decorated(
                        color:
                            controller.merchantCategoryIndex.value ==
                                categories.indexOf(e)
                            ? AppColors.primary
                            : AppColors.primaryText.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(100),
                      )
                      .gestures(
                        onTap: () => controller.onMerchantCategoryTap(
                            categories.indexOf(e)),
                        behavior: HitTestBehavior.opaque,
                      )
                      .padding(right: 5.w),
            ),
          ),
        ],
      ).scrollable(scrollDirection: Axis.horizontal);
    });
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final items =
          controller
              .home
              ?.shop[controller.merchantCategoryIndex.value]
              .banner ??
          [];
      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 265.w,
              autoPlay: items.length > 1,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                controller.merchantCarouselIndex.value = index;
                controller.onMerchantBannerPageChanged(
                  index,
                  reason,
                  items.length,
                );
              },
            ),
            items: [...items.map((e) => _CarouselItem(banner: e))],
          ),
          if (items.length > 1) ...[
            10.w.verticalSpace,
            Wrap(
              spacing: 5,
              children: [
                ...items.asMap().entries.map(
                  (e) => Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: controller.merchantCarouselIndex.value == e.key
                          ? AppColors.primary
                          : AppColors.primaryText.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({required this.banner});
  final MerchantList banner;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetImageCached(
              banner.firstPicture ?? '',
              width: double.infinity,
              height: 195.w,
              fit: BoxFit.cover,
            ),
            10.w.verticalSpace,
            Text(
              banner.name ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).padding(horizontal: 10.w),
            4.w.verticalSpace,
            Row(
              children: [
                if (banner.phone.isNotEmpty) ...[
                  Row(
                    children: [
                      Image.asset(Assets.iconTel, width: 12.w, height: 12.w),
                      5.w.horizontalSpace,
                      Text(
                        '${'電話'.tr}: ${banner.phone ?? ''}',
                        style: TextStyle(
                          color: AppColors.primaryText.withOpacity(0.8),
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ).expanded(),
                  5.w.horizontalSpace,
                ],
                Row(
                  children: [
                    Image.asset(Assets.iconLocation, width: 12.w, height: 12.w),
                    5.w.horizontalSpace,
                    Text(
                      '${'城市'.tr}: ${banner.cityName ?? ''}',
                      style: TextStyle(
                        color: AppColors.primaryText.withOpacity(0.8),
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).expanded(),
                  ],
                ).expanded(),
              ],
            ).padding(horizontal: 10.w),
          ],
        )
        .decorated(color: Colors.white)
        .clipRRect(topLeft: 6.w, topRight: 6.w)
        .padding(horizontal: 2.w)
        .gestures(
          onTap: () => controller.onTapMerchantItem(banner),
          behavior: HitTestBehavior.opaque,
        );
  }
}

class _GirdDataWidget extends StatelessWidget {
  const _GirdDataWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Obx(
      () => GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 180.w,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.w,
        ),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount:
            controller
                .home
                ?.shop[controller.merchantCategoryIndex.value]
                .list
                .length ??
            0,
        itemBuilder: (context, index) => _GirdItem(
          shop: controller
              .home!
              .shop[controller.merchantCategoryIndex.value]
              .list[index],
        ),
      ),
    );
  }
}

class _GirdItem extends StatelessWidget {
  const _GirdItem({required this.shop});
  final MerchantList shop;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetImageCached(
              shop.firstPicture ?? '',
              width: double.infinity,
              height: 95.w,
              fit: BoxFit.cover,
            ),
            8.w.verticalSpace,
            Text(
              shop.name ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).padding(horizontal: 8.w),
            if (shop.phone.isNotEmpty) ...[
              Row(
                children: [
                  Image.asset(Assets.iconTel, width: 12.w, height: 12.w),
                  5.w.horizontalSpace,
                  Text(
                    '${'電話'.tr}: ${shop.phone ?? ''}',
                    style: TextStyle(
                      color: AppColors.primaryText.withOpacity(0.8),
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).expanded(),
                ],
              ).padding(top: 8.w, horizontal: 8.w),
            ],
            Row(
              children: [
                Image.asset(Assets.iconLocation, width: 12.w, height: 12.w),
                5.w.horizontalSpace,
                Text(
                  '${'城市'.tr}: ${shop.cityName ?? ''}',
                  style: TextStyle(
                    color: AppColors.primaryText.withOpacity(0.8),
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).expanded(),
              ],
            ).padding(top: 6.w, horizontal: 8.w),
          ],
        )
        .decorated(color: Colors.white)
        .clipRRect(topLeft: 6.w, topRight: 6.w)
        .gestures(
          onTap: () => controller.onTapMerchantItem(shop),
          behavior: HitTestBehavior.opaque,
        );
  }
}
