import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';

class DatePicker extends StatelessWidget {
  DatePicker({
    super.key,
    this.title,
    DateTime? selected,
    this.mode = CupertinoDatePickerMode.monthYear,
    this.minDate,
    this.maxDate,
  }) {
    selectedDate.value = selected ?? DateTime.now();
  }

  final String? title;
  final CupertinoDatePickerMode mode;
  final DateTime? minDate;
  final DateTime? maxDate;
  final selectedDate = Rxn<DateTime>();

  static Future<DateTime?> show({
    String? title,
    DateTime? selected,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final result = await Get.bottomSheet(
      DatePicker(
        title: title,
        selected: selected,
        mode: mode,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
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
                  title ?? '',
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
              icon: const Icon(
                Icons.close,
                color: AppColors.primaryText,
              ),
            ).positioned(right: 0)
          ],
        ).constrained(height: 40),
        CupertinoDatePicker(
          initialDateTime: selectedDate.value,
          minimumDate: minDate,
          maximumDate: maxDate,
          mode: mode,
          use24hFormat: true,
          itemExtent: 44,
          onDateTimeChanged: (value) {
            selectedDate.value = value;
          },
        ).expanded(),
        Obx(() => SubmitButton(
              title: '確認'.tr,
              onPressed: () => Get.back(result: selectedDate.value),
              enabled: selectedDate.value != null,
            ).padding(horizontal: 15.w)),
      ],
    )
        .constrained(width: double.infinity, height: 340.h)
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
