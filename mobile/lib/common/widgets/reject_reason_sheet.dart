import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';

class RejectReasonSheet extends StatelessWidget {
  RejectReasonSheet({super.key, this.title, this.hintText}) {
    reason.value = '';
  }

  final String? title;
  final String? hintText;
  final reason = ''.obs;

  static Future<String?> show({String? title, String? hintText}) async {
    final result = await Get.bottomSheet(
      RejectReasonSheet(title: title, hintText: hintText),
    );
    return result is String && result.trim().isNotEmpty ? result.trim() : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: reason.value);

    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title ?? '拒絕理由'.tr,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: AppFontSize.md,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: AppColors.primaryText),
                ).positioned(right: 0),
              ],
            ).constrained(height: 40),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(
                  color: AppColors.assistantText.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: 5,
                minLines: 3,
                onChanged: (v) => reason.value = v,
                onTapOutside: (_) => hideKeyboard(context),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hintText ?? '請輸入拒絕理由'.tr,
                  hintStyle: TextStyle(
                    color: AppColors.assistantText,
                    fontSize: 14.sp,
                  ),
                ),
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              ),
            ),
            12.w.verticalSpace,
            Obx(
              () => SubmitButton(
                title: '提交'.tr,
                onPressed: () => Get.back(result: reason.value),
                enabled: reason.value.trim().isNotEmpty,
              ).padding(horizontal: 15.w),
            ),
          ],
        )
        .constrained(width: double.infinity, height: 280.h)
        .safeArea()
        .padding(horizontal: 15.w, top: 10.h)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.w),
            topRight: Radius.circular(16.w),
          ),
        );
  }
}
