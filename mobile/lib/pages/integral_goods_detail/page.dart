import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/pages/integral_goods_detail/widgets/banner.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/desc.dart';
import 'widgets/info.dart';

class IntegralGoodsDetailPage extends StatelessWidget with UserStoreMixin {
  const IntegralGoodsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegralGoodsDetailController());
    return IScaffold(
      title: '商品詳情'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(() {
        final goods = controller.goods;
        if (goods == null) return const SizedBox.shrink();
        return Column(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              children: const [
                IntegralGoodsBannerWidget(),
                IntegralGoodsInfoWidget(),
                IntegralGoodsDescWidget(),
              ],
            ).expanded(),
            SubmitButton(
              title: '立即兌換'.tr,
              onPressed: controller.onExchange,
              enabled: controller.canExchanged,
            ).padding(all: 14.w).safeArea().decorated(color: Colors.white),
          ],
        );
      }),
    );
  }
}
