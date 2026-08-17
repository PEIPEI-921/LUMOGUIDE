import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'common/index.dart';
import 'global.dart';

void _reportAppError(String error, String stack) {
  try {
    ApiProvider().dio.post(
      '/common/appError',
      data: {
        'page': 'flutter_runtime',
        'error': error,
        'stack': stack.length > 2000 ? stack.substring(0, 2000) : stack,
        'time': DateTime.now().toIso8601String(),
      },
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
  } catch (_) {}
}

void main() async {
  await Global.init();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _reportAppError(details.exceptionAsString(), details.toString());
  };

  ErrorWidget.builder = (details) {
    return Material(
      color: const Color(0xFFFFF3F3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Text(
          '頁面渲染錯誤: ${details.exceptionAsString()}',
          style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
        ),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _reportAppError(error.toString(), stack.toString());
    return true;
  };

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
