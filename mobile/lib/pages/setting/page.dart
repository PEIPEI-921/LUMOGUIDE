import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'index.dart';
import 'widgets/item.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgMine),
      title: '設置'.tr,
      body: Column(
        children: [
          ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
            itemBuilder: (context, index) =>
                SettingItemWidget(item: controller.items[index]),
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.primaryText.withOpacity(0.05),
              thickness: 0.5,
            ),
            itemCount: controller.items.length,
          ).expanded(),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              side: const BorderSide(color: AppColors.primary, width: 1),
            ),
            onPressed: () {
              controller.logout();
            },
            child: Text(
              '退出登錄'.tr,
              style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
            ).center().height(40),
          ).padding(horizontal: 15.w, bottom: 10.w),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              side: const BorderSide(color: AppColors.assistantText, width: 1),
            ),
            onPressed: () {
              controller.deleteAccount();
            },
            child: Text(
              '註銷賬號'.tr,
              style: TextStyle(fontSize: 14.sp, color: AppColors.assistantText),
            ).center().height(40),
          ).padding(horizontal: 15.w).safeArea().padding(bottom: 10.w),
        ],
      ),
    );
  }
}
