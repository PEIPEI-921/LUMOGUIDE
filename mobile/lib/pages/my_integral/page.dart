import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/list.dart';
import 'widgets/top.dart';

class MyIntegralPage extends StatelessWidget {
  const MyIntegralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyIntegralController());
    return IScaffold(
      appBar: IAppBar(
        title: '我的積分'.tr,
        actions: [
          TextButton(
            onPressed: controller.onRule,
            child: Text(
              '積分規則'.tr,
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
            ),
          ),
        ],
      ),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        children: [
          const MyIntegralTopWidget(),
          const MyIntegralListWidget().expanded(),
        ],
      ).padding(horizontal: 14.w, bottom: 20.w, top: 10.w),
    );
  }
}
