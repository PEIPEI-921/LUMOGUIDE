import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';

class ImageTipWidget extends StatelessWidget {
  const ImageTipWidget({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '僅允許上傳擁有版權或自拍的圖片，違法圖片後果自負'.tr,
      style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
    ).alignment(Alignment.centerLeft);
  }
}
