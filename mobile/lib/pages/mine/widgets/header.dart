import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../index.dart';

class MineHeaderWidget extends StatelessWidget {
  const MineHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.w.verticalSpace,
                const _UserInfo(),
                15.w.verticalSpace,
                const _Stats(),
              ],
            )
            .padding(all: 14.w)
            .decorated(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8.w),
              border: const Border(
                top: BorderSide(color: AppColors.primary, width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF666FFF).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
        const _ActionButtons().positioned(right: 5.w, top: 5.w),
      ],
    );
  }
}

class _UserInfo extends StatelessWidget with UserStoreMixin {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleNetworkImage(imageUrl: userInfo.avatar ?? '', radius: 40.w)
              .padding(all: 2)
              .decorated(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(100),
              )
              .gestures(
                onTap: controller.onEditUserInfo,
                behavior: HitTestBehavior.opaque,
              ),
          15.w.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userInfo.nickname ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).flexible(),
                  if (userInfo.identityStr.isNotEmpty) ...[
                    5.w.horizontalSpace,
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
                    5.w.horizontalSpace,
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
                        ),
                  ],
                ],
              ),
              _UserIdRow(id: userInfo.id.toString()),
              _InviteCodeRow(
                code: userInfo.inviterCode ?? '',
              ).gestures(onTap: () => Get.toNamed(AppRoutes.INVITE)),
            ],
          ).expanded(),
        ],
      ),
    );
  }
}

class _UserIdRow extends StatelessWidget {
  final String id;

  const _UserIdRow({required this.id});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('ID:'.tr).fontSize(12.sp).textColor(AppColors.assistantText),
        SizedBox(width: 4.w),
        Text(id).fontSize(12.sp).textColor(AppColors.assistantText),
      ],
    );
  }
}

class _InviteCodeRow extends StatelessWidget {
  final String code;

  const _InviteCodeRow({required this.code});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('邀請碼：'.tr).fontSize(12.sp).textColor(AppColors.assistantText),
        SizedBox(width: 4.w),
        Text(code).fontSize(12.sp).textColor(AppColors.assistantText),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(Assets.iconAccountEdit, width: 20.w, height: 20.w)
            .padding(all: 6.w)
            .ripple()
            .gestures(
              onTap: controller.onEditUserInfo,
              behavior: HitTestBehavior.opaque,
            ),
        4.w.horizontalSpace,
        Image.asset(Assets.iconAccountSetting, width: 20.w, height: 20.w)
            .padding(all: 6.w)
            .ripple()
            .gestures(
              onTap: controller.onSetting,
              behavior: HitTestBehavior.opaque,
            ),
      ],
    );
  }
}

class _Stats extends StatelessWidget with UserStoreMixin {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();
    return Obx(
      () => Row(
        children: [
          _StatItem(
                value: userInfo.followCount.toString(),
                label: '關注'.tr,
                showLine: false,
              )
              .gestures(
                onTap: () => controller.onMyFollow(),
                behavior: HitTestBehavior.opaque,
              )
              .expanded(),
          if (!userInfo.isUser)
            _StatItem(value: userInfo.fanCount.toString(), label: '粉絲'.tr)
                .gestures(
                  onTap: () => controller.onFollowMe(),
                  behavior: HitTestBehavior.opaque,
                )
                .expanded(),
          _StatItem(value: userInfo.integral.toString(), label: '積分'.tr)
              .gestures(
                onTap: () => controller.onMenuTap(MineMenu.fun),
                behavior: HitTestBehavior.opaque,
              )
              .expanded(),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool showLine;

  const _StatItem({
    required this.value,
    required this.label,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showLine)
          Container(
            margin: EdgeInsets.only(right: 15.w),
            width: 1,
            height: 30,
            color: AppColors.primaryText.withOpacity(0.05),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value)
                .fontSize(18.sp)
                .fontWeight(FontWeight.w600)
                .textColor(AppColors.primaryText),
            Text(label.tr).fontSize(12.sp).textColor(AppColors.assistantText),
          ],
        ),
      ],
    );
  }
}
