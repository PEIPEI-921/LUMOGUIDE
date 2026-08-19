import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/index.dart';

class MerchantBookingDetailPage extends StatelessWidget {
  const MerchantBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantBookingDetailController());
    return IScaffold(
      title: '預約我的'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(
        () => controller.merchantInfo == null
            ? const SizedBox.shrink()
            : Column(
                children: [
                  IRefresh(
                    controller: controller,
                    child: Column(
                      children: [
                        const MerchantInfoWidget(),
                        10.w.verticalSpace,
                        Column(
                              children: [
                                const BookingStatusWidget(),
                                10.w.verticalSpace,
                                const UserInfoWidget(),
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
                      ],
                    ).scrollable().padding(horizontal: 14.w),
                  ).expanded(),
                  const _OperateButtonsWidget(),
                ],
              ).safeArea(),
      ),
    );
  }
}

class _OperateButtonsWidget extends StatelessWidget {
  const _OperateButtonsWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantBookingDetailController>();

    return Obx(() {
      final info = controller.merchantInfo;
      if (info == null) return const SizedBox.shrink();

      final showConfirmOrComplete =
          controller.canConfirm || controller.canComplete;
      final showReject = controller.canReject;
      final showDelete = controller.canDelete;

      if (!showConfirmOrComplete && !showReject && !showDelete) {
        return const SizedBox.shrink();
      }

      Widget buildBtn(String text, VoidCallback onTap, {Color? color}) {
        return Container(
          height: 36.w,
          alignment: Alignment.center,
          child: Text(
            text.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: color ?? AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ).gestures(onTap: onTap, behavior: HitTestBehavior.opaque).expanded();
      }

      Widget divider() => Container(
        width: 1,
        height: 20.w,
        color: AppColors.assistantText.withValues(alpha: 0.3),
      );

      final children = <Widget>[];

      if (showConfirmOrComplete) {
        children.add(
          buildBtn(
            controller.canConfirm ? '確認預約' : '完成預約',
            controller.confirmReservation,
            color: AppColors.primary,
          ),
        );
        if (showReject || showDelete) children.add(divider());
      }

      if (showReject) {
        children.add(
          buildBtn(
            '拒絕',
            controller.rejectReservation,
            color: AppColors.primaryText,
          ),
        );
        if (showDelete) children.add(divider());
      }

      if (showDelete) {
        children.add(
          buildBtn('刪除', controller.deleteReservation, color: AppColors.red),
        );
      }

      return Row(children: children)
          .height(40.w)
          .backgroundColor(Colors.white.withValues(alpha: 0.6))
          .padding(horizontal: 14.w);
    });
  }
}

class _RejectReasonWidget extends StatelessWidget {
  const _RejectReasonWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantBookingDetailController>();
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
