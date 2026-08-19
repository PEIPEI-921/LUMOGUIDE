import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/content.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ForgetPasswordController());
    return IScaffold(
      title: '找回密碼'.tr,
      body: const ForgetPasswordContentWidget(),
    );
  }
}
