import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'controller.dart';

class JourneyEditorPage extends StatelessWidget {
  const JourneyEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(JourneyEditorController());

    // 检查是否有未完成的草稿需要恢复
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.checkDraftAndPrompt(context);
    });

    return IScaffold(
      title: ctrl.isEdit.value ? '编辑行程' : '新建工作',
      backgroundImage: const AssetImage(Assets.bgMine),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14.w),
        child: Column(children: [
          _QuickCreateCard(ctrl: ctrl),
          SizedBox(height: 12.w),
          _FlightSection(ctrl: ctrl),
          SizedBox(height: 8.w),
          _ItinerarySection(ctrl: ctrl),
          SizedBox(height: 8.w),
          _ExpandSection(
            title: '领队 & 司机', icon: Icons.person_outline,
            expanded: ctrl.showPeople, onToggle: () => ctrl.showPeople.toggle(),
            child: _PeopleForm(ctrl: ctrl),
          ),
          SizedBox(height: 8.w),
          _ExpandSection(
            title: '费用信息', icon: Icons.receipt_long_outlined,
            expanded: ctrl.showCost, onToggle: () => ctrl.showCost.toggle(),
            child: _CostForm(ctrl: ctrl),
          ),
          SizedBox(height: 8.w),
          _ExpandSection(
            title: '应急联系', icon: Icons.phone_outlined,
            expanded: ctrl.showEmergency, onToggle: () => ctrl.showEmergency.toggle(),
            child: _EmergencyForm(ctrl: ctrl),
          ),
          SizedBox(height: 14.w),
          _InField('备注', ctrl.descriptionCtrl),
          SizedBox(height: 20.w),
          _SubmitRow(ctrl: ctrl),
          SizedBox(height: 40.w),
        ]),
      ),
    );
  }
}

// ================================================================
// 快速创建卡片
// ================================================================
class _QuickCreateCard extends StatelessWidget {
  final JourneyEditorController ctrl;
  const _QuickCreateCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14.w),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.edit_note, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text('快速创建', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
        ]),
        SizedBox(height: 12.w),
        // 团名（自动生成，可手动编辑）
        _QField(Icons.work_outline, '团名 *', ctrl.titleCtrl),
        if (!ctrl.isEdit.value)
          Padding(
            padding: EdgeInsets.only(top: 4.w, left: 23.w),
            child: Text('选择起止城市和日期后自动生成',
                style: TextStyle(fontSize: 10.sp, color: AppColors.assistantText)),
          ),
        SizedBox(height: 10.w),
        // 游览起始城市
        _CityPickerRow(
          icon: Icons.trip_origin,
          label: '游览起始城市',
          city: ctrl.startCity,
          onTap: () => ctrl.showStartCityPicker(context),
          onClear: () => ctrl.startCity.value = null,
        ),
        SizedBox(height: 8.w),
        // 游览结束城市
        _CityPickerRow(
          icon: Icons.location_on_outlined,
          label: '游览结束城市',
          city: ctrl.endCity,
          onTap: () => ctrl.showEndCityPicker(context),
          onClear: () => ctrl.endCity.value = null,
        ),
        SizedBox(height: 10.w),
        // 日期范围（单一日历框）
        Row(children: [
          Icon(Icons.calendar_today, size: 15.sp, color: AppColors.assistantText),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => ctrl.pickDateRange(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Obx(() {
                  // 访问 daysCount 触发响应式更新
                  final days = ctrl.daysCount.value;
                  final s = ctrl.startDateCtrl.text;
                  final e = ctrl.endDateCtrl.text;
                  if (s.isEmpty && e.isEmpty) {
                    return Text('选择出发和结束日期',
                        style: TextStyle(fontSize: 13.sp, color: AppColors.assistantText));
                  }
                  return Row(children: [
                    Flexible(child: Text(_fmtDisplayDate(s),
                        style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
                        overflow: TextOverflow.ellipsis)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text('→', style: TextStyle(color: AppColors.assistantText, fontSize: 13.sp)),
                    ),
                    Flexible(child: Text(_fmtDisplayDate(e),
                        style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
                        overflow: TextOverflow.ellipsis)),
                    if (days > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Text('共$days天',
                            style: TextStyle(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]);
                }),
              ),
            ),
          ),
        ]),
        SizedBox(height: 10.w),
        // 人数
        Row(children: [
          Icon(Icons.people_outline, size: 15.sp, color: AppColors.assistantText),
          SizedBox(width: 8.w),
          SizedBox(width: 55.w, child: _MiniField('成人', ctrl.adultCountCtrl)),
          SizedBox(width: 4.w),
          Text('+', style: TextStyle(color: AppColors.assistantText, fontSize: 13.sp)),
          SizedBox(width: 4.w),
          SizedBox(width: 55.w, child: _MiniField('儿童', ctrl.childCountCtrl)),
          Obx(() => Text(' = ${ctrl.totalPeople.value}人',
              style: TextStyle(fontSize: 13.sp, color: AppColors.primary, fontWeight: FontWeight.w600))),
        ]),
        if (!ctrl.isEdit.value) ...[
          SizedBox(height: 10.w),
          Row(children: [
            Icon(Icons.lightbulb_outline, size: 13.sp, color: AppColors.assistantText),
            SizedBox(width: 4.w),
            Text('创建后可逐步补全详细信息', style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText)),
          ]),
        ],
      ]),
    );
  }
}

