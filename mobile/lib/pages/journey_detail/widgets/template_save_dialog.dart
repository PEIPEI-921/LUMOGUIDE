import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumotrip/common/index.dart';

class TemplateSaveDialog extends StatefulWidget {
  final String initialName;
  final void Function(String name) onConfirm;

  const TemplateSaveDialog({
    super.key,
    required this.initialName,
    required this.onConfirm,
  });

  static Future<void> show(
    String initialName,
    void Function(String name) onConfirm,
  ) {
    return Get.dialog(
      TemplateSaveDialog(initialName: initialName, onConfirm: onConfirm),
    );
  }

  @override
  State<TemplateSaveDialog> createState() => _TemplateSaveDialogState();
}

class _TemplateSaveDialogState extends State<TemplateSaveDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      Loading.toast('请输入模板名称');
      return;
    }
    Get.back();
    widget.onConfirm(name);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '保存为模板',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 16.w),
            TextField(
              controller: _ctrl,
              maxLength: 30,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '请输入模板名称',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.assistantText,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
                counterStyle: TextStyle(fontSize: 10.sp, color: AppColors.assistantText),
              ),
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
            ),
            SizedBox(height: 16.w),
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.assistantText,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.w),
                  ),
                  child: Text(
                    '确认',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
