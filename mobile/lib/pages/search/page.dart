import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchPageController());
    return IScaffold(
      appBar: IAppBar(
        titleWidget: const SearchBarWidget(),
        titleSpacing: 0,
        leadingWidth: 40,
      ),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        children: [
          10.w.verticalSpace,
          _CustomTabBar(controller: controller),
          8.w.verticalSpace,
          controller.pages.isEmpty
              ? const SizedBox.shrink()
              : PageView.builder(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return controller.pages[index];
                  },
                  itemCount: controller.pages.length,
                ).expanded(),
        ],
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar({required this.controller});
  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.separated(
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      itemCount: controller.allTypes.length,
      itemBuilder: (context, index) => _CustomTabBarItem(
        controller: controller,
        e: controller.allTypes[index],
      ),
      separatorBuilder: (context, index) => 10.w.horizontalSpace,
      itemScrollController: controller.scrollController,
    ).constrained(width: double.infinity, height: 40.w);
  }
}

class _CustomTabBarItem extends StatelessWidget {
  const _CustomTabBarItem({required this.controller, required this.e});
  final SearchPageController controller;
  final CityDetailTab e;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () => controller.onChangeTab(e),
        borderRadius: BorderRadius.circular(10.w),
        child:
            Row(
                  children: [
                    Image.asset(e.homeIcon, width: 16.w, height: 16.w),
                    4.w.horizontalSpace,
                    Text(
                      e.homeTitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                )
                .padding(horizontal: 15.w, vertical: 6.w)
                .decorated(
                  color: e.homeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.w),
                  border: e == controller.selectedType
                      ? Border.all(color: e.homeColor)
                      : null,
                ),
      ),
    );
  }
}
