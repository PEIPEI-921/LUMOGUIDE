import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'controller.dart';

class JourneyDetailPage extends StatelessWidget {
  const JourneyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(JourneyDetailController());

    return IScaffold(
      title: '工作详情',
      backgroundImage: const AssetImage(Assets.bgMine),
      appBar: IAppBar(
        title: '工作详情',
        actions: [
          Icon(
            Icons.qr_code,
            size: 20.w,
            color: AppColors.primaryText,
          )
              .padding(all: 12.w)
              .gestures(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ShareQrcodeDialog(type: 'trip', id: ctrl.workId),
                ),
                behavior: HitTestBehavior.opaque,
              ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18.sp, color: AppColors.primary),
            onPressed: () => ctrl.onEdit(),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red.shade400),
            onPressed: () => ctrl.onDeleteWork(),
          ),
        ],
      ),
      body: Obx(() {
        final w = ctrl.work.value;
        if (w == null) return const SizedBox.shrink();

        return Column(children: [
          _HeaderCard(work: w),
          _TabBar(ctrl: ctrl),
          Expanded(child: IndexedStack(
            index: ctrl.activeTab.value,
            children: [
              _ItineraryTab(work: w, ctrl: ctrl),
              _MergedDetailTab(work: w, ctrl: ctrl),
            ],
          )),
        ]);
      }),
    );
  }
}

// ================================================================
// 头部卡片
// ================================================================
class _HeaderCard extends StatelessWidget {
  final JourneyWork work;
  const _HeaderCard({required this.work});

  Color get statusColor {
    switch (work.effectiveStatus) {
      case JourneyWorkStatus.inProgress: return AppColors.jadeGreen;
      case JourneyWorkStatus.pending: return AppColors.primary;
      case JourneyWorkStatus.ended: return AppColors.assistantText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(14.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.w),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(work.title ?? '', style: TextStyle(
            fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(work.effectiveStatus.label, style: TextStyle(
              fontSize: 11.sp, color: statusColor, fontWeight: FontWeight.w500)),
          ),
        ]),
        SizedBox(height: 12.w),
        Row(children: [
          _StatIcon(Icons.calendar_today, '${work.startDate ?? '--'} → ${work.endDate ?? '--'}'),
          SizedBox(width: 16.w),
          _StatIcon(Icons.people_outline, '${work.peopleCount ?? 0}人'),
          SizedBox(width: 16.w),
          _StatIcon(Icons.timer_outlined, '${work.totalDays}天'),
        ]),
        if (work.cities.isNotEmpty) ...[
          SizedBox(height: 10.w),
          Wrap(spacing: 6.w, runSpacing: 4.w, children: work.cities.map((c) => GestureDetector(
            onTap: () => Get.find<JourneyDetailController>().onViewCity(c),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_outlined, size: 12.sp, color: AppColors.primary),
                SizedBox(width: 3.w),
                Text(c, style: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
              ]),
            ),
          )).toList()),
        ],
        if (work.isFromBooking) ...[
          SizedBox(height: 8.w),
          Row(children: [
            Icon(Icons.sync, size: 12.sp, color: AppColors.jadeGreen),
            SizedBox(width: 4.w),
            Text('来自预约同步', style: TextStyle(fontSize: 11.sp, color: AppColors.jadeGreen)),
          ]),
        ],
      ]),
    );
  }
}

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatIcon(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14.sp, color: AppColors.assistantText),
      SizedBox(width: 4.w),
      Text(text, style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText)),
    ]);
  }
}

// ================================================================
// Tab 导航
// ================================================================
class _TabBar extends StatelessWidget {
  final JourneyDetailController ctrl;
  const _TabBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Obx(() {
        final active = ctrl.activeTab.value;
        return Row(children: [
          _TabItem(0, Icons.view_day_outlined, '行程', active == 0, () => ctrl.activeTab.value = 0),
          _TabItem(1, Icons.info_outline, '详情', active == 1, () => ctrl.activeTab.value = 1),
        ]);
      }),
    );
  }
}

class _TabItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabItem(this.index, this.icon, this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: active ? AppColors.primary : Colors.transparent,
            width: 2,
          )),
        ),
        child: Column(children: [
          Icon(icon, size: 18.sp, color: active ? AppColors.primary : AppColors.assistantText),
          SizedBox(height: 2.w),
          Text(label, style: TextStyle(
            fontSize: 11.sp,
            color: active ? AppColors.primary : AppColors.assistantText,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    ));
  }
}

