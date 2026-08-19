import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class BookingDetailsWidget extends StatelessWidget {
  const BookingDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingGuideController>();

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelSelectField(
              label: '預約城市'.tr,
              value: controller.guideInfo.cityName ?? '',
              hintText: '請選擇預約城市'.tr,
              isRightArrow: false,
              onTap: () {},
            ),
            12.w.verticalSpace,
            LabelSelectField(
              label: '預計到達時間'.tr,
              value: controller.arriveTime ?? '',
              hintText: '請選擇預計到達時間'.tr,
              isRequired: true,
              onTap: controller.onSelectArriveTime,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.peopleCountController,
              hintText: '請輸入人數'.tr,
              labelText: '人數'.tr,
              isRequired: true,
              keyboardType: TextInputType.number,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.itineraryController,
              hintText: '請輸入行程/備註說明'.tr,
              labelText: '行程/備註說明'.tr,
              maxLines: 4,
              isRequired: true,
            ),
          ],
        ).padding(all: 16.w).decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ));
  }
}
