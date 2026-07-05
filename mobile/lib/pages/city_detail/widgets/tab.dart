import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class CityDetailTabWidget extends StatelessWidget {
  const CityDetailTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();
    final tabs = controller.tabs;
    return Obx(
      () =>
          Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  tabs.length,
                  (index) =>
                      Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              10.w.verticalSpace,
                              Image.asset(
                                controller.tabIndex == index
                                    ? tabs[index].iconActive
                                    : tabs[index].icon,
                                width: 16.w,
                                height: 16.w,
                              ),
                              4.w.verticalSpace,
                              Text(
                                tabs[index].title,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: controller.tabIndex == index
                                      ? AppColors.primary
                                      : AppColors.primaryText,
                                  height: 1,
                                ),
                              ),
                            ],
                          )
                          .padding(horizontal: 5.w)
                          .constrained(minWidth: 50.w, height: 65.w)
                          .decorated(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.w),
                            border: Border.all(
                              color: controller.tabIndex == index
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          )
                          .gestures(
                            onTap: () => controller.onChangeTab(index),
                            behavior: HitTestBehavior.opaque,
                          )
                          .padding(left: index == 0 ? 0 : 5.w),
                ),
              )
              .scrollable(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
              )
              .padding(horizontal: 14.w, top: 13.w, bottom: 5.w),
    );
  }
}
