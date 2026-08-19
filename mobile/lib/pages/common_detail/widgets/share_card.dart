import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller.dart';

class MerchantShareCardWidget extends StatelessWidget {
  const MerchantShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommonDetailController>();

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
        child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetImageCached(
                  controller.merchantInfo.pictures.isNotEmpty
                      ? controller.merchantInfo.pictures.first
                      : controller.merchantInfo.firstPicture ?? '',
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
                        controller.merchantInfo.name ?? '---',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      5.w.verticalSpace,
                      if (controller.merchantInfo.className?.isNotEmpty ??
                          false)
                        Text(
                              controller.merchantInfo.className ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.primary,
                              ),
                            )
                            .padding(horizontal: 8.w, vertical: 2.w)
                            .decorated(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12.w),
                            ),
                      12.w.verticalSpace,
                      if (controller.merchantInfo.cityName?.isNotEmpty ?? false)
                        Row(
                          children: [
                            Image.asset(Assets.iconAddress, width: 14.w),
                            8.w.horizontalSpace,
                            Text(
                              '${'所在地'.tr}：${controller.merchantInfo.cityName ?? '--'}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).flexible(),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            16.w.verticalSpace,
            if ((controller.merchantInfo.phone ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '聯繫電話'.tr,
                content: controller.merchantInfo.phone ?? '',
              ),
            if ((controller.merchantInfo.otherPhone ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '其他電話'.tr,
                content: controller.merchantInfo.otherPhone ?? '',
              ),
            if ((controller.merchantInfo.email ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '郵箱地址'.tr,
                content: controller.merchantInfo.email ?? '',
              ),
            if ((controller.merchantInfo.website ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '網站'.tr,
                content: controller.merchantInfo.website ?? '',
              ),
            if ((controller.merchantInfo.address ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '地址'.tr,
                content: controller.merchantInfo.address ?? '',
              ),
            if (controller.type == CommonDetailType.scenic &&
                (controller.merchantInfo.startTime ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '開放時間'.tr,
                content: controller.merchantInfo.startTime ?? '',
              ),
            if (controller.type == CommonDetailType.restaurant &&
                (controller.merchantInfo.startTime ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '營業時間'.tr,
                content: controller.merchantInfo.startTime ?? '',
              ),
            if (controller.type != CommonDetailType.scenic &&
                controller.type != CommonDetailType.restaurant &&
                (controller.merchantInfo.startTime ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '營業時間'.tr,
                content: controller.merchantInfo.startTime ?? '',
              ),
            if (controller.type == CommonDetailType.scenic &&
                (controller.merchantInfo.ticketsFree ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '票價'.tr,
                content: (controller.merchantInfo.ticketsFree ?? '') == '0'
                    ? (controller.merchantInfo.price ?? '')
                    : '免費'.tr,
              ),
            if (controller.type == CommonDetailType.restaurant &&
                (controller.merchantInfo.capacity ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '餐廳可容納人數'.tr,
                content: controller.merchantInfo.capacity ?? '',
              ),
            if ((controller.merchantInfo.companyInfo?.name ?? '').isNotEmpty)
              _ShareInfoItem(
                title: '公司名稱'.tr,
                content: controller.merchantInfo.companyInfo?.name ?? '',
              ),
            16.w.verticalSpace,
            Container(
              height: 1.w,
              color: AppColors.assistantText.withValues(alpha: 0.1),
            ),
            16.w.verticalSpace,
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
                  data: buildContentShareUrl('content', controller.id),
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
      ]),
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
