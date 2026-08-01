import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class MerchantManagementItemWidget extends StatelessWidget {
  const MerchantManagementItemWidget({super.key, required this.item});

  final MerchantShop item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantManagementController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.isRead == 0)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    margin: EdgeInsets.only(right: 4.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  '發佈時間: ${item.createdAt}',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                _StatusWidget(status: item.auditStatus),
              ],
            ),
            10.w.verticalSpace,
            NetImageCached(
              width: double.infinity,
              height: 185.w,
              item.firstPicture,
              fit: BoxFit.cover,
            ).clipRRect(all: 6.w),
            10.w.verticalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name ?? '',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ).expanded(),
                    Text(
                      item.type ?? '',
                      style: TextStyle(
                        color: const Color(0xFFFF8A00),
                        fontSize: 11.sp,
                      ),
                    ).padding(horizontal: 10.w, vertical: 4.w).decorated(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFFF8A00)),
                        ),
                  ],
                ),
                8.w.verticalSpace,
                _IconContent(
                  assets: Assets.iconTel,
                  title: '電話'.tr,
                  content: item.phone ?? '--',
                ).padding(bottom: 4.w),
                _IconContent(
                  assets: Assets.iconLocation,
                  title: '地址'.tr,
                  content: item.address ?? '',
                ).padding(bottom: 4.w).gestures(
                  onTap: () => openAddressMap(
                    name: item.name,
                    address: item.address,
                    latitude: item.latitude,
                    longitude: item.longitude,
                  ),
                  behavior: HitTestBehavior.opaque,
                )
              ],
            ),
            if (item.auditFeedback.isNotEmpty && item.auditStatus == 2)
              Text(
                '${'駁回原因'.tr}: ${item.auditFeedback ?? ''}',
                style: const TextStyle(
                  color: Color(0xFFDD0000),
                ),
              ).padding(top: 10.w),
          ],
        ).padding(all: 10.w).decorated(color: Colors.white),
        _OperateWidget(
          onEdit: () {
            controller.onEditMerchant(item);
          },
          onDelete: () {
            controller.onDeleteMerchant(item);
          },
        ),
      ],
    ).decorated(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ).clipRRect(all: 8.w);
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({this.status});
  final int? status;

  /// 0审核中/1审核通过/2驳回
  String get statusText {
    switch (status) {
      case 0:
        return '審核中';
      case 1:
        return '審核通過';
      case 2:
        return '審核駁回';
      default:
        return '';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0:
        return AppColors.primary;
      case 1:
        return const Color(0xFF00BEAA);
      case 2:
        return const Color(0xFFDD0000);
      default:
        return AppColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusText.isEmpty) return const SizedBox.shrink();
    return Text(
      statusText,
      style: TextStyle(
        color: statusColor,
        fontSize: 10.sp,
      ),
    ).padding(horizontal: 8.w, vertical: 5.w).decorated(
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            color: statusColor,
            width: 1.w,
          ),
        );
  }
}

class _IconContent extends StatelessWidget {
  const _IconContent({
    required this.assets,
    required this.title,
    required this.content,
  });
  final String assets;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          assets,
          width: 12.w,
          color: AppColors.assistantText,
        ),
        4.w.horizontalSpace,
        Text(
          '$title: ',
          style: TextStyle(
            color: AppColors.assistantText,
            fontSize: 12.sp,
          ),
        ),
        Text(
          content,
          style: TextStyle(
            color: AppColors.assistantText,
            fontSize: 12.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ).expanded(),
      ],
    );
  }
}

class _OperateWidget extends StatelessWidget {
  const _OperateWidget({this.onEdit, this.onDelete});
  final Function()? onEdit;
  final Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.iconPublishEdit,
              width: 12.w,
              color: AppColors.primaryText,
            ),
            5.w.horizontalSpace,
            Text(
              '編輯'.tr,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 15.sp,
              ),
            ),
          ],
        )
            .height(double.infinity)
            .gestures(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
            )
            .expanded(),
        Container(
          width: 1,
          height: 20.w,
          color: AppColors.assistantText.withOpacity(0.3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.iconPublishDelete,
              width: 12.w,
              color: AppColors.primaryText,
            ),
            5.w.horizontalSpace,
            Text(
              '刪除'.tr,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
          ],
        )
            .height(double.infinity)
            .gestures(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
            )
            .expanded(),
      ],
    ).height(40.w).backgroundColor(Colors.white.withOpacity(0.6));
  }
}
