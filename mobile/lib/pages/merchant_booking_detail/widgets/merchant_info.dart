import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class MerchantInfoWidget extends StatelessWidget {
  const MerchantInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantBookingDetailController>();

    return Obx(() {
      if (controller.merchantInfo == null) return const SizedBox.shrink();

      return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NetImageCached(
                controller.merchantInfo!.content?.firstPicture ?? '',
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
              ).clipRRect(all: 25.w),
              12.w.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.merchantInfo!.content?.name ?? '--',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: controller.merchantInfo!.isGrey
                          ? AppColors.assistantText
                          : AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.w.verticalSpace,
                  Text(
                        controller.shopType.title,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.primary,
                        ),
                      )
                      .padding(horizontal: 8.w, vertical: 2.w)
                      .decorated(
                        borderRadius: BorderRadius.circular(12.w),
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                ],
              ).expanded(),
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
