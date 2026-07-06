import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';

import 'status.dart';

class UserBookingMerchantController extends GetxController
    with ApiMixin, RefreshableMixin {
  final _focusedDay = DateTime.now().obs;
  DateTime get focusedDay => _focusedDay.value;

  final _selectedDay = Rxn<DateTime>();
  DateTime? get selectedDay => _selectedDay.value;

  final _isAllMode = false.obs;
  bool get isAllMode => _isAllMode.value;

  final _startTime = Rxn<DateTime>();
  final _endTime = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _selectedDay.value = DateTime.now();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    String startTime = '';
    String endTime = '';

    if (_startTime.value != null && _endTime.value != null) {
      startTime = DateFormat('yyyy-MM-dd').format(_startTime.value!);
      endTime = DateFormat('yyyy-MM-dd').format(_endTime.value!);
    } else if (!isAllMode) {
      final day = selectedDay ?? DateTime.now();
      startTime = DateFormat('yyyy-MM-dd').format(day);
      endTime = startTime;
    }

    final res = await get(
      ApiUrl.userReserveCompany,
      parameters: {
        'page': page,
        'limit': limit,
        if (startTime.isNotEmpty) 'start_time': startTime,
        if (endTime.isNotEmpty) 'end_time': endTime,
      },
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    final list = data.map((e) => UserReservationMerchant.fromJson(e)).toList();
    // 按到达时间排序
    list.sort((a, b) {
      final aTime = a.arrivalTime ?? '';
      final bTime = b.arrivalTime ?? '';
      if (aTime.isEmpty && bTime.isEmpty) return 0;
      if (aTime.isEmpty) return 1;
      if (bTime.isEmpty) return -1;
      return aTime.compareTo(bTime);
    });
    endLoad(list);
  }

  onTapItem(UserReservationMerchant item) async {
    final res = await Get.toNamed(
      AppRoutes.USER_BOOKING_MERCHANT_INFO,
      arguments: {'id': item.id},
    );
    if (res == true) {
      onRefresh();
    }
  }

  onDateSelected(DateTime startDate, DateTime endDate, bool allMode) {
    _isAllMode.value = allMode;
    if (allMode) {
      _startTime.value = null;
      _endTime.value = null;
      _selectedDay.value = null;
      _focusedDay.value = DateTime.now();
    } else {
      _selectedDay.value = startDate;
      _focusedDay.value = startDate;
      _startTime.value = startDate;
      _endTime.value = endDate;
    }
    Loading.show();
    onRefresh();
  }
}

class UserBookingMerchantWidget extends StatelessWidget {
  const UserBookingMerchantWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserBookingMerchantController());

    return Column(
      children: [
        Obx(
          () => DatePickerCalendarWidget(
            selectedDate: controller.selectedDay ?? DateTime.now(),
            onDateSelected: controller.onDateSelected,
            isAllMode: controller.isAllMode,
          ),
        ),
        10.w.verticalSpace,
        IRefresh(
          controller: controller,
          child: Obx(
            () => controller.items.isEmpty
                ? const EmptyListWidget()
                : ListView.separated(
                    itemBuilder: (context, index) =>
                        _Item(item: controller.items[index]),
                    separatorBuilder: (context, index) => 10.w.verticalSpace,
                    itemCount: controller.items.length,
                  ),
          ),
        ).expanded(),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item});
  final UserReservationMerchant item;

  // 状态颜色：1=紫色(即将) / 2=浅绿(进行中) / 其他=灰色(已发生)
  Color get _statusColor {
    switch (item.status) {
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.jadeGreen;
      default:
        return AppColors.assistantText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingMerchantController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        border: Border(
          left: BorderSide(color: _statusColor, width: 3.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${'預約時間'.tr}: ${item.createdAt}',
                style: TextStyle(
                  color: AppColors.assistantText,
                  fontSize: 12.sp,
                ),
              ).expanded(),
              if (item.arrivalTime?.isNotEmpty == true)
                Text(
                  '${'到達'.tr}: ${item.arrivalTime}',
                  style: TextStyle(
                    color: AppColors.assistantText,
                    fontSize: 11.sp,
                  ),
                ),
              6.w.horizontalSpace,
              StatusWidget(status: item.status),
            ],
          ),
          10.w.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NetImageCached(
                item.content?.firstPicture ?? '',
                width: 125.w,
                height: 70.w,
                fit: BoxFit.cover,
              ).clipRRect(all: 8.w),
              12.w.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.content?.name ?? '--',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: item.isGrey
                          ? AppColors.assistantText
                          : AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.w.verticalSpace,
                  Row(
                    children: [
                      Image.asset(Assets.iconTel2, width: 14.w),
                      6.w.horizontalSpace,
                      Text(
                        '${'電話'.tr}：${item.content?.phone ?? ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: item.isGrey
                              ? AppColors.assistantText
                              : AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  6.w.verticalSpace,
                  Row(
                    children: [
                      Image.asset(Assets.iconAddress, width: 14.w),
                      6.w.horizontalSpace,
                      Text(
                        '${'地址'.tr}：${item.content?.address ?? ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: item.isGrey
                              ? AppColors.assistantText
                              : AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).expanded(),
                    ],
                  ),
                ],
              ).expanded(),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.w,
                color: AppColors.assistantText,
              ),
            ],
          ),
        ],
      ).padding(all: 10.w),
    ).gestures(
      onTap: () => controller.onTapItem(item),
      behavior: HitTestBehavior.opaque,
    );
  }
}
