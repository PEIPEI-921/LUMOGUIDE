import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lumotrip/common/index.dart';
import 'controller.dart';
import 'widgets/template_picker_sheet.dart';

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
            _sliverPad(child: _StatusLegend(controller: controller)),
            _gap(12),
            // ===== 工作列表（按日期升序，不分块）=====
            Obx(() {
              final list = controller.filteredWorks;
              if (list.isEmpty) {
                return _sliverPad(child: SizedBox(height: 200.w, child: _JourneyEmptyWidget()));
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: EdgeInsets.only(bottom: 10.w),
                      child: _WorkCard(work: list[i], onTap: () => controller.onTapWork(list[i])),
                    ),
                    childCount: list.length,
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
        onPressed: () => _showCreateOptions(context, controller),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// FAB 弹出：新建工作分流面板
void _showCreateOptions(BuildContext context, JourneyController controller) {
  final bottomPadding = MediaQuery.of(context).padding.bottom;

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 10.w),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
        // 拖拽条 + 标题
        SizedBox(height: 10.w),
        Container(
            width: 36.w,
            height: 4.w,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.w))),
        SizedBox(height: 14.w),
        Text(
          '新建工作',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText),
        ),
        SizedBox(height: 16.w),
        // 选项列表
        _OptionRow(
          icon: Icons.edit_note,
          title: '空白创建',
          subtitle: '从头填写行程信息',
          onTap: () {
            Get.back();
            controller.onAddWork();
          },
        ),
        _OptionRow(
          icon: Icons.bookmark_outline,
          title: '从模板创建',
          subtitle: '选择已有模板快速创建',
          onTap: () async {
            Get.back();
            final template = await TemplatePickerSheet.show();
            if (template != null) {
              Get.toNamed(AppRoutes.JOURNEY_EDITOR,
                  arguments: {'template': template})?.then((_) => controller.onRefresh());
            }
          },
        ),
        _OptionRow(
          icon: Icons.camera_alt_outlined,
          title: '拍照导入',
          subtitle: '扫描纸质行程单',
          trailing: _ComingSoonTag(),
          onTap: () => Loading.toast('即将上线'),
        ),
        _OptionRow(
          icon: Icons.upload_file_outlined,
          title: '文件导入',
          subtitle: '导入 PDF/Word 行程文件',
          trailing: _ComingSoonTag(),
          onTap: () => Loading.toast('即将上线'),
        ),
        SizedBox(height: 8.w),
        // 取消按钮
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: SizedBox(
            width: double.infinity,
            height: 44.w,
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w)),
              ),
              child: Text('取消',
                  style: TextStyle(
                      fontSize: 14.sp, color: AppColors.assistantText)),
            ),
          ),
        ),
        SizedBox(height: 10.w),
      ]),
      ),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _OptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
        child: Row(children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText)),
                  if (trailing != null) ...[
                    SizedBox(width: 8.w),
                    trailing!,
                  ],
                ]),
                SizedBox(height: 2.w),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.assistantText)),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              size: 18.sp, color: AppColors.assistantText),
        ]),
      ),
    );
  }
}

class _ComingSoonTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Text('即将上线',
          style: TextStyle(fontSize: 9.sp, color: Colors.amber.shade700)),
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

/// 描述某一天在行程区间内的位置
class _DayEvent {
  final JourneyWork work;
  final int dayIndex;
  final int totalDays;
  final List<String> segments; // 预计算: 每格文字片段

  const _DayEvent({
    required this.work,
    required this.dayIndex,
    required this.totalDays,
    required this.segments,
  });

  bool get isStart => dayIndex == 0;
  bool get isEnd => dayIndex == totalDays - 1;
  bool get isSingle => totalDays == 1;
  bool get isInTitleZone => dayIndex < segments.length;

  Color get color => work.effectiveStatus == JourneyWorkStatus.inProgress
      ? AppColors.jadeGreen
      : work.effectiveStatus == JourneyWorkStatus.pending
          ? AppColors.primary
          : AppColors.assistantText;

  String titleSegment() {
    if (!isInTitleZone) return '';
    return segments[dayIndex];
  }
}

class _JourneyCalendar extends StatefulWidget {
  const _JourneyCalendar({required this.controller});
  final JourneyController controller;
  @override State<_JourneyCalendar> createState() => _JourneyCalendarState();
}

class _JourneyCalendarState extends State<_JourneyCalendar> {
  JourneyController get _ctrl => widget.controller;
  Worker? _monthWorker;

  final Map<int, List<String>> _segments = {};
  double _prevCellW = -1;
  static const double _titleFontSize = 9; // sp

  @override
  void initState() {
    super.initState();
    _monthWorker = ever(_ctrl.focusedMonthRx, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _monthWorker?.dispose();
    super.dispose();
  }

  /// 二分查找：从 pos 开始最多多少字符能放进 maxWidth
  int _charsThatFit(String text, int pos, TextStyle style, double maxWidth) {
    if (pos >= text.length || maxWidth <= 0) return 0;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    int lo = 0, hi = text.length - pos;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      tp.text = TextSpan(text: text.substring(pos, pos + mid), style: style);
      tp.layout();
      if (tp.width <= maxWidth) { lo = mid; } else { hi = mid - 1; }
    }
    return lo == 0 ? 1 : lo;
  }

