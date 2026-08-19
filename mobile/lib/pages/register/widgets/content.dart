import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/index.dart';
import '../index.dart';

// 主內容組件
class RegisterContentWidget extends StatelessWidget {
  const RegisterContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        10.h.verticalSpace,
        const _TitleView(),
        5.h.verticalSpace,
        const _SubtitleView(),
        30.h.verticalSpace,
        const _InviteCodeView(),
        20.h.verticalSpace,
        const _EmailView(),
        50.h.verticalSpace,
        const _NextStepView(),
      ],
    ).padding(horizontal: 20.w);
  }
}

// 標題組件
class _TitleView extends StatelessWidget {
  const _TitleView();

  @override
  Widget build(BuildContext context) {
    return Text(
      '輸入您的電子郵箱'.tr,
      style: TextStyle(
        fontSize: 24.sp,
        color: const Color(0xFF0E2038),
      ),
    );
  }
}

// 副標題組件
class _SubtitleView extends StatelessWidget {
  const _SubtitleView();

  @override
  Widget build(BuildContext context) {
    return Text(
      '使用您的郵箱註冊或登錄路盟'.tr,
      style: TextStyle(
        fontSize: 12.sp,
        color: AppColors.secondaryText,
      ),
    );
  }
}

// 邀請碼輸入框組件
class _InviteCodeView extends StatelessWidget {
  const _InviteCodeView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return Row(
      children: [
        Image.asset(
          Assets.iconInviteCode,
          width: 14.w,
          height: 14.w,
        ),
        TextField(
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primaryText,
          ),
          maxLines: 1,
          onTapOutside: (event) {
            hideKeyboard(context);
          },
          controller: controller.inviteCodeController,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
            border: InputBorder.none,
            hintText: '請輸入您的邀請碼'.tr,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: AppColors.assistantText,
            ),
          ),
        ).expanded(),
      ],
    ).padding(horizontal: 19.w).decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        );
  }
}

// 郵箱輸入框組件
class _EmailView extends StatelessWidget {
  const _EmailView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return Row(
      children: [
        Image.asset(
          Assets.iconMail,
          width: 14.w,
          height: 14.w,
        ),
        TextField(
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primaryText,
          ),
          maxLines: 1,
          onTapOutside: (event) {
            hideKeyboard(context);
          },
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
            border: InputBorder.none,
            hintText: '請輸入您的電子郵箱'.tr,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: AppColors.assistantText,
            ),
          ),
        ).expanded(),
      ],
    ).padding(horizontal: 19.w).decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        );
  }
}

// 下一步按鈕組件
class _NextStepView extends StatelessWidget {
  const _NextStepView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return SubmitButton(
      title: '下一步'.tr,
      onPressed: controller.nextStep,
      height: 46.w,
    );
  }
}
