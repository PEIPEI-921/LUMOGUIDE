import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MineAuthWidget extends StatelessWidget with UserStoreMixin {
  const MineAuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();

    return Obx(
      () => (userInfo.isUser && !userInfo.inAudit)
          ? Row(
              children: [
                if (userInfo.showGuideAuth)
                  _Item(
                    title: '您是旅遊⾏業從業者嗎？您想獲得更多旅遊資訊及展⽰⾃⼰嗎? ⾺上成為 LuMo Guide'.tr,
                    icon: Assets.iconAccountGuide,
                    background: Assets.bgAccountGuide,
                    clickColor: controller.guideAuthStatusColor,
                    click: controller.guideAuthStatusText,
                    onTap: controller.onToBeGuide,
                  ).expanded(flex: 1),
                if (userInfo.showGuideAuth && userInfo.showEnterpriseAuth)
                  10.w.horizontalSpace,
                if (userInfo.showEnterpriseAuth)
                  _Item(
                    title: '您想增加遊客業務和旅遊合作嗎？您想更多展⽰⾃⼰嗎? 去成為 LuMo 的合作商家'.tr,
                    icon: Assets.iconAccountMerchant,
                    background: Assets.bgAccountMerchant,
                    clickColor: controller.enterpriseAuthStatusColor,
                    click: controller.enterpriseAuthStatusText,
                    onTap: controller.onToBeMerchant,
                  ).expanded(flex: 1),
              ],
            ).padding(top: 20.w)
          : const SizedBox.shrink(),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.title,
    required this.icon,
    required this.background,
    required this.click,
    required this.onTap,
    this.clickColor,
  });

  final String title;
  final String icon;
  final String background;
  final String click;
  final Color? clickColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(icon, width: 16.w, height: 16.w),
            5.w.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
                10.w.verticalSpace,
                Text(
                      click,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: clickColor ?? Colors.white,
                      ),
                    )
                    .padding(horizontal: 10.w, vertical: 5.w)
                    .decorated(
                      border: Border.all(color: clickColor ?? Colors.white),
                      borderRadius: BorderRadius.circular(4.w),
                    )
                    .gestures(onTap: onTap, behavior: HitTestBehavior.opaque),
              ],
            ).expanded(),
          ],
        )
        .padding(horizontal: 8.w, vertical: 15.w)
        .decorated(
          image: DecorationImage(
            image: AssetImage(background),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(8.w),
        );
  }
}
