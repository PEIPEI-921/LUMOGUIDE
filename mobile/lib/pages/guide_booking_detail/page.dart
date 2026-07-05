import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class GuideBookingDetailPage extends StatelessWidget {
  const GuideBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuideBookingDetailController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgMine),
      appBar: IAppBar(
        title: '預約我的'.tr,
      ),
      body: Obx(
        () => controller.guideReservation == null
            ? const SizedBox.shrink()
            : Column(
                children: [
                  IRefresh(
                    controller: controller,
                    child: Column(
                      children: [
                        Column(
                              children: [
                                const _BookingStatusWidget(),
                                Divider(
                                  height: 20.w,
                                  thickness: 0.7.w,
                                  color: AppColors.primaryText.withOpacity(
                                    0.05,
                                  ),
                                ),
                                const _UserInfoWidget(),
                              ],
                            )
                            .padding(all: 10.w)
                            .decorated(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                        12.w.verticalSpace,
                        const _BookingDetailsWidget(),
                        12.w.verticalSpace,
                        const _ContactInfoWidget(),
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

class _BookingStatusWidget extends StatelessWidget {
  const _BookingStatusWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingDetailController>();

    return Obx(() {
      if (controller.guideReservation == null) return const SizedBox.shrink();

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              10.w.verticalSpace,
              Icon(Icons.access_time, size: 30.w, color: AppColors.primary),
              6.w.horizontalSpace,
              Text(
                '預約時間'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.assistantText,
                ),
              ),
              4.w.verticalSpace,
              Text(
                controller.guideReservation!.createdAt ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: controller.guideReservation!.isGrey
                      ? AppColors.assistantText
                      : AppColors.primaryText,
                ),
              ),
            ],
          ).width(double.infinity),
          _StatusWidget(
            status: controller.guideReservation!.status,
          ).positioned(top: 0.w, right: 0),
        ],
      );
    });
  }
}

class _UserInfoWidget extends StatelessWidget {
  const _UserInfoWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingDetailController>();

    return Obx(() {
      if (controller.guideReservation == null) return const SizedBox.shrink();

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NetImageCached(
            controller.guideReservation!.user?.avatar ?? '',
            width: 40.w,
            height: 40.w,
            fit: BoxFit.cover,
          ).clipRRect(all: 20.w),
          8.w.horizontalSpace,
          Text(
            controller.guideReservation!.user?.nickname ??
                controller.guideReservation!.contact ??
                '--',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
        ],
      );
    });
  }
}

class _BookingDetailsWidget extends StatelessWidget {
  const _BookingDetailsWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingDetailController>();

    return Obx(() {
      if (controller.guideReservation == null) return const SizedBox.shrink();

      return Column(
            children: [
              _DetailItem(
                label: '預約城市'.tr,
                value: controller.guideReservation!.cityName ?? '',
              ),
              _DetailItem(
                label: '預計到達時間'.tr,
                value: controller.guideReservation!.arrivalTime ?? '',
              ),
              _DetailItem(
                label: '人數'.tr,
                value: controller.guideReservation!.number ?? '',
              ),
              _DetailItem(
                label: '行程/備注說明'.tr,
                value: controller.guideReservation!.remark ?? '',
              ),
            ],
          )
          .padding(all: 10.w)
          .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
          );
    });
  }
}

class _ContactInfoWidget extends StatelessWidget {
  const _ContactInfoWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingDetailController>();

    return Obx(() {
      if (controller.guideReservation == null) return const SizedBox.shrink();

      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContactItem(
                label: '聯繫人'.tr,
                value: controller.guideReservation!.contact ?? '',
              ),
              _ContactItem(
                label: '聯繫電話'.tr,
                value: controller.guideReservation!.phone ?? '',
              ),
              _ContactItem(
                label: '聯繫人郵箱'.tr,
                value: controller.guideReservation!.email ?? '',
              ),
              _ContactItem(
                label: '其他聯繫方式'.tr,
                value: controller.guideReservation!.other ?? '',
              ),
            ],
          )
          .padding(all: 10.w)
          .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
          );
    });
  }
}

class _OperateButtonsWidget extends StatelessWidget {
  const _OperateButtonsWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingDetailController>();

    return Obx(() {
      final info = controller.guideReservation;
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
        color: AppColors.assistantText.withOpacity(0.3),
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
          .backgroundColor(Colors.white.withOpacity(0.6))
          .padding(horizontal: 14.w);
    });
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText),
          ),
          20.w.horizontalSpace,
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
            textAlign: TextAlign.right,
          ).expanded(),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String label;
  final String value;

  const _ContactItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText),
          ),
          20.w.horizontalSpace,
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
            textAlign: TextAlign.right,
          ).expanded(),
        ],
      ),
    );
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({this.status});
  final int? status;

  /// 1新預約/2已确认/3已完成/4已取消/5已拒絕/6已過期
  String get statusText {
    switch (status) {
      case 1:
        return '新預約'.tr;
      case 2:
        return '已確認'.tr;
      case 3:
        return '已完成'.tr;
      case 4:
        return '已取消';
      case 5:
        return '已拒絕';
      case 6:
        return '已過期';
      default:
        return '';
    }
  }

  Color get statusColor {
    switch (status) {
      case 1:
        return AppColors.primary;
      case 2:
        return const Color(0xFF00D6C4);
      case 3:
        return AppColors.primaryText;
      case 4:
        return AppColors.assistantText;
      case 5:
        return const Color(0xFFDD0000);
      case 6:
        return AppColors.assistantText;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusText.isEmpty) return const SizedBox.shrink();
    return Text(
          statusText,
          style: TextStyle(color: statusColor, fontSize: 10.sp),
        )
        .padding(horizontal: 8.w, vertical: 5.w)
        .decorated(
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: statusColor, width: 1.w),
        );
  }
}

class _RejectReasonWidget extends StatelessWidget {
  const _RejectReasonWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingDetailController>();
    return Obx(() {
      if (controller.guideReservation == null) return const SizedBox.shrink();
      if (controller.guideReservation!.status != 5)
        return const SizedBox.shrink();
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '拒絕理由'.tr,
                style: TextStyle(fontSize: 14.sp, color: AppColors.red),
              ),
              4.w.verticalSpace,
              Text(
                controller.guideReservation!.reason ?? '-',
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
