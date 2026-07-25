import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';

/// 客户行程预览卡片 — 含水印，用于预览和截图导出
class ClientItineraryPreview extends StatelessWidget {
  final JourneyWork work;
  final GlobalKey repaintKey;

  const ClientItineraryPreview({
    super.key,
    required this.work,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 340.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.w),
        ),
        child: Stack(
          children: [
            // --- 主内容 ---
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(work: work),
                  SizedBox(height: 12.w),
                  _DottedLine(),
                  SizedBox(height: 12.w),
                  // 每日行程
                  ...work.itineraryDays.map((day) => _DaySection(day: day)),
                  SizedBox(height: 4.w),
                  _DottedLine(),
                  SizedBox(height: 10.w),
                  _Footer(),
                ],
              ),
            ),
            // --- 水印 ---
            const IgnorePointer(child: _Watermark()),
          ],
        ),
      ),
    );
  }
}

/// 头部：logo + 行程标题
class _Header extends StatelessWidget {
  final JourneyWork work;
  const _Header({required this.work});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Image.asset(Assets.iconLogoText, height: 22.h),
      SizedBox(width: 10.w),
      Expanded(
        child: Text(
          work.title ?? '',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}

/// 虚线分隔
class _DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}

/// 每日行程区块
class _DaySection extends StatelessWidget {
  final ItineraryDay day;
  const _DaySection({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 天头
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Text(
              '第${day.dayNumber}天  ${day.date ?? ''}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          if (day.theme?.isNotEmpty == true) ...[
            SizedBox(height: 4.w),
            Text(
              day.theme!,
              style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText),
            ),
          ],
          SizedBox(height: 8.w),
          // 时间线 items（含城市块标题）
          ...day.cityBlocks.expand((block) => [
            if (block.cityName?.isNotEmpty == true)
              Padding(
                padding: EdgeInsets.only(top: 2.w, bottom: 2.w),
                child: Text('📍 ${block.cityName}',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ...block.items.map((item) => _TimelineItem(item: item)),
          ]),
          // 酒店
          if (day.hotelName?.isNotEmpty == true) ...[
            SizedBox(height: 6.w),
            const _HotelRow(hotelName: ''),
            _HotelRow(hotelName: day.hotelName!),
          ],
        ],
      ),
    );
  }
}

/// 时间线单项
class _TimelineItem extends StatelessWidget {
  final ItineraryItem item;
  const _TimelineItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42.w,
            child: Text(
              item.time ?? '',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 2,
            height: 36,
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? '',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                if (item.description?.isNotEmpty == true) ...[
                  SizedBox(height: 2.w),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 酒店行
class _HotelRow extends StatelessWidget {
  final String hotelName;
  const _HotelRow({required this.hotelName});

  @override
  Widget build(BuildContext context) {
    if (hotelName.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.w),
      child: Row(children: [
        SizedBox(width: 42.w),
        SizedBox(width: 2),
        SizedBox(width: 8.w),
        Icon(Icons.hotel_outlined, size: 12.sp, color: AppColors.assistantText),
        SizedBox(width: 4.w),
        Text(
          hotelName,
          style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText),
        ),
      ]),
    );
  }
}

/// Footer：生成日期
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return Center(
      child: Text(
        '生成日期: $dateStr',
        style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText),
      ),
    );
  }
}

/// 水印层 — 居中倾斜大字 LUMO
class _Watermark extends StatelessWidget {
  const _Watermark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -0.785,
        child: Opacity(
          opacity: 0.08,
          child: Text(
            'LUMO',
            style: TextStyle(
              fontSize: 36.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 6.w,
            ),
          ),
        ),
      ),
    );
  }
}
