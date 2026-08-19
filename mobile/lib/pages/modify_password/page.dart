import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class ModifyPasswordPage extends StatelessWidget {
  const ModifyPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ModifyPasswordController());
    return IScaffold(
      resizeToAvoidBottomInset: false,
      title: '修改密碼'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        children: [
          CustomTextField(
            controller: controller.emailController,
            hintText: '請輸入注册时填写的邮箱'.tr,
            keyboardType: TextInputType.emailAddress,
            backgroundColor: Colors.white,
          ),
          10.w.verticalSpace,
          Row(
            children: [
              CustomTextField(
                controller: controller.codeController,
                hintText: '請輸入郵箱驗證碼'.tr,
                keyboardType: TextInputType.phone,
                backgroundColor: Colors.white,
              ).expanded(),
              Obx(() => TextButton(
                    onPressed:
                        controller.isCountingDown ? null : controller.sendCode,
                    child: Text(
                      !controller.isCountingDown
                          ? '獲取驗證碼'.tr
                          : '${controller.countDown}s'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ).constrained(width: 100.w)),
            ],
          ).decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
          ),
          10.w.verticalSpace,
          CustomTextField(
            controller: controller.passwordController,
            hintText: '請輸入新密碼'.tr,
            obscureText: true,
            isPassword: true,
            backgroundColor: Colors.white,
          ),
          10.w.verticalSpace,
          CustomTextField(
            controller: controller.confirmPasswordController,
            hintText: '請輸入確認密碼'.tr,
            obscureText: true,
            isPassword: true,
            backgroundColor: Colors.white,
          ),
          const Spacer(),
          SubmitButton(
            title: '確定'.tr,
            onPressed: controller.onSubmit,
          )
        ],
      ).padding(horizontal: 16.w, bottom: 30.w, top: 10.w),
    );
  }
}
