import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'common/index.dart';
import 'global.dart';

void main() async {
  await Global.init();
  runApp(const MyApp());
  Global.setSystemUi();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 834),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'LUMOGUIDE',
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          ),
          translations: TranslationService(),
          locale: LocalizationService.to.locale,
          fallbackLocale: TranslationService.fallbackLocale,
          supportedLocales: LocalizationService.to.languages,
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          navigatorObservers: [AppPages.observer],
          builder: (context, child) {
            Widget app = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: EasyLoading.init()(context, child),
            );

            if (isDesktop) {
              app = Container(
                color: AppColors.primary,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: app,
                  ),
                ),
              );
            }

            return app;
          },
        );
      },
    );
  }
}
