import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class BookingDetailsWidget extends StatelessWidget {
  const BookingDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingMerchantInfoController>();

    return Obx(() {
      if (controller.merchantInfo == null) return const SizedBox.shrink();

      return Column(
        children: _buildTypeSpecificFields(controller),
      ).padding(all: 10.w).decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          );
    });
  }

  List<Widget> _buildTypeSpecificFields(
      UserBookingMerchantInfoController controller) {
    switch (controller.shopType) {
      case MerchantShopType.restaurant:
        return _buildRestaurantFields(controller);
      case MerchantShopType.shopping:
        return _buildShoppingFields(controller);
      case MerchantShopType.hotel:
        return _buildHotelFields(controller);
      case MerchantShopType.ticket:
        return _buildTicketFields(controller);
      case MerchantShopType.scenic:
        return _buildScenicFields(controller);
    }
  }

  List<Widget> _buildRestaurantFields(
      UserBookingMerchantInfoController controller) {
    return [
      if (controller.merchantInfo!.arrivalTime?.isNotEmpty == true)
        _DetailItem(
          label: '預計到達時間'.tr,
          value: controller.merchantInfo!.arrivalTime!,
        ),
      _DetailItem(
        label: '人數'.tr,
        value: controller.merchantInfo!.number ?? '',
      ),
      _DetailItem(
        label: '備注說明'.tr,
        value: controller.merchantInfo!.remark ?? '',
      ),
    ];
  }

  List<Widget> _buildShoppingFields(
      UserBookingMerchantInfoController controller) {
    return [
      if (controller.merchantInfo!.arrivalTime?.isNotEmpty == true)
        _DetailItem(
          label: '預計到達時間'.tr,
          value: controller.merchantInfo!.arrivalTime!,
        ),
      _DetailItem(
        label: '人數'.tr,
        value: controller.merchantInfo!.number ?? '',
      ),
      _DetailItem(
        label: '備注說明'.tr,
        value: controller.merchantInfo!.remark ?? '',
      ),
      if (controller.merchantInfo!.file?.isNotEmpty == true)
        _DetailItem(
          label: '客戶名單'.tr,
          value: '點擊查看'.tr,
          valueColor: AppColors.primary,
        ).gestures(
        onTap: () {
          controller.onTapFile();
        },
        behavior: HitTestBehavior.opaque,
      ),
    ];
  }

  List<Widget> _buildHotelFields(UserBookingMerchantInfoController controller) {
    return [
      if (controller.merchantInfo!.arrivalTime?.isNotEmpty == true)
        _DetailItem(
          label: '入住時間'.tr,
          value: controller.merchantInfo!.arrivalTime!,
        ),
      if (controller.merchantInfo!.leaveTime?.isNotEmpty == true)
        _DetailItem(
          label: '離店時間'.tr,
          value: controller.merchantInfo!.leaveTime!,
        ),
      _DetailItem(
        label: '入住人數'.tr,
        value: controller.merchantInfo!.number ?? '',
      ),
      if (controller.merchantInfo!.roomNumber?.isNotEmpty == true)
        _DetailItem(
          label: '房間數'.tr,
          value: controller.merchantInfo!.roomNumber!,
        ),
      _DetailItem(
        label: '其他要求'.tr,
        value: controller.merchantInfo!.remark ?? '',
      ),
    ];
  }

  List<Widget> _buildTicketFields(
      UserBookingMerchantInfoController controller) {
    return [
      _DetailItem(
        label: '人數'.tr,
        value: controller.merchantInfo!.number ?? '',
      ),
      _DetailItem(
        label: '備注說明'.tr,
        value: controller.merchantInfo!.remark ?? '',
      ),
    ];
  }

  List<Widget> _buildScenicFields(
      UserBookingMerchantInfoController controller) {
    return [
      if (controller.merchantInfo!.arrivalTime?.isNotEmpty == true)
        _DetailItem(
          label: '預計到達時間'.tr,
          value: controller.merchantInfo!.arrivalTime!,
        ),
      _DetailItem(
        label: '人數'.tr,
        value: controller.merchantInfo!.number ?? '',
      ),
      if (controller.merchantInfo!.ticketsType?.isNotEmpty == true)
        _DetailItem(
          label: '門票類型'.tr,
          value: controller.merchantInfo!.ticketsType!,
        ),
      _DetailItem(
        label: '備注說明'.tr,
        value: controller.merchantInfo!.remark ?? '',
      ),
    ];
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText,
            ),
          ),
          20.w.horizontalSpace,
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor ?? AppColors.primaryText,
            ),
            textAlign: TextAlign.right,
          ).expanded(),
        ],
      ),
    );
  }
}
