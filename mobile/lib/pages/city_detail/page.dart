import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/banner.dart';
import 'widgets/tab.dart';

class CityDetailPage extends StatelessWidget {
  const CityDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CityDetailController());
    return IScaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8F8F9),
      backgroundImage: null,
      body: Obx(
        () => controller.cityInfo.id == null
            ? const SizedBox.shrink()
            : NestedScrollView(
                controller: controller.scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                      return [_CustomAppBar(controller: controller)];
                    },
                body: PageView.builder(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => controller.pages[index],
                  itemCount: controller.pages.length,
                ),
              ),
      ),
      floatingActionButton: Obx(
        () => !controller.showGuidePublishButton
            ? const SizedBox.shrink()
            : FloatingActionButton(
                heroTag: 'city_detail_fab',
                onPressed: controller.onPublishTap,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 20),
                    Text(
                      '發佈'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar({required this.controller});

  final CityDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SliverAppBar(
        expandedHeight: controller.expandedHeight,
        toolbarHeight: controller.toolbarHeight,
        pinned: true,
        foregroundColor: controller.showPinned ? Colors.black : Colors.white,
        leadingWidth: 150.w,
        leading:
            Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                    ).padding(right: 2.w),
                    Text(
                      '城市詳情'.tr,
                      style: TextStyle(
                        color: controller.showPinned
                            ? Colors.black
                            : Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                )
                .paddingOnly(left: 14.w)
                .gestures(
                  onTap: () => Get.back(),
                  behavior: HitTestBehavior.opaque,
                ),
        systemOverlayStyle: controller.showPinned
            ? customOverlayStyle
            : SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarColor: Colors.white,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
        flexibleSpace: Stack(
          children: [
            const CityDetailBannerWidget(),
            if (controller.showPinned) Container(color: Colors.white),
          ],
        ),
        bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  controller.tabHeight + controller.categoryTabHeight,
                ),
                child: Container(
                  color: const Color(0xFFF8F8F9),
                  child: Column(
                    children: [
                      const CityDetailTabWidget(),
                      if (controller.needsCategoryTabs)
                        const _CategoryTabsWidget(),
                    ],
                  ),
                ).clipRRect(topLeft: 15.w, topRight: 15.w),
              ),
      ),
    );
  }
}

class _CategoryTabsWidget extends StatelessWidget {
  const _CategoryTabsWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();
    return Obx(() {
      final tabs = controller.currentCategoryTabs;
      return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...tabs.asMap().entries.map(
                (e) => Obx(
                  () =>
                      Text(
                            e.value,
                            style: TextStyle(
                              color: controller.categoryTabIndex == e.key
                                  ? Colors.white
                                  : AppColors.primaryText.withOpacity(0.8),
                              fontSize: 12.sp,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .padding(horizontal: 10.w, vertical: 7.w)
                          .constrained(minWidth: 55.w)
                          .decorated(
                            color: controller.categoryTabIndex == e.key
                                ? AppColors.primary
                                : AppColors.primaryText.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(100),
                          )
                          .gestures(
                            onTap: () => controller.onCategoryTabChanged(e.key),
                            behavior: HitTestBehavior.opaque,
                          )
                          .padding(right: 5.w),
                ),
              ),
            ],
          )
          .scrollable(scrollDirection: Axis.horizontal)
          .alignment(Alignment.centerLeft)
          .padding(horizontal: 14.w)
          .height(controller.categoryTabHeight);
    });
  }
}

class _CategoryTabItem extends StatelessWidget {
  const _CategoryTabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? AppColors.primary : AppColors.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        if (isSelected)
          Container(
            width: 20.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(1.w),
            ),
          ).translate(offset: Offset(0, 2.w)),
      ],
    ).gestures(onTap: onTap).padding(right: 24.w);
  }
}
