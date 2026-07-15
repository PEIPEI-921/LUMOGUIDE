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
            _sliverPad(child: _SearchBar(controller: controller)),
            _gap(12),
            // 状态筛选
            _sliverPad(child: _StatusFilter(controller: controller)),
            _gap(12),
            // 区域筛选
            _sliverPad(child: _RegionFilter(controller: controller)),
            _gap(12),
            // 日历
            _sliverPad(child: _JourneyCalendar(controller: controller)),
            _gap(12),
            // 图例
            _sliverPad(child: const _StatusLegend()),
            _gap(12),
            // ===== 工作列表：活跃在上，已结束在下 =====
            Obx(() {
              final list = controller.filteredWorks;
              if (list.isEmpty) {
                return _sliverPad(child: SizedBox(height: 200.w, child: _JourneyEmptyWidget()));
              }
              final active = list.where((w) => w.effectiveStatus != JourneyWorkStatus.ended).toList();
              final ended = list.where((w) => w.effectiveStatus == JourneyWorkStatus.ended).toList();
              final hasEnded = ended.isNotEmpty;

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      // 已结束分隔线
                      if (hasEnded && i == active.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.w),
                          child: Row(children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text('已结束', style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ]),
                        );
                      }
                      final w = i < active.length ? active[i] : ended[i - active.length - 1];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.w),
                        child: _WorkCard(work: w, onTap: () => controller.onTapWork(w)),
                      );
                    },
                    childCount: active.length + ended.length + (hasEnded ? 1 : 0),
                  ),
                ),
              );
            }),
            _gap(80),
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

SliverPadding _sliverPad({required Widget child}) =>
    SliverPadding(padding: EdgeInsets.symmetric(horizontal: 14.w), sliver: SliverToBoxAdapter(child: child));

SliverToBoxAdapter _gap(double h) => SliverToBoxAdapter(child: SizedBox(height: h.w));

// =============== 搜索栏 ===============
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final JourneyController controller;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(height: 38.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19.w)),
      child: TextField(controller: controller.searchCtrl,
        style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
        decoration: InputDecoration(hintText: '搜索工作', hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.assistantText),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w), border: InputBorder.none))).expanded(),
    8.w.horizontalSpace,
    Container(width: 38.w, height: 38.w,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10.w)),
      child: Icon(Icons.search, size: 20.sp, color: Colors.white)),
  ]);
}

// =============== 状态筛选 ===============
class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.controller});
  final JourneyController controller;
  static const _items = [(0, '全部'), (1, '进行中'), (2, '待出发'), (3, '已结束')];
  @override
  Widget build(BuildContext context) => Obx(() => Row(children: _items.map((e) {
    final s = controller.statusFilter.value == e.$1;
    return GestureDetector(onTap: () => controller.onStatusChanged(e.$1),
      child: Container(
        margin: EdgeInsets.only(right: 6.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.w),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(
          color: s ? AppColors.primary : Colors.transparent, width: 2))),
        child: Text(e.$2, style: TextStyle(fontSize: 13.sp,
          color: s ? AppColors.primary : AppColors.secondaryText,
          fontWeight: s ? FontWeight.w600 : FontWeight.normal))));
  }).toList()));
}

