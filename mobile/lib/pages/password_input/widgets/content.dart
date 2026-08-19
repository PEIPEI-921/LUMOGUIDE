import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../index.dart';

class PasswordContentWidget extends StatelessWidget {
  const PasswordContentWidget({super.key});

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
        const _PasswordInputView(),
        16.h.verticalSpace,
        const _ConfirmPasswordInputView(),
        50.h.verticalSpace,
        const _SubmitButtonView(),
      ],
    ).padding(horizontal: 20.w);
  }
}

class _TitleView extends StatelessWidget {
  const _TitleView();

  @override
  Widget build(BuildContext context) {
    return Text(
      '密碼設置'.tr,
      style: TextStyle(
        fontSize: 24.sp,
        color: const Color(0xFF0E2038),
      ),
    );
  }
}

class _SubtitleView extends StatelessWidget {
  const _SubtitleView();

  @override
  Widget build(BuildContext context) {
    return Text(
      '請輸入6~12位密碼，包含數字、字母'.tr,
      style: TextStyle(
        fontSize: 12.sp,
        color: AppColors.secondaryText,
      ),
    );
  }
}

class _PasswordInputView extends StatelessWidget {
  const _PasswordInputView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordInputController>();

    return Obx(() => Row(
          children: [
            Image.asset(
              Assets.iconLock,
              width: 14.w,
              height: 14.w,
            ),
            TextField(
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.primaryText,
              ),
              obscureText: !controller.isPasswordVisible.value,
              obscuringCharacter: '●',
              maxLines: 1,
              onTapOutside: (event) {
                hideKeyboard(context);
              },
              controller: controller.passwordController,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
                border: InputBorder.none,
                hintText: '請輸入密碼'.tr,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.assistantText,
                ),
                suffixIcon: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.assistantText,
                    size: 20,
                  ),
                ),
              ),
            ).expanded(),
          ],
        ).padding(horizontal: 19.w).decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ));
  }
}

class _ConfirmPasswordInputView extends StatelessWidget {
  const _ConfirmPasswordInputView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordInputController>();

    return Obx(() => Row(
          children: [
            Image.asset(
              Assets.iconLock,
              width: 14.w,
              height: 14.w,
            ),
            TextField(
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.primaryText,
              ),
              obscureText: !controller.isConfirmPasswordVisible.value,
              obscuringCharacter: '●',
              maxLines: 1,
              onTapOutside: (event) {
                hideKeyboard(context);
              },
              controller: controller.confirmPasswordController,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
                border: InputBorder.none,
                hintText: '請重複密碼'.tr,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.assistantText,
                ),
                suffixIcon: IconButton(
                  onPressed: controller.toggleConfirmPasswordVisibility,
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.assistantText,
                    size: 20,
                  ),
                ),
              ),
            ).expanded(),
          ],
        ).padding(horizontal: 19.w).decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ));
  }
}

class _SubmitButtonView extends StatelessWidget {
  const _SubmitButtonView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordInputController>();

    return SubmitButton(
      title: '確定'.tr,
      onPressed: controller.submit,
      height: 46.w,
    );
  }
}
