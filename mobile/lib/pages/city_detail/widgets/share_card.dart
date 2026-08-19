import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller.dart';

class CityShareCardWidget extends StatelessWidget {
  const CityShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 375.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: AppColors.assistantText.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 城市封面圖 + 基本信息
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetImageCached(
                  controller.cityInfo.pictures.isNotEmpty
                      ? controller.cityInfo.pictures.first
                      : '',
                  width: 120.w,
                  height: 120.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 8.w),
                16.w.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      4.w.verticalSpace,
                      Text(
                        controller.cityInfo.name ?? '',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((controller.cityInfo.nameEn ?? '').isNotEmpty) ...[
                        4.w.verticalSpace,
                        Text(
                          controller.cityInfo.nameEn ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.assistantText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      12.w.verticalSpace,
                      if ((controller.cityInfo.currency ?? '').isNotEmpty)
                        _ShareInfoItem(
                          title: '貨幣'.tr,
                          content: controller.cityInfo.currency ?? '',
                        ),
                      if ((controller.cityInfo.language ?? '').isNotEmpty)
                        _ShareInfoItem(
                          title: '語言'.tr,
                          content: controller.cityInfo.language ?? '',
                        ),
                      if ((controller.cityInfo.population ?? '').isNotEmpty)
                        _ShareInfoItem(
                          title: '人口'.tr,
                          content: controller.cityInfo.population ?? '',
                        ),
                    ],
                  ),
                ),
              ],
            ),
            16.w.verticalSpace,
            Container(
              height: 1.w,
              color: AppColors.assistantText.withValues(alpha: 0.1),
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
                  data: buildContentShareUrl('city', controller.cityId),
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  size: 80.w,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareInfoItem extends StatelessWidget {
  final String title;
  final String content;

  const _ShareInfoItem({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
          ).constrained(width: 100.w),
          Expanded(
            child: Text(
              content,
              style: TextStyle(fontSize: 12.sp, color: AppColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
