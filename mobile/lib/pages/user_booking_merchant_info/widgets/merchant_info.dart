import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class MerchantInfoWidget extends StatelessWidget {
  const MerchantInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserBookingMerchantInfoController>();

    return Obx(() {
      if (controller.merchantInfo == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetImageCached(
            controller.merchantInfo!.content?.firstPicture,
            width: double.infinity,
            height: 189.w,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8.w),
          ),
          12.w.verticalSpace,
          Text(
            controller.merchantInfo!.content?.name ?? '',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: controller.merchantInfo!.isGrey
                  ? AppColors.assistantText
                  : AppColors.primaryText,
            ),
          ),
          12.w.verticalSpace,
          Column(
            children: [
              if (controller.merchantInfo!.content?.startTime?.isNotEmpty ==
                  true)
                _InfoItem(
                  icon: Assets.iconDial,
                  title: controller.shopType == MerchantShopType.scenic
                      ? '開放時間'.tr
                      : '營業時間'.tr,
                  content: controller.merchantInfo!.content!.startTime!,
                  isGrey: controller.merchantInfo!.isGrey,
                ),
              if (controller.merchantInfo!.content?.endTime?.isNotEmpty == true)
                _InfoItem(
                  icon: Assets.iconDial,
                  title: '結束時間'.tr,
                  content: controller.merchantInfo!.content!.endTime!,
                  isGrey: controller.merchantInfo!.isGrey,
                ),
              if (controller.shopType == MerchantShopType.scenic)
                _InfoItem(
                  icon: Assets.iconTicket,
                  title: '票價'.tr,
                  content: controller.merchantInfo!.content!.ticketsFree == '0'
                      ? controller.merchantInfo!.content!.price ?? ''
                      : '免費'.tr,
                  isGrey: controller.merchantInfo!.isGrey,
                ),
              if (controller.shopType == MerchantShopType.restaurant) ...[
                if (controller.merchantInfo!.content?.capacity?.isNotEmpty ==
                    true)
                  _InfoItem(
                    icon: Assets.iconPeople,
                    title: '餐廳可容納人數'.tr,
                    content: controller.merchantInfo!.content!.capacity!,
                    isGrey: controller.merchantInfo!.isGrey,
                  ),
                _InfoItem(
                  icon: Assets.iconClock,
                  title: '是否接受團餐預訂'.tr,
                  content: controller.merchantInfo!.content!.orderFood == '1'
                      ? '是'.tr
                      : '否'.tr,
                  isGrey: controller.merchantInfo!.isGrey,
                ),
              ],
              if (controller.merchantInfo!.content?.phone?.isNotEmpty == true)
                _InfoItem(
                  icon: Assets.iconTel2,
                  title: '電話'.tr,
                  content: controller.merchantInfo!.content!.phone!,
                  hasAction: true,
                  isGrey: controller.merchantInfo!.isGrey,
                  onTap: controller.makePhoneCall,
                ),
              if (controller.merchantInfo!.content?.email?.isNotEmpty == true)
                _InfoItem(
                  icon: Assets.iconEmail,
                  title: '郵箱'.tr,
                  content: controller.merchantInfo!.content!.email!,
                  isGrey: controller.merchantInfo!.isGrey,
                ),
              if (controller.merchantInfo!.content?.website?.isNotEmpty == true)
                _InfoItem(
                  icon: Assets.iconWebsite,
                  title: '網址'.tr,
                  content: controller.merchantInfo!.content!.website!,
                  isGrey: controller.merchantInfo!.isGrey,
                ),
              if (controller.merchantInfo!.content?.address?.isNotEmpty == true)
                _InfoItem(
                  icon: Assets.iconAddress,
                  title: '地址'.tr,
                  content: controller.merchantInfo!.content!.address!,
                  isLast: true,
                  isGrey: controller.merchantInfo!.isGrey,
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _InfoItem extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final bool hasAction;
  final bool hasArrow;
  final bool isLast;
  final bool isGrey;
  final VoidCallback? onTap;
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.content,
    this.hasAction = false,
    this.hasArrow = false,
    this.isLast = false,
    this.isGrey = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(icon, width: 12.w),
            8.w.horizontalSpace,
            Text(
              '$title: ',
              style: TextStyle(
                fontSize: 14.sp,
                color: isGrey ? AppColors.assistantText : AppColors.primaryText,
              ),
            ),
          ],
        ),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            color: isGrey ? AppColors.assistantText : AppColors.primaryText,
          ),
        ).expanded(),
        if (hasAction && content.isNotEmpty) ...[
          8.w.horizontalSpace,
          Image.asset(Assets.iconTelFill, width: 16.w),
        ],
        if (hasArrow && content.isNotEmpty) ...[
          8.w.horizontalSpace,
          Icon(
            Icons.arrow_forward_ios,
            size: 14.w,
            color: AppColors.assistantText,
          ),
        ],
      ],
    ).padding(bottom: isLast ? 0 : 10.w).gestures(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
        );
  }
}
