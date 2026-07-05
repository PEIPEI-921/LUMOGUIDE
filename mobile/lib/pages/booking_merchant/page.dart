import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/index.dart';

class BookingMerchantPage extends StatelessWidget {
  const BookingMerchantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingMerchantController());
    return IScaffold(
      title: controller.shopType.reservationTitle,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MerchantInfoWidget(),
            12.w.verticalSpace,
            const BookingDetailsWidget(),
            12.w.verticalSpace,
            const ContactInfoWidget(),
            24.w.verticalSpace,
            SubmitButton(
              title: controller.isEdit ? '確認修改'.tr : '立即預約'.tr,
              onPressed: controller.onSubmit,
            ).clipRRect(all: 100),
            20.w.verticalSpace,
          ],
        ).padding(horizontal: 14.w),
      ).safeArea(),
    );
  }
}
