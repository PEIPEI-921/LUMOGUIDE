import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MessageSystemDetailPage extends StatelessWidget {
  const MessageSystemDetailPage({super.key, required this.model});
  final MessageSystemModel model;

  @override
  Widget build(BuildContext context) {
    return IScaffold(
      title: '消息詳情'.tr,
      body:
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.w),
            children: [
              Row(
                children: [
                  Text(
                    model.title ?? '',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ).expanded(),
                  Text(
                    model.time ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primaryText.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              5.w.verticalSpace,
              Text(
                model.desc ?? '',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                ),
              ),
              Divider(
                height: 20,
                thickness: 0.5,
                color: AppColors.primaryText.withValues(alpha: 0.1),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4.w,
                children: [
                  Text(
                    model.content ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primaryText,
                      height: 1.5,
                    ),
                  ),
                  if (model.hasLinkedContent)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '查看詳情'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            height: 1.5,
                          ),
                        ),
                        2.w.horizontalSpace,
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12.w,
                          color: AppColors.primary,
                        ),
                      ],
                    ).gestures(
                      onTap: model.openLinkedContent,
                      behavior: HitTestBehavior.opaque,
                    ),
                ],
              ),
            ],
          ).decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
          ),
    );
  }
}
