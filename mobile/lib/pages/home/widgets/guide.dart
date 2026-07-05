import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../index.dart';
import 'section.dart';

class HomeCityGuideWidget extends StatelessWidget {
  const HomeCityGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => controller.home?.guide.isEmpty == true
          ? const SizedBox.shrink()
          : Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeSectionWidget(section: HomeSection.guide),
                    13.w.verticalSpace,
                    const _Category(),
                  ],
                ).padding(right: 14.w),
                14.w.verticalSpace,
                ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(right: 14.w),
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final guide = controller
                          .home!
                          .guide[controller.guideCategoryIndex.value]
                          .list[index];
                      return _Item(guide: guide);
                    });
                  },
                  separatorBuilder: (context, index) => 10.w.horizontalSpace,
                  itemCount: controller
                      .home!
                      .guide[controller.guideCategoryIndex.value]
                      .list
                      .length,
                ).height(217.w),
              ],
            ).padding(left: 14.w, top: 20.w),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final categories =
          controller.home?.guide.map((e) => e.name).toList() ?? [];
      return Row(
        children: [
          ...categories.map(
            (e) => Obx(
              () =>
                  Text(
                        e ?? '',
                        style: TextStyle(
                          color:
                              controller.guideCategoryIndex.value ==
                                  categories.indexOf(e)
                              ? Colors.white
                              : AppColors.primaryText.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                      )
                      .padding(horizontal: 10.w, vertical: 7.w)
                      .decorated(
                        color:
                            controller.guideCategoryIndex.value ==
                                categories.indexOf(e)
                            ? AppColors.primary
                            : AppColors.primaryText.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(100),
                      )
                      .gestures(
                        onTap: () => controller.guideCategoryIndex.value =
                            categories.indexOf(e),
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

class _Item extends StatelessWidget {
  const _Item({required this.guide});

  final GuideList guide;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
          children: [
            NetImageCached(
              guide.photo ?? '',
              width: 105.w,
              height: 135.w,
              fit: BoxFit.cover,
            ),
            Text(
              guide.name ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).padding(top: 5, horizontal: 2),
            Text(
                  guide.language?.firstOrNull ?? '',
                  style: TextStyle(color: AppColors.primary, fontSize: 11.sp),
                )
                .padding(horizontal: 10.w, vertical: 5.w)
                .decorated(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(100),
                )
                .padding(top: 3.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Assets.iconLocation, width: 11.w, height: 11.w),
                4.w.horizontalSpace,
                Text(
                  guide.cityName ?? '',
                  // '巴黎巴黎巴黎巴黎巴黎巴黎',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).flexible(),
              ],
            ).padding(top: 3.w, horizontal: 2),
          ],
        )
        .constrained(width: 105.w)
        .decorated(color: Colors.white)
        .clipRRect(all: 8.w)
        .gestures(
          onTap: () => controller.onTapGuideItem(guide),
          behavior: HitTestBehavior.opaque,
        );
  }
}
