import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key, this.status});
  final int? status;

  /// 1待确认/2已确认/3已完成
  String get statusText {
    switch (status) {
      case 1:
        return '待確認';
      case 2:
        return '已確認';
      case 3:
        return '已完成';
      case 4:
        return '已取消';
      case 5:
        return '已拒絕';
      case 6:
        return '已過期';
      default:
        return '';
    }
  }

  Color get statusColor {
    switch (status) {
      case 1:
        return AppColors.primary;       // 紫色：即将发生
      case 2:
        return AppColors.jadeGreen;     // 浅绿：正在进行
      case 3:
        return AppColors.primaryText;   // 深色：已完成
      case 4:
        return AppColors.assistantText; // 灰色：已取消
      case 5:
        return AppColors.assistantText; // 灰色：已拒绝
      case 6:
        return AppColors.assistantText; // 灰色：已过期
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusText.isEmpty) return const SizedBox.shrink();
    return Text(
          statusText,
          style: TextStyle(color: statusColor, fontSize: 10.sp),
        )
        .padding(horizontal: 8.w, vertical: 5.w)
        .decorated(
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: statusColor, width: 1.w),
        );
  }
}