// ================================================================
// Tab 1: 详情（概览 + 详情合并）
// ================================================================
class _MergedDetailTab extends StatelessWidget {
  final JourneyWork work;
  final JourneyDetailController ctrl;
  const _MergedDetailTab({required this.work, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hasOverview = work.cities.isNotEmpty ||
        work.description?.isNotEmpty == true ||
        work.leaderName?.isNotEmpty == true ||
        work.driverName?.isNotEmpty == true;
    final hasInfo = work.arrivalFlight != null ||
        work.departureFlight != null ||
        work.totalPrice?.isNotEmpty == true ||
        work.cashAdvance?.isNotEmpty == true ||
        work.agencyContact?.isNotEmpty == true ||
        work.emergencyPhone?.isNotEmpty == true;

    if (!hasOverview && !hasInfo) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.info_outline, size: 48.sp, color: AppColors.assistantText),
        SizedBox(height: 10.w),
        Text('暂无详细信息', style: TextStyle(fontSize: 14.sp, color: AppColors.assistantText)),
        Text('点击右上角编辑添加', style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText)),
      ]));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(14.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // --- 概览部分 ---
        if (work.cities.isNotEmpty) ...[
          _SectionHeader('涉及城市'),
          SizedBox(height: 6.w),
          _InfoCard('涉及城市', work.cities.join('、'), Icons.location_on_outlined),
          SizedBox(height: 10.w),
        ],
        if (work.description?.isNotEmpty == true) ...[
          _SectionHeader('备注'),
          SizedBox(height: 6.w),
          _InfoCard('备注', work.description!, Icons.notes),
          SizedBox(height: 10.w),
        ],
        if (work.leaderName?.isNotEmpty == true || work.driverName?.isNotEmpty == true) ...[
          _SectionHeader('人员信息'),
          SizedBox(height: 6.w),
          if (work.leaderName?.isNotEmpty == true)
            _InfoCard('领队', '${work.leaderName}  ${work.leaderPhone ?? ''}', Icons.person_outline),
          SizedBox(height: 6.w),
          if (work.driverName?.isNotEmpty == true)
            _InfoCard('司机', '${work.driverName}  ${work.driverPhone ?? ''}', Icons.airline_seat_recline_normal),
          SizedBox(height: 6.w),
          if (work.vehicleInfo?.isNotEmpty == true)
            _InfoCard('车辆', work.vehicleInfo!, Icons.directions_bus_outlined),
          SizedBox(height: 10.w),
        ],

        // --- 详情部分 ---
        if (work.arrivalFlight != null || work.departureFlight != null) ...[
          _SectionHeader('航班信息'),
          SizedBox(height: 6.w),
          if (work.arrivalFlight != null) ...[
            _InfoCard('抵达航班', work.arrivalFlight!.flightNumber ?? '--', Icons.flight),
            SizedBox(height: 4.w),
            _InfoCard('抵达时间', work.arrivalFlight!.dateTime ?? '--', Icons.schedule),
            SizedBox(height: 4.w),
            _InfoCard('抵达机场', work.arrivalFlight!.airport ?? '--', Icons.local_airport),
            SizedBox(height: 10.w),
          ],
          if (work.departureFlight != null) ...[
            _InfoCard('离开航班', work.departureFlight!.flightNumber ?? '--', Icons.flight_land),
            SizedBox(height: 4.w),
            _InfoCard('离开时间', work.departureFlight!.dateTime ?? '--', Icons.schedule),
            SizedBox(height: 4.w),
            _InfoCard('离开机场', work.departureFlight!.airport ?? '--', Icons.local_airport),
            SizedBox(height: 10.w),
          ],
        ],
        if (work.totalPrice?.isNotEmpty == true || work.cashAdvance?.isNotEmpty == true) ...[
          _SectionHeader('费用信息'),
          SizedBox(height: 6.w),
          if (work.totalPrice?.isNotEmpty == true)
            _InfoCard('团款总额', work.totalPrice!, Icons.euro),
          if (work.cashAdvance?.isNotEmpty == true)
            _InfoCard('备用金', work.cashAdvance!, Icons.account_balance_wallet_outlined),
          if (work.ticketBudget?.isNotEmpty == true)
            _InfoCard('门票预算', work.ticketBudget!, Icons.confirmation_number_outlined),
          if (work.mealBudget?.isNotEmpty == true)
            _InfoCard('餐费预算', work.mealBudget!, Icons.restaurant_outlined),
          SizedBox(height: 10.w),
        ],
        if (work.agencyContact?.isNotEmpty == true || work.emergencyPhone?.isNotEmpty == true) ...[
          _SectionHeader('应急联系'),
          SizedBox(height: 6.w),
          if (work.agencyContact?.isNotEmpty == true)
            _InfoCard('组团社', '${work.agencyContact}  ${work.agencyContactPhone ?? ''}', Icons.business_outlined),
          if (work.localContact?.isNotEmpty == true)
            _InfoCard('地接社', '${work.localContact}  ${work.localContactPhone ?? ''}', Icons.support_agent_outlined),
          if (work.emergencyPhone?.isNotEmpty == true)
            _InfoCard('紧急电话', work.emergencyPhone!, Icons.emergency_outlined),
          SizedBox(height: 10.w),
        ],

        // --- 操作按钮 ---
        SizedBox(height: 16.w),
        _ActionButton(Icons.bookmark_outline, '保存为模板', () => ctrl.onSaveAsTemplate()),
        SizedBox(height: 8.w),
        _ActionButton(Icons.auto_awesome_outlined, '生成客户行程', () => ctrl.onGenerateClientItinerary()),
        if (work.isFromBooking) ...[
          SizedBox(height: 8.w),
          _ActionButton(Icons.event_note, '查看预约详情', () => ctrl.onViewBooking()),
        ],
        SizedBox(height: 40.w),
      ]),
    );
  }
}

