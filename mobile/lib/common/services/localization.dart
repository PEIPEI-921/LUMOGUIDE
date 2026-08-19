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
    // 优先读取用户手动选择的语言（updateLocate 写入）。
    // 无记录时：中文设备跟随设备语言（繁中/简中），
    // 非中文设备也默认简体中文 —— 本 App 是中文产品，避免首次启动直接显示英文。
    final savedLocale =
        StorageService.to.getString(STORAGE_LANGUAGE_CODE_KEY);
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
      final device = ui.PlatformDispatcher.instance.locale;
      if (device.languageCode.toLowerCase() == 'zh') {
        locale = _localeFromDevice(device);
      } else {
        // 非中文设备默認簡體中文（中文產品）
        locale = LanguageType.zh.locale;
      }
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
    _language.value = LanguageType.values.firstWhereOrNull(
      (lang) =>
          lang.locale.languageCode == value.languageCode &&
          lang.locale.countryCode == value.countryCode,
    ) ??
        // 找不到精确匹配时，回退到语言码匹配（如 zh → zh_CN）
        LanguageType.values.firstWhereOrNull(
          (lang) => lang.locale.languageCode == value.languageCode,
        ) ??
        LanguageType.en;
    // 關鍵：通知 GetX 重建 GetMaterialApp，.tr 才會按新 locale 生效
    Get.updateLocale(value);
  }
}
