import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/item.dart';

class IntegralExchangeRecordPage extends StatelessWidget {
  const IntegralExchangeRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegralExchangeRecordController());
    return IScaffold(
      title: '兌換記錄'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: IRefresh(
        controller: controller,
        child: Obx(() => controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
                itemBuilder: (context, index) {
                  return IntegralOrderItem(item: controller.items[index]);
                },
                separatorBuilder: (context, index) => 10.verticalSpace,
                itemCount: controller.itemCount,
              )),
      ).safeArea(),
    );
  }
}
