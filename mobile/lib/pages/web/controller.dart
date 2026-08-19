import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebController extends GetxController {
  late WebViewController webViewController;
  var title = '';

  final _progress = 0.0.obs;
  double get progress => _progress.value;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments['url'] != null) {
      title = Get.arguments['title'] ?? '';
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(NavigationDelegate(
          onProgress: (int progress) {
            _progress.value = progress / 100;
          },
        ))
        ..loadRequest(Uri.parse(Get.arguments['url']));
    }
  }
}
