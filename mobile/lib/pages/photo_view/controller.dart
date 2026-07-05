import 'package:get/get.dart';

class PhotoViewPageController extends GetxController {

  List<String> pictures = [];
  final _index = 0.obs;
  int get index => _index.value;

  @override
  void onInit() {
    super.onInit();
    pictures = Get.arguments['pictures'] as List<String>;
    _index.value = Get.arguments['index'] as int;
  }

  void onPageChanged(int index) {
    _index.value = index;
  }

}
