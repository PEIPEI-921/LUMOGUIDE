import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';
import 'package:lumotrip/common/index.dart';

class MineMenuWidget extends StatelessWidget {
  const MineMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的服务'.tr,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          10.w.verticalSpace,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisExtent: 80.w,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 10.w,
            ),
            padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 2.w),
            itemBuilder: (context, index) {
              return _Item(menu: controller.menus[index]);
            },
            itemCount: controller.menus.length,
          ).decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          ),
        ],
      ).padding(top: 20.w),
    );
  }
}

class _Item extends StatelessWidget with UserStoreMixin {
  const _Item({required this.menu});
  final MineMenu menu;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            5.w.verticalSpace,
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(menu.icon, width: 24.w, height: 24.w),
                if (controller.unReadCount(menu) > 0)
                  Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${controller.unReadCount(menu) > 99 ? '99' : controller.unReadCount(menu)}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ).positioned(top: -5.w, right: -5.w),
              ],
            ),
            10.w.verticalSpace,
            Text(
              menu.title,
              style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    ).gestures(
      onTap: () => controller.onMenuTap(menu),
      behavior: HitTestBehavior.opaque,
    );
  }
}
