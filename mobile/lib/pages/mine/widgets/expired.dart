import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MineExpiredWidget extends StatelessWidget with UserStoreMixin {
  const MineExpiredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();

    return Obx(
      () => (userInfo.isFreeVip || userInfo.inAudit || !userInfo.isVip)
          ? const SizedBox.shrink()
          : Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo.isVipExpired
                              ? '會員已過期'.tr
                              : '${'會員有效期'.tr}: ${userInfo.vipExpirationTimeStr}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        5.w.verticalSpace,
                        Text(
                          userInfo.isGuide
                              ? '繼續使⽤LuMo Guide的全部功能， \n請您使⽤積分兌換或付費延長會籍'.tr
                              : '想繼續成為 LuMo 的合作商家嗎？\n⾺上延長會籍'.tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ).expanded(),
                    Row(
                          children: [
                            Text(
                              '延長會籍'.tr,
                              style: TextStyle(
                                color: const Color(0xFF82330C),
                                fontSize: 12.sp,
                              ),
                            ),
                            4.w.horizontalSpace,
                            Image.asset(
                              Assets.iconAccountArrow,
                              width: 12.w,
                              height: 12.w,
                            ),
                          ],
                        )
                        .padding(horizontal: 10.w, vertical: 4.w)
                        .ripple()
                        .decorated(
                          color: const Color(0xFFFFF8EC),
                          borderRadius: BorderRadius.circular(20),
                        )
                        .clipRRect(all: 20)
                        .gestures(
                          onTap: controller.onExtendVip,
                          behavior: HitTestBehavior.opaque,
                        ),
                  ],
                )
                .padding(horizontal: 12.w, top: 10.w, bottom: 10)
                .constrained(minHeight: 85.w)
                .decorated(
                  image: const DecorationImage(
                    image: AssetImage(Assets.bgAccountVip),
                    fit: BoxFit.fill,
                  ),
                )
                .padding(top: 20.w),
    );
  }
}
