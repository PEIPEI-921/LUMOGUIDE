import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class NewsPage extends StatelessWidget with UserStoreMixin {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewsController());
    return IScaffold(
      appBar: IAppBar(title: '資訊'.tr, showBackButton: false),
      body: Obx(
        () => controller.titles.isEmpty
            ? const EmptyWidget().center()
            : Column(
                children: [
                  const _CustomTabBar(),
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
                ],
              ).padding(horizontal: 14.w),
      ),
      floatingActionButton: Obx(
        () => !(userInfo.isGuide && userInfo.isVip)
            ? const SizedBox.shrink()
            : FloatingActionButton(
                heroTag: 'news_fab',
                onPressed: controller.onPublishNews,
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

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();
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
      ).scrollable(scrollDirection: Axis.horizontal, padding: EdgeInsets.zero),
    ).width(double.infinity);
  }
}
