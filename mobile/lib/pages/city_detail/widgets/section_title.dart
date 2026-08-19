import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';

class SectionTitleWidget extends StatelessWidget {
  const SectionTitleWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          width: 20.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ).translate(offset: Offset(0, -5.w)),
      ],
    );
  }
}
