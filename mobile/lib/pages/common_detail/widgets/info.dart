import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class CommonDetailInfoWidget extends StatelessWidget {
  const CommonDetailInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommonDetailController>();

    return Obx(
      () =>
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.merchantInfo.name ?? '',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  6.w.verticalSpace,
                  Row(
                    children: [
                      Text(
                            controller.merchantInfo.className ?? '',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                            ),
                          )
                          .padding(horizontal: 12.w, vertical: 5.w)
                          .decorated(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                      if (controller.merchantInfo.cityName.isNotEmpty)
                        Text(
                              controller.merchantInfo.cityName ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            )
                            .padding(horizontal: 12.w, vertical: 5.w)
                            .decorated(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20.w),
                            )
                            .gestures(
                              onTap: () {
                                controller.onCityTap();
                              },
                              behavior: HitTestBehavior.opaque,
                            )
                            .padding(left: 10.w),
                    ],
                  ),
                  10.w.verticalSpace,
                  // if (controller.merchantInfo.companyInfo?.id != null)
                  //   _CompanyItem(company: controller.merchantInfo.companyInfo!)
                  //       .padding(bottom: 10.w),
                  Column(
                        children: [
                          if (controller.merchantInfo.startTime.isNotEmpty)
                            _InfoItem(
                              icon: Assets.iconDial,
                              title:
                                  controller.type == CommonDetailType.activity
                                  ? '開始時間'.tr
                                  : controller.type == CommonDetailType.scenic
                                  ? '開放時間'.tr
                                  : '營業時間'.tr,
                              content: controller.merchantInfo.startTime!,
                            ),
                          if (controller.merchantInfo.endTime.isNotEmpty)
                            _InfoItem(
                              icon: Assets.iconDial,
                              title: '结束时间'.tr,
                              content: controller.merchantInfo.endTime!,
                            ),
                          if (controller.type == CommonDetailType.scenic)
                            _InfoItem(
                              icon: Assets.iconTicket,
                              title: '票價'.tr,
                              content:
                                  controller.merchantInfo.ticketsFree == '0'
                                  ? controller.merchantInfo.price ?? ''
                                  : '免費'.tr,
                            ),
                          if (controller.type ==
                              CommonDetailType.restaurant) ...[
                            _InfoItem(
                              icon: Assets.iconPeople,
                              title: '餐廳可容納人數'.tr,
                              content: controller.merchantInfo.capacity ?? '',
                            ),
                            _InfoItem(
                              icon: Assets.iconClock,
                              title: '是否接受團餐預訂'.tr,
                              content: controller.merchantInfo.orderFood == '1'
                                  ? '是'.tr
                                  : '否'.tr,
                            ),
                          ],
                          if (controller.merchantInfo.phone.isNotEmpty)
                            _InfoItem(
                              icon: Assets.iconTel2,
                              title: '電話'.tr,
                              content: controller.merchantInfo.phone!,
                              hasAction: true,
                              onTap: controller.makePhoneCall,
                            ),
                          if (controller.merchantInfo.email.isNotEmpty)
                            _InfoItem(
                              icon: Assets.iconEmail,
                              title: '郵箱'.tr,
                              content: controller.merchantInfo.email!,
                              onTap: controller.sendEmail,
                            ),
                          if (controller.merchantInfo.website.isNotEmpty)
                            _InfoItem(
                              icon: Assets.iconWebsite,
                              title: '網址'.tr,
                              content: controller.merchantInfo.website!,
                              onTap: controller.openWebsite,
                            ),
                          if (controller.merchantInfo.address.isNotEmpty)
                            _InfoItem(
                              icon: Assets.iconAddress,
                              title: '地址'.tr,
                              content: controller.merchantInfo.address!,
                              isLast: true,
                              onTap: controller.viewAddress,
                            ),
                        ],
                      )
                      .padding(all: 10.w)
                      .decorated(
                        color: AppColors.primaryText.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                ],
              )
              .width(double.infinity)
              .padding(top: 20.w, horizontal: 14.w)
              .decorated(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.w),
              ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final bool hasAction;
  final bool hasArrow;
  final VoidCallback? onTap;
  final bool isLast;
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.content,
    this.hasAction = false,
    this.hasArrow = false,
    this.isLast = false,
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
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
            Text(
              content,
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
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
        )
        .padding(bottom: isLast ? 0 : 10.w)
        .gestures(onTap: onTap, behavior: HitTestBehavior.opaque);
  }
}
