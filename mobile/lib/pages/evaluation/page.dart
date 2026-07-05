import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/input.dart';
import 'widgets/rating.dart';

class EvaluationPage extends StatelessWidget {
  const EvaluationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EvaluationController());
    return IScaffold(
      resizeToAvoidBottomInset: false,
      title: controller.backTitle,
      body: Column(
        children: [
          const EvaluationInputWidget(),
          // const EvaluationRatingWidget(),
          const Spacer(),
          SubmitButton(
            title: '提交'.tr,
            onPressed: controller.onSubmit,
          ).padding(bottom: 30.w),
        ],
      ).padding(horizontal: 14.w),
    );
  }
}
