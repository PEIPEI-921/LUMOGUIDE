import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class IntegralExchangeRecordController extends GetxController
    with ApiMixin, RefreshableMixin<IntegralOrderList> {
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(ApiUrl.integralExchangeOrders, parameters: {
      'page': 1,
      'limit': 10,
    });
    if (!res.isSuccess) {
      return;
    }
    final list = res.dataJson['list'] as List<dynamic>;
    final data = list.map((e) => IntegralOrderList.fromJson(e)).toList();
    endLoad(data);
  }

  onTapItem(IntegralOrderList item) {
    Get.toNamed(AppRoutes.INTEGRAL_EXCHANGE_ORDER, arguments: {'id': item.id});
  }
}
