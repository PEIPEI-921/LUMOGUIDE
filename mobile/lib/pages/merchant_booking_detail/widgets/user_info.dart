import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';
import '../controller.dart';

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantBookingDetailController>();
    return Obx(() {
      if (controller.merchantInfo?.user == null) return const SizedBox.shrink();

      final user = controller.merchantInfo!.user!;
      return Row(
        children: [
          NetImageCached(
            controller.merchantInfo!.user!.avatar,
            width: 40.w,
            height: 40.w,
            fit: BoxFit.cover,
          ).clipRRect(all: 20.w),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname ?? ''.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                // 4.w.verticalSpace,
                // Text(
                //   '預約用戶'.tr,
                //   style: TextStyle(
                //     fontSize: 12.sp,
                //     color: AppColors.secondaryText,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
