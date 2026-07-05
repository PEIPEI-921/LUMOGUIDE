import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';

import 'status.dart';

class UserBookingGuideController extends GetxController
    with ApiMixin, RefreshableMixin {
  final _focusedDay = DateTime.now().obs;
  DateTime get focusedDay => _focusedDay.value;

  final _selectedDay = Rxn<DateTime>();
  DateTime? get selectedDay => _selectedDay.value;

  final _isAllMode = false.obs;
  bool get isAllMode => _isAllMode.value;

  // final _currentMode = CalendarMode.day.obs;
  // CalendarMode get currentMode => _currentMode.value;

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
      ApiUrl.userReserveGuide,
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
    final list = data.map((e) => UserReservationGuide.fromJson(e)).toList();
    endLoad(list);
  }

  onTapItem(UserReservationGuide item) async {
    final res = await Get.toNamed(
      AppRoutes.USER_BOOKING_GUIDE_INFO,
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

class UserBookingGuideWidget extends StatelessWidget {
  const UserBookingGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserBookingGuideController());

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
  final UserReservationGuide item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingGuideController>();

    return Column(
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
                StatusWidget(status: item.status),
              ],
            ),
            10.w.verticalSpace,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NetImageCached(
                  item.guide?.photo ?? '',
                  width: 77.w,
                  height: 100.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 8.w),
                12.w.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.guide?.name ?? '--',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: item.isGrey
                                ? AppColors.assistantText
                                : AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).flexible(),
                        8.w.horizontalSpace,
                        Text(
                              item.guide?.identityType ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.primary,
                              ),
                            )
                            .padding(horizontal: 8.w, vertical: 2.w)
                            .decorated(
                              borderRadius: BorderRadius.circular(12.w),
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                      ],
                    ),
                    12.w.verticalSpace,
                    Row(
                      children: [
                        Image.asset(Assets.iconLan, width: 14.w),
                        6.w.horizontalSpace,
                        Text(
                          '${'語言'.tr}：${item.guide?.language?.join(',') ?? ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: item.isGrey
                                ? AppColors.assistantText
                                : AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    6.w.verticalSpace,
                    Row(
                      children: [
                        Image.asset(Assets.iconAddress, width: 14.w),
                        6.w.horizontalSpace,
                        Text(
                          '${'所在地'.tr}：${item.guide?.cityName ?? ''}',
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
                    10.w.verticalSpace,
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
        )
        .padding(all: 10.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        )
        .gestures(
          onTap: () => controller.onTapItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
