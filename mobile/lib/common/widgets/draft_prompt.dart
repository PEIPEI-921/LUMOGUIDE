import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../index.dart';

/// 草稿恢复提示卡片
class DraftPromptCard extends StatelessWidget {
  final String message;
  final VoidCallback onContinue;
  final VoidCallback onDiscard;

  const DraftPromptCard({
    super.key,
    required this.message,
    required this.onContinue,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF666FFF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(
          color: const Color(0xFF666FFF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF666FFF),
            size: 20.w,
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 13.sp,
              ),
            ),
          ),
          8.w.horizontalSpace,
          _ActionButton(
            label: '重新填寫'.tr,
            isPrimary: false,
            onTap: onDiscard,
          ),
          8.w.horizontalSpace,
          _ActionButton(
            label: '繼續編輯'.tr,
            isPrimary: true,
            onTap: onContinue,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF666FFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6.w),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFF666FFF), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFF666FFF),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