/// 日期格式化：2026-07-03 → 7月3日
String _fmtDisplayDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.month}月${d.day}日';
}

// ================================================================
// 游览起始/结束城市选择行
// ================================================================
class _CityPickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Rxn<CityList> city;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _CityPickerRow({
    required this.icon,
    required this.label,
    required this.city,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 15.sp, color: AppColors.assistantText),
      SizedBox(width: 8.w),
      Expanded(
        child: Obx(() {
          final c = city.value;
          final controller = Get.find<JourneyEditorController>();
          final country = c != null ? controller.cityCountry(c) : '';
          if (c == null) {
            return GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(label,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.assistantText)),
              ),
            );
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(children: [
              Icon(Icons.location_on, size: 14.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${c.name ?? ''}${country.isNotEmpty ? ' · $country' : ''}',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 16.sp, color: AppColors.assistantText),
              ),
            ]),
          );
        }),
      ),
    ]);
  }
}

// ================================================================
// 航班/交通区块
// ================================================================
class _FlightSection extends StatelessWidget {
  final JourneyEditorController ctrl;
  const _FlightSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: Colors.grey.shade200, width: 0.5)),
      child: Column(children: [
        InkWell(
          onTap: () => ctrl.showFlight.toggle(),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.w),
            child: Row(children: [
              Icon(Icons.flight, size: 17.sp, color: ctrl.showFlight.value ? AppColors.primary : AppColors.secondaryText),
              SizedBox(width: 8.w),
              Text('大交通', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,
                color: ctrl.showFlight.value ? AppColors.primary : AppColors.primaryText)),
              const Spacer(),
              SizedBox(
                width: 150.w,
                child: Text(
                [ctrl.arrFlightCtrl.text, ctrl.depFlightCtrl.text].where((s) => s.isNotEmpty).join(' / '),
                style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              SizedBox(width: 4.w),
              Icon(ctrl.showFlight.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18.sp, color: AppColors.assistantText),
            ]),
          ),
        ),
        Obx(() => ctrl.showFlight.value ? Padding(
          padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
          child: Column(children: [
            Row(children: [
              Icon(Icons.flight, size: 13.sp, color: AppColors.jadeGreen),
              SizedBox(width: 6.w),
              Text('到达', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.jadeGreen)),
            ]),
            SizedBox(height: 6.w),
            _InField('航班号', ctrl.arrFlightCtrl),
            SizedBox(height: 6.w),
            Row(children: [
              Expanded(child: _DateTap('日期', ctrl.arrDateCtrl, () => ctrl.pickDate(context, ctrl.arrDateCtrl))),
              SizedBox(width: 8.w),
              Expanded(child: _TimeTap('时间', ctrl.arrTimeCtrl, () => ctrl.pickTime(context, ctrl.arrTimeCtrl))),
            ]),
            SizedBox(height: 6.w),
            _InField('机场/航站楼', ctrl.arrAirportCtrl),
            SizedBox(height: 12.w),
            Row(children: [
              Icon(Icons.flight_land, size: 13.sp, color: AppColors.assistantText),
              SizedBox(width: 6.w),
              Text('离开', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.assistantText)),
            ]),
            SizedBox(height: 6.w),
            _InField('航班号', ctrl.depFlightCtrl),
            SizedBox(height: 6.w),
            Row(children: [
              Expanded(child: _DateTap('日期', ctrl.depDateCtrl, () => ctrl.pickDate(context, ctrl.depDateCtrl))),
              SizedBox(width: 8.w),
              Expanded(child: _TimeTap('时间', ctrl.depTimeCtrl, () => ctrl.pickTime(context, ctrl.depTimeCtrl))),
            ]),
            SizedBox(height: 6.w),
            _InField('机场', ctrl.depAirportCtrl),
          ]),
        ) : const SizedBox.shrink()),
      ]),
    );
  }
}

