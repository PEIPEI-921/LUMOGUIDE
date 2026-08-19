import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/index.dart';
import 'widgets/operate.dart';

class UserBookingGuideInfoPage extends StatelessWidget {
  const UserBookingGuideInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserBookingGuideInfoController());
    return IScaffold(
      title: '我的預約'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(
        () => controller.guideInfo == null
            ? const SizedBox.shrink()
            : Column(
                children: [
                  IRefresh(
                    controller: controller,
                    child: Column(
                      children: [
                        Column(
                              children: [
                                const BookingStatusWidget(),
                                Divider(
                                  height: 20.w,
                                  thickness: 0.7.w,
                                  color: AppColors.primaryText.withValues(alpha: 
                                    0.05,
                                  ),
                                ),
                                const GuideInfoWidget(),
                              ],
                            )
                            .padding(all: 10.w)
                            .decorated(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                        12.w.verticalSpace,
                        const BookingDetailsWidget(),
                        12.w.verticalSpace,
                        const ContactInfoWidget(),
                        10.w.verticalSpace,
                        const _RejectReasonWidget(),
                        10.w.verticalSpace,
                      ],
                    ).scrollable().padding(horizontal: 14.w),
                  ).expanded(),
                  10.verticalSpace,
                  const UserBookingGuideInfoOperateWidget(),
                ],
              ).safeArea(),
      ),
    );
  }
}

class _RejectReasonWidget extends StatelessWidget {
  const _RejectReasonWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingGuideInfoController>();
    return Obx(() {
      if (controller.guideInfo == null) return const SizedBox.shrink();
      if (controller.guideInfo!.status != 5) return const SizedBox.shrink();
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '拒絕理由'.tr,
                style: TextStyle(fontSize: 14.sp, color: AppColors.red),
              ),
              4.w.verticalSpace,
              Text(
                controller.guideInfo!.reason ?? '-',
                style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
              ),
            ],
          )
          .padding(all: 10.w)
          .constrained(width: double.infinity)
          .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
          );
    });
  }
}
