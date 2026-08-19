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
    cityList.value = data.map((e) => CityList.fromJson(e)).toList();
  }
}
