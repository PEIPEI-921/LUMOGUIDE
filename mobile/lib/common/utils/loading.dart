import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Loading {
  Loading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 1500)
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 35.0
      ..lineWidth = 2
      ..radius = 13.5
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black.withValues(alpha: 0.7)
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black.withValues(alpha: 0.6)
      ..dismissOnTap = false
      ..maskType = EasyLoadingMaskType.custom;
  }

  static void reset() {
    EasyLoading.instance
      ..textColor = Colors.white
      ..backgroundColor = Colors.black.withValues(alpha: 0.7)
      ..contentPadding = const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 20.0,
      );
  }

  static void show([String? text]) {
    reset();
    EasyLoading.show(status: text, maskType: EasyLoadingMaskType.clear);
  }

  static Future<void> toast(
    String? text, {
    EasyLoadingToastPosition position = EasyLoadingToastPosition.center,
    bool userInteraction = true,
  }) async {
    reset();
    if (text == null) return;
    await EasyLoading.showToast(
      text,
      maskType: userInteraction
          ? EasyLoadingMaskType.none
          : EasyLoadingMaskType.clear,
      toastPosition: position,
    );
  }

  static Future<void> success(
    String? text, {
    bool userInteractions = true,
  }) async {
    if (text == null) return;
    reset();
    await EasyLoading.showSuccess(
      text,
      maskType: userInteractions
          ? EasyLoadingMaskType.none
          : EasyLoadingMaskType.clear,
    );
  }

  static Future<void> error(String? text,
      {bool userInteractions = true}) async {
    if (text == null) return;
    reset();
    await EasyLoading.showError(
      text,
      maskType: userInteractions
          ? EasyLoadingMaskType.none
          : EasyLoadingMaskType.clear,
    );
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }

  static void customToast(
    String? text, {
    EasyLoadingToastPosition position = EasyLoadingToastPosition.top,
    Color? textColor = Colors.black,
    Color? backgroundColor = Colors.white,
  }) async {
    if (text == null) return;

    EasyLoading.instance
      ..textColor = textColor ?? Colors.white
      ..backgroundColor = backgroundColor ?? Colors.black.withValues(alpha: 0.7)
      ..contentPadding = const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 30.0,
      );
    await EasyLoading.showToast(
      text,
      toastPosition: position,
      maskType: EasyLoadingMaskType.clear,
    );
  }

  static void showW([String? text]) {
    EasyLoading.instance
      ..textColor = const Color(0xFF585858)
      ..backgroundColor = Colors.white
      ..indicatorColor = const Color(0xFFA3A3A3)
      ..contentPadding = const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 20.0,
      );
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show(status: text, maskType: EasyLoadingMaskType.clear);
  }
}
