import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class JourneyDetailController extends GetxController {
  final work = Rxn<JourneyWork>();

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments?['id'] as int?;
    _loadDetail(id);
  }

  void _loadDetail(int? id) {
    // TODO: 对接后端 API: GET /user/journeyDetail?id=$id
    // 目前使用 mock 数据
    final list = JourneyWork.mockData();
    work.value = list.firstWhere((w) => w.id == id, orElse: () => list.first);
  }

  void onViewBooking() {
    Get.toNamed(AppRoutes.USER_BOOKING_MANAGER);
  }
}
