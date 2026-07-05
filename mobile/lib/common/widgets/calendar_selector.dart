import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSelectorWidget extends StatefulWidget {
  const CalendarSelectorWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    this.selectedYear,
    this.selectedMonth,
    this.onMonthSelected,
    this.onAllSelected,
    this.onModeChanged,
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
  final int? selectedYear;
  final int? selectedMonth;
  final Function(int year, int month)? onMonthSelected;
  final VoidCallback? onAllSelected;
  final Function(CalendarMode mode)? onModeChanged;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final CalendarFormat calendarFormat;
  final double daysOfWeekHeight;
  final double rowHeight;
  final StartingDayOfWeek startingDayOfWeek;
  final List events;

  @override
  State<CalendarSelectorWidget> createState() => _CalendarSelectorWidgetState();
}

class _CalendarSelectorWidgetState extends State<CalendarSelectorWidget> {
  late CalendarMode _currentMode;
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _currentMode = CalendarMode.day;
    _selectedYear = widget.selectedYear ?? DateTime.now().year;
    _selectedMonth = widget.selectedMonth ?? DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildContent(),
        Positioned(top: 6.w, right: 6.w, child: _buildModeSelector()),
      ],
    ).decorated(color: Colors.white, borderRadius: BorderRadius.circular(8.w));
  }

  Widget _buildModeSelector() {
    return PopupMenuButton<CalendarMode>(
      tooltip: '',
      color: Colors.white,
      initialValue: _currentMode,
      onSelected: (CalendarMode mode) {
        setState(() => _currentMode = mode);
        widget.onModeChanged?.call(mode);
        switch (mode) {
          case CalendarMode.day:
            // 切换到日模式时，确保有选中的日期
            if (widget.selectedDay == null) {
              widget.onDaySelected(DateTime.now(), DateTime.now());
            }
            break;
          case CalendarMode.month:
            // 切换到月模式时，可以选择当前月份
            widget.onMonthSelected?.call(
              DateTime.now().year,
              DateTime.now().month,
            );
            break;
          case CalendarMode.all:
            widget.onAllSelected?.call();
            break;
        }
      },
      itemBuilder: (BuildContext context) => CalendarMode.values.map((
        CalendarMode mode,
      ) {
        return PopupMenuItem<CalendarMode>(
          value: mode,
          child: Row(
            children: [
              Text(
                mode.title,
                style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
              ),
              if (mode == _currentMode) ...[
                8.w.horizontalSpace,
                Icon(Icons.check, size: 16.w, color: AppColors.primary),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        height: 28.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(color: AppColors.assistantText, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentMode.title,
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
            ),
            4.w.horizontalSpace,
            Icon(
              Icons.arrow_drop_down,
              size: 16.w,
              color: AppColors.primaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentMode) {
      case CalendarMode.day:
        return CalendarWidget(
          focusedDay: widget.focusedDay,
          selectedDay: widget.selectedDay,
          onDaySelected: widget.onDaySelected,
          onFocusedDayChanged: (newFocusedDay) {
            widget.onDaySelected(
              widget.selectedDay ?? newFocusedDay,
              newFocusedDay,
            );
          },
          firstDay: widget.firstDay,
          lastDay: widget.lastDay,
          calendarFormat: widget.calendarFormat,
          daysOfWeekHeight: widget.daysOfWeekHeight,
          rowHeight: widget.rowHeight,
          startingDayOfWeek: widget.startingDayOfWeek,
          events: widget.events,
        );
      case CalendarMode.month:
        return MonthSelectorWidget(
          selectedYear: _selectedYear,
          selectedMonth: _selectedMonth,
          onMonthSelected: (year, month) {
            setState(() {
              _selectedYear = year;
              _selectedMonth = month;
            });
            widget.onMonthSelected?.call(year, month);
          },
        );
      case CalendarMode.all:
        return SizedBox(
          height: 40.w,
          child: Center(
            child: Text(
              '全部數據'.tr,
              style: TextStyle(fontSize: 14.sp, color: AppColors.assistantText),
            ),
          ),
        );
    }
  }
}
