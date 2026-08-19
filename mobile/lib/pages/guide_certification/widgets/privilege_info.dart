import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/index.dart';

class PrivilegeInfoWidget extends StatelessWidget {
  const PrivilegeInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Text('LuMo Guide 特權'.tr)
                .fontSize(18.sp)
                .fontWeight(FontWeight.bold)
                .textColor(Colors.white),
          ),
          30.w.verticalSpace,
          const _PrivilegeItem(
            icon: Icons.star,
            title: '推廣您的業務，讓所有LuMo用戶找到您',
          ),
          15.w.verticalSpace,
          const _PrivilegeItem(
            icon: Icons.people,
            title: '建立您的行業人脈',
          ),
          15.w.verticalSpace,
          const _PrivilegeItem(
            icon: Icons.info,
            title: '獲取LuMo Guide分享的所有一手資訊',
          ),
          15.w.verticalSpace,
          const _PrivilegeItem(
            icon: Icons.connect_without_contact,
            title: '在線聯絡 LuMo Guide 和合作商家',
          ),
          15.w.verticalSpace,
          const _PrivilegeItem(
            icon: Icons.calendar_today,
            title: '管理預訂',
          ),
          15.w.verticalSpace,
          const _PrivilegeItem(
            icon: Icons.share,
            title: '分享行業相關信息和 Tips，獲得更多 LuMoFun',
          ),
          50.w.verticalSpace,
          Text('想成為LuMo Guide 請點擊 "下一步"'.tr)
              .fontSize(14.sp)
              .textColor(AppColors.primaryText)
              .textAlignment(TextAlign.center),
          10.w.verticalSpace,
          Text('開始上傳的您的身份信息'.tr)
              .fontSize(14.sp)
              .textColor(AppColors.primaryText)
              .textAlignment(TextAlign.center),
        ],
      ).padding(horizontal: 20.w, vertical: 20.w),
    );
  }
}

class _PrivilegeItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PrivilegeItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.orange,
          size: 24.w,
        ),
        10.w.horizontalSpace,
        Text(title.tr)
            .fontSize(14.sp)
            .textColor(AppColors.primaryText)
            .expanded(),
      ],
    );
  }
}
