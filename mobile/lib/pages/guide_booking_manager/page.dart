import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/calendar.dart';
import 'widgets/item.dart';

class GuideBookingManagerPage extends StatelessWidget {
  const GuideBookingManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuideBookingManagerController());
    return IScaffold(
      title: '預約我的'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        children: [
          const GuideBookingManagerCalendarWidget(),
          10.w.verticalSpace,
          IRefresh(
            controller: controller,
            child: Obx(
              () => controller.items.isEmpty
                  ? const EmptyListWidget()
                  : ListView.separated(
                      itemBuilder: (context, index) =>
                          GuideBookItemWidget(item: controller.items[index]),
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
