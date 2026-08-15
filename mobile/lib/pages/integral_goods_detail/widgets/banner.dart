import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class IntegralGoodsBannerWidget extends StatelessWidget {
  const IntegralGoodsBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralGoodsDetailController>();

    return Obx(() => controller.goods?.pictures.isEmpty ?? true
        ? const SizedBox.shrink()
        : Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 347.w,
                  autoPlay: (controller.goods?.pictures.length ?? 0) > 1,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    controller.onBannerChanged(index);
                  },
                ),
                items: (controller.goods?.pictures ?? [])
                    .map((imageUrl) => NetImageCached(
                          imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ))
                    .toList(),
              ),
              Text(
                '${controller.bannerIndex + 1}/${controller.goods?.pictures.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              )
                  .center()
                  .constrained(width: 38.w, height: 21.w)
                  .decorated(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(11.w),
                  )
                  .positioned(bottom: 10.w, right: 10.w),
            ],
          ).clipRRect(all: 8.w));
  }
}
