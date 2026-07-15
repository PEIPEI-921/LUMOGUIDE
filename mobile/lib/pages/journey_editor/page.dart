import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'controller.dart';

class JourneyEditorPage extends StatelessWidget {
  const JourneyEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(JourneyEditorController());

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
        // 团名
        _QField(Icons.work_outline, '团名 *', ctrl.titleCtrl),
        SizedBox(height: 10.w),
        // 日期
        Row(children: [
          Icon(Icons.calendar_today, size: 15.sp, color: AppColors.assistantText),
          SizedBox(width: 8.w),
          Expanded(child: _DateTap('出发日期', ctrl.startDateCtrl, () => ctrl.pickDate(context, ctrl.startDateCtrl))),
          Padding(padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text('→', style: TextStyle(color: AppColors.assistantText, fontSize: 14.sp))),
          Expanded(child: _DateTap('结束日期', ctrl.endDateCtrl, () => ctrl.pickDate(context, ctrl.endDateCtrl))),
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
          Text(' = ${ctrl.totalPeople}人', style: TextStyle(fontSize: 13.sp, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ]),
        SizedBox(height: 10.w),
        // 城市（从站内选）
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.location_on_outlined, size: 15.sp, color: AppColors.assistantText),
          SizedBox(width: 8.w),
          Expanded(child: Obx(() {
            if (ctrl.cities.isEmpty) {
              return GestureDetector(
                onTap: () => ctrl.showCityPicker(context),
                child: Text('选择城市', style: TextStyle(fontSize: 13.sp, color: AppColors.assistantText)),
              );
            }
            return Wrap(spacing: 6.w, runSpacing: 4.w, children: [
              ...ctrl.cities.map((c) => Chip(
                label: Text(c.name ?? '', style: TextStyle(fontSize: 11.sp)),
                deleteIcon: Icon(Icons.close, size: 14.sp),
                onDeleted: () => ctrl.removeCity(c),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
                labelStyle: TextStyle(fontSize: 11.sp, color: AppColors.primary),
              )),
              ActionChip(
                label: Icon(Icons.add, size: 14.sp, color: AppColors.primary),
                onPressed: () => ctrl.showCityPicker(context),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
            ]);
          })),
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

class _DayCard extends StatelessWidget {
  final JourneyEditorController ctrl;
  final int index;
  final ItineraryDay day;
  const _DayCard({required this.ctrl, required this.index, required this.day});

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
          const Spacer(),
          // 当天城市选择
          GestureDetector(
            onTap: () => ctrl.showDayCityPicker(context, index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_outlined, size: 11.sp, color: AppColors.primary),
                SizedBox(width: 3.w),
                Text(day.cityName ?? '选城市', style: TextStyle(fontSize: 10.sp, color: AppColors.primary)),
              ]),
            ),
          ),
        ]),
        SizedBox(height: 6.w),
        _SmlInput('主题', (v) => ctrl.updateDayField(index, 'theme', v), day.theme),
        SizedBox(height: 6.w),
        // 活动列表
        ...day.items.asMap().entries.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 4.w),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => ctrl.pickItemTime(context, index, item.key),
              child: Container(
                width: 48.w, height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4.w),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                alignment: Alignment.center,
                child: Text(day.items[item.key].time?.isNotEmpty == true ? day.items[item.key].time! : '时间',
                  style: TextStyle(fontSize: 10.sp, color: day.items[item.key].time?.isNotEmpty == true
                    ? AppColors.primaryText : AppColors.assistantText)),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(child: _TnyInput(
              day.items[item.key].title ?? '',
              (v) => ctrl.updateDayItem(index, item.key, 'title', v),
              hint: '活动/景点',
            )),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () => ctrl.removeDayItem(index, item.key),
              child: Icon(Icons.close, size: 15.sp, color: AppColors.assistantText),
            ),
          ]),
        )),
        GestureDetector(
          onTap: () => ctrl.addDayItem(index),
          child: Row(children: [
            Icon(Icons.add, size: 15.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text('添加', style: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
          ]),
        ),
        // 城市推荐
        Obx(() {
          final recs = ctrl.cityRecommendations[index];
          if (recs == null || recs.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: 8.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.auto_awesome_outlined, size: 12.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text('${day.cityName ?? ''}推荐', style: TextStyle(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ]),
              SizedBox(height: 4.w),
              Wrap(spacing: 4.w, runSpacing: 4.w, children: recs.map((r) => ActionChip(
                avatar: Icon(r.icon, size: 13.sp, color: AppColors.primary),
                label: Text(r.label, style: TextStyle(fontSize: 10.sp, color: AppColors.primary)),
                onPressed: () => ctrl.addResourceToDay(index, r),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
              )).toList()),
            ]),
          );
        }),
        SizedBox(height: 6.w),
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
