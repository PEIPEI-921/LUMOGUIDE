import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class IntegralMallPage extends StatelessWidget {
  const IntegralMallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegralMallController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgMine),
      appBar: IAppBar(
        title: 'LuMoFun'.tr,
        actions: [
          TextButton(
            onPressed: controller.onLoMoFunTap,
            child: Text('LuMoFun'.tr),
          ),
        ],
      ),
      body: Obx(
        () => controller.titles.isEmpty
            ? const SizedBox.shrink()
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
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralMallController>();
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
                    : Colors.white,
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
