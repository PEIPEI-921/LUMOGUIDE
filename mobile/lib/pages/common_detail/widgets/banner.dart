import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class CommonDetailBannerWidget extends StatelessWidget {
  const CommonDetailBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommonDetailController>();

    return Obx(() {
      final pictures = controller.merchantInfo.pictures;
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
              items: pictures
                  .asMap()
                  .entries
                  .map((e) => _BannerItem(
                        imageUrl: e.value,
                        index: e.key,
                        pictures: pictures,
                      ))
                  .toList(),
            ),
            if (pictures.length > 1)
              Positioned(
                bottom: 30.w,
                child: Obx(() => Wrap(
                      spacing: 5,
                      children: List.generate(
                        pictures.length,
                        (index) => Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: controller.bannerIndex == index
                                ? AppColors.primary
                                : AppColors.primaryText.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    )),
              ),
          ],
        );
    });
  }
}

class _BannerItem extends StatelessWidget {
  const _BannerItem({
    required this.imageUrl,
    required this.index,
    required this.pictures,
  });
  final String imageUrl;
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
      child: NetImageCached(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
