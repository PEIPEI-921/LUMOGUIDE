import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/my_integral/widgets/rule.dart';

class MyIntegralController extends GetxController
    with ApiMixin, RefreshableMixin {
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  onRule() async {
    Get.to(() => const IntegralRuleWidget());
  }

  onRecord() async {
    Get.toNamed(AppRoutes.INTEGRAL_EXCHANGE_RECORD);
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.integralUserDetails,
      parameters: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final records = data['list'] as List<dynamic>? ?? [];
    final integralRecords = records
        .map((e) => IntegralRecord.fromJson(e))
        .toList();
    endLoad(integralRecords);
  }
}