// ================================================================
// 每日行程区块
// ================================================================
class _ItinerarySection extends StatelessWidget {
  final JourneyEditorController ctrl;
  const _ItinerarySection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: Colors.grey.shade200, width: 0.5)),
      child: Column(children: [
        InkWell(
          onTap: () => ctrl.showItinerary.toggle(),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.w),
            child: Row(children: [
              Icon(Icons.view_day_outlined, size: 17.sp,
                color: ctrl.showItinerary.value ? AppColors.primary : AppColors.secondaryText),
              SizedBox(width: 8.w),
              Text('每日行程', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,
                color: ctrl.showItinerary.value ? AppColors.primary : AppColors.primaryText)),
              const Spacer(),
              Obx(() => Text('${ctrl.itineraryDays.length}天',
                style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText))),
              SizedBox(width: 4.w),
              Icon(ctrl.showItinerary.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18.sp, color: AppColors.assistantText),
            ]),
          ),
        ),
        Obx(() => ctrl.showItinerary.value && ctrl.itineraryDays.isNotEmpty
          ? Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
              child: Column(children: ctrl.itineraryDays.asMap().entries.map((e) =>
                _DayCard(ctrl: ctrl, index: e.key, day: e.value)).toList()))
          : const SizedBox.shrink()),
      ]),
    );
  }
}

/// 单个城市块（城市名 + 独立活动列表 + 推荐）
class _CityBlockSection extends StatefulWidget {
  final int dayIndex;
  final int blockIndex;
  final DayCityBlock block;
  final JourneyEditorController ctrl;
  final BuildContext context;

  const _CityBlockSection({
    required this.dayIndex,
    required this.blockIndex,
    required this.block,
    required this.ctrl,
    required this.context,
  });

  @override
  State<_CityBlockSection> createState() => _CityBlockSectionState();
}

class _CityBlockSectionState extends State<_CityBlockSection> {
  final _expandedCats = <String>{};

