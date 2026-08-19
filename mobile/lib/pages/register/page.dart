import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/content.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RegisterController());
    return IScaffold(
      title: '註冊'.tr,
      body: const RegisterContentWidget(),
    );
  }
}
