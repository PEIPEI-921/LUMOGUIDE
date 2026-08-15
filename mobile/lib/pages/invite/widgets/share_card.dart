import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteShareCardWidget extends StatelessWidget with UserStoreMixin {
  const InviteShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
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
              children: [
                NetImageCached(
                  userInfo.avatar ?? '',
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.cover,
                ).clipRRect(all: 25.w),
                12.w.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfo.nickname ?? '',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      if (userInfo.identityStr.isNotEmpty) ...[
                        4.w.verticalSpace,
                        Text(
                              userInfo.identityStr ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: userInfo.isGuide
                                    ? AppColors.primary
                                    : AppColors.orange,
                              ),
                            )
                            .padding(horizontal: 7.w, vertical: 2.w)
                            .decorated(
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(
                                color: userInfo.isGuide
                                    ? AppColors.primary
                                    : AppColors.orange,
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            24.w.verticalSpace,
            Column(
              children: [
                QrImageView(
                  data: userInfo.inviteUrl ?? '',
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  size: 200.w,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
                16.w.verticalSpace,
                Text(
                  '${'邀請碼：'.tr}${userInfo.inviterCode ?? ''}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ).center(),
            24.w.verticalSpace,
            Container(
              height: 1.w,
              color: AppColors.assistantText.withValues(alpha: 0.1),
            ),
            16.w.verticalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                  '邀請您加入 LUMOGUIDE'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.assistantText,
                  ),
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
