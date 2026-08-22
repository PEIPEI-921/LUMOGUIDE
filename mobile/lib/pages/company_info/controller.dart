import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class CompanyInfoController extends GetxController
    with ApiMixin, RefreshableMixin {
  final _companyInfo = Rxn<CompanyInfo>();
  CompanyInfo? get companyInfo => _companyInfo.value;

  int id = 0;

  @override
  onInit() {
    super.onInit();
    if (Get.arguments != null) {
      id = Get.arguments['id'] as int? ?? 0;
    }
    initRefresh();
  }

  @override
  void onReady() {
    super.onReady();
    Loading.show();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(ApiUrl.companyInfo, parameters: {'company_id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    _companyInfo.value = CompanyInfo.fromJson(res.dataJson);
    endLoad([]);
  }

  onTapShop(MerchantShop shop) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': shop.id,
        'city_id': shop.cityId,
        'type_id': shop.typeId,
      },
    );
  }

  /// 联系企业：创建单聊并进入聊天页
  Future<void> onSendMessage() async {
    if (!ChatStore.to.isReady) {
      Loading.toast('聊天服務未就緒'.tr);
      return;
    }
    final userNumber = _companyInfo.value?.userNumber ?? '';
    if (userNumber.isEmpty) {
      AlertUtils.error('創建會話失敗'.tr);
      return;
    }
    final conversation = await ChatStore.to.getOrCreateDirect(userNumber);
    if (conversation == null) {
      AlertUtils.error('創建會話失敗'.tr);
      return;
    }
    Get.toNamed(AppRoutes.CHAT, arguments: {'conversation': conversation});
  }
}
