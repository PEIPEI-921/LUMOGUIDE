import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/content.dart';

class PasswordInputPage extends StatelessWidget {
  const PasswordInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordInputController());
    return IScaffold(
      title: controller.title,
      body: const PasswordContentWidget(),
    );
  }
}
