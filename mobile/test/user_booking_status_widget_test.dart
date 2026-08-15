import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/user_booking_manager/widgets/status.dart';

/// 预订状态徽章（StatusWidget）的状态 → 文本/颜色映射测试。
///
/// 覆盖「预订列表状态色」链路的核心逻辑：status 1~6 的文案与颜色，
/// 以及空/未知状态不渲染。渲染路径需 ScreenUtil 初始化（.sp/.w 扩展）。
void main() {
  group('StatusWidget 状态映射（预订）', () {
    test('status=1 → 待確認 / primary', () {
      const w = StatusWidget(status: 1);
      expect(w.statusText, '待確認');
      expect(w.statusColor, AppColors.primary);
    });

    test('status=2 → 已確認 / jadeGreen', () {
      const w = StatusWidget(status: 2);
      expect(w.statusText, '已確認');
      expect(w.statusColor, AppColors.jadeGreen);
    });

    test('status=3 → 已完成 / primaryText', () {
      const w = StatusWidget(status: 3);
      expect(w.statusText, '已完成');
      expect(w.statusColor, AppColors.primaryText);
    });

    test('status=4 → 已取消 / assistantText', () {
      const w = StatusWidget(status: 4);
      expect(w.statusText, '已取消');
      expect(w.statusColor, AppColors.assistantText);
    });

    test('status=5 → 已拒絕 / assistantText', () {
      const w = StatusWidget(status: 5);
      expect(w.statusText, '已拒絕');
      expect(w.statusColor, AppColors.assistantText);
    });

    test('status=6 → 已過期 / assistantText', () {
      const w = StatusWidget(status: 6);
      expect(w.statusText, '已過期');
      expect(w.statusColor, AppColors.assistantText);
    });

    test('status=null → 空文本（不渲染）', () {
      const w = StatusWidget(status: null);
      expect(w.statusText, '');
    });

    test('未知 status → 空文本（不渲染）', () {
      const w = StatusWidget(status: 99);
      expect(w.statusText, '');
    });
  });

  group('StatusWidget 渲染', () {
    Future<void> pump(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 834),
          builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
        ),
      );
    }

    testWidgets('status=2 渲染「已確認」绿色文本', (tester) async {
      await pump(tester, const StatusWidget(status: 2));
      final text = tester.widget<Text>(find.text('已確認'));
      expect(text.style?.color, AppColors.jadeGreen);
    });

    testWidgets('status=null 不渲染任何 Text', (tester) async {
      await pump(tester, const StatusWidget(status: null));
      expect(find.byType(Text), findsNothing);
    });
  });
}
