import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'en_US.dart';
import 'zh_CN.dart';
import 'zh_TW.dart';

class TranslationService extends Translations {
  static Locale? get locale => LanguageType.en.locale;
  static Locale get fallbackLocale => LanguageType.en.locale;
  static List<Locale> supportsLocales = LanguageType.values
      .map((e) => e.locale)
      .toList();

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en_US,
    'zh_CN': zh_CN,
    'zh_TW': zh_TW,
  };
}

enum LanguageType { zh, tw, en }

extension LanguageTypeExtension on LanguageType {
  Locale get locale {
    switch (this) {
      case LanguageType.zh:
        return const Locale('zh', 'CN');
      case LanguageType.tw:
        return const Locale('zh', 'TW');
      case LanguageType.en:
        return const Locale('en', 'US');
    }
  }

  String get text {
    switch (this) {
      case LanguageType.zh:
        return '简体中文';
      case LanguageType.tw:
        return '繁體中文';
      case LanguageType.en:
        return 'English';
    }
  }

  bool get isCurrent {
    return Get.locale?.languageCode == locale.languageCode &&
        Get.locale?.countryCode == locale.countryCode;
  }
}
