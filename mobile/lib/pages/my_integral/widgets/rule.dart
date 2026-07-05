import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class IntegralRuleWidget extends StatelessWidget {
  const IntegralRuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final html = ConfigService.to.systemConfig.integralRule ?? '';
    return IScaffold(
      appBar: IAppBar(title: '積分規則'.tr),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: html.isEmpty
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 20.w),
              child: HtmlWidget(
                html,
                textStyle: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16.sp,
                ),
              ),
            ),
    );
  }
}