  void _recomputeSegments(double cellContentWidth) {
    _segments.clear();
    final style = TextStyle(fontSize: _titleFontSize.sp, fontWeight: FontWeight.w600);
    for (final w in _ctrl.allWorks) {
      final title = w.title ?? '';
      if (title.isEmpty) continue;
      final segs = <String>[];
      int pos = 0;
      while (pos < title.length) {
        final fit = _charsThatFit(title, pos, style, cellContentWidth);
        segs.add(title.substring(pos, pos + fit));
        pos += fit;
      }
      _segments[w.id ?? identityHashCode(w)] = segs;
    }
  }

  /// 为当前日期找到最高优先级的事件及其在区间内的位置
  _DayEvent? _getEventForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final List<(JourneyWork, int prio)> hits = [];
    for (final w in _ctrl.allWorks) {
      final s = DateTime.tryParse(w.startDate ?? '');
      final e = DateTime.tryParse(w.endDate ?? '');
      if (s == null || e == null) continue;
      final start = DateTime(s.year, s.month, s.day);
      final end = DateTime(e.year, e.month, e.day);
      if (day.isBefore(start) || day.isAfter(end)) continue;
      final prio = w.effectiveStatus == JourneyWorkStatus.inProgress ? 0
          : w.effectiveStatus == JourneyWorkStatus.pending ? 1 : 2;
      hits.add((w, prio));
    }
    if (hits.isEmpty) return null;
    hits.sort((a, b) => a.$2.compareTo(b.$2));
    final best = hits.first.$1;
    final s = DateTime.tryParse(best.startDate ?? '')!;
    final e = DateTime.tryParse(best.endDate ?? '')!;
    final start = DateTime(s.year, s.month, s.day);
    final end = DateTime(e.year, e.month, e.day);
    final totalDays = end.difference(start).inDays + 1;
    final dayIndex = day.difference(start).inDays;
    final segs = _segments[best.id ?? identityHashCode(best)] ?? [];
    return _DayEvent(work: best, dayIndex: dayIndex, totalDays: totalDays, segments: segs);
  }

  @override
  Widget build(BuildContext context) {
    // 根据实际窗口宽度计算每格内容宽度
    final totalW = MediaQuery.of(context).size.width;
    final cellContentW = ((totalW - 52.w) / 7 - 4.w).clamp(20.0, 200.0);
    if ((cellContentW - _prevCellW).abs() > 2 || _segments.isEmpty) {
      _prevCellW = cellContentW;
      _recomputeSegments(cellContentW);
    }

    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.w),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: [
          Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(
                    onTap: () => _ctrl.onMonthChanged(
                        DateTime(_ctrl.focusedMonth.year, _ctrl.focusedMonth.month - 1)),
                    child:
                        Icon(Icons.chevron_left, size: 20.sp, color: AppColors.secondaryText)),
                Text('${_ctrl.focusedMonth.year}.${_ctrl.focusedMonth.month}',
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                GestureDetector(
                    onTap: () => _ctrl.onMonthChanged(
                        DateTime(_ctrl.focusedMonth.year, _ctrl.focusedMonth.month + 1)),
                    child: Icon(Icons.chevron_right, size: 20.sp, color: AppColors.secondaryText)),
              ])),
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
            rowHeight: 42.w,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) =>
                _ctrl.selectedDay != null && isSameDay(_ctrl.selectedDay!, day),
            onDaySelected: (day, _) => _ctrl.onDaySelected(day),
            onPageChanged: (day) => _ctrl.onMonthChanged(day),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final ev = _getEventForDate(date);
                return _dayCell(date, ev);
              },
            ),
            calendarStyle: const CalendarStyle(outsideDaysVisible: false, cellMargin: EdgeInsets.zero),
            daysOfWeekStyle: DaysOfWeekStyle(
                dowTextFormatter: (d, _) =>
                    const ['一', '二', '三', '四', '五', '六', '日'][d.weekday - 1],
                weekdayStyle: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText),
                weekendStyle: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
          ),
        ]),
      );
  }

  Widget _dayCell(DateTime date, _DayEvent? ev) {
    final isSelected =
        _ctrl.selectedDay != null && isSameDay(date, _ctrl.selectedDay!);

    // ---- 无事件：纯日期 ----
    if (ev == null) {
      return Container(
        margin: EdgeInsets.all(2.w),
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6.w))
            : null,
        child: Text('${date.day}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.primaryText,
            )),
      );
    }

    // ---- 有事件 ----
    final color = ev.color;
    final isStart = ev.isStart;
    final isEnd = ev.isEnd;
    final isSingle = ev.isSingle;
    final inTitle = ev.isInTitleZone;

    // 背景圆角：行程区间首尾圆角，中间无圆角
    BorderRadiusGeometry barRadius;
    if (isSingle) {
      barRadius = BorderRadius.circular(4.w);
    } else if (isStart) {
      barRadius = BorderRadius.horizontal(left: Radius.circular(4.w));
    } else if (isEnd) {
      barRadius = BorderRadius.horizontal(right: Radius.circular(4.w));
    } else {
      barRadius = BorderRadius.zero;
    }

    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.30)
        : color.withValues(alpha: 0.18);

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(color: bgColor, borderRadius: barRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 日期数字
          Expanded(
            child: Center(
              child: Text('${date.day}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.primaryText,
                  )),
            ),
          ),
          // 标题栏 或 细色条
          if (inTitle)
            _titleBar(ev, color, isStart, isEnd, isSingle)
          else
            Container(
              height: 3.5.w,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: isEnd
                    ? BorderRadius.only(bottomRight: Radius.circular(4.w))
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  /// 标题栏：每格自动填满，文字跨格流动无断开感
  Widget _titleBar(_DayEvent ev, Color color, bool isStart, bool isEnd, bool isSingle) {
    final segment = ev.titleSegment();
    final titleEnd = ev.dayIndex == ev.segments.length - 1;

    BorderRadiusGeometry titleRadius;
    if (isSingle) {
      titleRadius = BorderRadius.only(
          bottomLeft: Radius.circular(4.w), bottomRight: Radius.circular(4.w));
    } else if (isStart) {
      titleRadius = BorderRadius.only(
          bottomLeft: Radius.circular(4.w), bottomRight: Radius.circular(2.w));
    } else if (isEnd) {
      titleRadius = BorderRadius.only(bottomRight: Radius.circular(4.w));
    } else if (titleEnd) {
      titleRadius = BorderRadius.only(bottomRight: Radius.circular(2.w));
    } else {
      titleRadius = BorderRadius.zero;
    }

    final padLeft = isStart ? 3.w : 1.w;
    final padRight = (isEnd || titleEnd) ? 3.w : 1.w;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(padLeft, 2.5.w, padRight, 2.5.w),
      decoration: BoxDecoration(color: color, borderRadius: titleRadius),
      child: Text(
        segment,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
            fontSize: _titleFontSize.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

// =============== 图例 ===============
class _StatusLegend extends StatelessWidget {
  const _StatusLegend({required this.controller});
  final JourneyController controller;
  @override
  Widget build(BuildContext context) => Obx(() {
    final hideEnded = !controller.showEnded.value;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _Leg(color: AppColors.jadeGreen, label: '进行中'), SizedBox(width: 20.w),
      _Leg(color: AppColors.primary, label: '即将开始'), SizedBox(width: 20.w),
      GestureDetector(
        onTap: () => controller.toggleShowEnded(),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 10.w, height: 10.w,
            decoration: BoxDecoration(
              color: AppColors.assistantText,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          5.w.horizontalSpace,
          Text('已结束',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.secondaryText,
              decoration: hideEnded ? TextDecoration.lineThrough : null,
              decorationColor: hideEnded ? AppColors.assistantText : null,
            )),
        ]),
      ),
    ]);
  });
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
  @override Widget build(BuildContext context) {
    if (work.isTemplate) return _buildTemplateCard();
    return _buildWorkCard();
  }

  /// 模板卡片
  Widget _buildTemplateCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.w),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (work.region?.isNotEmpty == true) Container(margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4.w),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
              child: Text(work.region!, style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w600))),
            Text(work.title ?? '', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)).expanded(),
            Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.w),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10.w)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.bookmark, size: 11.sp, color: Colors.amber.shade700),
                SizedBox(width: 4.w),
                Text('模板', style: TextStyle(fontSize: 10.sp, color: Colors.amber.shade700, fontWeight: FontWeight.w500)),
              ])),
          ]),
          10.w.verticalSpace,
          if (work.peopleCount != null && work.peopleCount! > 0)
            Padding(padding: EdgeInsets.only(bottom: 6.w), child: _Dr(Icons.people, '${work.peopleCount}人')),
          if (work.totalDays > 0)
            Padding(padding: EdgeInsets.only(bottom: 6.w), child: _Dr(Icons.calendar_today, '${work.totalDays}天行程')),
          if (work.cities.isNotEmpty)
            Padding(padding: EdgeInsets.only(bottom: 6.w), child: _Dr(Icons.location_on, work.cities.join('、'))),
          Padding(
            padding: EdgeInsets.only(top: 4.w),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.touch_app, size: 11.sp, color: AppColors.primary.withValues(alpha: 0.5)),
              SizedBox(width: 4.w),
              Text('点击使用模板创建行程', style: TextStyle(fontSize: 10.sp, color: AppColors.primary.withValues(alpha: 0.5))),
            ]),
          ),
        ]),
      ),
    );
  }

  /// 普通工作卡片
  Widget _buildWorkCard() {
    return GestureDetector(onTap: onTap,
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
