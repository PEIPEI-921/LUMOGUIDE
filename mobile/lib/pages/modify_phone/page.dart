import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class ModifyPhonePage extends StatelessWidget {
  const ModifyPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ModifyPhoneController());
    return IScaffold(
      resizeToAvoidBottomInset: false,
      backgroundImage: const AssetImage(Assets.bgMine),
      title: '綁定手機號'.tr,
      body: Column(
        children: [
          CustomTextField(
            controller: controller.phoneController,
            hintText: '請輸入手機號'.tr,
            keyboardType: TextInputType.phone,
            backgroundColor: Colors.white,
          ),
          10.w.verticalSpace,
          Row(
            children: [
              CustomTextField(
                controller: controller.codeController,
                hintText: '請輸入短信驗證碼'.tr,
                keyboardType: TextInputType.number,
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
                  ).constrained(width: 100.w))
            ],
          ).decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
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
