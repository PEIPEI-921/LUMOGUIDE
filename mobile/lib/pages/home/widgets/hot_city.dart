import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';
import 'section.dart';

class HomeHotCityWidget extends StatelessWidget {
  const HomeHotCityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => controller.home?.city.isEmpty == true
          ? const SizedBox.shrink()
          : Column(
              children: [
                const HomeSectionWidget(section: HomeSection.city),
                13.w.verticalSpace,
                ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _SingleItem(city: controller.home!.city[0]);
                    }
                    int cityIndex1 = 1 + (index - 1) * 2;
                    int cityIndex2 = cityIndex1 + 1;
                    return _DoubleItem(
                      city1: controller.home!.city[cityIndex1],
                      city2: cityIndex2 < controller.home!.city.length
                          ? controller.home!.city[cityIndex2]
                          : null,
                    );
                  },
                  separatorBuilder: (context, index) => 5.w.horizontalSpace,
                  itemCount: controller.home?.city.isEmpty == true
                      ? 0
                      : (controller.home!.city.length + 2) ~/ 2,
                ).height(140.w),
              ],
            ).padding(horizontal: 14.w, top: 20.w),
    );
  }
}

class _SingleItem extends StatelessWidget {
  const _SingleItem({required this.city});

  final CityList city;

  @override
  Widget build(BuildContext context) {
    return _CityItem(city: city).constrained(width: 100.w);
  }
}

class _DoubleItem extends StatelessWidget {
  const _DoubleItem({required this.city1, this.city2});
  final CityList city1;
  final CityList? city2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CityItem(city: city1).expanded(flex: 1),
        if (city2 != null) 5.w.verticalSpace,
        city2 == null
            ? const SizedBox().expanded(flex: 1)
            : _CityItem(city: city2!).expanded(flex: 1),
      ],
    ).constrained(width: 100.w);
  }
}

class _CityItem extends StatelessWidget {
  const _CityItem({required this.city});
  final CityList city;

  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
            NetImageCached(
              city.firstPicture ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: Image.asset(
                Assets.iconEmpty,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      city.nameEn ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
                .padding(horizontal: 4.w, vertical: 2.w)
                .constrained(maxWidth: 80.w)
                .decorated(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(5.w),
                )
                .positioned(left: 5, top: 5),
          ],
        )
        .clipRRect(all: 6.w)
        .gestures(
          onTap: () {
            Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': city.id});
          },
          behavior: HitTestBehavior.opaque,
        );
  }
}
