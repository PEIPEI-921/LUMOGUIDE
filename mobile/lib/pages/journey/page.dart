import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lumotrip/common/index.dart';
import 'controller.dart';

class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JourneyController());

    return IScaffold(
      title: '我的工作'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: IRefresh(
        controller: controller,
        child: CustomScrollView(
          slivers: [
            // 搜索栏
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              sliver: SliverToBoxAdapter(
                  child: _SearchBar(controller: controller)),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.w)),
            // 状态筛选
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              sliver: SliverToBoxAdapter(
                  child: _StatusFilter(controller: controller)),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.w)),
            // 区域筛选
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              sliver: SliverToBoxAdapter(
                  child: _RegionFilter(controller: controller)),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.w)),
            // 日历卡片
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              sliver: SliverToBoxAdapter(
                  child: _JourneyCalendar(controller: controller)),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.w)),
            // 图例
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              sliver:
                  SliverToBoxAdapter(child: const _StatusLegend()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.w)),
            // 行程卡片 — 用 Obx 只包裹列表部分
            Obx(
              () {
                if (controller.filteredWorks.isEmpty) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200.w,
                        child: _JourneyEmptyWidget(),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 10.w),
                        child: _WorkCard(
                          work: controller.filteredWorks[index],
                          onTap: () => controller
                              .onTapWork(controller.filteredWorks[index]),
                        ),
                      ),
                      childCount: controller.filteredWorks.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => controller.onAddWork(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// =============== 搜索栏 ===============
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final JourneyController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 胶囊输入框
        Container(
          height: 38.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19.w),
          ),
          child: TextField(
            controller: controller.searchCtrl,
            style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: '請輸入工作名稱',
              hintStyle: TextStyle(
                  fontSize: 13.sp, color: AppColors.assistantText),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
              border: InputBorder.none,
            ),
          ),
        ).expanded(),
        8.w.horizontalSpace,
        // 紫色搜索按钮
        GestureDetector(
          onTap: () {}, // 输入时实时搜索，按钮仅作视觉标识
          child: Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Icon(Icons.search, size: 20.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// =============== 状态筛选 ===============
class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.controller});
  final JourneyController controller;

  static const _items = [
    (0, '全部'),
    (1, '进行中'),
    (2, '待出发'),
    (3, '已结束'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _items.map((e) {
            final selected = controller.statusFilter.value == e.$1;
            return GestureDetector(
              onTap: () => controller.onStatusChanged(e.$1),
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.w),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Text(
                  e.$2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: selected ? Colors.white : AppColors.secondaryText,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// =============== 区域筛选 ===============
class _RegionFilter extends StatelessWidget {
  const _RegionFilter({required this.controller});
  final JourneyController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.regions.length <= 1
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.regions.map((r) {
                  final selected = controller.regionFilter.value == r;
                  return GestureDetector(
                    onTap: () => controller.onRegionChanged(r),
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.w),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                      child: Text(
                        r,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              selected ? Colors.white : AppColors.secondaryText,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

// =============== 日历卡片 ===============
class _JourneyCalendar extends StatefulWidget {
  const _JourneyCalendar({required this.controller});
  final JourneyController controller;

  @override
  State<_JourneyCalendar> createState() => _JourneyCalendarState();
}

class _JourneyCalendarState extends State<_JourneyCalendar> {
  DateTime? _selected;

  JourneyController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _selected = _ctrl.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 月导航
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _ctrl.onMonthChanged(DateTime(
                    _ctrl.focusedMonth.year,
                    _ctrl.focusedMonth.month - 1,
                  )),
                  child: Icon(Icons.chevron_left,
                      size: 20.sp, color: AppColors.secondaryText),
                ),
                Text(
                  '${_ctrl.focusedMonth.year}.${_ctrl.focusedMonth.month}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                GestureDetector(
                  onTap: () => _ctrl.onMonthChanged(DateTime(
                    _ctrl.focusedMonth.year,
                    _ctrl.focusedMonth.month + 1,
                  )),
                  child: Icon(Icons.chevron_right,
                      size: 20.sp, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          6.w.verticalSpace,
          TableCalendar(
            key: ValueKey(_ctrl.focusedMonth),
            locale: LocalizationService.to.locale.toLanguageTag(),
            focusedDay: _ctrl.focusedMonth,
            firstDay: DateTime(2020),
            lastDay: DateTime(2035),
            calendarFormat: CalendarFormat.month,
            headerVisible: false,
            daysOfWeekHeight: 22.w,
            rowHeight: 34.w,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              _selected = _ctrl.selectedDay;
              return _selected != null && isSameDay(_selected!, day);
            },
            onDaySelected: (day, _) => _ctrl.onDaySelected(day),
            onPageChanged: (day) => _ctrl.onMonthChanged(day),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                // 计算该日期对应的最高优先级状态
                JourneyWorkStatus? status;
                for (final w in _ctrl.allWorks) {
                  final d = DateTime(date.year, date.month, date.day);
                  final start = DateTime.tryParse(w.startDate ?? '');
                  final end = DateTime.tryParse(w.endDate ?? '');
                  if (start == null || end == null) continue;
                  final s = DateTime(start.year, start.month, start.day);
                  final e = DateTime(end.year, end.month, end.day);
                  if (!d.isBefore(s) && !d.isAfter(e)) {
                    final st = w.effectiveStatus;
                    // 优先级：进行中 > 待出发 > 已结束
                    if (status == null ||
                        st == JourneyWorkStatus.inProgress ||
                        (st == JourneyWorkStatus.pending &&
                            status == JourneyWorkStatus.ended)) {
                      status = st;
                    }
                  }
                }
                return _dayCell(date, status);
              },
            ),
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, _) {
                const w = ['一', '二', '三', '四', '五', '六', '日'];
                return w[date.weekday - 1];
              },
              weekdayStyle: TextStyle(
                  fontSize: 11.sp, color: AppColors.secondaryText),
              weekendStyle:
                  TextStyle(fontSize: 11.sp, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime date, JourneyWorkStatus? status) {
    final isSelected =
        _ctrl.selectedDay != null && isSameDay(date, _ctrl.selectedDay!);
    // 背景色：选中 > 进行中(绿) > 待出发(紫) > 已结束(灰)
    Color? bgColor;
    if (isSelected) {
      bgColor = AppColors.primary;
    } else if (status == JourneyWorkStatus.inProgress) {
      bgColor = AppColors.jadeGreen.withValues(alpha: 0.25);
    } else if (status == JourneyWorkStatus.pending) {
      bgColor = AppColors.primary.withValues(alpha: 0.15);
    } else if (status == JourneyWorkStatus.ended) {
      bgColor = AppColors.assistantText.withValues(alpha: 0.12);
    }

    // 底部小圆点：进行中=绿, 待出发=紫, 已结束=灰
    Color? dotColor;
    if (!isSelected && status != null) {
      switch (status) {
        case JourneyWorkStatus.inProgress:
          dotColor = AppColors.jadeGreen;
          break;
        case JourneyWorkStatus.pending:
          dotColor = AppColors.primary;
          break;
        case JourneyWorkStatus.ended:
          dotColor = AppColors.assistantText;
          break;
      }
    }

    return Container(
      margin: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.primaryText,
            ),
          ),
          if (dotColor != null)
            Positioned(
              bottom: 2.w,
              child: Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============== 状态图例 ===============
class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.jadeGreen, label: '进行中'),
        SizedBox(width: 20.w),
        _LegendItem(color: AppColors.primary, label: '即将开始'),
        SizedBox(width: 20.w),
        _LegendItem(color: AppColors.assistantText, label: '已结束'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        5.w.horizontalSpace,
        Text(label,
            style:
                TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
      ],
    );
  }
}

// =============== 工作卡片 ===============
class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.work, required this.onTap});
  final JourneyWork work;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (work.effectiveStatus) {
      case JourneyWorkStatus.inProgress:
        return AppColors.jadeGreen;
      case JourneyWorkStatus.pending:
        return AppColors.primary;
      case JourneyWorkStatus.ended:
        return AppColors.assistantText;
    }
  }

  String get _shortDate {
    // 07/08 - 07/08日
    String shorten(String? d) {
      if (d == null || d.length < 10) return d ?? '';
      return d.substring(5); // "yyyy-MM-dd" → "MM-dd"
    }

    final s = shorten(work.startDate);
    final e = shorten(work.endDate);
    return '$s - ${e}日';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 第一行：地区标签 + 标题 + 状态 ----
            Row(
              children: [
                // 地区标签
                if (work.region?.isNotEmpty == true)
                  Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4.w),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      work.region!,
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                // 标题
                Text(
                  work.title ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ).expanded(),
                // 状态标签
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.w),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Text(
                    work.effectiveStatus.label,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: _statusColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            10.w.verticalSpace,
            // ---- 第二、三行：详情（纵向排列） ----
            _DetailRow(
                icon: Icons.people,
                text: '${work.peopleCount ?? 0}人'),
            6.w.verticalSpace,
            _DetailRow(
                icon: Icons.calendar_today, text: _shortDate),
            6.w.verticalSpace,
            if (work.cities.isNotEmpty)
              _DetailRow(
                  icon: Icons.location_on,
                  text: work.cities.join('、')),
            // 预约同步标记
            if (work.isFromBooking)
              Padding(
                padding: EdgeInsets.only(top: 6.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 11.sp,
                        color: AppColors.jadeGreen),
                    4.w.horizontalSpace,
                    Text('预约同步',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.jadeGreen)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.assistantText),
        6.w.horizontalSpace,
        Text(text,
            style:
                TextStyle(fontSize: 12.sp, color: AppColors.secondaryText)),
      ],
    );
  }
}

// =============== 空状态（不用 EmptyListWidget 避免嵌套 ListView） ===============
class _JourneyEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Assets.iconEmpty, height: 110.w),
          SizedBox(height: 18.w),
          Text(
            '暫無工作行程',
            style: const TextStyle(
              color: AppColors.assistantText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
