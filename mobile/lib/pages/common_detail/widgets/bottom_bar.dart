import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class CommonDetailBottomBarWidget extends StatelessWidget {
  const CommonDetailBottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommonDetailController>();

    return Obx(
      () => controller.merchantInfo.isReserve == 1
          ? Row(
                  children: [
                    Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Assets.iconSendMsg, width: 14.w),
                            4.w.horizontalSpace,
                            Text(
                              '發消息'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        )
                        .height(40.w)
                        .decorated(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(22.w),
                        )
                        .gestures(
                          onTap: controller.sendMessage,
                          behavior: HitTestBehavior.opaque,
                        )
                        .expanded(),
                    16.w.horizontalSpace,
                    Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Assets.iconReservation, width: 14.w),
                            4.w.horizontalSpace,
                            Text(
                              controller.type.reservationText,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFFFF9000),
                              ),
                            ),
                          ],
                        )
                        .height(40.w)
                        .decorated(
                          border: Border.all(
                            color: const Color(0xFFFF9000),
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(22.w),
                        )
                        .gestures(
                          onTap: controller.makeReservation,
                          behavior: HitTestBehavior.opaque,
                        )
                        .expanded(),
                  ],
                )
                .padding(horizontal: 14.w, vertical: 10.w)
                .safeArea(top: false)
                .decorated(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.w),
                    topRight: Radius.circular(20.w),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.05),
                      blurRadius: 20.w,
                    ),
                  ],
                )
          : const SizedBox.shrink(),
    );
  }
}
