import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumotrip/common/index.dart';

/// 語言服務測試：持久化讀寫 + 切換生效（Get.updateLocale）。
/// 使用 testWidgets + GetMaterialApp 提供 widget 樹，Get.updateLocale 的
/// forceAppUpdate 才能在測試框架內工作。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setupApp(WidgetTester tester, {Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    Get.reset();
    Get.put(await StorageService().init());
    final service = LocalizationService();
    await service.init(); // 真實 App 中 Global.init 調用
    Get.put(service);
    await tester.pumpWidget(GetMaterialApp(
      translations: TranslationService(),
      locale: Get.find<LocalizationService>().locale,
      fallbackLocale: TranslationService.fallbackLocale,
      supportedLocales: Get.find<LocalizationService>().languages,
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SizedBox(),
    ));
  }

  group('LocalizationService 語言持久化與切換', () {
    testWidgets('無記錄時非中文設備默認簡體中文', (tester) async {
      await setupApp(tester);
      final service = Get.find<LocalizationService>();
      expect(service.locale, const Locale('zh', 'CN'));
      expect(service.language, LanguageType.zh);
    });

    testWidgets('切換語言後寫入存儲（持久化）+ Get.locale 更新', (tester) async {
      await setupApp(tester);
      final service = Get.find<LocalizationService>();
      service.updateLocate(const Locale('en', 'US'));
      await tester.pump();
      expect(
        StorageService.to.getString(STORAGE_LANGUAGE_CODE_KEY),
        'en_US',
      );
      expect(service.language, LanguageType.en);
      expect(Get.locale?.languageCode, 'en');
    });

    testWidgets('有存儲記錄時 initLocale 讀取持久化值', (tester) async {
      await setupApp(tester, prefs: {'language_code': 'zh_TW'});
      final service = Get.find<LocalizationService>();
      expect(service.locale, const Locale('zh', 'TW'));
      expect(service.language, LanguageType.tw);
    });

    testWidgets('存儲無效值時回退設備語言且不拋異常', (tester) async {
      await setupApp(tester, prefs: {'language_code': 'xx_YY_invalid'});
      final service = Get.find<LocalizationService>();
      // 不拋異常；匹配不到時回退設備語言（測試環境為 en_US）
      expect(service.language, LanguageType.en);
    });
  });
}
