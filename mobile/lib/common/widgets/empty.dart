import 'package:flutter/material.dart';
import '../index.dart';
import 'package:get/get.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.text,
    this.image = Assets.iconEmpty,
    this.height,
    this.paddingTop,
  });
  final String? text;
  final String? image;
  final double? height;
  final double? paddingTop;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image != null)
          Image.asset(
            image!.isNotEmpty ? image! : Assets.iconEmpty,
            height: height ?? 110.w,
          ).padding(bottom: 18.w),
        Text(
          text ?? '暫無紀錄'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.assistantText,
            fontSize: AppFontSize.sm,
          ),
        ),
      ],
    ).padding(top: paddingTop ?? 50.w);
  }
}

class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({
    super.key,
    this.text,
    this.image = Assets.iconEmpty,
    this.height,
    this.paddingTop = 100,
  });
  final String? text;
  final String? image;
  final double? height;
  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            if (image != null)
              Image.asset(
                image!.isNotEmpty ? image! : Assets.iconEmpty,
                height: height ?? 110.w,
              ).padding(bottom: 18.w),
            Text(
              text ?? '暫無紀錄'.tr,
              style: const TextStyle(
                color: AppColors.assistantText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ).padding(top: paddingTop),
      ],
    );
  }
}
