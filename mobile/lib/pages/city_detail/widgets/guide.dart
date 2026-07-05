import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class CityDetailGuideWidget extends StatelessWidget {
  const CityDetailGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();

    return EasyRefresh(
      header: const MaterialHeader(),
      onRefresh: () async {
        await controller
            .onCategoryTabChanged(controller.guideCategoryIndex.value);
      },
      child: Obx(() {
        final list = controller.guideList;
        if (list.isEmpty) {
          return const EmptyListWidget();
        }
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 200.w,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.w,
          ),
          itemBuilder: (context, index) => _Item(list[index]),
        );
      }),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item);

  final GuideList item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();
    return Column(
      children: [
        NetImageCached(
          item.photo ?? '',
          width: 105.w,
          height: 135.w,
          fit: BoxFit.cover,
        ),
        Text(
          item.name ?? '',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ).padding(top: 5, horizontal: 2),
        Text(
          item.language?.firstOrNull ?? '',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11.sp,
          ),
        )
            .padding(horizontal: 10.w, vertical: 5.w)
            .decorated(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(100),
            )
            .padding(top: 3.w),
      ],
    )
        .constrained(width: 105.w)
        .decorated(color: Colors.white)
        .clipRRect(all: 8.w)
        .gestures(
          onTap: () => controller.onTapGuideItem(item.id ?? 0),
          behavior: HitTestBehavior.opaque,
        );
  }
}
