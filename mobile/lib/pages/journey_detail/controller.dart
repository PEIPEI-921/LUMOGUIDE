import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class JourneyDetailController extends GetxController {
  final work = Rxn<JourneyWork>();
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments?['id'] as int?;
    _loadDetail(id);
  }

  void _loadDetail(int? id) {
    // TODO: 对接后端 API
    final list = JourneyWork.mockData();
    work.value = list.firstWhere((w) => w.id == id, orElse: () => list.first);
  }

  void onEdit() {
    Get.toNamed(AppRoutes.JOURNEY_EDITOR, arguments: {
      'work': work.value,
    })?.then((_) => _loadDetail(work.value?.id));
  }

  void onSaveAsTemplate() {
    // TODO: POST /user/journeyTemplate/create
  }

  void onGenerateClientItinerary() {
    // TODO: 客户行程生成
  }

  void onViewBooking() {
    Get.toNamed(AppRoutes.USER_BOOKING_MANAGER);
  }

  void onViewCity(String city) {
    Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'city': city});
  }
}
