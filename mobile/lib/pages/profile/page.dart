import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    return IScaffold(
        backgroundImage: const AssetImage(Assets.bgMine),
        appBar: IAppBar(
          title: '修改資料'.tr,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AvatarItem().ripple().gestures(
                  onTap: controller.onEditAvatar,
                  behavior: HitTestBehavior.opaque,
                ),
            const _Divider(),
            const _NicknameItem().ripple().gestures(
                  onTap: controller.onEditNickname,
                  behavior: HitTestBehavior.opaque,
                ),
            const _Divider(),
            const _EmailItem(),
            const _Divider(),
            const _PhoneItem().ripple().gestures(
                  onTap: controller.onBindPhone,
                  behavior: HitTestBehavior.opaque,
                ),
            const _Divider(),
            const _BirthdateItem().ripple().gestures(
                  onTap: controller.onEditBirthdate,
                  behavior: HitTestBehavior.opaque,
                ),
          ],
        )
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            )
            .padding(horizontal: 14.w, vertical: 10.w));
  }
}

class _AvatarItem extends StatelessWidget with UserStoreMixin {
  const _AvatarItem();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
          child: Row(
            children: [
              Text('頭像'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
              const Spacer(),
              CircleNetworkImage(
                imageUrl: userInfo.avatar,
                radius: 24.w,
              ),
              4.w.horizontalSpace,
              Icon(
                Icons.chevron_right,
                color: AppColors.assistantText,
                size: 20.w,
              ),
            ],
          ),
        ));
  }
}

class _NicknameItem extends StatelessWidget with UserStoreMixin {
  const _NicknameItem();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
          child: Row(
            children: [
              Text('暱稱'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
              const Spacer(),
              Text(userInfo.nickname ?? '')
                  .fontSize(14.sp)
                  .textColor(AppColors.primaryText),
              4.w.horizontalSpace,
              Icon(
                Icons.chevron_right,
                color: AppColors.assistantText,
                size: 20.w,
              ),
            ],
          ),
        ));
  }
}

class _EmailItem extends StatelessWidget with UserStoreMixin {
  const _EmailItem();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
          child: Row(
            children: [
              Text('郵箱'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
              const Spacer(),
              Text(userInfo.email ?? '')
                  .fontSize(14.sp)
                  .textColor(AppColors.assistantText),
            ],
          ),
        ));
  }
}

class _PhoneItem extends StatelessWidget with UserStoreMixin {
  const _PhoneItem();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
          child: Row(
            children: [
              Text('手機號'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
              const Spacer(),
              Text(userInfo.phone ?? '去绑定'.tr)
                  .fontSize(14.sp)
                  .textColor(AppColors.assistantText),
              4.w.horizontalSpace,
              if (userInfo.phone.isEmpty)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.assistantText,
                  size: 20.w,
                ),
            ],
          ),
        ));
  }
}

class _BirthdateItem extends StatelessWidget with UserStoreMixin {
  const _BirthdateItem();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
          child: Row(
            children: [
              Text('出生日期'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
              const Spacer(),
              Text(userInfo.birthday ?? '')
                  .fontSize(14.sp)
                  .textColor(AppColors.primaryText),
              4.w.horizontalSpace,
              Icon(
                Icons.chevron_right,
                color: AppColors.assistantText,
                size: 20.w,
              ),
            ],
          ),
        ));
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: AppColors.primaryText.withValues(alpha: 0.05),
    );
  }
}
