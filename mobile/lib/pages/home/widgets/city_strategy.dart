import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:marquee/marquee.dart';

import '../index.dart';

class HomeStrategyWidget extends StatelessWidget {
  const HomeStrategyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Image.asset(
          Assets.bgHomeCityStrategy,
          height: 170.w,
          fit: BoxFit.cover,
        ),
        Obx(
          () => Image.asset(
            LocalizationService.to.language == LanguageType.en
                ? Assets.iconCityStrategyEn
                : Assets.iconCityStrategyZh,
            height: 36.w,
            fit: BoxFit.cover,
          ),
        ).positioned(top: 24.w, left: 19.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const _Item(CityDetailTab.guide),
                7.w.horizontalSpace,
                const _Item(CityDetailTab.restaurant),
              ],
            ),
            8.w.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const _Item(CityDetailTab.scenic),
                7.w.horizontalSpace,
                const _Item(CityDetailTab.mall),
                7.w.horizontalSpace,
                const _Item(CityDetailTab.hotel),
                7.w.horizontalSpace,
                const _Item(CityDetailTab.ticket),
              ],
            ),
          ],
        ).padding(right: 10.w),
      ],
    ).padding(horizontal: 14.w, top: 15.w);
  }
}

class _Item extends StatelessWidget {
  const _Item(this.type);
  final CityDetailTab type;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(type.homeIcon, width: 26.w, height: 26.w),
            7.w.verticalSpace,
            _SmartMarqueeText(
              text: type.homeTitle,
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              maxWidth: 72.w,
            ).height(20.w).padding(horizontal: 2.w),
          ],
        )
        .constrained(width: 76.w, height: 70.w)
        .decorated(
          color: type.homeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.w),
        )
        .ripple(splashColor: type.homeColor.withOpacity(0.1))
        .clipRRect(all: 6.w)
        .gestures(
          onTap: () => controller.onCityGuideTap(type),
          behavior: HitTestBehavior.opaque,
        );
  }
}

/// 智能滚动文本：超出范围才滚动，未超出则居中显示
class _SmartMarqueeText extends StatelessWidget {
  const _SmartMarqueeText({
    required this.text,
    required this.style,
    required this.maxWidth,
  });

  final String text;
  final TextStyle style;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 测量文本实际宽度
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );
        textPainter.layout();
        final textWidth = textPainter.size.width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : maxWidth;

        if (textWidth > availableWidth) {
          return Marquee(
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: 20.w,
            velocity: 50.w,
            startAfter: const Duration(seconds: 2),
            pauseAfterRound: const Duration(seconds: 2),
            text: text,
            style: style,
          ).padding(horizontal: 2.w);
        } else {
          // 文本未超出，居中显示
          return Center(
            child: Text(
              text,
              style: style,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          );
        }
      },
    );
  }
}