// =============== 区域筛选 ===============
class _RegionFilter extends StatelessWidget {
  const _RegionFilter({required this.controller});
  final JourneyController controller;
  @override
  Widget build(BuildContext context) => Obx(() {
    if (controller.regions.length <= 1) return const SizedBox.shrink();
    return Row(children: [
      Icon(Icons.location_on_outlined, size: 14.sp, color: AppColors.assistantText),
      SizedBox(width: 6.w),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(controller.regions.length, (i) {
              final r = controller.regions[i];
              final selected = controller.regionFilter.value == r;
              return GestureDetector(
                onTap: () => controller.onRegionChanged(r),
                child: Container(
                  margin: EdgeInsets.only(right: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(4.w),
                    border: Border.all(
                      color: selected ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey.shade200,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: selected ? AppColors.primary : AppColors.secondaryText,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ]);
  });
}

// =============== 日历 ===============
class _JourneyCalendar extends StatefulWidget {
  const _JourneyCalendar({required this.controller});
  final JourneyController controller;
  @override State<_JourneyCalendar> createState() => _JourneyCalendarState();
}
class _JourneyCalendarState extends State<_JourneyCalendar> {
  JourneyController get _ctrl => widget.controller;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.w),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))]),
    child: Column(children: [
      Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(onTap: () => _ctrl.onMonthChanged(DateTime(_ctrl.focusedMonth.year, _ctrl.focusedMonth.month - 1)),
          child: Icon(Icons.chevron_left, size: 20.sp, color: AppColors.secondaryText)),
        Text('${_ctrl.focusedMonth.year}.${_ctrl.focusedMonth.month}',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
        GestureDetector(onTap: () => _ctrl.onMonthChanged(DateTime(_ctrl.focusedMonth.year, _ctrl.focusedMonth.month + 1)),
          child: Icon(Icons.chevron_right, size: 20.sp, color: AppColors.secondaryText)),
      ])),
      6.w.verticalSpace,
      TableCalendar(
        key: ValueKey(_ctrl.focusedMonth), locale: LocalizationService.to.locale.toLanguageTag(),
        focusedDay: _ctrl.focusedMonth, firstDay: DateTime(2020), lastDay: DateTime(2035),
        calendarFormat: CalendarFormat.month, headerVisible: false,
        daysOfWeekHeight: 22.w, rowHeight: 34.w, startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => _ctrl.selectedDay != null && isSameDay(_ctrl.selectedDay!, day),
        onDaySelected: (day, _) => _ctrl.onDaySelected(day),
        onPageChanged: (day) => _ctrl.onMonthChanged(day),
        calendarBuilders: CalendarBuilders(defaultBuilder: (context, date, _) {
          JourneyWorkStatus? st;
          for (final w in _ctrl.allWorks) {
            final d = DateTime(date.year, date.month, date.day);
            final s = DateTime.tryParse(w.startDate ?? ''); final e = DateTime.tryParse(w.endDate ?? '');
            if (s == null || e == null) continue;
            if (!d.isBefore(DateTime(s.year, s.month, s.day)) && !d.isAfter(DateTime(e.year, e.month, e.day))) {
              final cs = w.effectiveStatus;
              if (st == null || cs == JourneyWorkStatus.inProgress ||
                  (cs == JourneyWorkStatus.pending && st == JourneyWorkStatus.ended)) st = cs;
            }
          }
          return _dayCell(date, st);
        }),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (d, _) => const ['一','二','三','四','五','六','日'][d.weekday-1],
          weekdayStyle: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText),
          weekendStyle: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
      ),
    ]),
  );

  Widget _dayCell(DateTime date, JourneyWorkStatus? status) {
    final isSelected = _ctrl.selectedDay != null && isSameDay(date, _ctrl.selectedDay!);
    Color? bg = isSelected ? AppColors.primary
      : status == JourneyWorkStatus.inProgress ? AppColors.jadeGreen.withValues(alpha: 0.25)
      : status == JourneyWorkStatus.pending ? AppColors.primary.withValues(alpha: 0.15)
      : status == JourneyWorkStatus.ended ? AppColors.assistantText.withValues(alpha: 0.12) : null;
    Color? dot = !isSelected && status != null
      ? (status == JourneyWorkStatus.inProgress ? AppColors.jadeGreen
        : status == JourneyWorkStatus.pending ? AppColors.primary : AppColors.assistantText) : null;
    return Container(margin: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(color: bg ?? Colors.transparent, borderRadius: BorderRadius.circular(6.w)),
      child: Stack(alignment: Alignment.center, children: [
        Text('${date.day}', style: TextStyle(fontSize: 12.sp,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.primaryText)),
        if (dot != null) Positioned(bottom: 2.w, child: Container(width: 5.w, height: 5.w, decoration: BoxDecoration(color: dot, shape: BoxShape.circle))),
      ]));
  }
}

// =============== 图例 ===============
class _StatusLegend extends StatelessWidget {
  const _StatusLegend();
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _Leg(color: AppColors.jadeGreen, label: '进行中'), SizedBox(width: 20.w),
    _Leg(color: AppColors.primary, label: '即将开始'), SizedBox(width: 20.w),
    _Leg(color: AppColors.assistantText, label: '已结束')]);
}
class _Leg extends StatelessWidget {
  final Color color; final String label;
  const _Leg({required this.color, required this.label});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10.w, height: 10.w, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.w))),
    5.w.horizontalSpace, Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText))]);
}

// =============== 工作卡片 ===============
class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.work, required this.onTap});
  final JourneyWork work; final VoidCallback onTap;
  Color get _sc => work.effectiveStatus == JourneyWorkStatus.inProgress ? AppColors.jadeGreen
    : work.effectiveStatus == JourneyWorkStatus.pending ? AppColors.primary : AppColors.assistantText;
  String get _sd { String s(String? d) => d != null && d.length >= 10 ? d.substring(5) : (d ?? ''); return '${s(work.startDate)} - ${s(work.endDate)}日'; }
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Opacity(opacity: work.effectiveStatus == JourneyWorkStatus.ended ? 0.45 : 1.0,
      child: Container(padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.w),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (work.region?.isNotEmpty == true) Container(margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4.w),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
              child: Text(work.region!, style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w600))),
            Text(work.title ?? '', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)).expanded(),
            Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.w),
              decoration: BoxDecoration(color: _sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.w)),
              child: Text(work.effectiveStatus.label, style: TextStyle(fontSize: 10.sp, color: _sc, fontWeight: FontWeight.w500))),
          ]),
          10.w.verticalSpace,
          _Dr(Icons.people, '${work.peopleCount ?? 0}人'), 6.w.verticalSpace,
          _Dr(Icons.calendar_today, _sd), 6.w.verticalSpace,
          if (work.cities.isNotEmpty) _Dr(Icons.location_on, work.cities.join('、')),
          if (work.isFromBooking) Padding(padding: EdgeInsets.only(top: 6.w),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.sync, size: 11.sp, color: AppColors.jadeGreen), 4.w.horizontalSpace,
              Text('预约同步', style: TextStyle(fontSize: 10.sp, color: AppColors.jadeGreen))])),
          ]))));
}
class _Dr extends StatelessWidget {
  final IconData icon; final String text; const _Dr(this.icon, this.text);
  @override Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14.sp, color: AppColors.assistantText), 6.w.horizontalSpace,
    Text(text, style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText))]);
}
class _JourneyEmptyWidget extends StatelessWidget {
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Image.asset(Assets.iconEmpty, height: 110.w), SizedBox(height: 18.w),
    Text('暂无工作行程', style: const TextStyle(color: AppColors.assistantText, fontSize: 14, fontWeight: FontWeight.w500))]));
}
