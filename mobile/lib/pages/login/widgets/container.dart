import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/index.dart';
import '../index.dart';

// 主登录容器组件
class LoginContainerWidget extends StatelessWidget {
  const LoginContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TitleView(),
        18.w.verticalSpace,
        const _EmailView(),
        15.w.verticalSpace,
        const _PasswordView(),
        30.w.verticalSpace,
        const _LoginView(),
        15.w.verticalSpace,
        const _RememberView(),
        15.w.verticalSpace,
        const _FooterView(),
      ],
    ).padding(horizontal: 15.w, top: 15.w, bottom: 20.w).decorated(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.w),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ).padding(horizontal: 22.w);
  }
}

// 登录标题组件
class _TitleView extends StatelessWidget {
  const _TitleView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '登錄'.tr,
          style: TextStyle(
            fontSize: 20.sp,
            color: AppColors.primaryText,
          ),
        ),
        4.verticalSpace,
        Container(
          width: 20.w,
          height: 3,
          color: AppColors.primary,
        ),
      ],
    ).center();
  }
}

// 邮箱输入框组件
class _EmailView extends StatelessWidget {
  const _EmailView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

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
            hintText: '請輸入郵箱'.tr,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primaryText.withOpacity(0.3),
            ),
          ),
        ).expanded(),
      ],
    ).padding(horizontal: 19.w).decorated(
          color: AppColors.primaryText.withOpacity(0.03),
          borderRadius: BorderRadius.circular(100),
        );
  }
}

// 密码输入框组件
class _PasswordView extends StatelessWidget {
  const _PasswordView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Row(
      children: [
        Image.asset(
          Assets.iconLock,
          width: 14.w,
          height: 14.w,
        ),
        Obx(() => TextField(
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.primaryText,
              ),
              onTapOutside: (event) {
                hideKeyboard(context);
              },
              obscureText: controller.isObscure.value,
              obscuringCharacter: '●',
              maxLines: 1,
              controller: controller.passwordController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.w),
                border: InputBorder.none,
                hintText: '請輸入密碼'.tr,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.primaryText.withOpacity(0.3),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.togglePasswordVisible();
                  },
                  icon: Icon(
                    controller.isObscure.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.primaryText.withOpacity(0.3),
                  ),
                ),
              ),
            )).expanded(),
      ],
    ).padding(horizontal: 19.w).decorated(
          color: AppColors.primaryText.withOpacity(0.03),
          borderRadius: BorderRadius.circular(100),
        );
  }
}

// 记住密码组件
class _RememberView extends StatelessWidget {
  const _RememberView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Row(
      children: [
        Obx(
          () => Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: controller.rememberPassword.value
                  ? null
                  : Border.all(color: Colors.grey),
              color: controller.rememberPassword.value
                  ? AppColors.primary
                  : Colors.transparent,
            ),
            child: controller.rememberPassword.value
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ).gestures(
            onTap: controller.toggleRememberPassword,
          ),
        ),
        8.w.horizontalSpace,
        Text(
          '記住密碼'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryText,
          ),
        ).gestures(
          onTap: controller.toggleRememberPassword,
        ),
      ],
    );
  }
}

// 登录按钮组件
class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return SubmitButton(
      title: '登 錄'.tr,
      onPressed: controller.login,
      height: 50,
    );
  }
}

// 底部链接组件
class _FooterView extends StatelessWidget {
  const _FooterView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '忘記密碼'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primary,
          ),
        ).padding(vertical: 5.w).gestures(
              onTap: controller.forgotPassword,
              behavior: HitTestBehavior.opaque,
            ),
        Text(
          '還沒有帳號? 去註冊'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryText.withOpacity(0.8),
          ),
        ).padding(vertical: 5.w).gestures(
              onTap: controller.goToRegister,
              behavior: HitTestBehavior.opaque,
            ),
      ],
    );
  }
}
