import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class IntegralGoodsDescWidget extends StatelessWidget {
  const IntegralGoodsDescWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntegralGoodsDetailController>();

    return Obx(() => controller.goods?.content == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '商品詳情'.tr,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              10.w.verticalSpace,
              HtmlWidget(controller.goods?.content ?? '')
            ],
          )
            .padding(all: 10.w)
            .decorated(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            )
            .padding(top: 10.w));
  }
}
