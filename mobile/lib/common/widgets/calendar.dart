import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    this.onFocusedDayChanged,
    this.firstDay,
    this.lastDay,
    this.calendarFormat = CalendarFormat.week,
    this.daysOfWeekHeight = 20,
    this.rowHeight = 35,
    this.startingDayOfWeek = StartingDayOfWeek.monday,
    this.events = const [],
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime day, DateTime focusedDay) onDaySelected;
  final Function(DateTime)? onFocusedDayChanged;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final CalendarFormat calendarFormat;
  final double daysOfWeekHeight;
  final double rowHeight;
  final StartingDayOfWeek startingDayOfWeek;
  final List events;

  @override
  Widget build(BuildContext context) {
    final effectiveFirstDay =
        firstDay ?? DateTime.now().subtract(const Duration(days: 365));
    final effectiveLastDay =
        lastDay ?? DateTime.now().add(const Duration(days: 365));

    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCustomHeader(
              context,
              focusedDay,
              effectiveFirstDay,
              effectiveLastDay,
            ),
            TableCalendar(
              locale: LocalizationService.to.locale.toLanguageTag(),
              focusedDay: focusedDay,
              firstDay: effectiveFirstDay,
              lastDay: effectiveLastDay,
              calendarFormat: calendarFormat,
              daysOfWeekHeight: daysOfWeekHeight,
              rowHeight: rowHeight,
              startingDayOfWeek: startingDayOfWeek,
              headerVisible: false,
              calendarStyle: _calendarStyle,
              calendarBuilders: _calendarBuilders,
              daysOfWeekStyle: _daysOfWeekStyle,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: onDaySelected,
              onPageChanged: (newFocusedDay) {
                onFocusedDayChanged?.call(newFocusedDay);
              },
            ),
          ],
        )
        .padding(bottom: 10.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        );
  }

  CalendarBuilders get _calendarBuilders => CalendarBuilders(
    markerBuilder: (context, day, events) {
      if (events.isEmpty) {
        return const SizedBox.shrink();
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ).positioned(bottom: 0);
    },
  );

  Widget _buildCustomHeader(
    BuildContext context,
    DateTime focusedDay,
    DateTime firstDay,
    DateTime lastDay,
  ) {
    final yearMonthText = DateFormat(
      'yyyy年MM月',
      LocalizationService.to.locale.languageCode,
    ).format(focusedDay);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.w, horizontal: 70.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.primaryText,
              size: 25,
            ),
            onPressed: () {
              final previousMonth = DateTime(
                focusedDay.year,
                focusedDay.month - 1,
              );
              if (previousMonth.isBefore(firstDay)) return;
              onFocusedDayChanged?.call(previousMonth);
            },
          ),
          GestureDetector(
            onTap: () =>
                _showYearMonthPicker(context, focusedDay, firstDay, lastDay),
            child: Text(
              yearMonthText,
              style: TextStyle(fontSize: 16.sp, color: AppColors.primaryText),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.primaryText,
              size: 25,
            ),
            onPressed: () {
              final nextMonth = DateTime(focusedDay.year, focusedDay.month + 1);
              if (nextMonth.isAfter(lastDay)) return;
              onFocusedDayChanged?.call(nextMonth);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showYearMonthPicker(
    BuildContext context,
    DateTime currentDate,
    DateTime firstDay,
    DateTime lastDay,
  ) async {
    if (onFocusedDayChanged == null) return;

    final selected = await DatePicker.show(
      title: '選擇年月'.tr,
      selected: currentDate,
      mode: CupertinoDatePickerMode.monthYear,
      minDate: firstDay,
      maxDate: lastDay,
    );

    if (selected != null) {
      final newFocusedDay = DateTime(selected.year, selected.month);
      if (newFocusedDay.isAfter(lastDay) || newFocusedDay.isBefore(firstDay)) {
        return;
      }
      if (newFocusedDay.year != currentDate.year ||
          newFocusedDay.month != currentDate.month) {
        onFocusedDayChanged!.call(newFocusedDay);
      }
    }
  }

  CalendarStyle get _calendarStyle => CalendarStyle(
    defaultTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
    weekendTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
    todayTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
    todayDecoration: BoxDecoration(
      color: Colors.grey[200],
      shape: BoxShape.circle,
    ),
    selectedTextStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
    selectedDecoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
  );

  DaysOfWeekStyle get _daysOfWeekStyle => DaysOfWeekStyle(
    dowTextFormatter: (date, locale) {
      return DateFormat(
        'E',
        LocalizationService.to.locale.languageCode,
      ).format(date)[1];
    },
    weekdayStyle: const TextStyle(color: AppColors.assistantText, fontSize: 12),
    weekendStyle: const TextStyle(color: AppColors.assistantText, fontSize: 12),
  );
}
