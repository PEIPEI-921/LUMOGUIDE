import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class IntegralGoodsDetailController extends GetxController
    with ApiMixin, UserStoreMixin {
  int id = 0;

  final _goods = Rxn<IntegralGoods>();
  IntegralGoods? get goods => _goods.value;

  final _bannerIndex = 0.obs;
  int get bannerIndex => _bannerIndex.value;

  bool get canExchanged {
    return (userInfo.integral ?? 0) > (goods?.price ?? 0);
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      id = Get.arguments['id'] as int? ?? 0;
    }
    _fetchIntegralGoodsDetail();
  }

  void onBannerChanged(int index) {
    _bannerIndex.value = index;
  }

  Future<void> onExchange() async {
    Get.toNamed(AppRoutes.INTEGRAL_GOODS_EXCHANGE, arguments: {
      'goods': goods,
    });
  }
}

extension on IntegralGoodsDetailController {
  _fetchIntegralGoodsDetail() async {
    Loading.show();
    final res = await get(ApiUrl.integralGoodsInfo, parameters: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      await AlertUtils.error(res.message);
      Get.back();
      return;
    }
    final data = res.dataJson;
    _goods.value = IntegralGoods.fromJson(data);
  }
}
