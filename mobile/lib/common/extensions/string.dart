import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension StringExt on String {
  // base64
  String get base64Encoded => base64.encode(utf8.encode(this));
  String get base64Decoded => utf8.decode(base64.decode(this));

  // url
  String get urlEncoded => Uri.encodeQueryComponent(this);
  String get urlDecoded => Uri.decodeQueryComponent(this);

  // 手机号码
  String get phoneFormatted {
    if (contains('*')) return this;
    if (length != 11) return this;
    return replaceRange(3, 7, '****');
  }

  // 身份证号
  String get idCardFormatted {
    if (contains('*')) return this;
    if (length != 15 && length != 18) return this;
    final padding = '*' * (length - 4);
    return '${substring(0, 2)}$padding${substring(length - 2)}';
  }

  // 银行卡
  String get bankcardFormatted {
    if (contains('*')) return this;
    if (length <= 4) return '**** **** **** $this';
    return '**** **** **** ${substring(length - 4)}';
  }

  Map<String, dynamic>? get toMap {
    try {
      return json.decode(this) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  List<dynamic>? get toList {
    try {
      return json.decode(this) as List<dynamic>;
    } catch (e) {
      return null;
    }
  }

  // 复制到剪贴板
  void copyToPasteboard() {
    Clipboard.setData(ClipboardData(text: this));
  }
}

extension StringRegExp on String {
  bool get isMobile {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }

  bool get isIdCard {
    return RegExp(r'^(\d{14}|\d{17})(\d|[xX])$').hasMatch(this);
  }

  // 注意：本扩展不定义 isEmail —— 邮箱校验由 Get 包的 String.isEmail 扩展提供
  // （GetUtils.isEmail）。login/register/forget_password/modify_password 均依赖它。

  bool get isChinese {
    return RegExp(r'^[\u4e00-\u9fa5]*$').hasMatch(this);
  }

  bool get isLetter {
    return RegExp(r'^[a-zA-Z]*$').hasMatch(this);
  }

  bool get isMoney {
    return RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(this);
  }

  bool get isNumber {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  // 密码复杂度：至少 6 位，且同时包含数字和字母。
  // modify_password / password_input 两个 controller 共用此规则（原为各自 private 实现）。
  bool get isValidPassword {
    if (length < 6) return false;
    final hasDigit = contains(RegExp(r'[0-9]'));
    final hasLetter = contains(RegExp(r'[a-zA-Z]'));
    return hasDigit && hasLetter;
  }
}

extension StringLocalized on String {
  String get localized {
    return Intl.message(this, name: this);
  }
}

extension Truncate on String {
  String obfuscateString(int startIndex, int endIndex) {
    if (length <= startIndex + endIndex) {
      return this;
    }

    final start = substring(0, startIndex);
    final end = substring(length - endIndex);

    return '$start***$end';
  }
}
