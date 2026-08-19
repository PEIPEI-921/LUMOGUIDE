import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class MerchantListPage extends StatelessWidget {
  const MerchantListPage(
      {super.key,
      required this.type,
      required this.categories,
      required this.cityId});
  final CityDetailTab type;
  final List<Category> categories;
  final int cityId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        MerchantListController(
          type: type,
          categories: categories,
          cityId: cityId,
        ),
        tag: '${cityId}_$type');
    if (controller.pageController.initialPage != controller.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.pageController.jumpToPage(controller.currentIndex);
      });
    }
    return Obx(() => Column(
          children: [
            if (controller.titles.isEmpty) ...[
              const EmptyWidget().center()
            ] else ...[
              _CustomTabBar(
                key: ValueKey('${controller.type}_${controller.cityId}'),
                controller: controller,
              ),
              8.w.verticalSpace,
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                physics: const ClampingScrollPhysics(),
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
  const _CustomTabBar({super.key, required this.controller});
  final MerchantListController controller;

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
                    : AppColors.primaryText.withValues(alpha: 0.08),
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
