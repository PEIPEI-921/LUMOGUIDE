import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class MyPublishPage extends StatelessWidget {
  const MyPublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyPublishController());
    return IScaffold(
      appBar: IAppBar(
        title: '我的發佈'.tr,
      ),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        children: [
          const _CustomTabBar(),
          12.w.verticalSpace,
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: (index) =>
                controller.onPageChanged(controller.types[index]),
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return controller.pages[index];
            },
            itemCount: controller.pages.length,
          ).expanded(),
        ],
      ).padding(horizontal: 14.w),
      floatingActionButton: FloatingActionButton(
        heroTag: 'my_publish_fab',
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyPublishController>();
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.types
            .map((e) => InkWell(
                  onTap: () => controller.onChangeTab(e),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.w),
                    decoration: BoxDecoration(
                      color: controller.currentType == e
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      e.title,
                      style: TextStyle(
                        color: controller.currentType == e
                            ? Colors.white
                            : AppColors.primaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    )
        .height(40.w)
        .padding(horizontal: 2.5.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        )
        .width(double.infinity);
  }
}
