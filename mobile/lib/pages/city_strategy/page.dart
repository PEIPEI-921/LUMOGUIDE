import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/pages/city_strategy/widgets/city_selector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/city_selection_panel.dart';

class CityStrategyPage extends StatelessWidget {
  const CityStrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CityStrategyController());
    return IScaffold(
      appBar: IAppBar(
        title: '城市攻略'.tr,
        actions: const [
          CitySelectorWidget(),
        ],
      ),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(() => Stack(
            children: [
              Column(
                children: [
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
              Obx(
                () => controller.isCityPanelVisible
                    ? Positioned.fill(
                        child: GestureDetector(
                          onTap: controller.hideCitySelection,
                          child: Container(
                            color: Colors.white10.withOpacity(0.01),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 40.w,
                                  left: 0,
                                  right: 0,
                                  child: const CitySelectionPanel(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          )),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar({required this.controller});
  final CityStrategyController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.separated(
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      itemCount: controller.allTypes.length,
      itemBuilder: (context, index) => _CustomTabBarItem(
          controller: controller, e: controller.allTypes[index]),
      separatorBuilder: (context, index) => 10.w.horizontalSpace,
      itemScrollController: controller.scrollController,
    ).constrained(width: double.infinity, height: 40.w);
  }
}

class _CustomTabBarItem extends StatelessWidget {
  const _CustomTabBarItem({required this.controller, required this.e});
  final CityStrategyController controller;
  final CityDetailTab e;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () => controller.onChangeTab(e),
        borderRadius: BorderRadius.circular(10.w),
        child: Row(
          children: [
            Image.asset(
              e.homeIcon,
              width: 16.w,
              height: 16.w,
            ),
            4.w.horizontalSpace,
            Text(
              e.homeTitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ).padding(horizontal: 15.w, vertical: 6.w).decorated(
              color: e.homeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.w),
              border: e == controller.selectedType
                  ? Border.all(color: e.homeColor)
                  : null,
            ),
      ),
    );
  }
}