  static const _categoryDefs = [
    _CategoryDef('attraction', '景点', Icons.landscape_outlined),
    _CategoryDef('activity', '活动', Icons.festival_outlined),
    _CategoryDef('merchant', '餐厅', Icons.restaurant_outlined),
    _CategoryDef('shopping', '购物', Icons.shopping_bag_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final di = widget.dayIndex;
    final bi = widget.blockIndex;
    final block = widget.block;

    return Container(
      margin: EdgeInsets.only(bottom: 8.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ---- 城市头部 ----
        Row(children: [
          Container(
            width: 6.w, height: 6.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
          SizedBox(width: 6.w),
          Text(block.cityName ?? '未选城市',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
          const Spacer(),
          GestureDetector(
            onTap: () => ctrl.removeDayCity(di, bi),
            child: Icon(Icons.close, size: 15.sp, color: AppColors.assistantText),
          ),
        ]),
        SizedBox(height: 8.w),
        // ---- 活动列表 ----
        ...block.items.asMap().entries.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 4.w),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => ctrl.pickItemTime(context, di, bi, item.key),
              child: Container(
                width: 48.w, height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4.w),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                alignment: Alignment.center,
                child: Text(block.items[item.key].time?.isNotEmpty == true ? block.items[item.key].time! : '时间',
                  style: TextStyle(fontSize: 10.sp, color: block.items[item.key].time?.isNotEmpty == true
                    ? AppColors.primaryText : AppColors.assistantText)),
              ),
            ),
            SizedBox(width: 4.w),
            _typeBadge(block.items[item.key].type),
            Expanded(child: _TnyInput(
              block.items[item.key].title ?? '',
              (v) => ctrl.updateDayItem(di, bi, item.key, 'title', v),
              hint: '活动/景点',
            )),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () => ctrl.removeDayItem(di, bi, item.key),
              child: Icon(Icons.close, size: 15.sp, color: AppColors.assistantText),
            ),
          ]),
        )),
        GestureDetector(
          onTap: () => ctrl.addDayItem(di, bi),
          child: Row(children: [
            Icon(Icons.add, size: 15.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text('添加活动', style: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
          ]),
        ),
        // ---- 城市推荐 ----
        Obx(() {
          final recs = ctrl.cityRecommendations[di];
          if (recs == null || recs.isEmpty) return const SizedBox.shrink();

          // 只显示属于当前城市块的推荐
          final myItems = recs.where((r) => r.cityId == block.cityId).toList();
          if (myItems.isEmpty) return const SizedBox.shrink();

          final Map<String, List<CityResource>> groups = {};
          for (final r in myItems) {
            groups.putIfAbsent(r.type, () => []).add(r);
          }

          final List<Widget> children = [
            SizedBox(height: 4.w),
            Row(children: [
              Icon(Icons.auto_awesome_outlined, size: 11.sp, color: AppColors.primary),
              SizedBox(width: 4.w),
              Text('${block.cityName ?? ''}推荐',
                style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w500)),
            ]),
          ];

          for (final cat in _categoryDefs) {
            final items = groups[cat.type];
            if (items == null || items.isEmpty) continue;
            final isExpanded = _expandedCats.contains(cat.type);

            children.add(InkWell(
              onTap: () => setState(() {
                isExpanded ? _expandedCats.remove(cat.type) : _expandedCats.add(cat.type);
              }),
              borderRadius: BorderRadius.circular(4.w),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.w),
                child: Row(children: [
                  Icon(cat.icon, size: 12.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Text(cat.label, style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Text('${items.length}', style: TextStyle(fontSize: 9.sp, color: AppColors.primary)),
                  ),
                  const Spacer(),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 14.sp, color: AppColors.assistantText),
                ]),
              ),
            ));

            if (isExpanded) {
              children.add(SizedBox(height: 3.w));
              children.add(Wrap(
                spacing: 4.w,
                runSpacing: 4.w,
                children: items.map((r) => ActionChip(
                  avatar: Icon(r.icon, size: 12.sp, color: AppColors.primary),
                  label: Text(r.name ?? r.label, style: TextStyle(fontSize: 10.sp, color: AppColors.primary)),
                  onPressed: () => ctrl.addResourceToDay(di, bi, r),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
                )).toList(),
              ));
            }
          }

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
        }),
      ]),
    );
  }
}

