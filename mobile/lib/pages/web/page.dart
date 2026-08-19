import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../common/index.dart';
import 'controller.dart';

class WebPage extends StatelessWidget {
  const WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WebController());
    return IScaffold(
      title: controller.title,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller.webViewController,
          ),
          Obx(() => controller.progress >= 1
              ? const SizedBox.shrink()
              : LinearProgressIndicator(
                  value: controller.progress,
                  color: AppColors.primary,
                )),
        ],
      ),
    );
  }
}
