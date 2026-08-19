import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/storage.dart';
import '../values/storage.dart';
import '../langs/translation_service.dart';

class LocalizationService extends GetxService {
  static LocalizationService get to => Get.find();

  final List<Locale> languages = TranslationService.supportsLocales;

  Locale locale =
      TranslationService.locale ?? TranslationService.fallbackLocale;

  final _language = LanguageType.en.obs;
  LanguageType get language => _language.value;

  Future<LocalizationService> init() async {
    initLocale();
    return this;
  }

  static Locale _localeFromDevice(ui.Locale device) {
    final lang = device.languageCode.toLowerCase();
    final country = device.countryCode?.toUpperCase();
    if (lang == 'zh') {
      if (country == 'TW' || country == 'HK' || country == 'MO') {
        return LanguageType.tw.locale;
      }
      return LanguageType.zh.locale;
    }
    return LanguageType.en.locale;
  }

  void initLocale() {
    const savedLocale = 'zh_CN';
    if (savedLocale.isNotEmpty) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        final languageCode = parts[0];
        final countryCode = parts[1];
        locale = languages.firstWhere(
          (e) => e.languageCode == languageCode && e.countryCode == countryCode,
          orElse: () =>
              _localeFromDevice(ui.PlatformDispatcher.instance.locale),
        );
      } else {
        locale = languages.firstWhere(
          (e) => e.languageCode == savedLocale,
          orElse: () =>
              _localeFromDevice(ui.PlatformDispatcher.instance.locale),
        );
      }
    } else {
      locale = _localeFromDevice(ui.PlatformDispatcher.instance.locale);
    }
    _language.value =
        LanguageType.values.firstWhereOrNull(
          (lang) =>
              lang.locale.languageCode == locale.languageCode &&
              lang.locale.countryCode == locale.countryCode,
        ) ??
        LanguageType.tw;
  }

  void updateLocate(Locale value) {
    locale = value;
    final localeKey = value.countryCode != null
        ? '${value.languageCode}_${value.countryCode}'
        : value.languageCode;
    StorageService.to.setString(STORAGE_LANGUAGE_CODE_KEY, localeKey);
    _language.value = LanguageType.values.firstWhere(
      (lang) => lang.locale == value,
    );
  }
}
