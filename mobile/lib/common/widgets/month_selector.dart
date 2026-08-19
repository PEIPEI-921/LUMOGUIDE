import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MonthSelectorWidget extends StatelessWidget {
  const MonthSelectorWidget({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final int selectedYear;
  final int selectedMonth;
  final Function(int year, int month) onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;
    final years = [currentYear - 1, currentYear, currentYear + 1];
    final availableMonths = getAvailableMonthsForYear(
      selectedYear,
      currentYear,
      currentMonth,
    );

    return Column(
      children: [
        _buildYearSelector(years),
        6.w.verticalSpace,
        _buildMonthGrid(availableMonths),
      ],
    ).padding(horizontal: 10.w, bottom: 6.w, top: 6.w);
  }

  List<int> getAvailableMonthsForYear(
    int year,
    int currentYear,
    int currentMonth,
  ) {
    if (year == currentYear - 1) {
      // 前一年：从当前月份开始到12月
      return List.generate(
        12 - currentMonth + 1,
        (index) => currentMonth + index,
      );
    } else if (year == currentYear) {
      // 当前年：1月到12月
      return List.generate(12, (index) => index + 1);
    } else if (year == currentYear + 1) {
      // 后一年：1月到当前月份
      return List.generate(currentMonth, (index) => index + 1);
    }
    return [];
  }

  Widget _buildYearSelector(List<int> years) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: years.map((year) {
        final isSelected = year == selectedYear;
        return GestureDetector(
          onTap: () {
            final currentYear = DateTime.now().year;
            final currentMonth = DateTime.now().month;
            final availableMonths = getAvailableMonthsForYear(
              year,
              currentYear,
              currentMonth,
            );

            // 如果当前选中的月份不在新年份的可用范围内，选择第一个可用月份
            int newMonth = selectedMonth;
            if (!availableMonths.contains(selectedMonth)) {
              newMonth = availableMonths.isNotEmpty ? availableMonths.first : 1;
            }

            onMonthSelected(year, newMonth);
          },
          child: Container(
            width: 65.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20.w),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.assistantText,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isSelected ? Colors.white : AppColors.primaryText,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).padding(right: 50.w);
  }

  Widget _buildMonthGrid(List<int> months) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 2.2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        final isSelected = month == selectedMonth;

        return GestureDetector(
          onTap: () => onMonthSelected(selectedYear, month),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.w),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.assistantText,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$month月'.tr,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.assistantText,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
