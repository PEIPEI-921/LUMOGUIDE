import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class GuideBookingManagerCalendarWidget extends StatelessWidget {
  const GuideBookingManagerCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideBookingManagerController>();

    return Obx(
      () => DatePickerCalendarWidget(
        selectedDate: controller.selectedDay ?? DateTime.now(),
        onDateSelected: controller.onDateSelected,
        isAllMode: controller.isAllMode,
      ),
    );
  }
}
