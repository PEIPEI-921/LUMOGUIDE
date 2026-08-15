import 'package:get/get.dart';

import '../../common/index.dart';

class IntegralExchangeResultController extends GetxController {
  /*
   * {
          "order_sn": "I2025082720272167938",
          "pay_time": "2025-08-27 20:27:21",
          "create_time": "2025-08-27 20:27:21"
        }
   */

  String orderSn = '';
  String payTime = '';
  String createTime = '';
  int? id;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final data = Get.arguments as Map<String, dynamic>;
      orderSn = data['order_sn'] ?? '';
      payTime = data['pay_time'] ?? '';
      createTime = data['create_time'] ?? '';
      id = data['id'] as int? ?? 0;
    }
  }

  onOrderDetail() async {
    Get.offNamed(AppRoutes.INTEGRAL_EXCHANGE_ORDER, arguments: {'id': id});
  }
}
