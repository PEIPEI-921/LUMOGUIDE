import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class CityDetailOverviewWidget extends StatelessWidget {
  const CityDetailOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();

    return Obx(
      () => EasyRefresh(
        header: const MaterialHeader(),
        onRefresh: () async {
          await controller.fetchCityDetail();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopView(),
            20.w.verticalSpace,
            SectionTitleWidget(title: '城市概覽'.tr),
            Text(
              controller.cityInfo.overview ?? '',
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            ),
            10.w.verticalSpace,
            SectionTitleWidget(title: '城市歷史'.tr),
            Text(
              controller.cityInfo.history ?? '',
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            ),
            10.verticalSpace,
          ],
        ).padding(horizontal: 14.w, top: 5.w).scrollable(),
      ),
    );
  }
}

class _TopView extends StatelessWidget {
  const _TopView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...CityDetailOverviewType.values.map(
          (e) =>
              Obx(() => _TopViewItem(type: e, value: controller.briefValue(e))),
        ),
      ],
    ).height(102.w).decorated(color: Colors.white);
  }
}

class _TopViewItem extends StatelessWidget {
  const _TopViewItem({required this.type, required this.value});

  final CityDetailOverviewType type;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        5.w.verticalSpace,
        Image.asset(type.icon, width: 20.w, height: 20.w),
        Text(
          type.title,
          style: TextStyle(
            color: AppColors.primaryText.withValues(alpha: 0.5),
            fontSize: 12.sp,
          ),
          textAlign: TextAlign.center,
        ).padding(vertical: 5.w),
        Text(
          value,
          style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
          textAlign: TextAlign.center,
        ),
      ],
    ).expanded(flex: 1);
  }
}
