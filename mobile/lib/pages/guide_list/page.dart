import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class GuideListPage extends StatelessWidget {
  const GuideListPage(
      {super.key, required this.cityId, required this.categories});
  final int cityId;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        GuideListController(cityId: cityId, categories: categories),
        tag: cityId.toString());
    return Obx(() => Column(
          children: [
            if (controller.titles.isEmpty) ...[
              const EmptyWidget().center()
            ] else ...[
              _CustomTabBar(controller: controller),
              8.w.verticalSpace,
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  return controller.pages[index];
                },
                itemCount: controller.pages.length,
              ).expanded(),
            ]
          ],
        ).padding(horizontal: 14.w));
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar({required this.controller});
  final GuideListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          controller.titles.length,
          (index) => InkWell(
            onTap: () => controller.onChangeTab(index),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.w),
              decoration: BoxDecoration(
                color: controller.currentIndex == index
                    ? AppColors.primary
                    : AppColors.primaryText.withOpacity(0.08),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                controller.titles[index].tr,
                style: TextStyle(
                  color: controller.currentIndex == index
                      ? Colors.white
                      : AppColors.primaryText,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ).padding(left: index == 0 ? 0 : 10.w),
        ),
      ).scrollable(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
      ),
    ).width(double.infinity);
  }
}
