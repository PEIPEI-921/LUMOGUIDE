import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/index.dart';

class BookingGuidePage extends StatelessWidget {
  const BookingGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingGuideController());
    return IScaffold(
      appBar: IAppBar(title: '預約行程'.tr),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const GuideInfoWidget(),
            12.w.verticalSpace,
            const BookingDetailsWidget(),
            12.w.verticalSpace,
            const ContactInfoWidget(),
            24.w.verticalSpace,
            SubmitButton(
              title: controller.isEdit ? '確認修改'.tr : '我要預約'.tr,
              onPressed: controller.onSubmit,
            ).clipRRect(all: 100),
            20.w.verticalSpace,
          ],
        ).padding(horizontal: 14.w),
      ).safeArea(),
    );
  }
}
