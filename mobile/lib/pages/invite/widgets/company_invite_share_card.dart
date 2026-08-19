import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller.dart';

class CompanyInviteShareCardWidget extends StatelessWidget with UserStoreMixin {
  const CompanyInviteShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InviteController>();
    return RepaintBoundary(
      key: repaintKey,
      child: Obx(() {
        final info = controller.companyInfo;
        return Container(
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
              _Header(info: info, userInfo: userInfo),
              if ((info?.phone?.isNotEmpty ?? false)) ...[
                16.w.verticalSpace,
                _ShareInfoItem(title: '聯繫電話'.tr, content: info!.phone!),
              ],
              if ((info?.email?.isNotEmpty ?? false))
                _ShareInfoItem(title: 'EMAIL'.tr, content: info!.email!),
              if ((info?.website?.isNotEmpty ?? false))
                _ShareInfoItem(title: '公司網站'.tr, content: info!.website!),
              if ((info?.wechat?.isNotEmpty ?? false))
                _ShareInfoItem(title: '微信/Wechat'.tr, content: info!.wechat!),
              if ((info?.whatsApp?.isNotEmpty ?? false))
                _ShareInfoItem(title: 'WhatsApp'.tr, content: info!.whatsApp!),
              if ((info?.line?.isNotEmpty ?? false))
                _ShareInfoItem(title: 'Line'.tr, content: info!.line!),
              if ((info?.otherContact?.isNotEmpty ?? false))
                _ShareInfoItem(
                  title: '其他聯繫方式'.tr,
                  content: info!.otherContact!,
                ),
              if ((info?.introduction?.isNotEmpty ?? false)) ...[
                8.w.verticalSpace,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '簡介'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.assistantText,
                      ),
                    ).constrained(width: 100.w),
                    Expanded(
                      child: Text(
                        info!.introduction!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              16.w.verticalSpace,
              Container(height: 1.w, color: AppColors.assistantText.withValues(alpha: 0.1)),
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
              Container(height: 1.w, color: AppColors.assistantText.withValues(alpha: 0.1)),
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
                        '${info?.fullName ?? userInfo.nickname ?? ''}${'邀請您加入 LUMOGUIDE'.tr}',
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

class _Header extends StatelessWidget {
  const _Header({required this.info, required this.userInfo});

  final CompanyInfo? info;
  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NetImageCached(
          userInfo.avatar ?? '',
          width: 60.w,
          height: 60.w,
          fit: BoxFit.cover,
        ).clipRRect(all: 30.w),
        16.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              4.w.verticalSpace,
              Text(
                info?.fullName ?? userInfo.nickname ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if ((info?.businessType?.isNotEmpty ?? false)) ...[
                6.w.verticalSpace,
                Text(
                      info!.businessType!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF9C27B0),
                      ),
                    )
                    .padding(horizontal: 8.w, vertical: 2.w)
                    .decorated(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
              ],
              if ((info?.cityName?.isNotEmpty ?? false)) ...[
                10.w.verticalSpace,
                Row(
                  children: [
                    Image.asset(Assets.iconAddress, width: 14.w),
                    8.w.horizontalSpace,
                    Text(
                      info!.cityName!,
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
    );
  }
}

class _ShareInfoItem extends StatelessWidget {
  const _ShareInfoItem({required this.title, required this.content});

  final String title;
  final String content;

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
