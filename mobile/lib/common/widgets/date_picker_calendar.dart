import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';
import 'package:table_calendar/table_calendar.dart';

enum DatePickerMode { year, month, day }

class DatePickerCalendarWidget extends StatefulWidget {
  const DatePickerCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isAllMode = false,
    this.firstDay,
    this.lastDay,
    this.calendarFormat = CalendarFormat.week,
    this.daysOfWeekHeight = 20,
    this.rowHeight = 35,
    this.startingDayOfWeek = StartingDayOfWeek.monday,
    this.events = const [],
  });

  final DateTime selectedDate;
  final Function(DateTime startDate, DateTime endDate, bool allMode)
  onDateSelected;
  final bool isAllMode;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final CalendarFormat calendarFormat;
  final double daysOfWeekHeight;
  final double rowHeight;
  final StartingDayOfWeek startingDayOfWeek;
  final List events;

  @override
  State<DatePickerCalendarWidget> createState() =>
      _DatePickerCalendarWidgetState();
}

class _DatePickerCalendarWidgetState extends State<DatePickerCalendarWidget> {
  late DatePickerMode _currentMode;
  late DateTime _selectedDate;
  late int? _selectedYear;
  late int? _selectedMonth;
  late int? _selectedDay;
  late ScrollController _monthScrollController;
  bool _hasScrolledToMonth = false;

