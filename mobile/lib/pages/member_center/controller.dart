import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MemberCenterController extends GetxController
    with ApiMixin, UserStoreMixin, RefreshableMixin {
  bool get isGuide => userInfo.isGuide;

  // 选中的产品索引
  final selectedProductId = 0.obs;

  MemberProduct get selectedProduct =>
      products.firstWhere((e) => e.id == selectedProductId.value);

  // 产品数据列表
  final products = <MemberProduct>[].obs;

  final _ability = MemberAbility().obs;
  MemberAbility get ability => _ability.value;

  @override
  void onInit() {
    super.onInit();
    Loading.show();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    fetchVipAbility();
    isGuide ? fetchVipGuide() : fetchVipCompany();
  }

  // 选择产品
  void selectProduct(int index) {
    selectedProductId.value = index;
  }

  onSubscribeAgreement() async {
    Get.toNamed(
      AppRoutes.WEB,
      arguments: {
        'url': ConfigService.to.systemConfig.vipUserSubscribe,
        'title': 'VIP會員訂閲服務協議'.tr,
      },
    );
  }

  onMemberAgreement() async {
    Get.toNamed(
      AppRoutes.WEB,
      arguments: {
        'url': ConfigService.to.systemConfig.vipUserProtocol,
        'title': 'VIP會員服務協議'.tr,
      },
    );
  }

  onSubmit() async {
    final flag = await AlertUtils.show(
      title: '確定要立即訂閱麼？'.tr,
      cancelText: '取消'.tr,
      confirmText: '確定'.tr,
    );
    if (!flag) {
      return;
    }
    isGuide ? subscribeGuide() : subscribeCompany();
  }
}

extension on MemberCenterController {
  fetchVipAbility() async {
    final res = await get(ApiUrl.vipAbility);
    if (!res.isSuccess) {
      return;
    }
    _ability.value = MemberAbility.fromJson(res.dataJson);
  }

  fetchVipGuide() async {
    final res = await get(ApiUrl.vipGuide);
    Loading.dismiss();
    if (!res.isSuccess) {
      return;
    }
    products.value = res.dataList
        .map((e) => MemberProduct.fromJson(e))
        .toList();
    selectedProductId.value = products.firstOrNull?.id ?? 0;
  }

  fetchVipCompany() async {
    final res = await get(ApiUrl.vipCompany);
    Loading.dismiss();
    if (!res.isSuccess) {
      return;
    }
    products.value = res.dataList
        .map((e) => MemberProduct.fromJson(e))
        .toList();
    selectedProductId.value = products.firstOrNull?.id ?? 0;
  }

  subscribeGuide() async {
    Loading.show();
    final res = await post(
      ApiUrl.vipSubscribeGuide,
      data: {'id': selectedProductId.value},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    final clientSecret = res.dataJson['client_secret'] as String? ?? '';
    final orderSn = res.dataJson['order_sn'] as String? ?? '';
    if (clientSecret.isEmpty) {
      reloadUserInfo();
      await AlertUtils.success('訂閱成功'.tr);
      Get.back();
      return;
    }
    final payResult = await StripeService.to.createPaymentSheet(
      clientSecret,
      orderSn: orderSn,
    );

    if (payResult.isSuccess) {
      reloadUserInfo();
      await AlertUtils.success('訂閱成功'.tr);
      Get.back();
    } else {
      AlertUtils.error(payResult.message ?? '');
    }
  }

  subscribeCompany() async {
    Loading.show();
    final res = await post(
      ApiUrl.vipSubscribeCompany,
      data: {'id': selectedProductId.value},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    final clientSecret = res.dataJson['client_secret'] as String? ?? '';
    final orderSn = res.dataJson['order_sn'] as String? ?? '';
    if (clientSecret.isEmpty) {
      reloadUserInfo();
      await AlertUtils.success('訂閱成功'.tr);
      Get.back();
      return;
    }
    final payResult = await StripeService.to.createPaymentSheet(
      clientSecret,
      orderSn: orderSn,
    );

    if (payResult.isSuccess) {
      reloadUserInfo();
      await AlertUtils.success('訂閱成功'.tr);
      Get.back();
    } else {
      AlertUtils.error(payResult.message ?? '');
    }
  }
}
