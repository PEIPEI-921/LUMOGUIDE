import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class ReservationController extends GetxController {
  var type = CommonDetailType.scenic;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      type =
          Get.arguments['type'] as CommonDetailType? ?? CommonDetailType.scenic;
    }
  }
}
