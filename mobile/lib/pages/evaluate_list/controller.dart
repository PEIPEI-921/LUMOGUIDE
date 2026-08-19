import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'index.dart';

class EvaluateListController extends GetxController
    with ApiMixin, RefreshableMixin {
  EvaluateListType type = EvaluateListType.news;
  int id = 0;
  int cityId = 0;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      type = Get.arguments['type'] ?? EvaluateListType.news;
      cityId = Get.arguments['cityId'] ?? 0;
      id = Get.arguments['id'] ?? 0;
    }
    initRefresh(isLoadMore: true);
    Loading.show();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    if (type == EvaluateListType.news) {
      await _fetchNewsEvaluate();
    } else {
      await _fetchMerchantEvaluate();
    }
    Loading.dismiss();
  }
}

extension on EvaluateListController {
  _fetchNewsEvaluate() async {
    final res = await get(ApiUrl.informationEvaluate, parameters: {
      'id': id,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>;
    final list = data.map((e) => EvaluateList.fromJson(e)).toList();
    endLoad(list);
  }

  _fetchMerchantEvaluate() async {
    final res = await get(ApiUrl.contentEvaluate, parameters: {
      'id': id,
      'page': page,
      'limit': limit,
      'city_id': cityId,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>;
    final list = data.map((e) => EvaluateList.fromJson(e)).toList();
    endLoad(list);
  }
}
