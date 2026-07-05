import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class GuideChangeCityController extends GetxController
    with ApiMixin, UserStoreMixin {
  final cities = <CityList>[].obs;

  final _city = Rxn<CityList>();
  CityList? get city => _city.value;

  String? get cityName => city?.name ?? userInfo.guideInfo?.cityName;

  final _isEnabled = false.obs;
  bool get isEnabled => _isEnabled.value;

  @override
  void onInit() {
    super.onInit();

    fetchCity();
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
    await Future.delayed(1.seconds);
    Get.back();
  }

  onSelectCity() async {
    final selectedId =
        city?.id ??
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
    final res = await get(
      ApiUrl.cityList,
      parameters: {'limit': 1000, 'page': 1},
    );
    if (!res.isSuccess) return;
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    cities.value = data.map((e) => CityList.fromJson(e)).toList();
  }
}
