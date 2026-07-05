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
    return RegExp(r'^(\\d{14}|\\d{17})(\\d|[xX])$').hasMatch(this);
  }

  // bool get isEmail {
  //   return RegExp(r'[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}')
  //       .hasMatch(this);
  // }

  bool get isChinese {
    return RegExp(r'^[\u4e00-\u9fa5]*$').hasMatch(this);
  }

  bool get isLetter {
    return RegExp(r'^[a-zA-z]*$').hasMatch(this);
  }

  bool get isMoney {
    return RegExp(r'^\\d+(\\.\\d{1,2})?$').hasMatch(this);
  }

  bool get isNumber {
    return RegExp(r'^[0-9]+$').hasMatch(this);
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
