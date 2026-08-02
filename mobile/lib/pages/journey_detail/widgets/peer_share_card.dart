import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller.dart';

/// 行程同行分享卡片 — 分享給旅遊業同行
///
/// 包含完整工作資訊 + 邀請碼 + QR 碼
class JourneyPeerShareCardWidget extends StatelessWidget {
  const JourneyPeerShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JourneyDetailController>();
    final w = controller.work.value;
    if (w == null) return const SizedBox.shrink();

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 375.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: AppColors.assistantText.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題 + 狀態
                Row(
                  children: [
                    Text(
                      w.title ?? '',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).expanded(),
                    8.w.horizontalSpace,
                    _StatusBadge(status: w.effectiveStatusValue),
                  ],
                ),
                12.w.verticalSpace,
                // 日期 / 天數 / 人數
                _MetaRow(icon: Icons.calendar_today, text: '${w.startDate ?? '--'} → ${w.endDate ?? '--'}'),
                4.w.verticalSpace,
                _MetaRow(icon: Icons.timer_outlined, text: '${'共'.tr} ${w.totalDays} ${'天'.tr}'),
                4.w.verticalSpace,
                _MetaRow(icon: Icons.people_outline, text: '${w.peopleCount ?? '--'} ${'人'.tr}'),
                if (w.cities.isNotEmpty) ...[
                  4.w.verticalSpace,
                  _MetaRow(icon: Icons.location_on_outlined, text: w.cities.join('、')),
                ],
                if ((w.leaderName ?? '').isNotEmpty) ...[
                  4.w.verticalSpace,
                  _MetaRow(icon: Icons.person_outline, text: '${'領隊'.tr}: ${w.leaderName}'),
                ],
                16.w.verticalSpace,
                Container(
                  height: 1.w,
                  color: AppColors.assistantText.withOpacity(0.1),
                ),
                16.w.verticalSpace,
                // 底部：品牌 + QR 碼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              Assets.iconLogo,
                              height: 24.w,
                              fit: BoxFit.contain,
                            ).clipRRect(all: 20),
                            8.w.horizontalSpace,
                            Text(
                              'LUMOGUIDE',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ],
                        ),
                        5.w.verticalSpace,
                        Text(
                          '${UserStore.to.profile.nickname ?? ''}${'邀請您加入 LUMOGUIDE'.tr}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.assistantText,
                          ),
                        ),
                        if (UserStore.to.profile.inviterCode?.isNotEmpty ?? false)
                          Text(
                            '${'邀請碼'.tr}: ${UserStore.to.profile.inviterCode ?? ''}',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ).padding(top: 5.w),
                      ],
                    ).expanded(),
                    16.w.horizontalSpace,
                    QrImageView(
                      data: buildContentShareUrl('trip', controller.workId),
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      size: 80.w,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ],
                ),
              ],
            ),
            const ShareWatermark(),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.assistantText),
        6.w.horizontalSpace,
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: AppColors.primaryText),
        ).flexible(),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int status; // 1=inProgress, 2=pending, 3=ended
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status == 1 ? '進行中' : status == 2 ? '待出發' : '已結束';
    final color = status == 1
        ? AppColors.jadeGreen
        : status == 2
            ? AppColors.primary
            : AppColors.assistantText;
    return Text(
      label.tr,
      style: TextStyle(fontSize: 10.sp, color: color),
    ).padding(horizontal: 8.w, vertical: 2.w).decorated(
      borderRadius: BorderRadius.circular(12.w),
      border: Border.all(color: color),
    );
  }
}
