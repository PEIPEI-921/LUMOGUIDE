import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class FollowPage extends StatelessWidget {
  const FollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FollowController());
    return IScaffold(
        title: controller.title,
        body: Obx(
          () => controller.titles.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  children: [
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
                        ),
                    PageView.builder(
                      controller: controller.pageController,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) => controller.pages[index],
                      itemCount: controller.pages.length,
                      onPageChanged: controller.onPageChanged,
                    ).expanded(),
                  ],
                ).padding(horizontal: 13.w),
        ));
  }
}
