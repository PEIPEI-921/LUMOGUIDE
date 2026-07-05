import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/index.dart';

class MerchantManagementController extends GetxController
    with ApiMixin, RefreshableMixin {
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  onAddMerchant() async {
    if (!VIPCheckUtils.check()) {
      return;
    }

    /// 试用期间只能添加一个店铺
    if ((UserStore.to.profile.isFreeVip && itemCount >= 1)) {
      AlertUtils.show(
        title: '提示'.tr,
        content: '免費試⽤期間只能添加一個店铺，想繼續使用全部功能，請延長會員會籍'.tr,
      );
      return;
    }
    final res = await Get.toNamed(
      AppRoutes.MERCHANT_EDITOR,
      arguments: {'type': MerchantEditorType.add},
    );
    if (res == true) {
      onRefresh();
    }
  }

  onEditMerchant(MerchantShop item) async {
    if (item.isRead == 0) {
      item.isRead = 1;
      refreshItems();
    }
    final res = await Get.toNamed(
      AppRoutes.MERCHANT_EDITOR,
      arguments: {'type': MerchantEditorType.edit, 'id': item.id},
    );
    if (res == true) {
      onRefresh();
    }
  }

  onDeleteMerchant(MerchantShop item) async {
    final flag = await AlertUtils.show(
      title: '確定要刪除該店铺麼？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) {
      return;
    }
    Loading.show();
    final res = await post(ApiUrl.companyShopDel, data: {'id': item.id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('已刪除'.tr);
    onRefresh();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.companyShop,
      parameters: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>;
    final list = data.map((e) => MerchantShop.fromJson(e)).toList();
    endLoad(list);
  }
}
