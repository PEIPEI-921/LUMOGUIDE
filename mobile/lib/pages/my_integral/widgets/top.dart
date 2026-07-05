import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MyIntegralTopWidget extends StatelessWidget with UserStoreMixin {
  const MyIntegralTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyIntegralController>();

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(Assets.bgIntegralTop, height: 100.w),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(Assets.iconIntegral, width: 14.w, height: 14.w),
                    3.w.horizontalSpace,
                    Text(
                      '當前積分'.tr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  userInfo.integral.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
                  '兌換紀錄'.tr,
                  style: TextStyle(color: AppColors.primary, fontSize: 12.sp),
                )
                .padding(left: 13.w, vertical: 5.w, right: 10.w)
                .decorated(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.w),
                    bottomLeft: Radius.circular(20.w),
                  ),
                )
                .gestures(
                  onTap: controller.onRecord,
                  behavior: HitTestBehavior.opaque,
                ),
          ],
        ).padding(left: 18.w),
      ],
    );
  }
}
