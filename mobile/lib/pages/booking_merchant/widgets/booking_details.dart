import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class BookingDetailsWidget extends StatelessWidget {
  const BookingDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingMerchantController>();

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._buildTypeSpecificFields(controller)],
        )
        .padding(all: 16.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        );
  }

  List<Widget> _buildTypeSpecificFields(BookingMerchantController controller) {
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

  List<Widget> _buildRestaurantFields(BookingMerchantController controller) {
    return [
      Obx(
        () => LabelSelectField(
          label: '預計到達時間'.tr,
          value: controller.arriveTime ?? '',
          hintText: '請選擇預計到達時間'.tr,
          isRequired: true,
          onTap: controller.onSelectArriveTime,
        ),
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.peopleCountController,
        hintText: '請輸入人數'.tr,
        labelText: '人數'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.remarksController,
        hintText: '請輸入備注說明'.tr,
        labelText: '備注說明'.tr,
        maxLines: 4,
        // isRequired: true,
      ),
    ];
  }

  List<Widget> _buildShoppingFields(BookingMerchantController controller) {
    return [
      Obx(
        () => LabelSelectField(
          label: '預計到達時間'.tr,
          value: controller.arriveTime ?? '',
          hintText: '請選擇預計到達時間'.tr,
          isRequired: true,
          onTap: controller.onSelectArriveTime,
        ),
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.peopleCountController,
        hintText: '請輸入人數'.tr,
        labelText: '人數'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.remarksController,
        hintText: '請輸入備注說明'.tr,
        labelText: '備注說明'.tr,
        maxLines: 4,
        // isRequired: true,
      ),
      12.w.verticalSpace,
      _CustomerListWidget(),
    ];
  }

  List<Widget> _buildHotelFields(BookingMerchantController controller) {
    return [
      Obx(
        () => LabelSelectField(
          label: '入住時間'.tr,
          value: controller.checkInTime ?? '',
          hintText: '請選擇入住時間'.tr,
          isRequired: true,
          onTap: controller.onSelectCheckInTime,
        ),
      ),
      12.w.verticalSpace,
      Obx(
        () => LabelSelectField(
          label: '離店時間'.tr,
          value: controller.checkOutTime ?? '',
          hintText: '請選擇離店時間'.tr,
          isRequired: true,
          onTap: controller.onSelectCheckOutTime,
        ),
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.peopleCountController,
        hintText: '請輸入入住人數'.tr,
        labelText: '入住人數'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.roomCountController,
        hintText: '請輸入房間數'.tr,
        labelText: '房間數'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.otherRequirementsController,
        hintText: '請輸入其他要求'.tr,
        labelText: '其他要求'.tr,
        maxLines: 4,
      ),
    ];
  }

  List<Widget> _buildTicketFields(BookingMerchantController controller) {
    return [
      CustomTextField(
        controller: controller.peopleCountController,
        hintText: '請輸入人數'.tr,
        labelText: '人數'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.remarksController,
        hintText: '請輸入備注說明'.tr,
        labelText: '備注說明'.tr,
        maxLines: 4,
        // isRequired: true,
      ),
    ];
  }

  List<Widget> _buildScenicFields(BookingMerchantController controller) {
    return [
      Obx(
        () => LabelSelectField(
          label: '預計到達時間'.tr,
          value: controller.arriveTime ?? '',
          hintText: '請選擇預計到達時間'.tr,
          isRequired: true,
          onTap: controller.onSelectArriveTime,
        ),
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.peopleCountController,
        hintText: '請輸入人數'.tr,
        labelText: '人數'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.ticketTypeController,
        hintText: '請輸入門票類型'.tr,
        labelText: '門票類型'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.remarksController,
        hintText: '請輸入備注說明'.tr,
        labelText: '備注說明'.tr,
        maxLines: 4,
        // isRequired: true,
      ),
    ];
  }
}

class _CustomerListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingMerchantController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '客戶名單'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
        ),
        8.w.verticalSpace,
        Container(
          width: double.infinity,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Center(
            child: Obx(
              () => Text(
                controller.fileName == null ? '選擇文件'.tr : controller.fileName!,
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ).padding(horizontal: 20.w),
        ).gestures(
          onTap: () {
            controller.onSelectFile();
          },
          behavior: HitTestBehavior.opaque,
        ),
      ],
    );
  }
}
