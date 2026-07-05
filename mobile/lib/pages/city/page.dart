import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/search.dart';

class CityPage extends StatelessWidget with UserStoreMixin {
  const CityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CityController());
    return IScaffold(
      appBar: IAppBar(
        title: '城市'.tr,
        showBackButton: false,
      ),
      body: GestureDetector(
        onTap: () {
          // 点击城市页面其他区域时隐藏搜索悬浮框
          controller.hideSearchOverlay();
        },
        child: Obx(
          () => controller.titles.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    const CitySearchWidget(),
                    TabBar(
                      controller: controller.tabController,
                      tabs: controller.titles.map((e) => Tab(text: e)).toList(),
                      onTap: controller.onChangeTab,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.primaryText,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      automaticIndicatorColorAdjustment: false,
                      dividerHeight: 0,
                      labelPadding: EdgeInsets.only(right: 12.w),
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 14.sp,
                      ),
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                    )
                        .alignment(Alignment.centerLeft)
                        .padding(horizontal: 13.w)
                        .decorated(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.w),
                        )
                        .padding(top: 15.w),
                    PageView.builder(
                      controller: controller.pageController,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) => controller.pages[index],
                      itemCount: controller.pages.length,
                      onPageChanged: controller.onPageChanged,
                    ).expanded(),
                  ],
                ).padding(horizontal: 13.w),
        ),
      ),
      floatingActionButton: Obx(() => !(userInfo.isGuide && userInfo.isVip)
          ? const SizedBox.shrink()
          : FloatingActionButton(
              heroTag: 'city_fab',
              onPressed: controller.onPublishCity,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            )),
    );
  }
}
