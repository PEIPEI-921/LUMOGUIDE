import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/address.dart';
import 'widgets/goods.dart';
import 'widgets/price.dart';
import 'widgets/order_info.dart';
import 'widgets/express.dart';
import 'widgets/status.dart';

class IntegralExchangeOrderPage extends StatelessWidget {
  const IntegralExchangeOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegralExchangeOrderController());
    return IScaffold(
      title: '訂單詳情'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(() {
        final info = controller.orderInfo;
        if (info == null) {
          return const SizedBox.shrink();
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
          children: const [
            StatusWidget(),
            AddressCard(),
            GoodsCard(),
            OrderInfoCard(),
            ExpressCard(),
          ],
        ).safeArea();
      }),
    );
  }
}
