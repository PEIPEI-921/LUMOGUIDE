import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/index.dart';
import 'widgets/operate.dart';

class UserBookingMerchantInfoPage extends StatelessWidget {
  const UserBookingMerchantInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserBookingMerchantInfoController());
    return IScaffold(
      title: '我的預約'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(() {
        if (controller.merchantInfo == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            IRefresh(
              controller: controller,
              child: Column(
                children: [
                  Column(
                        children: [
                          const BookingStatusWidget(),
                          10.w.verticalSpace,
                          const MerchantInfoWidget(),
                        ],
                      )
                      .padding(all: 10.w)
                      .decorated(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                  10.w.verticalSpace,
                  const BookingDetailsWidget(),
                  10.w.verticalSpace,
                  const ContactInfoWidget(),
                  10.w.verticalSpace,
                  const _RejectReasonWidget(),
                  10.w.verticalSpace,
                ],
              ).scrollable(padding: EdgeInsets.symmetric(horizontal: 14.w)),
            ).expanded(),
            10.verticalSpace,
            const UserBookingMerchantInfoOperateWidget(),
          ],
        ).safeArea();
      }),
    );
  }
}

class _RejectReasonWidget extends StatelessWidget {
  const _RejectReasonWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingMerchantInfoController>();
    return Obx(() {
      if (controller.merchantInfo == null) return const SizedBox.shrink();
      if (controller.merchantInfo!.status != 5) return const SizedBox.shrink();
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '拒絕理由'.tr,
                style: TextStyle(fontSize: 14.sp, color: AppColors.red),
              ),
              4.w.verticalSpace,
              Text(
                controller.merchantInfo!.reason ?? '-',
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
