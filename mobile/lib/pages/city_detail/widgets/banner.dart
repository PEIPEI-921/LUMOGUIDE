import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class CityDetailBannerWidget extends StatelessWidget {
  const CityDetailBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();
    return Obx(() {
      final pictures = controller.cityInfo.pictures;
      if (pictures.isEmpty) return const SizedBox.shrink();
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 235.w,
              autoPlay: pictures.length > 1,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                controller.onBannerChanged(index);
              },
            ),
            items: [
              ...pictures.asMap().entries.map(
                (e) => _BannerItem(
                  image: e.value,
                  index: e.key,
                  pictures: pictures,
                ),
              ),
            ],
          ),
          if (pictures.length > 1)
            Wrap(
              spacing: 5,
              children: [
                ...List.generate(
                  pictures.length,
                  (index) => Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: controller.bannerIndex == index
                          ? AppColors.primary
                          : AppColors.primaryText.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ).positioned(bottom: 30.w),
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        controller.cityInfo.name ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).constrained(maxWidth: 100.w),
                      if (controller.cityInfo.isCapital == 1)
                        Text(
                              '首都'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            )
                            .padding(all: 3.w)
                            .decorated(
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4.w),
                            )
                            .padding(left: 8.w),
                    ],
                  ),
                  Text(
                    controller.cityInfo.nameEn ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).constrained(maxWidth: 120.w),
                ],
              )
              .padding(horizontal: 14.w, vertical: 10.w)
              .constrained(minWidth: 170.w)
              .decorated(
                borderRadius: BorderRadius.circular(8.w),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.primary, Colors.transparent],
                ),
              )
              .positioned(left: 14.w, bottom: 80.w),
        ],
      );
    });
  }
}

class _BannerItem extends StatelessWidget {
  const _BannerItem({
    required this.image,
    required this.index,
    required this.pictures,
  });
  final String image;
  final int index;
  final List<String> pictures;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.PHOTO_VIEW,
          arguments: {'pictures': pictures, 'index': index},
        );
      },
      child: Stack(
        children: [
          NetImageCached(
            image,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}
