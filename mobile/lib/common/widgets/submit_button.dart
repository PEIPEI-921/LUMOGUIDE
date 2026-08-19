import 'package:flutter/material.dart';
import '../../common/index.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.enabled = true,
    this.height = 44,
    this.backgroundColor,
  });

  final String title;
  final VoidCallback onPressed;
  final bool enabled;
  final double? height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        backgroundColor: (backgroundColor ?? AppColors.primary)
            .withValues(alpha: enabled ? 1 : 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        shadowColor: const Color(0xFF666FFF).withValues(alpha: 0.15),
        elevation: 20,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.white,
        ),
      ),
    ).constrained(
      height: height,
      width: double.infinity,
    );
  }
}
