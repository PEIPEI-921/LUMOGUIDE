import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class UserBookingManagerPage extends StatelessWidget {
  const UserBookingManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserBookingManagerController());
    return IScaffold(
      appBar: IAppBar(title: '我的預約'.tr, titleWidget: const _CustomTabBar()),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        children: [
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
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingManagerController>();
    return Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: controller.types
                .map(
                  (e) => InkWell(
                    onTap: () => controller.onChangeTab(e),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 6.w,
                      ),
                      decoration: BoxDecoration(
                        color: controller.currentType == e
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
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
                  ).expanded(),
                )
                .toList(),
          ),
        )
        .height(35.w)
        .padding(horizontal: 2.5.w, vertical: 2.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        )
        .width(200.w);
  }
}
