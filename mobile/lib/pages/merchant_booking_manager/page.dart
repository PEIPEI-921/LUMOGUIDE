import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/item.dart';

class MerchantBookingManagerPage extends StatelessWidget {
  const MerchantBookingManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantBookingManagerController());
    return IScaffold(
      title: '預約我的'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
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
                          MerchantBookItemWidget(item: controller.items[index]),
                      separatorBuilder: (context, index) => 10.w.verticalSpace,
                      itemCount: controller.items.length,
                    ),
            ),
          ).expanded(),
        ],
      ).padding(horizontal: 14.w),
    );
  }
}
