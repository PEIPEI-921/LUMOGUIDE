import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/auth.dart';
import 'widgets/expired.dart';
import 'widgets/header.dart';
import 'widgets/menu.dart';
import 'widgets/trial.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MineController());
    return IScaffold(
      appBar: IAppBar(
        title: '我的'.tr,
        showBackButton: false,
      ),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: EasyRefresh(
        header: const MaterialHeader(),
        onRefresh: controller.onRefresh,
        child: const Column(
          children: [
            MineHeaderWidget(),
            MineTrialWidget(),
            MineExpiredWidget(),
            MineAuthWidget(),
            MineMenuWidget(),
          ],
        ).padding(horizontal: 14.w).scrollable(),
      ),
    );
  }
}
