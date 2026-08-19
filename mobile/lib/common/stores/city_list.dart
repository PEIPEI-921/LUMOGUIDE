import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class CityListStore extends GetxController with ApiMixin {
  static CityListStore get to => Get.find();

  final cityList = <CityList>[].obs;

  fetchCityList() async {
    final res = await get(ApiUrl.cityList, parameters: {
      'limit': 1000,
      'page': 1,
    });
    if (!res.isSuccess) return;
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    // 過濾非 Map 元素，避免後端髒數據導致 fromJson 強轉崩潰
    cityList.value = data
        .whereType<Map<String, dynamic>>()
        .map((e) => CityList.fromJson(e))
        .toList();
  }
}
