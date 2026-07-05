import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MyPublishCityController extends GetxController
    with RefreshableMixin, ApiMixin, UserStoreMixin {
  final cities = <CityList>[].obs;

  final _city = Rxn<CityList>();
  CityList? get city => _city.value;

  String? get cityName =>
      city?.name ??
      userInfo.guideInfo?.cityName ??
      cities.firstWhereOrNull((e) => e.id == 0)?.name;

  final _isEnabled = false.obs;
  bool get isEnabled => _isEnabled.value;

  @override
  void onInit() {
    super.onInit();
    fetchCity();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.guideCityList,
      parameters: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['data'] as List<dynamic>? ?? [];
    final list = data.map((e) => GuidePublishCity.fromJson(e)).toList();
    endLoad(list);
  }

  onAddCity() async {
    if (!VIPCheckUtils.check()) {
      return;
    }
    final result = await Get.toNamed(AppRoutes.PUBLISH_CITY);
    if (result != true) {
      return;
    }
    onRefresh();
  }

  onEditCity(GuidePublishCity item) async {
    if (item.isRead == 0) {
      item.isRead = 1;
      refreshItems();
    }
    final result = await Get.toNamed(
      AppRoutes.PUBLISH_CITY,
      arguments: {'id': item.id},
    );
    if (result != true) {
      return;
    }
    onRefresh();
  }

  onDeleteCity(GuidePublishCity item) async {
    final flag = await AlertUtils.show(
      title: '確定要刪除這個城市嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) {
      return;
    }
    Loading.show();
    final res = await post(ApiUrl.guideDelCity, data: {'id': item.id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    onRefresh();
  }

  onSubmit() async {
    Loading.show();
    final res = await post(ApiUrl.guideChangeCity, data: {'city_id': city?.id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('选择成功'.tr);
    reloadUserInfo();
  }

  onSelectCity() async {
    if (cities.isEmpty) {
      Loading.toast('暫無數據'.tr);
      return;
    }
    final selectedId = city?.id ??
        cities
            .firstWhereOrNull((e) => e.name == userInfo.guideInfo?.cityName)
            ?.id;
    final picked = await CityPickerSheet.show(
      title: '請選擇城市'.tr,
      cities: cities,
      selectedCityId: selectedId,
    );
    if (picked != null) {
      _city.value = picked;
    }
    _isEnabled.value =
        city != null && userInfo.guideInfo?.cityName != city?.name;
  }

  fetchCity() async {
    final res = await get(ApiUrl.cityOptions);
    if (!res.isSuccess) return;
    final data = res.dataList as List<dynamic>? ?? [];
    cities.value = data.map((e) => CityList.fromJson(e)).toList();
  }
}
