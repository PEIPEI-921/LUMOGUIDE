import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'index.dart';

class MessageSystemController extends GetxController
    with RefreshableMixin, ApiMixin {
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.messageSystem,
      parameters: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    final list = data.map((e) => MessageSystemModel.fromJson(e)).toList();
    endLoad(list);
  }

  onTapItem(MessageSystemModel model) {
    Get.to(MessageSystemDetailPage(model: model));
  }
}