class _DayCard extends StatefulWidget {
  final JourneyEditorController ctrl;
  final int index;
  final ItineraryDay day;
  const _DayCard({required this.ctrl, required this.index, required this.day});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  JourneyEditorController get ctrl => widget.ctrl;
  int get index => widget.index;
  ItineraryDay get day => widget.day;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 天头部
        Row(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Text('第${day.dayNumber}天', style: TextStyle(
              fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          SizedBox(width: 6.w),
          Text(day.date ?? '', style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
        ]),
        SizedBox(height: 6.w),
        _SmlInput('主题', (v) => ctrl.updateDayField(index, 'theme', v), day.theme),
        SizedBox(height: 6.w),
        // ---- 每个城市块独立渲染 ----
        ...List.generate(day.cityBlocks.length, (bi) {
          final block = day.cityBlocks[bi];
          return _CityBlockSection(
            dayIndex: index,
            blockIndex: bi,
            block: block,
            ctrl: ctrl,
            context: context,
          );
        }),
        // 添加城市按钮
        Padding(
          padding: EdgeInsets.only(top: 6.w),
          child: GestureDetector(
            onTap: () => ctrl.showDayCityPicker(context, index),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), style: BorderStyle.solid),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_location_outlined, size: 14.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text('添加城市', style: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
              ]),
            ),
          ),
        ),
        SizedBox(height: 8.w),
        _SmlInput('酒店', (v) => ctrl.updateDayField(index, 'hotel_name', v), day.hotelName),
        SizedBox(height: 4.w),
        _SmlInput('车程(h)', (v) => ctrl.updateDayField(index, 'driving_hours', v), day.drivingHours),
        SizedBox(height: 4.w),
        _SmlInput('备注', (v) => ctrl.updateDayField(index, 'day_note', v), day.dayNote),
      ]),
    );
  }
}

// ================================================================
// 通用小组件
// ================================================================
class _ExpandSection extends StatelessWidget {
  final String title; final IconData icon; final RxBool expanded;
  final VoidCallback onToggle; final Widget child;
  const _ExpandSection({required this.title, required this.icon,
    required this.expanded, required this.onToggle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: Colors.grey.shade200, width: 0.5)),
      child: Column(children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.w),
            child: Row(children: [
              Icon(icon, size: 17.sp, color: expanded.value ? AppColors.primary : AppColors.secondaryText),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,
                color: expanded.value ? AppColors.primary : AppColors.primaryText)),
              const Spacer(),
              Icon(expanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18.sp, color: AppColors.assistantText),
            ]),
          ),
        ),
        Obx(() => expanded.value ? Padding(
          padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w), child: child) : const SizedBox.shrink()),
      ]),
    );
  }
}

class _QField extends StatelessWidget {
  final IconData icon; final String hint; final TextEditingController ctrl;
  const _QField(this.icon, this.hint, this.ctrl);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 15.sp, color: AppColors.assistantText), SizedBox(width: 8.w),
    Expanded(child: TextFormField(controller: ctrl,
      style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.assistantText),
        border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  ]);
}

class _InField extends StatelessWidget {
  final String hint; final TextEditingController ctrl;
  const _InField(this.hint, this.ctrl);
  @override
  Widget build(BuildContext context) => TextFormField(controller: ctrl,
    style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
      border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero));
}

class _DateTap extends StatelessWidget {
  final String hint; final TextEditingController ctrl; final VoidCallback onTap;
  const _DateTap(this.hint, this.ctrl, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AbsorbPointer(child: TextFormField(controller: ctrl,
      style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
        border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))));
}

class _TimeTap extends StatelessWidget {
  final String hint; final TextEditingController ctrl; final VoidCallback onTap;
  const _TimeTap(this.hint, this.ctrl, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AbsorbPointer(child: TextFormField(controller: ctrl,
      style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
        border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))));
}

class _MiniField extends StatelessWidget {
  final String hint; final TextEditingController ctrl;
  const _MiniField(this.hint, this.ctrl);
  @override
  Widget build(BuildContext context) => TextFormField(controller: ctrl, keyboardType: TextInputType.number,
    textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 11.sp, color: AppColors.assistantText),
      border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero));
}

