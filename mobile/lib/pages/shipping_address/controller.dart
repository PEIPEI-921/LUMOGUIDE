import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/index.dart';

class ShippingAddressController extends GetxController
    with RefreshableMixin<ShippingAddress>, ApiMixin {
  @override
  void onInit() {
    super.onInit();
    initRefresh(isLoadMore: false);
    Loading.show();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(ApiUrl.addressLists, parameters: {
      'page': 1,
      'limit': 1000,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final list = res.dataJson['list'] as List<dynamic>;
    final data = list.map((e) => ShippingAddress.fromJson(e)).toList();
    endLoad(data);
  }

  onEditAddress(ShippingAddress item) async {
    final res =
        await Get.toNamed(AppRoutes.SHIPPING_ADDRESS_EDITOR, arguments: {
      'type': AddressEditorType.edit,
      'item': item,
    });
    if (res != null) {
      fetchData();
    }
  }

  onSelectAddress(ShippingAddress item) async {
    Get.back(result: item);
  }

  onAddAddress() async {
    final res =
        await Get.toNamed(AppRoutes.SHIPPING_ADDRESS_EDITOR, arguments: {
      'type': AddressEditorType.add,
    });
    if (res != null) {
      fetchData();
    }
  }
}
