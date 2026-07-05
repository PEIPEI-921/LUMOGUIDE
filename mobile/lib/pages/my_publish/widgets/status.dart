import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key, this.status});
  final int? status;

  /// 0审核中/1审核通过/2驳回
  String get statusText {
    switch (status) {
      case 0:
        return '審核中';
      case 1:
        return '審核通過';
      case 2:
        return '審核駁回';
      default:
        return '';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0:
        return AppColors.primary;
      case 1:
        return const Color(0xFF00BEAA);
      case 2:
        return const Color(0xFFDD0000);
      default:
        return AppColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusText.isEmpty) return const SizedBox.shrink();
    return Text(
      statusText,
      style: TextStyle(
        color: statusColor,
        fontSize: 10.sp,
      ),
    ).padding(horizontal: 8.w, vertical: 5.w).decorated(
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            color: statusColor,
            width: 1.w,
          ),
        );
  }
}
