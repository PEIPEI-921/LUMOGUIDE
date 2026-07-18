import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumotrip/common/index.dart';

enum ClientItineraryFormat { image, pdf, word }

class FormatPickerDialog extends StatelessWidget {
  const FormatPickerDialog({super.key});

  static Future<ClientItineraryFormat?> show() {
    return Get.dialog<ClientItineraryFormat>(const FormatPickerDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择导出格式',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 20.w),
            _FormatOption(
              icon: Icons.image_outlined,
              title: '图片',
              subtitle: 'PNG 格式，适合快速分享',
              onTap: () => Get.back(result: ClientItineraryFormat.image),
            ),
            SizedBox(height: 8.w),
            _FormatOption(
              icon: Icons.picture_as_pdf_outlined,
              title: 'PDF',
              subtitle: '多页文档，适合打印或邮件',
              onTap: () => Get.back(result: ClientItineraryFormat.pdf),
            ),
            SizedBox(height: 8.w),
            _FormatOption(
              icon: Icons.description_outlined,
              title: 'Word 文档',
              subtitle: '可编辑文档，适合进一步修改',
              onTap: () => Get.back(result: ClientItineraryFormat.word),
            ),
            SizedBox(height: 16.w),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.assistantText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FormatOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundBlue,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(children: [
          Icon(icon, size: 28.sp, color: AppColors.primary),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 2.w),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.assistantText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20.sp, color: AppColors.assistantText),
        ]),
      ),
    );
  }
}