// ================================================================
// Tab 0: 每日行程
// ================================================================
class _ItineraryTab extends StatelessWidget {
  final JourneyWork work;
  final JourneyDetailController ctrl;
  const _ItineraryTab({required this.work, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (work.itineraryDays.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.view_day_outlined, size: 48.sp, color: AppColors.assistantText),
        SizedBox(height: 10.w),
        Text('暂无日行程', style: TextStyle(fontSize: 14.sp, color: AppColors.assistantText)),
        SizedBox(height: 6.w),
        Text('点击右上角编辑添加', style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText)),
      ]));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(14.w),
      child: Column(children: [
        ...work.itineraryDays.map((day) => _DayDetailCard(day: day, ctrl: ctrl)),
        // 操作按钮 — 保存的主要是行程
        SizedBox(height: 20.w),
        _ActionButton(Icons.bookmark_outline, '保存为模板', () => ctrl.onSaveAsTemplate()),
        SizedBox(height: 8.w),
        _ActionButton(Icons.auto_awesome_outlined, '生成客户行程', () => ctrl.onGenerateClientItinerary()),
        SizedBox(height: 40.w),
      ]),
    );
  }
}

class _DayDetailCard extends StatelessWidget {
  final ItineraryDay day;
  final JourneyDetailController ctrl;
  const _DayDetailCard({required this.day, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 天头
        Row(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Text('第${day.dayNumber}天', style: TextStyle(
              fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          SizedBox(width: 8.w),
          Text(day.date ?? '', style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText)),
          if (day.theme?.isNotEmpty == true) ...[
            SizedBox(width: 8.w),
            Text('· ${day.theme}', style: TextStyle(fontSize: 12.sp, color: AppColors.primaryText, fontWeight: FontWeight.w500)),
          ],
        ]),
        if (day.cityBlocks.any((b) => b.items.isNotEmpty)) ...[
          SizedBox(height: 10.w),
          ...day.cityBlocks.expand((block) => [
            if (block.cityName?.isNotEmpty == true)
              Padding(
                padding: EdgeInsets.only(top: 2.w, bottom: 4.w),
                child: GestureDetector(
                  onTap: () => ctrl.onTapCityBlock(block),
                  behavior: HitTestBehavior.opaque,
                  child: Row(children: [
                    Container(width: 6.w, height: 6.w,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3.w))),
                    SizedBox(width: 6.w),
                    Text(block.cityName!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    SizedBox(width: 4.w),
                    Icon(Icons.open_in_new, size: 11.sp, color: AppColors.primary.withValues(alpha: 0.4)),
                  ]),
                ),
              ),
            ...block.items.map((item) => GestureDetector(
            onTap: () => ctrl.onTapItineraryItem(item, block.cityId),
            behavior: HitTestBehavior.opaque,
            child: Padding(
            padding: EdgeInsets.only(bottom: 6.w),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 40.w, child: Text(item.time ?? '', style: TextStyle(
                fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w500))),
              Container(width: 2, height: 40, color: AppColors.primary.withValues(alpha: 0.15)),
              SizedBox(width: 8.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(item.title ?? '', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.primaryText))),
                  if (item.resourceId != null || item.resourceType != null)
                    Icon(Icons.chevron_right, size: 14.sp, color: AppColors.assistantText),
                ]),
                if (item.description?.isNotEmpty == true) ...[
                  SizedBox(height: 2.w),
                  Text(item.description!, style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
                ],
              ])),
            ]),
          ))),
          ]),
        ],
        // 底部信息
        if (day.hotelName?.isNotEmpty == true || day.drivingHours?.isNotEmpty == true || day.dayNote?.isNotEmpty == true) ...[
          Divider(height: 20.w, color: Colors.grey.shade200),
          if (day.hotelName?.isNotEmpty == true)
            _DayMeta(Icons.hotel_outlined, day.hotelName!),
          if (day.drivingHours?.isNotEmpty == true)
            _DayMeta(Icons.directions_car_outlined, '车程约${day.drivingHours}小时'),
          if (day.dayNote?.isNotEmpty == true)
            _DayMeta(Icons.notes, day.dayNote!),
        ],
      ]),
    );
  }
}

class _DayMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DayMeta(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.w),
      child: Row(children: [
        Icon(icon, size: 13.sp, color: AppColors.assistantText),
        SizedBox(width: 6.w),
        Text(text, style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
      ]),
    );
  }
}

// ================================================================
// 共享组件
// ================================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.w),
      child: Text(title, style: TextStyle(
        fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoCard(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Row(children: [
        Icon(icon, size: 16.sp, color: AppColors.assistantText),
        SizedBox(width: 10.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText)),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 17.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
