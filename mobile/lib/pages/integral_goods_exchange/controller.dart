import 'dart:math';

import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class IntegralGoodsExchangeController extends GetxController
    with ApiMixin, UserStoreMixin {
  IntegralGoods? goods;

  final _address = Rxn<ShippingAddress>();
  ShippingAddress? get address => _address.value;

  String get remainingIntegral =>
      (max(0, (userInfo.integral ?? 0) - (goods?.price ?? 0))).toString();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      goods = Get.arguments['goods'] as IntegralGoods?;
    }

    _fetchAddress();
  }

  onSelectAddress() async {
    final res = await Get.toNamed(AppRoutes.SHIPPING_ADDRESS);
    if (res != null) {
      _address.value = res as ShippingAddress;
    }
  }

  Future<void> onSubmit() async {
    if (address == null && goods?.goodsType == 1) {
      await Loading.toast('請選擇收貨地址'.tr);
      return;
    }

    final flag = await AlertUtils.show(
      title: '確定要兌換麼？'.tr,
      cancelText: '取消'.tr,
      confirmText: '確定'.tr,
    );
    if (!flag) {
      return;
    }

    Loading.show();
    final res = await post(ApiUrl.integralExchange, data: {
      'goods_id': goods?.id,
      'address_id': address?.id,
    });
    Loading.dismiss();

    if (!res.isSuccess) {
      await AlertUtils.error(res.message);
      return;
    }
    reloadUserInfo();
    Get.offNamedUntil(
      AppRoutes.INTEGRAL_EXCHANGE_RESULT,
      (route) => route.isFirst,
      arguments: res.dataJson,
    );
  }
}

extension on IntegralGoodsExchangeController {
  _fetchAddress() async {
    if (goods?.goodsType == 2) {
      return;
    }
    final res = await get(ApiUrl.addressLists, parameters: {
      'page': 1,
      'limit': 1000,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      return;
    }
    final list = res.dataJson['list'] as List<dynamic>;
    final data = list.map((e) => ShippingAddress.fromJson(e)).toList();
    _address.value =
        data.firstWhereOrNull((e) => e.isDefault == 1) ?? data.firstOrNull;
  }
}
