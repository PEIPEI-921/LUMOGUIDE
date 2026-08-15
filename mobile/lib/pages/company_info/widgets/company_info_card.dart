import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class CompanyInfoCard extends StatelessWidget {
  const CompanyInfoCard({super.key, required this.companyInfo});

  final CompanyInfo companyInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.w),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                companyInfo.fullName,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ).expanded(),
              if (companyInfo.businessType != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Text(
                    companyInfo.businessType ?? '',
                    style: TextStyle(
                      color: const Color(0xFF9C27B0),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          8.w.verticalSpace,
          if (companyInfo.cityName != null)
            Text(
              '${companyInfo.cityName}: ${companyInfo.address}',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
            ).gestures(
              onTap: () => openAddressMap(
                name: companyInfo.name,
                address: companyInfo.address,
              ),
              behavior: HitTestBehavior.opaque,
            ),
          12.w.verticalSpace,
          if (companyInfo.introduction != null) ...[
            Text(
              '簡介'.tr,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
            ),
            4.w.verticalSpace,
            Text(
              companyInfo.introduction ?? '',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            12.w.verticalSpace,
          ],
          _ContactInfo(
            email: companyInfo.email,
            phone: companyInfo.phone,
            website: companyInfo.website,
            otherContact: companyInfo.otherContact,
            wechat: companyInfo.wechat,
            whatsApp: companyInfo.whatsApp,
            line: companyInfo.line,
          ),
        ],
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  const _ContactInfo({
    this.email,
    this.phone,
    this.website,
    this.otherContact,
    this.wechat,
    this.whatsApp,
    this.line,
  });

  final String? email;
  final String? phone;
  final String? website;
  final String? otherContact;
  final String? wechat;
  final String? whatsApp;
  final String? line;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (email != null && email!.isNotEmpty)
          _ContactItem(label: 'EMAIL'.tr, value: email!),
        if (phone != null && phone!.isNotEmpty)
          _ContactItem(label: '聯繫電話'.tr, value: phone!),
        if (website != null && website!.isNotEmpty)
          _ContactItem(label: '公司網站'.tr, value: website!),
        if (wechat != null && wechat!.isNotEmpty)
          _ContactItem(label: '微信/Wechat'.tr, value: wechat!),
        if (whatsApp != null && whatsApp!.isNotEmpty)
          _ContactItem(label: 'WhatsApp'.tr, value: whatsApp!),
        if (line != null && line!.isNotEmpty)
          _ContactItem(label: 'Line'.tr, value: line!),
        if (otherContact != null && otherContact!.isNotEmpty)
          _ContactItem(label: '其他聯繫方式'.tr, value: otherContact!),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          10.w.horizontalSpace,
          Text(
            value,
            style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            textAlign: TextAlign.right,
          ).expanded(),
        ],
      ),
    );
  }
}
