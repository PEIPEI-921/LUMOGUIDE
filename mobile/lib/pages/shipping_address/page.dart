import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/item.dart';

class ShippingAddressPage extends StatelessWidget {
  const ShippingAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShippingAddressController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgMine),
      title: '我的地址'.tr,
      body: Column(
        children: [
          IRefresh(
            controller: controller,
            child: Obx(() => controller.items.isEmpty ? EmptyListWidget(text: '暫無收貨地址'.tr) : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
              itemBuilder: (context, index) {
                return ShippingAddressItemWidget(item: controller.items[index]);
              },
              separatorBuilder: (context, index) {
                return 10.w.verticalSpace;
                },
                itemCount: controller.itemCount,
              ),
            ),
          ).expanded(),
          SubmitButton(
            title: '新增收貨地址'.tr,
            onPressed: controller.onAddAddress,
          ).padding(horizontal: 14.w, top: 20.w)
        ],
      ).safeArea(),
    );
  }
}
