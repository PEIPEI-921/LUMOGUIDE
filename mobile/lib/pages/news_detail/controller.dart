import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/index.dart';

class NewsDetailController extends GetxController with ApiMixin {
  int id = 0;

  final _news = News().obs;
  News get news => _news.value;

  final _evaluateCount = 0.obs;
  int get evaluateCount => _evaluateCount.value;

  final evaluateList = <EvaluateList>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      id = Get.arguments['id'] ?? 0;
    }
    fetchNewsDetail();
    fetchNewsEvaluate();
  }

  onMoreEvaluate() async {
    Get.toNamed(
      AppRoutes.EVALUATE_LIST,
      arguments: {'id': id, 'type': EvaluateListType.news},
    );
  }

  onEvaluate() async {
    await Get.toNamed(
      AppRoutes.EVALUATION,
      arguments: {'id': id, 'type': EvaluationType.news},
    );
    fetchNewsEvaluate();
  }

  onUserTap() async {
    await Get.toNamed(
      AppRoutes.GUIDE_DETAIL,
      arguments: {'id': news.user?.guideId},
    );
  }

  onCityTap() async {
    await Get.toNamed(
      AppRoutes.CITY_DETAIL,
      arguments: {'id': news.user?.cityId},
    );
  }
}

extension NewsDetailApiExt on NewsDetailController {
  fetchNewsDetail() async {
    Loading.show();
    final res = await get(ApiUrl.informationInfo, parameters: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      return;
    }
    _news.value = News.fromJson(res.dataJson);
  }

  fetchNewsEvaluate() async {
    final res = await get(
      ApiUrl.informationEvaluate,
      parameters: {'id': id, 'page': 1, 'limit': 2},
    );
    if (!res.isSuccess) {
      return;
    }
    final list = res.dataJson['list'] as List<dynamic>;
    _evaluateCount.value = res.dataJson['total'] as int? ?? 0;
    evaluateList.value = list.map((e) => EvaluateList.fromJson(e)).toList();
  }
}
