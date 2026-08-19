import 'package:flutter/services.dart';

vibrate() async {
  try {
    await HapticFeedback.lightImpact();
  } catch (_) {
    // 忽略震動失敗（部分平台/設備不支持）
  }
}
