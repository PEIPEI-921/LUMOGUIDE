import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../index.dart';

class IAppBar extends AppBar {
  IAppBar({
    super.key,
    Widget? titleWidget,
    String? title,
    TextStyle titleStyle = const TextStyle(color: Colors.black, fontSize: 16),
    Widget? leading,
    bool showBackButton = true,
    super.actions,
    super.backgroundColor = Colors.transparent,
    super.elevation = 0,
    super.centerTitle = true,
    super.foregroundColor = Colors.black,
    double? toolbarHeight,
    super.titleSpacing = 0,
    double? leadingWidth,
    super.shape,
    super.bottom,
    SystemUiOverlayStyle? systemOverlayStyle,
    super.scrolledUnderElevation = 0,
  }) : super(
         title: titleWidget,
         leading:
             leading ??
             _buildTitleWithBackButton(title, titleStyle, showBackButton),
         leadingWidth: leadingWidth ?? _calculateLeadingWidth(title ?? ''),
         toolbarHeight: toolbarHeight ?? 50,
         systemOverlayStyle: systemOverlayStyle ?? customOverlayStyle,
       );

  static double _calculateLeadingWidth(String title) {
    final baseWidth = 40.0.w;
    final averageCharWidth = 16.0.w;
    double estimatedWidth = baseWidth + (title.length * averageCharWidth);
    return max(50.0, estimatedWidth);
  }

  static Widget _buildTitleWithBackButton(
    String? title,
    TextStyle titleStyle,
    bool showBackButton,
  ) {
    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBackButton)
              const Icon(Icons.arrow_back_ios, size: 18).padding(right: 2.w),
            Text(
              title ?? '',
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).flexible(),
          ],
        )
        .paddingOnly(left: 14.w)
        .gestures(onTap: () => Get.back(), behavior: HitTestBehavior.opaque);
  }
}

final customOverlayStyle = SystemUiOverlayStyle.dark.copyWith(
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.light,
);
