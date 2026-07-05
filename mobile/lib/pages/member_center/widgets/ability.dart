import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class MemberCenterAbilityWidget extends StatelessWidget with UserStoreMixin {
  const MemberCenterAbilityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberCenterController>();

    return Obx(() => Column(
          children: [
            Row(
              children: [
                Text(
                  '會員權益'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                10.w.horizontalSpace,
                Container(
                  height: 1,
                  color: AppColors.primaryText.withOpacity(0.1),
                ).expanded(),
              ],
            ),
            10.w.verticalSpace,
            if (userInfo.isGuide)
              Column(
                children: [
                  ...controller.ability.guide.map((e) => _Item(title: e)),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controller.ability.company.map(
                    (list) => Column(
                      children: [
                        ...list.map((e) => _Item(title: e)),
                      ],
                    ).expanded(flex: 1),
                  ),
                ],
              ),
          ],
        ).padding(horizontal: 14.w, top: 10.w));
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          Assets.iconMemberArrow,
          width: 7.w,
        ).padding(top: 6.w),
        4.w.horizontalSpace,
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.primaryText,
          ),
        ).expanded(),
      ],
    ).padding(bottom: 3.w);
  }
}
