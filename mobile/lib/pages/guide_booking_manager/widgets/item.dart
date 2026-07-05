import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class GuideBookItemWidget extends StatelessWidget {
  const GuideBookItemWidget({super.key, required this.item});
  final GuideReservation item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingManagerController>();

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
                  children: [
                    Row(
                      children: [
                        if (item.isRead == 0)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(right: 4.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          '${'預約時間'.tr}: ${item.createdAt}',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12.sp,
                          ),
                        ).expanded(),
                        _StatusWidget(status: item.status),
                      ],
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      color: AppColors.primaryText.withOpacity(0.05),
                    ),
                    _BookingDetailsGrid(item: item),
                  ],
                )
                .padding(all: 10.w)
                .decorated(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w),
                ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NetImageCached(
                  item.user?.avatar ?? '',
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 20.w),
                8.w.horizontalSpace,
                Text(
                  item.user?.nickname ?? item.contact ?? '--',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ).padding(all: 10.w),
          ],
        )
        .decorated(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(8.w),
        )
        .gestures(
          onTap: () => controller.onTapItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}

class _BookingDetailsGrid extends StatelessWidget {
  const _BookingDetailsGrid({required this.item});
  final GuideReservation item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GridItem(
              label: '預約城市'.tr,
              value: item.cityName ?? '',
              isGrey: item.isGrey,
            ).expanded(flex: 3),
            5.w.horizontalSpace,
            _GridItem(
              label: '預計到達時間'.tr,
              value: item.arrivalTime ?? '',
              isGrey: item.isGrey,
            ).expanded(flex: 5),
            5.w.horizontalSpace,
            _GridItem(
              label: '人數'.tr,
              value: item.number ?? '',
              isGrey: item.isGrey,
            ).expanded(flex: 2),
          ],
        ),
      ],
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem({
    required this.label,
    required this.value,
    this.isGrey = false,
  });

  final String label;
  final String value;
  final bool isGrey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        4.w.verticalSpace,
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: 14.sp,
            color: isGrey ? AppColors.assistantText : AppColors.primaryText,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({this.status});
  final int? status;

  /// 1新預約/2已确认/3已完成
  String get statusText {
    switch (status) {
      case 1:
        return '新預約'.tr;
      case 2:
        return '已確認'.tr;
      case 3:
        return '已完成'.tr;
      case 4:
        return '已取消';
      case 5:
        return '已拒絕';
      case 6:
        return '已過期';
      default:
        return '';
    }
  }

  Color get statusColor {
    switch (status) {
      case 1:
        return AppColors.primary;
      case 2:
        return const Color(0xFF00D6C4);
      case 3:
        return AppColors.primaryText;
      case 4:
        return AppColors.assistantText;
      case 5:
        return const Color(0xFFDD0000);
      case 6:
        return AppColors.assistantText;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusText.isEmpty) return const SizedBox.shrink();
    return Text(
          statusText,
          style: TextStyle(color: statusColor, fontSize: 10.sp),
        )
        .padding(horizontal: 8.w, vertical: 5.w)
        .decorated(
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: statusColor, width: 1.w),
        );
  }
}
