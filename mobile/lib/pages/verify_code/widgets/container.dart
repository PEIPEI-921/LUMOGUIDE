import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:pinput/pinput.dart';
import '../controller.dart';

class VerifyCodeContainerWidget extends StatelessWidget {
  const VerifyCodeContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        10.h.verticalSpace,
        const _TitleWidget(),
        5.h.verticalSpace,
        _EmailInfoWidget(),
        30.h.verticalSpace,
        _VerifyInputWidget(),
        50.h.verticalSpace,
        _ConfirmButtonWidget(),
        _ResendButtonWidget(),
      ],
    ).padding(horizontal: 20.w);
  }
}

// 標題組件
class _TitleWidget extends StatelessWidget {
  const _TitleWidget();

  @override
  Widget build(BuildContext context) {
    return Text(
      '輸入驗證碼'.tr,
      style: TextStyle(
        fontSize: 24.sp,
        color: const Color(0xFF0E2038),
      ),
    );
  }
}

// 郵箱顯示組件
class _EmailInfoWidget extends GetView<VerifyCodeController> {
  @override
  Widget build(BuildContext context) {
    return Text(
      '已發送6位驗證碼至'.tr + controller.email,
      style: TextStyle(
        fontSize: AppFontSize.sm,
        color: AppColors.secondaryText,
      ),
    );
  }
}

// 驗證碼輸入組件
class _VerifyInputWidget extends GetView<VerifyCodeController> {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 70.w,
      height: 60.w,
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4.0,
          )
        ],
      ),
    );

    return Pinput(
      length: 6,
      controller: controller.pinController,
      focusNode: controller.focusNode,
      defaultPinTheme: defaultPinTheme,
      separatorBuilder: (index) => SizedBox(width: 10.w),
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration?.copyWith(
          border: Border.all(color: AppColors.primary, width: 2),
        ),
      ),
      // onCompleted: (pin) => controller.submitCode(),
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
    ).center();
  }
}

// 確定按鈕組件
class _ConfirmButtonWidget extends GetView<VerifyCodeController> {
  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      title: '確定'.tr,
      onPressed: () => controller.submitCode(),
    );
  }
}

// 重新獲取按鈕組件
class _ResendButtonWidget extends GetView<VerifyCodeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => TextButton(
          onPressed: controller.isCountingDown.value
              ? null
              : () => controller.resendCode(),
          child: Text(
            controller.isCountingDown.value
                ? '重新獲取(@s)秒'
                    .trParams({'s': controller.countDown.value.toString()})
                : '重新獲取'.tr,
            style: TextStyle(
              color: controller.isCountingDown.value
                  ? AppColors.secondaryText
                  : AppColors.primary,
              fontSize: AppFontSize.sm,
            ),
          ),
        ).center()).padding(top: 16.h);
  }
}
