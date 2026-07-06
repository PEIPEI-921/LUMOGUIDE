import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:table_calendar/table_calendar.dart';

class DatePickerCalendarWidget extends StatefulWidget {
  const DatePickerCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isAllMode = false,
    this.firstDay,
    this.lastDay,
    this.startingDayOfWeek = StartingDayOfWeek.monday,
  });

  final DateTime selectedDate;
  final Function(DateTime startDate, DateTime endDate, bool allMode)
      onDateSelected;
  final bool isAllMode;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final StartingDayOfWeek startingDayOfWeek;

  @override
  State<DatePickerCalendarWidget> createState() =>
      _DatePickerCalendarWidgetState();
}

class _DatePickerCalendarWidgetState extends State<DatePickerCalendarWidget> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  // 滑轮选择器状态
  bool _showYearWheel = false;
  bool _showMonthWheel = false;
  late FixedExtentScrollController _yearScrollCtrl;
  late FixedExtentScrollController _monthScrollCtrl;
  late TextEditingController _yearInputCtrl;
  late TextEditingController _monthInputCtrl;

  static const _itemExtent = 40.0;

  static const _startYear = 1970;
  static const _endYear = 3000;
  List<int> get _years =>
      List.generate(_endYear - _startYear + 1, (i) => _startYear + i);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);

    final yearIdx = _years.indexOf(_focusedMonth.year);
    _yearScrollCtrl =
        FixedExtentScrollController(initialItem: yearIdx.clamp(0, _years.length - 1));
    _monthScrollCtrl =
        FixedExtentScrollController(initialItem: _focusedMonth.month - 1);
    _yearInputCtrl = TextEditingController(text: '${_focusedMonth.year}');
    _monthInputCtrl = TextEditingController(text: '${_focusedMonth.month}');
  }

  @override
  void dispose() {
    _yearScrollCtrl.dispose();
    _monthScrollCtrl.dispose();
    _yearInputCtrl.dispose();
    _monthInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            8.w.verticalSpace,
            if (_showYearWheel)
              _buildYearWheel()
            else if (_showMonthWheel)
              _buildMonthWheel()
            else
              _buildCalendar(),
          ],
        ).padding(horizontal: 15.w, vertical: 12.w).decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
        ),
        // "全部" 模式遮罩
        if (widget.isAllMode)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.w),
              ),
            ),
          ).positioned(top: 0, left: 0, right: 0, bottom: 0),
        _buildAllButton().positioned(top: 12.w, right: 6.w),
      ],
    );
  }

  // ---------- 全部 / 单日切换按钮 ----------
  Widget _buildAllButton() {
    final isSelected = widget.isAllMode;
    return GestureDetector(
      onTap: () {
        if (widget.isAllMode) {
          widget.onDateSelected(_selectedDate, _selectedDate, false);
        } else {
          widget.onDateSelected(DateTime.now(), DateTime.now(), true);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.w),
          border: isSelected
              ? null
              : Border.all(color: AppColors.assistantText, width: 0.5),
        ),
        child: Text(
          '全部'.tr,
          style: TextStyle(
            fontSize: 11.sp,
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ---------- 头部 ----------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 年份按钮
        _headerChip(
          '${_focusedMonth.year}年',
          _showYearWheel,
          () => setState(() {
            _showYearWheel = !_showYearWheel;
            _showMonthWheel = false;
            if (_showYearWheel) {
              _syncWheelToFocused();
            }
          }),
        ),
        SizedBox(width: 8.w),
        // 月份按钮
        _headerChip(
          '${_focusedMonth.month}月',
          _showMonthWheel,
          () => setState(() {
            _showMonthWheel = !_showMonthWheel;
            _showYearWheel = false;
            if (_showMonthWheel) {
              _syncWheelToFocused();
            }
          }),
        ),
      ],
    ).padding(horizontal: 10.w);
  }

  void _syncWheelToFocused() {
    final yearIdx = _years.indexOf(_focusedMonth.year);
    if (yearIdx >= 0 && _yearScrollCtrl.hasClients) {
      _yearScrollCtrl.jumpToItem(yearIdx);
    }
    if (_monthScrollCtrl.hasClients) {
      _monthScrollCtrl.jumpToItem(_focusedMonth.month - 1);
    }
    _yearInputCtrl.text = '${_focusedMonth.year}';
    _monthInputCtrl.text = '${_focusedMonth.month}';
  }

  Widget _headerChip(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.assistantText.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              isActive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 16.sp,
              color: AppColors.assistantText,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- 年份滑轮选择器 ----------
  Widget _buildYearWheel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 输入框
        _buildInputRow(
          controller: _yearInputCtrl,
          suffix: '年',
          onSubmit: (val) {
            final y = int.tryParse(val);
            if (y != null && y >= _startYear && y <= _endYear) {
              setState(() {
                _focusedMonth = DateTime(y, _focusedMonth.month);
                _syncWheelToFocused();
              });
            }
          },
        ),
        8.w.verticalSpace,
        // 滑轮
        SizedBox(
          height: _itemExtent * 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListWheelScrollView.useDelegate(
                controller: _yearScrollCtrl,
                itemExtent: _itemExtent,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (idx) {
                  _yearInputCtrl.text = '${_years[idx]}';
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final y = _years[index];
                    final isSelected = y == _focusedMonth.year;
                    return Center(
                      child: Text(
                        '$y',
                        style: TextStyle(
                          fontSize: isSelected ? 22.sp : 16.sp,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.assistantText,
                        ),
                      ),
                    );
                  },
                  childCount: _years.length,
                ),
              ),
              // 选中遮罩边框
              IgnorePointer(
                child: Container(
                  height: _itemExtent,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1),
                      bottom: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        10.w.verticalSpace,
        _buildConfirmButton(() {
          final idx = _yearScrollCtrl.selectedItem;
          setState(() {
            _focusedMonth = DateTime(_years[idx], _focusedMonth.month);
            _showYearWheel = false;
            _showMonthWheel = true;
            _monthScrollCtrl.jumpToItem(_focusedMonth.month - 1);
            _monthInputCtrl.text = '${_focusedMonth.month}';
          });
        }),
      ],
    );
  }

  // ---------- 月份滑轮选择器 ----------
  Widget _buildMonthWheel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInputRow(
          controller: _monthInputCtrl,
          suffix: '月',
          onSubmit: (val) {
            final m = int.tryParse(val);
            if (m != null && m >= 1 && m <= 12) {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, m);
                _syncWheelToFocused();
              });
            }
          },
        ),
        8.w.verticalSpace,
        SizedBox(
          height: _itemExtent * 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListWheelScrollView.useDelegate(
                controller: _monthScrollCtrl,
                itemExtent: _itemExtent,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (idx) {
                  _monthInputCtrl.text = '${idx + 1}';
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final m = index + 1;
                    final isSelected = m == _focusedMonth.month;
                    return Center(
                      child: Text(
                        '$m 月',
                        style: TextStyle(
                          fontSize: isSelected ? 22.sp : 16.sp,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.assistantText,
                        ),
                      ),
                    );
                  },
                  childCount: 12,
                ),
              ),
              IgnorePointer(
                child: Container(
                  height: _itemExtent,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1),
                      bottom: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        10.w.verticalSpace,
        _buildConfirmButton(() {
          final idx = _monthScrollCtrl.selectedItem;
          setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, idx + 1);
            _showMonthWheel = false;
          });
        }),
      ],
    );
  }

  // ---------- 输入行 ----------
  Widget _buildInputRow({
    required TextEditingController controller,
    required String suffix,
    required Function(String) onSubmit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80.w,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8.w),
              isDense: true,
              filled: true,
              fillColor: AppColors.backgroundBlue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onSubmitted: onSubmit,
            onEditingComplete: () => onSubmit(controller.text),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          suffix,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // ---------- 确认按钮 ----------
  Widget _buildConfirmButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.w),
        ),
        child: Text(
          '確定',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------- 日历主体 ----------
  Widget _buildCalendar() {
    final effectiveFirstDay =
        widget.firstDay ?? DateTime(_startYear, 1, 1);
    final effectiveLastDay =
        widget.lastDay ?? DateTime(_endYear, 12, 31);

    return TableCalendar(
      locale: LocalizationService.to.locale.toLanguageTag(),
      focusedDay: _focusedMonth,
      firstDay: effectiveFirstDay,
      lastDay: effectiveLastDay,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: widget.startingDayOfWeek,
      headerVisible: false,
      daysOfWeekHeight: 28.w,
      rowHeight: 42.w,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      calendarStyle: _calendarStyle,
      calendarBuilders: _calendarBuilders,
      daysOfWeekStyle: _daysOfWeekStyle,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedMonth = DateTime(selectedDay.year, selectedDay.month);
          widget.onDateSelected(selectedDay, selectedDay, false);
        });
      },
      onPageChanged: (focusedDay) {
        _focusedMonth = focusedDay;
      },
    );
  }

  CalendarBuilders get _calendarBuilders => CalendarBuilders(
    defaultBuilder: (context, date, focused) {
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isToday = dateOnly == todayOnly;
      final isSelected = isSameDay(date, _selectedDate);
      final isCurrentMonth = date.month == _focusedMonth.month;
      final isFuture = dateOnly.isAfter(todayOnly);

      Color bgColor = Colors.transparent;
      Color textColor;

      if (isSelected) {
        bgColor = AppColors.primary;
        textColor = Colors.white;
      } else if (!isCurrentMonth) {
        textColor = AppColors.assistantText.withValues(alpha: 0.35);
      } else if (!isFuture && !isToday) {
        textColor = AppColors.assistantText;
      } else {
        textColor = AppColors.primaryText;
      }

      return Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.w),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 13.sp,
              color: textColor,
              fontWeight:
                  isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    },
  );

  CalendarStyle get _calendarStyle => CalendarStyle(
    outsideDaysVisible: true,
    outsideTextStyle: TextStyle(
      color: AppColors.assistantText.withValues(alpha: 0.35),
      fontSize: 13.sp,
    ),
    weekendTextStyle: TextStyle(
      color: AppColors.primaryText,
      fontSize: 13.sp,
    ),
    todayDecoration: const BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
    ),
    todayTextStyle: TextStyle(
      color: AppColors.primaryText,
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
    ),
    selectedDecoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    defaultTextStyle: TextStyle(
      color: AppColors.primaryText,
      fontSize: 13.sp,
    ),
    selectedTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
    ),
    markerDecoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
  );

  DaysOfWeekStyle get _daysOfWeekStyle => DaysOfWeekStyle(
    dowTextFormatter: (date, locale) {
      final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      return weekdays[date.weekday - 1];
    },
    weekdayStyle: TextStyle(
      color: AppColors.secondaryText,
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
    ),
    weekendStyle: TextStyle(
      color: AppColors.primary,
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
    ),
  );
}
