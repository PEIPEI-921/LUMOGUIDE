import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class InviteTipWidget extends StatelessWidget {
  const InviteTipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '邀請說明'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        HtmlWidget(
          ConfigService.to.systemConfig.inviteRule ?? '',
          textStyle: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
      ],
    ).width(double.infinity).padding(horizontal: 32.w, top: 20.w, bottom: 20.w);
  }
}