Widget _SmlInput(String hint, Function(String) onChanged, String? value) {
  return SizedBox(height: 34.w, child: TextFormField(
    initialValue: value ?? '', onChanged: onChanged,
    style: TextStyle(fontSize: 12.sp, color: AppColors.primaryText),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 11.sp, color: AppColors.assistantText),
      filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.w), borderSide: BorderSide(color: Colors.grey.shade200)),
      isDense: true)));
}

Widget _TnyInput(String value, Function(String) onChanged, {String hint = ''}) {
  return SizedBox(height: 28.w, child: TextFormField(
    initialValue: value, onChanged: onChanged,
    style: TextStyle(fontSize: 11.sp, color: AppColors.primaryText),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 10.sp, color: AppColors.assistantText),
      filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.symmetric(horizontal: 6.w),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.w), borderSide: BorderSide(color: Colors.grey.shade200)),
      isDense: true)));
}

/// 行程项类型图标
const _typeMeta = {
  'attraction': (Icons.landscape, Color(0xFF44B89D)),
  'activity': (Icons.festival, Color(0xFFF5A623)),
  'merchant': (Icons.restaurant, Color(0xFFE8734A)),
  'shopping': (Icons.shopping_bag, Color(0xFF5B8DEF)),
};

Widget _typeBadge(String? type) {
  final meta = _typeMeta[type];
  if (meta == null) return SizedBox(width: 4.w);
  return Padding(
    padding: EdgeInsets.only(right: 4.w),
    child: Icon(meta.$1, size: 14.sp, color: meta.$2),
  );
}

// ================================================================
// 人员 / 费用 / 应急
// ================================================================
class _PeopleForm extends StatelessWidget {
  final JourneyEditorController ctrl;
  const _PeopleForm({required this.ctrl});
  @override
  Widget build(BuildContext context) => Column(children: [
    _InField('领队姓名', ctrl.leaderNameCtrl), SizedBox(height: 8.w),
    _InField('领队电话', ctrl.leaderPhoneCtrl), SizedBox(height: 8.w),
    _InField('司机姓名', ctrl.driverNameCtrl), SizedBox(height: 8.w),
    _InField('司机电话', ctrl.driverPhoneCtrl), SizedBox(height: 8.w),
    _InField('车辆信息', ctrl.vehicleCtrl),
  ]);
}

class _CostForm extends StatelessWidget {
  final JourneyEditorController ctrl;
  const _CostForm({required this.ctrl});
  @override
  Widget build(BuildContext context) => Column(children: [
    _InField('团款总额', ctrl.totalPriceCtrl), SizedBox(height: 8.w),
    _InField('备用金', ctrl.cashAdvanceCtrl),
  ]);
}

class _EmergencyForm extends StatelessWidget {
  final JourneyEditorController ctrl;
  const _EmergencyForm({required this.ctrl});
  @override
  Widget build(BuildContext context) => Column(children: [
    _InField('组团社联系人', ctrl.agencyContactCtrl), SizedBox(height: 8.w),
    _InField('组团社电话', ctrl.agencyPhoneCtrl), SizedBox(height: 8.w),
    _InField('紧急电话', ctrl.emergencyPhoneCtrl),
  ]);
}

// ================================================================
// 提交按钮
// ================================================================
class _SubmitRow extends StatelessWidget {
  final JourneyEditorController ctrl;
  const _SubmitRow({required this.ctrl});
  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox(width: double.infinity, height: 44.w,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.w))),
        onPressed: () => ctrl.onSubmit(),
        child: Text(ctrl.isEdit.value ? '保存' : '创建',
          style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    ),
    SizedBox(height: 10.w),
    SizedBox(width: double.infinity, height: 40.w,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.w)),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3))),
        onPressed: () => ctrl.onSaveAsTemplate(),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bookmark_outline, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text('保存为模板', style: TextStyle(fontSize: 14.sp, color: AppColors.primary)),
        ]),
      ),
    ),
  ]);
}

// ================================================================
// 推荐分类定义
// ================================================================
class _CategoryDef {
  final String type;
  final String label;
  final IconData icon;
  const _CategoryDef(this.type, this.label, this.icon);
}
