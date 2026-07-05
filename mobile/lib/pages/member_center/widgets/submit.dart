import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MemberCenterSubmitWidget extends StatelessWidget {
  const MemberCenterSubmitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberCenterController>();

    return Obx(() => controller.products.isEmpty
        ? const SizedBox.shrink()
        : Column(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '點擊按鈕即同意'.tr),
                    TextSpan(
                      text: '《VIP會員服務協議》'.tr,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          controller.onMemberAgreement();
                        },
                    ),
                    const TextSpan(text: '、'),
                    TextSpan(
                      text: '《VIP會員訂閲服務協議》'.tr,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          controller.onSubscribeAgreement();
                        },
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              10.w.verticalSpace,
              TextButton(
                onPressed: controller.onSubmit,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.selectedProduct.buyType == 2)
                      Image.asset(
                        Assets.iconIntegral,
                        width: 12.w,
                        height: 12.w,
                        color: Colors.white,
                      )
                    else
                      Text(
                        controller.selectedProduct.icon ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    4.w.horizontalSpace,
                    Text(
                      controller.selectedProduct.price ?? '0',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontFamily: 'Bebas',
                      ),
                    ).translate(offset: const Offset(0, 1)),
                    8.w.horizontalSpace,
                    Text(
                      '立即訂閱'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
                  .constrained(
                    height: 44,
                    width: double.infinity,
                  )
                  .padding(horizontal: 14.w)
                  .padding(bottom: 20.w),
            ],
          ));
  }
}
