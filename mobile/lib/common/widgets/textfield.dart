import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../index.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isPassword;
  final int maxLines;
  final bool isRequired;
  final EdgeInsetsGeometry? contentPadding;
  final bool isReadOnly;
  final Color? backgroundColor;
  final Widget? suffix;
  final double? hintFontSize;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.isPassword = false,
    this.maxLines = 1,
    this.isRequired = false,
    this.isReadOnly = false,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 13,
    ),
    this.backgroundColor,
    this.suffix,
    this.hintFontSize,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  bool get _hasError {
    if (_focusNode.hasFocus) {
      return false;
    }
    return widget.validator?.call(widget.controller.text) != null &&
        widget.controller.text.isNotEmpty;
  }

  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _isObscure = widget.obscureText;
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: AppFontSize.sm,
                  ),
                ),
              Text(
                widget.labelText ?? '',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: AppFontSize.sm,
                ),
              ),
            ],
          ).padding(bottom: 8),
        ],
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          readOnly: widget.isReadOnly,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: _isObscure,
          obscuringCharacter: '●',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: AppFontSize.sm,
          ),
          cursorColor: AppColors.primary,
          onChanged: widget.onChanged ?? (_) {},
          maxLength: widget.maxLength,
          onTapOutside: (_) {
            hideKeyboard(context);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            isCollapsed: true,
            contentPadding: widget.contentPadding,
            hintStyle: TextStyle(
              color: AppColors.assistantText,
              fontSize: widget.hintFontSize ?? AppFontSize.sm,
            ),
            border: InputBorder.none,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.assistantText,
                    ),
                  )
                : widget.suffix,
            counterText: '',
          ),
        ).decorated(
          color: widget.backgroundColor ?? AppColors.backgroundBlue,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}

class LabelSelectField extends StatefulWidget {
  final String label;
  final String value;
  final Function() onTap;
  final bool isRequired;
  final String? hintText;
  final bool isRightArrow;

  const LabelSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.hintText,
    this.isRequired = false,
    this.isRightArrow = true,
  });

  @override
  State<LabelSelectField> createState() => _LabelSelectFieldState();
}

class _LabelSelectFieldState extends State<LabelSelectField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Row(
            children: [
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: AppFontSize.sm,
                  ),
                ),
              Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: AppFontSize.sm,
                ),
              ),
            ],
          ),
          8.verticalSpace,
        ],
        Row(
              children: [
                Text(
                  widget.value.isEmpty ? widget.hintText ?? '' : widget.value,
                  style: TextStyle(
                    color: widget.value.isEmpty
                        ? AppColors.assistantText
                        : AppColors.primaryText,
                    fontSize: AppFontSize.sm,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).expanded(),
                if (widget.isRightArrow)
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.assistantText,
                  ).padding(left: 8),
              ],
            )
            .padding(vertical: 13, horizontal: 12)
            .decorated(
              color: AppColors.backgroundBlue,
              borderRadius: BorderRadius.circular(12),
            )
            .gestures(onTap: widget.onTap, behavior: HitTestBehavior.opaque),
      ],
    );
  }
}
