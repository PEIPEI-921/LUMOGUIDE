import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lumotrip/common/routers/names.dart';
import 'package:lumotrip/main.dart' as app;
import 'package:lumotrip/pages/login/page.dart';
import 'package:lumotrip/pages/root/page.dart';

/// LUMOGUIDE 冒烟测试（integration_test）。
///
/// 在真实进程内驱动 App：启动 → 欢迎页自动跳转（登录态进主框架 / 未登录进登录页）
/// → 进入主框架 → 遍历底部导航 5 个 tab，断言每一步均无渲染异常（溢出/崩溃）。
/// 不依赖 macOS 辅助功能权限，直接通过
/// `flutter test integration_test/app_smoke_test.dart -d macos` 运行。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('冒烟：启动 → 主框架五 tab 渲染无异常', (tester) async {
    // 1. 启动（Global.init 完成服务/仓库初始化后 runApp，异步不 await）
    app.main();

    // 2. 欢迎页约 1s 后联网检查并跳转：已登录 → 主框架，未登录 → 登录页
    final landed = await _waitForAny(
      tester,
      [find.byType(RootPage), find.byType(LoginPage)],
      timeout: const Duration(seconds: 30),
    );
    expect(landed, isTrue, reason: '启动后应进入主框架或登录页');

    final alreadyLoggedIn = find.byType(RootPage).evaluate().isNotEmpty;
    if (!alreadyLoggedIn) {
      // 未登录：验证登录页渲染，再手动进入主框架
      expect(find.byType(TextField), findsNWidgets(2),
          reason: '登录页应有邮箱 + 密码两个输入框');
      expect(tester.takeException(), isNull, reason: '登录页渲染无异常');
      Get.offAllNamed(AppRoutes.ROOT);
      final onRoot = await _waitFor(
        tester,
        find.byType(RootPage),
        timeout: const Duration(seconds: 15),
      );
      expect(onRoot, isTrue, reason: '应进入主框架');
    }

    expect(find.byType(RootPage), findsOneWidget, reason: '应处于主框架');
    expect(tester.takeException(), isNull, reason: '首页渲染无异常');

    // 3. 遍历公开 tab（首页/城市/资讯，无需登录）
    for (final label in ['城市', '资讯', '首页']) {
      await _tapTab(tester, label);
      expect(tester.takeException(), isNull, reason: '切到「$label」tab 无渲染异常');
    }

    // 4. 消息 / 我的 tab：未登录跳登录页，已登录正常切换；两者均不应崩溃
    for (final label in ['消息', '我的']) {
      await _tapTab(tester, label);
      if (find.byType(LoginPage).evaluate().isNotEmpty) {
        // 未登录：跳转登录页属预期，验证后返回主框架继续
        expect(tester.takeException(), isNull, reason: '「$label」跳登录页无异常');
        Get.back();
        await _waitFor(
          tester,
          find.byType(RootPage),
          timeout: const Duration(seconds: 10),
        );
      }
      expect(tester.takeException(), isNull, reason: '「$label」tab 无渲染异常');
    }
  });
}

/// 反复 pump 直到 [finder] 命中，或 [timeout] 超时返回 false。
Future<bool> _waitFor(
  WidgetTester tester,
  Finder finder, {
  required Duration timeout,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await tester.pump();
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

/// 反复 pump 直到 [finders] 中任意一个命中，或 [timeout] 超时返回 false。
Future<bool> _waitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  required Duration timeout,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await tester.pump();
    if (finders.any((f) => f.evaluate().isNotEmpty)) return true;
  }
  return false;
}

/// 点击底部导航栏中标签为 [label] 的 tab 并等待渲染。
Future<void> _tapTab(WidgetTester tester, String label) async {
  final finder = find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(label),
  );
  await tester.tap(finder);
  await Future<void>.delayed(const Duration(milliseconds: 800));
  await tester.pump();
}
