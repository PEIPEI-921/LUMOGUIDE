import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/container.dart';

class VerifyCodePage extends StatelessWidget {
  const VerifyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyCodeController());
    return IScaffold(
      title: controller.title,
      body: const VerifyCodeContainerWidget(),
    );
  }
}
