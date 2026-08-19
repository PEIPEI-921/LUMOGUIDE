import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({
    super.key,
    this.title,
    DateTime? selected,
    this.minDate,
    this.maxDate,
  }) : _selected = selected;

  final String? title;
  final DateTime? _selected;
  final DateTime? minDate;
  final DateTime? maxDate;

  static Future<DateTime?> show({
    String? title,
    DateTime? selected,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final result = await Get.bottomSheet(
      DateTimePicker(
        title: title,
        selected: selected,
        minDate: minDate,
        maxDate: maxDate,
      ),
      isScrollControlled: true,
    );
    return result;
  }

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourScrollController;
  late FixedExtentScrollController _minuteScrollController;

  final List<int> _minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
  final List<int> _hours = List.generate(24, (index) => index);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initial = widget._selected ?? now;

    DateTime initialDate = DateTime(initial.year, initial.month, initial.day);
    if (widget.minDate != null) {
      final minDate = DateTime(
        widget.minDate!.year,
        widget.minDate!.month,
        widget.minDate!.day,
      );
      if (initialDate.isBefore(minDate)) {
        initialDate = minDate;
      }
    }
    _selectedDate = initialDate;

    _selectedHour = initial.hour;

    int targetMinute = initial.minute;
    int roundedMinute = ((targetMinute / 5).ceil() * 5) % 60;
    _selectedMinute = roundedMinute;

    _hourScrollController = FixedExtentScrollController(
      initialItem: _hours.indexOf(_selectedHour),
    );
    _minuteScrollController = FixedExtentScrollController(
      initialItem: _minutes.indexOf(_selectedMinute),
    );
  }

  @override
  void dispose() {
    _hourScrollController.dispose();
    _minuteScrollController.dispose();
    super.dispose();
  }

  DateTime get _currentDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedMinute,
    );
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
                      widget.title ?? '',
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
            Row(
              children: [
                CupertinoDatePicker(
                  initialDateTime: _selectedDate,
                  minimumDate: widget.minDate != null
                      ? DateTime(
                          widget.minDate!.year,
                          widget.minDate!.month,
                          widget.minDate!.day,
                        )
                      : DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                  maximumDate: widget.maxDate != null
                      ? DateTime(
                          widget.maxDate!.year,
                          widget.maxDate!.month,
                          widget.maxDate!.day,
                        )
                      : DateTime.now().add(const Duration(days: 365)),
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  itemExtent: 44,
                  onDateTimeChanged: (value) {
                    setState(() {
                      _selectedDate = DateTime(
                        value.year,
                        value.month,
                        value.day,
                      );
                    });
                  },
                ).expanded(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60.w,
                      child: CupertinoPicker(
                        scrollController: _hourScrollController,
                        itemExtent: 44,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedHour = _hours[index];
                          });
                        },
                        children: _hours.map((hour) {
                          return Center(
                            child: Text(
                              hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: AppColors.primaryText,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(
                      width: 60.w,
                      child: CupertinoPicker(
                        scrollController: _minuteScrollController,
                        itemExtent: 44,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMinute = _minutes[index];
                          });
                        },
                        children: _minutes.map((minute) {
                          return Center(
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: AppColors.primaryText,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ).expanded(),
            SubmitButton(
              title: '確認'.tr,
              onPressed: () => Get.back(result: _currentDateTime),
            ).padding(horizontal: 15.w),
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
