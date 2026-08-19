import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class IntegralExchangeOrderController extends GetxController with ApiMixin {
  int id = 0;

  final _orderInfo = Rxn<IntegralOrderInfo>();
  IntegralOrderInfo? get orderInfo => _orderInfo.value;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      id = Get.arguments['id'] as int? ?? 0;
    }
    _fetchOrder();
  }

  _fetchOrder() async {
    Loading.show();
    final res = await get(ApiUrl.integralExchangeOrderInfo, parameters: {
      'id': id,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      await AlertUtils.error(res.message);
      Get.back();
      return;
    }
    final order = IntegralOrderInfo.fromJson(res.dataJson);
    _orderInfo.value = order;
  }

  void copyOrderSn() async {
    final text = orderInfo?.orderSn ?? '';
    if (text.isEmpty) return;
    text.copyToPasteboard();
    await Loading.success('複製成功'.tr);
  }

  void copyExpressNo() async {
    final text = orderInfo?.expressDeliveryNumber ?? '';
    if (text.isEmpty) return;
    text.copyToPasteboard();
    await Loading.success('複製成功'.tr);
  }
}