  @override
  void initState() {
    super.initState();
    _currentMode = DatePickerMode.day;
    _selectedDate = widget.selectedDate;
    _selectedYear = _selectedDate.year;
    _selectedMonth = _selectedDate.month;
    _selectedDay = _selectedDate.day;
    _monthScrollController = ScrollController();
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildHeader(), 10.w.verticalSpace, _buildContent()],
            )
            .padding(horizontal: 15.w, vertical: 10.w)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
        if (widget.isAllMode)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.w),
              ),
            ),
          ).positioned(top: 0, left: 0, right: 0, bottom: 0),
        _buildAllButton().positioned(top: 10.w, right: 6.w),
      ],
    );
  }

  Widget _buildHeader() {
    final yearText = _selectedYear != null ? '$_selectedYear年' : '請選擇';
    final monthText = _selectedMonth != null ? '$_selectedMonth月' : '請選擇';
    final dayText = _selectedDay != null ? '$_selectedDay日' : '請選擇';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeaderButton(
          yearText,
          _currentMode == DatePickerMode.year,
          _selectedYear != null || _currentMode == DatePickerMode.year,
          () => setState(() => _currentMode = DatePickerMode.year),
        ),
        Text(
          ' - ',
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
        ),
        _buildHeaderButton(
          monthText,
          _currentMode == DatePickerMode.month,
          _selectedYear != null,
          () {
            if (_selectedYear == null) {
              setState(() {
                _currentMode = DatePickerMode.year;
                _hasScrolledToMonth = false;
              });
            } else {
              setState(() {
                _currentMode = DatePickerMode.month;
                _hasScrolledToMonth = false;
              });
              _scrollToSelectedMonth();
            }
          },
        ),
        Text(
          ' - ',
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
        ),
        _buildHeaderButton(
          dayText,
          _currentMode == DatePickerMode.day,
          _selectedYear != null && _selectedMonth != null,
          () {
            if (_selectedYear == null) {
              setState(() => _currentMode = DatePickerMode.year);
            } else if (_selectedMonth == null) {
              setState(() {
                _currentMode = DatePickerMode.month;
                _hasScrolledToMonth = false;
              });
              _scrollToSelectedMonth();
            } else {
              setState(() {
                _currentMode = DatePickerMode.day;
                _hasScrolledToMonth = false;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAllButton() {
    final isSelected = widget.isAllMode;
    return GestureDetector(
      onTap: () {
        if (widget.isAllMode) {
          _updateSelectedDate();
        } else {
          widget.onDateSelected(DateTime.now(), DateTime.now(), true);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? null
              : Border.all(color: AppColors.assistantText, width: 1),
        ),
        child: Text(
          '全部'.tr,
          style: TextStyle(
            fontSize: 10.sp,
            color: isSelected ? Colors.white : AppColors.primaryText,
          ),
        ).padding(all: 2).center(),
      ),
    );
  }

  Widget _buildHeaderButton(
    String text,
    bool isSelected,
    bool isEnabled,
    VoidCallback onTap,
  ) {
    final isPlaceholder = text == '請選擇';
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: !isEnabled
                ? AppColors.assistantText.withOpacity(0.5)
                : (isPlaceholder
                      ? AppColors.assistantText
                      : (isSelected
                            ? AppColors.primary
                            : AppColors.primaryText)),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentMode) {
      case DatePickerMode.year:
        return _buildYearView();
      case DatePickerMode.month:
        return _buildMonthView();
      case DatePickerMode.day:
        return _buildDayView();
    }
  }

  Widget _buildYearView() {
    final currentYear = DateTime.now().year;
    final years = [currentYear - 1, currentYear, currentYear + 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: years.map((year) {
        final isSelected = year == _selectedYear;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedYear = year;
              _selectedMonth = null;
              _selectedDay = null;
              _currentMode = DatePickerMode.month;
              _hasScrolledToMonth = false;
              _updateSelectedDate();
            });
            _scrollToSelectedMonth();
          },
          child: Container(
            width: 60.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.assistantText,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected ? Colors.white : AppColors.primaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _scrollToSelectedMonth() {
    if (_selectedMonth == null || _hasScrolledToMonth) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 10), () {
        if (_monthScrollController.hasClients &&
            _currentMode == DatePickerMode.month &&
            !_hasScrolledToMonth) {
          final selectedIndex = _selectedMonth! - 1;
          final itemWidth = 60.w + 8.w;
          var targetOffset = selectedIndex * itemWidth;

          final position = _monthScrollController.position;
          final maxScrollExtent = position.maxScrollExtent;
          final minScrollExtent = position.minScrollExtent;

          targetOffset = targetOffset.clamp(minScrollExtent, maxScrollExtent);

          position.jumpTo(targetOffset);

          _hasScrolledToMonth = true;
        }
      });
    });
  }

  Widget _buildMonthView() {
    final months = List.generate(12, (index) => index + 1);

    if (!_hasScrolledToMonth && _currentMode == DatePickerMode.month) {
      _scrollToSelectedMonth();
    }

    return SizedBox(
      height: 30.w,
      child: ListView.separated(
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: months.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month == _selectedMonth;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMonth = month;
                _selectedDay = null;
                _currentMode = DatePickerMode.day;
                _updateSelectedDate();
              });
            },
            child: Container(
              width: 60.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8.w),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.assistantText, width: 1),
              ),
              child: Center(
                child: Text(
                  '$month月'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : AppColors.primaryText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayView() {
    if (_selectedYear == null || _selectedMonth == null) {
      return const SizedBox.shrink();
    }

    final effectiveFirstDay =
        widget.firstDay ?? DateTime.now().subtract(const Duration(days: 365));
    final effectiveLastDay =
        widget.lastDay ?? DateTime.now().add(const Duration(days: 365));

    final focusedDate = DateTime(
      _selectedYear!,
      _selectedMonth!,
      _selectedDay ?? 1,
    );
    final selectedDate = _selectedDay != null
        ? DateTime(_selectedYear!, _selectedMonth!, _selectedDay!)
        : null;

    return TableCalendar(
      locale: LocalizationService.to.locale.toLanguageTag(),
      focusedDay: focusedDate,
      firstDay: effectiveFirstDay,
      lastDay: effectiveLastDay,
      calendarFormat: widget.calendarFormat,
      daysOfWeekHeight: widget.daysOfWeekHeight,
      rowHeight: widget.rowHeight,
      startingDayOfWeek: widget.startingDayOfWeek,
      headerVisible: false,
      calendarStyle: _calendarStyle,
      calendarBuilders: _calendarBuilders,
      daysOfWeekStyle: _daysOfWeekStyle,
      selectedDayPredicate: (day) {
        return selectedDate != null && isSameDay(selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          if (selectedDay.year != _selectedYear ||
              selectedDay.month != _selectedMonth) {
            _selectedYear = selectedDay.year;
            _selectedMonth = selectedDay.month;
          }
          _selectedDay = selectedDay.day;
          _updateSelectedDate();
        });
      },
    );
  }

  CalendarBuilders get _calendarBuilders => CalendarBuilders(
    defaultBuilder: (context, date, focused) {
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isFuture = dateOnly.isAfter(todayOnly);

      final isSelected =
          _selectedDay != null &&
          _selectedYear != null &&
          _selectedMonth != null &&
          date.year == _selectedYear! &&
          date.month == _selectedMonth! &&
          date.day == _selectedDay!;

      Color textColor;
      if (isSelected) {
        textColor = Colors.white;
      } else if (isFuture) {
        textColor = AppColors.primaryText.withOpacity(0.5);
      } else {
        textColor = AppColors.primaryText;
      }

      return Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(fontSize: 12.sp, color: textColor),
          ),
        ),
      );
    },
  );

  CalendarStyle get _calendarStyle => CalendarStyle(
    outsideDaysVisible: false,
    outsideTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
    weekendTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
    todayDecoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    todayTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
    selectedDecoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    defaultTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
    selectedTextStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
  );

  DaysOfWeekStyle get _daysOfWeekStyle => DaysOfWeekStyle(
    dowTextFormatter: (date, locale) {
      return DateFormat(
        'E',
        LocalizationService.to.locale.languageCode,
      ).format(date)[1];
    },
    weekdayStyle: TextStyle(color: AppColors.assistantText, fontSize: 12.sp),
    weekendStyle: TextStyle(color: AppColors.assistantText, fontSize: 12.sp),
  );

  void _updateSelectedDate() {
    if (_selectedYear != null) {
      DateTime startDate;
      DateTime endDate;

      if (_selectedMonth != null && _selectedDay != null) {
        final date = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
        startDate = date;
        endDate = date;
        _selectedDate = date;
      } else if (_selectedMonth != null) {
        startDate = DateTime(_selectedYear!, _selectedMonth!, 1);
        final lastDay = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
        endDate = DateTime(_selectedYear!, _selectedMonth!, lastDay);
      } else {
        startDate = DateTime(_selectedYear!, 1, 1);
        endDate = DateTime(_selectedYear!, 12, 31);
      }
      widget.onDateSelected(startDate, endDate, false);
    }
  }
}
