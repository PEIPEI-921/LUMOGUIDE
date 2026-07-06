import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'controller.dart';

class JourneyDetailPage extends StatelessWidget {
  const JourneyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JourneyDetailController());

    return IScaffold(
      title: '工作詳情'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      appBar: IAppBar(
        title: '工作詳情'.tr,
        actions: [
          GestureDetector(
            onTap: () => controller.onViewBooking(),
            child: Text('查看預約',
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500))
                .padding(right: 14.w),
          ),
        ],
      ),
      body: Obx(
        () {
          final w = controller.work.value;
          if (w == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题卡片
                _SectionCard(
                  children: [
                    _InfoRow('行程標題', w.title ?? '--'),
                    _InfoRow('人數', '${w.peopleCount ?? 0}人'),
                    _InfoRow('開始時間', w.startDate ?? '--'),
                    _InfoRow('結束時間', w.endDate ?? '--'),
                    if (w.region?.isNotEmpty == true)
                      _InfoRow('區域', w.region!),
                    if (w.cities.isNotEmpty)
                      _InfoRow('涉及城市', w.cities.join('、')),
                  ],
                ),
                12.w.verticalSpace,
                // 路线信息
                _SectionCard(
                  title: '路線信息',
                  children: [
                    _InfoRow('行程出發城市', w.departureCity ?? '--'),
                    _InfoRow('到達方式', w.arrivalMethod ?? '--'),
                    _InfoRow('到達時間', w.arrivalTime ?? '--'),
                    _InfoRow('到達地點', w.arrivalLocation ?? '--'),
                    _InfoRow('行程結束城市', w.endCity ?? '--'),
                    _InfoRow('離開方式', w.departureMethod ?? '--'),
                  ],
                ),
                12.w.verticalSpace,
                // 备注
                if (w.description?.isNotEmpty == true)
                  _SectionCard(
                    title: '備註',
                    children: [
                      Text(w.description!,
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.secondaryText)),
                    ],
                  ),
                // 同步来源
                if (w.isFromBooking)
                  Container(
                    margin: EdgeInsets.only(top: 12.w),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.jadeGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.w),
                      border: Border.all(
                          color: AppColors.jadeGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sync,
                            size: 16.sp, color: AppColors.jadeGreen),
                        8.w.horizontalSpace,
                        Text('此行程來自預約同步',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.jadeGreen)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.only(bottom: 10.w),
              child: Text(title!,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText)),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.sp, color: AppColors.assistantText)),
          ),
          Text(value,
                  style: TextStyle(
                      fontSize: 13.sp, color: AppColors.primaryText))
              .expanded(),
        ],
      ),
    );
  }
}
