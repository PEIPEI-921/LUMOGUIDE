import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class SettingItemWidget extends StatelessWidget {
  const SettingItemWidget({super.key, required this.item});

  final SettingList item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingController>();

    return Row(
      children: [
        Text(item.title,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryText,
            )),
        const Spacer(),
        Text(controller.valueOfItem(item),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryText,
            )),
        Icon(
          Icons.chevron_right,
          color: AppColors.assistantText,
          size: 20.w,
        ),
      ],
    )
        .padding(vertical: 15.w, horizontal: 10.w)
        .ripple()
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: item == SettingList.language
                ? Radius.circular(8.w)
                : Radius.zero,
            topRight: item == SettingList.language
                ? Radius.circular(8.w)
                : Radius.zero,
            bottomLeft: item == SettingList.version
                ? Radius.circular(8.w)
                : Radius.zero,
            bottomRight: item == SettingList.version
                ? Radius.circular(8.w)
                : Radius.zero,
          ),
        )
        .gestures(
          onTap: () => controller.onItemTap(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
