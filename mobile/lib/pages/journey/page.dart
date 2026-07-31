import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

// =============== 日历（30 天网格，5 行 × 6 列） ===============

const _kCalRows = 5;
const _kCalCols = 6;
const _kCalTotal = _kCalRows * _kCalCols; // 30
const _kCalBefore = 10; // 今天前面 10 天（已过期）

class _JourneyCalendar extends StatelessWidget {
  final JourneyController controller;
  const _JourneyCalendar({required this.controller});

  DateTime get _today => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime get _start => _today.subtract(Duration(days: _kCalBefore));

  List<DateTime> get _allDays => List.generate(_kCalTotal, (i) => _start.add(Duration(days: i)));

  List<JourneyWork> _worksForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return controller.allWorks.where((w) {
      if (w.isTemplate) return false;
      final s = DateTime.tryParse(w.startDate ?? '');
      final e = DateTime.tryParse(w.endDate ?? '');
      if (s == null || e == null) return false;
      return !day.isBefore(DateTime(s.year, s.month, s.day)) &&
          !day.isAfter(DateTime(e.year, e.month, e.day));
    }).toList()
      ..sort((a, b) {
        int p(JourneyWork w) {
          switch (w.effectiveStatus) {
            case JourneyWorkStatus.inProgress: return 0;
            case JourneyWorkStatus.pending: return 1;
            default: return 2;
          }
        }
        final c = p(a).compareTo(p(b));
        if (c != 0) return c;
        return (a.startDate ?? '').compareTo(b.startDate ?? '');
      });
  }

  Color _statusColor(JourneyWorkStatus s) {
    switch (s) {
      case JourneyWorkStatus.inProgress: return AppColors.jadeGreen;
      case JourneyWorkStatus.pending: return AppColors.primary;
      default: return AppColors.assistantText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.w),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Obx(() {
        final _ = controller.allWorks; // 响应数据变化
        final days = _allDays;
        final lastDay = days.last;
        final sameMonth = _start.month == lastDay.month;
        final monthLabel = sameMonth
            ? '${_start.year}.${_start.month}'
            : '${_start.year}.${_start.month} — ${lastDay.month}';

        return Column(children: [
          // 月份标签
          Text(monthLabel, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
          SizedBox(height: 10.w),
          // 5 行 × 6 列
          for (int r = 0; r < _kCalRows; r++) ...[
            Row(children: [
              for (int c = 0; c < _kCalCols; c++)
                _DayCell(
                  date: days[r * _kCalCols + c],
                  works: _worksForDate(days[r * _kCalCols + c]),
                  isToday: days[r * _kCalCols + c] == _today,
                  statusColor: _statusColor,
                  onTap: (date, works) => _showDaySheet(context, date, works),
                ),
            ]),
            if (r < _kCalRows - 1) SizedBox(height: 6.w),
          ],
        ]);
      }),
    );
  }

  void _showDaySheet(BuildContext context, DateTime date, List<JourneyWork> works) {
    if (works.isEmpty) return;
    final month = date.month;
    final day = date.day;
    final wd = ['一', '二', '三', '四', '五', '六', '日'][date.weekday - 1];

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
        ),
        padding: EdgeInsets.only(top: 10.w, left: 14.w, right: 14.w, bottom: MediaQuery.of(context).padding.bottom + 10.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // 拖拽条
          Container(width: 36.w, height: 4.w, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.w))),
          SizedBox(height: 14.w),
          // 标题
          Text('$month 月 $day 日 星期$wd', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
          SizedBox(height: 4.w),
          Text('共 ${works.length} 个工作', style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText)),
          SizedBox(height: 14.w),
          // 工作列表
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: works.length,
              itemBuilder: (_, i) {
                final w = works[i];
                final color = _statusColor(w.effectiveStatus);
                final sd = w.startDate?.isNotEmpty == true ? w.startDate!.substring(w.startDate!.length >= 10 ? 5 : 0) : '';
                final ed = w.endDate?.isNotEmpty == true ? w.endDate!.substring(w.endDate!.length >= 10 ? 5 : 0) : '';
                return GestureDetector(
                  onTap: () {
                    Get.back();
                    controller.onTapWork(w);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.w),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.w),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      Container(width: 4.w, height: 36.w,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.w))),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(w.title ?? '', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                          SizedBox(height: 4.w),
                          Row(children: [
                            Icon(Icons.calendar_today, size: 11.sp, color: AppColors.assistantText),
                            SizedBox(width: 4.w),
                            Text('$sd → $ed  ${w.totalDays}天',
                                style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
                            SizedBox(width: 10.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.w),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3.w)),
                              child: Text(w.effectiveStatus.label,
                                  style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w500)),
                            ),
                          ]),
                        ]),
                      ),
                      Icon(Icons.chevron_right, size: 16.sp, color: AppColors.assistantText),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ---- 日期格子 ----

class _DayCell extends StatelessWidget {
  final DateTime date;
  final List<JourneyWork> works;
  final bool isToday;
  final Color Function(JourneyWorkStatus) statusColor;
  final void Function(DateTime, List<JourneyWork>) onTap;

  const _DayCell({
    required this.date,
    required this.works,
    required this.isToday,
    required this.statusColor,
    required this.onTap,
  });

  String get _wd => ['一', '二', '三', '四', '五', '六', '日'][date.weekday - 1];
  bool get _isPast => date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  Color get _textColor => _isPast ? AppColors.assistantText : AppColors.primaryText;

  @override
  Widget build(BuildContext context) {
    final hasWorks = works.isNotEmpty;
    return Expanded(
      child: GestureDetector(
        onTap: hasWorks ? () => onTap(date, works) : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 星期
              Text(_wd, style: TextStyle(fontSize: 7.sp, color: _textColor, height: 1.2)),
              // 日期
              isToday
                  ? Container(
                      width: 26.w, height: 26.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 1.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: Text('${date.day}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                    )
                  : Text('${date.day}',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _textColor)),
              SizedBox(height: 2.w),
              // 工作圆点（最多 3 个）
              if (hasWorks) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < works.length && i < 3; i++)
                      Container(
                        width: 4.w, height: 4.w,
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        decoration: BoxDecoration(
                          color: statusColor(works[i].effectiveStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (works.length > 3)
                      Text('+${works.length - 3}',
                          style: TextStyle(fontSize: 6.sp, color: AppColors.assistantText)),
                  ],
                ),
                SizedBox(height: 2.w),
              ],
            ],
          ),
        ),
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
