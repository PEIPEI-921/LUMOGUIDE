import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../index.dart';

class CityDetailTicketWidget extends StatelessWidget {
  const CityDetailTicketWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();
    return EasyRefresh(
      header: const MaterialHeader(),
      onRefresh: () async {
        await controller.onCategoryTabChanged(
          controller.ticketCategoryIndex.value,
        );
      },
      child: Obx(() {
        final list = controller.ticketList;
        if (list.isEmpty) {
          return const EmptyListWidget();
        }
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 180.w,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.w,
          ),
          itemBuilder: (context, index) => _TicketItem(list[index]),
          itemCount: list.length,
        );
      }),
    );
  }
}

class _TicketItem extends StatelessWidget {
  const _TicketItem(this.item);
  final MerchantList item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NetImageCached(
          item.firstPicture ?? '',
          width: double.infinity,
          height: 95.w,
          fit: BoxFit.cover,
        ),
        10.w.verticalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            5.w.verticalSpace,
            Row(
              children: [
                Image.asset(
                  Assets.iconTel,
                  width: 12.w,
                  color: AppColors.assistantText,
                ),
                4.w.horizontalSpace,
                Text(
                  '${'電話'.tr}：${item.phone ?? ''}',
                  style: TextStyle(
                    color: AppColors.assistantText,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).expanded(),
              ],
            ),
            2.w.verticalSpace,
            Row(
              children: [
                Image.asset(
                  Assets.iconComment,
                  width: 12.w,
                ),
                4.w.horizontalSpace,
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
        ).padding(horizontal: 8.w)
      ],
    ).decorated(color: Colors.white).clipRRect(all: 8.w).gestures(
          onTap: () => controller.onTapTicketItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
