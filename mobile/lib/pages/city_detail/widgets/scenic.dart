import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../index.dart';

class CityDetailScenicWidget extends StatelessWidget {
  const CityDetailScenicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();

    return EasyRefresh(
      header: const MaterialHeader(),
      onRefresh: () async {
        await controller
            .onCategoryTabChanged(controller.scenicCategoryIndex.value);
      },
      child: Obx(() {
        final list = controller.scenicList;
        if (list.isEmpty) {
          return const EmptyListWidget();
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          itemBuilder: (context, index) => _Item(list[index]),
          separatorBuilder: (context, index) => 10.verticalSpace,
          itemCount: list.length,
        );
      }),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item);

  final MerchantList item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NetImageCached(
          item.firstPicture ?? '',
          width: 100.w,
          height: 75.w,
          borderRadius: BorderRadius.circular(8.w),
        ),
        12.w.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            5.w.verticalSpace,
            Row(
              children: [
                Image.asset(
                  Assets.iconDial,
                  width: 12.w,
                  color: AppColors.assistantText,
                ),
                5.w.horizontalSpace,
                Text(
                  '${'開放時間'.tr}：${item.startTime ?? ''}',
                  style: TextStyle(
                    color: AppColors.assistantText,
                    fontSize: 12.sp,
                  ),
                ).expanded(),
              ],
            ),
            5.w.verticalSpace,
            Row(
              children: [
                Image.asset(
                  Assets.iconTicket,
                  width: 12.w,
                  color: AppColors.assistantText,
                ),
                5.w.horizontalSpace,
                Text(
                  '${'門票'.tr}：${item.ticketsFree ?? ''}',
                  style: TextStyle(
                    color: AppColors.assistantText,
                    fontSize: 12.sp,
                  ),
                ).expanded(),
                10.w.horizontalSpace,
                Image.asset(
                  Assets.iconComment,
                  width: 12.w,
                ),
                5.w.horizontalSpace,
                Text(
                  '${item.evaluateCount ?? 0}',
                  style: TextStyle(
                    color: AppColors.assistantText,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ).expanded(),
      ],
    )
        .padding(all: 10.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        )
        .gestures(
          onTap: () => controller.onTapScenicItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
