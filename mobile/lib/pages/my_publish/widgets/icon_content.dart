import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';

class IconContent extends StatelessWidget {
  const IconContent({
    super.key,
    required this.assets,
    required this.title,
    required this.content,
  });
  final String assets;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          assets,
          width: 12.w,
          color: AppColors.assistantText,
        ),
        4.w.horizontalSpace,
        Text(
          '$title: ',
          style: TextStyle(
            color: AppColors.assistantText,
            fontSize: 12.sp,
          ),
        ),
        Text(
          content,
          style: TextStyle(
            color: AppColors.assistantText,
            fontSize: 12.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ).expanded(),
      ],
    );
  }
}
