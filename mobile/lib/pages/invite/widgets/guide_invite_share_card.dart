import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller.dart';

class GuideInviteShareCardWidget extends StatelessWidget with UserStoreMixin {
  const GuideInviteShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InviteController>();
    return RepaintBoundary(
      key: repaintKey,
      child: Obx(() {
        final guideInfo = controller.guideInfo;
        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetImageCached(
                    guideInfo?.photo ?? userInfo.avatar ?? '',
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
                          guideInfo?.fullName ?? userInfo.nickname ?? '',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        5.w.verticalSpace,
                        if ((guideInfo?.identityTypeName?.isNotEmpty ?? false))
                          Text(
                                guideInfo!.identityTypeName ?? '',
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
                        if ((guideInfo?.language?.isNotEmpty ?? false)) ...[
                          12.w.verticalSpace,
                          Row(
                            children: [
                              Image.asset(Assets.iconLan, width: 14.w),
                              8.w.horizontalSpace,
                              Text(
                                '${'語  言'.tr}：${guideInfo!.language!.join(',')}',
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
                        if ((guideInfo?.cityName?.isNotEmpty ?? false)) ...[
                          10.w.verticalSpace,
                          Row(
                            children: [
                              Image.asset(Assets.iconAddress, width: 14.w),
                              8.w.horizontalSpace,
                              Text(
                                '${'所在地'.tr}：${guideInfo!.cityName}',
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
                      ],
                    ),
                  ),
                ],
              ),
              if ((guideInfo?.phone?.isNotEmpty ?? false)) ...[
                16.w.verticalSpace,
                _ShareInfoItem(
                  title: '聯繫電話'.tr,
                  content: guideInfo!.phone ?? '',
                ),
              ],
              if ((guideInfo?.email?.isNotEmpty ?? false))
                _ShareInfoItem(
                  title: '郵箱地址'.tr,
                  content: guideInfo!.email ?? '',
                ),
              if ((guideInfo?.wechat?.isNotEmpty ?? false))
                _ShareInfoItem(
                  title: '微信/Wechat'.tr,
                  content: guideInfo!.wechat ?? '',
                ),
              if ((guideInfo?.whatsApp?.isNotEmpty ?? false))
                _ShareInfoItem(
                  title: 'WhatsApp'.tr,
                  content: guideInfo!.whatsApp ?? '',
                ),
              if ((guideInfo?.line?.isNotEmpty ?? false))
                _ShareInfoItem(
                  title: 'Line'.tr,
                  content: guideInfo!.line ?? '',
                ),
              if ((guideInfo?.otherContact?.isNotEmpty ?? false))
                _ShareInfoItem(
                  title: '其他聯繫方式'.tr,
                  content: guideInfo!.otherContact ?? '',
                ),
              if ((guideInfo?.industryType?.isNotEmpty ?? false)) ...[
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
                        children: (guideInfo!.industryType ?? '')
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
              Text(
                '${'邀請碼：'.tr}${userInfo.inviterCode ?? ''}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ).center(),
              24.w.verticalSpace,
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
                      8.w.verticalSpace,
                      Text(
                        '${guideInfo?.fullName ?? userInfo.nickname ?? ''}${'邀請您加入 LUMOGUIDE'.tr}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.assistantText,
                        ),
                      ),
                    ],
                  ).expanded(),
                  16.w.horizontalSpace,
                  QrImageView(
                    data: userInfo.inviteUrl ?? '',
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    size: 80.w,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
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
