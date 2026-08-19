import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class CitySelectorWidget extends StatelessWidget {
  const CitySelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityStrategyController>();
    return Obx(
      () => InkWell(
        onTap: controller.showCitySelection,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryText,
              size: 15.w,
            ).padding(left: 12.w),
            Text(
              controller.currentCity?.name ?? '選擇城市'.tr,
              style: TextStyle(
                color: controller.currentCity != null
                    ? AppColors.primaryText
                    : AppColors.assistantText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ).padding(left: 8.w),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.assistantText,
              size: 20.w,
            ).padding(right: 12.w),
          ],
        ),
      ).height(40.w),
    );
  }
}
