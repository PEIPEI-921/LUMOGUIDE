import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MemberCenterTopWidget extends StatelessWidget with UserStoreMixin {
  const MemberCenterTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          Image.asset(
            userInfo.isGuide ? Assets.bgMemberGuide : Assets.bgMemberMerchant,
            width: double.infinity,
          ),
          Row(
            children: [
              CircleNetworkImage(imageUrl: userInfo.avatar ?? '', radius: 25.w),
              10.w.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userInfo.nickname ?? '',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Row(
                    children: [
                      if (userInfo.identityStr.isNotEmpty) ...[
                        3.w.verticalSpace,
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
                      if (userInfo.vipName.isNotEmpty) ...[
                        3.w.verticalSpace,
                        Text(
                              userInfo.vipName ?? '',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.orange,
                              ),
                            )
                            .padding(horizontal: 7.w, vertical: 2.w)
                            .decorated(
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(color: AppColors.orange),
                            )
                            .padding(left: 10.w),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ).positioned(top: 20.w, left: 14.w),
          Text(
            userInfo.isVipExpired
                ? '會員已過期'.tr
                : '${'會員有效期'.tr}: ${userInfo.vipExpirationTimeStr}',
            style: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
          ).positioned(bottom: 10.w, left: 14.w),
        ],
      ).padding(horizontal: 14.w).safeArea(bottom: false),
    );
  }
}
