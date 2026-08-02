import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller.dart';

class GuideShareCardWidget extends StatelessWidget {
  const GuideShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideDetailController>();

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetImageCached(
                  controller.guideInfo!.photo,
                  width: 108.w,
                  height: 140.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 8.w),
                16.w.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      4.w.verticalSpace,
                      Text(
                        controller.guideInfo!.fullName,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      5.w.verticalSpace,
                      Text(
                            controller.guideInfo!.identityTypeName ?? '',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                            ),
                          )
                          .padding(horizontal: 8.w, vertical: 2.w)
                          .decorated(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                      12.w.verticalSpace,
                      Row(
                        children: [
                          Image.asset(Assets.iconLan, width: 14.w),
                          8.w.horizontalSpace,
                          Text(
                            '${'語  言'.tr}：${controller.guideInfo!.language?.join(',')}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).flexible(),
                        ],
                      ),
                      10.w.verticalSpace,
                      Row(
                        children: [
                          Image.asset(Assets.iconAddress, width: 14.w),
                          8.w.horizontalSpace,
                          Text(
                            '${'所在地'.tr}：${controller.guideInfo!.cityName.isNotEmpty ? controller.guideInfo!.cityName : '--'}',
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
            _ShareInfoItem(
              title: '聯繫電話'.tr,
              content: controller.guideInfo!.phone ?? '',
            ),
            _ShareInfoItem(
              title: '郵箱地址'.tr,
              content: controller.guideInfo!.email ?? '',
            ),
            if (controller.guideInfo!.wechat.isNotEmpty)
              _ShareInfoItem(
                title: '微信/Wechat'.tr,
                content: controller.guideInfo!.wechat ?? '',
              ),
            if (controller.guideInfo!.whatsApp.isNotEmpty)
              _ShareInfoItem(
                title: 'WhatsApp'.tr,
                content: controller.guideInfo!.whatsApp ?? '',
              ),
            if (controller.guideInfo!.line.isNotEmpty)
              _ShareInfoItem(
                title: 'Line'.tr,
                content: controller.guideInfo!.line ?? '',
              ),
            if (controller.guideInfo!.otherContact.isNotEmpty)
              _ShareInfoItem(
                title: '其他聯繫方式'.tr,
                content: controller.guideInfo!.otherContact ?? '',
              ),
            if (controller.guideInfo!.industryType?.isNotEmpty ?? false) ...[
              8.w.verticalSpace,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '可從事工作類型'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.assistantText,
                    ),
                  ).constrained(width: 100.w),
                  Expanded(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 5.w,
                      children: (controller.guideInfo!.industryType ?? '')
                          .split(',')
                          .where((e) => e.isNotEmpty)
                          .map((e) {
                            return Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.primary,
                                  ),
                                )
                                .padding(horizontal: 8.w, vertical: 2.w)
                                .decorated(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12.w),
                                );
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
            16.w.verticalSpace,
            Container(
              height: 1.w,
              color: AppColors.assistantText.withOpacity(0.1),
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
                  data: buildContentShareUrl('guide', controller.id),
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
