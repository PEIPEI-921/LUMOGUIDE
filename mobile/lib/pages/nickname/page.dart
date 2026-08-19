import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class NicknamePage extends StatelessWidget {
  const NicknamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NicknameController());
    return IScaffold(
      resizeToAvoidBottomInset: false,
      backgroundImage: const AssetImage(Assets.bgMine),
      title: '修改暱稱'.tr,
      body: Column(
        children: [
          CustomTextField(
            controller: controller.nicknameController,
            hintText: '請輸入'.tr,
          ),
          Text(
            '暱稱最多8個字'.tr,
            style: TextStyle(
              color: AppColors.assistantText,
              fontSize: 12.sp,
            ),
          ).alignment(Alignment.centerLeft).padding(top: 10.w),
          const Spacer(),
          SubmitButton(
            title: '確定'.tr,
            onPressed: controller.onSubmit,
          )
        ],
      ).padding(horizontal: 16.w, bottom: 30.w, top: 10.w),
    );
  }
}
