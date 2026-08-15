import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/my_publish/widgets/status.dart';

/// 发布审核状态徽章（StatusWidget）的状态 → 文本/颜色映射测试。
void main() {
  group('StatusWidget 状态映射（发布审核）', () {
    test('status=0 → 審核中 / primary', () {
      const w = StatusWidget(status: 0);
      expect(w.statusText, '審核中');
      expect(w.statusColor, AppColors.primary);
    });

    test('status=1 → 審核通過 / #00BEAA', () {
      const w = StatusWidget(status: 1);
      expect(w.statusText, '審核通過');
      expect(w.statusColor, const Color(0xFF00BEAA));
    });

    test('status=2 → 審核駁回 / #DD0000', () {
      const w = StatusWidget(status: 2);
      expect(w.statusText, '審核駁回');
      expect(w.statusColor, const Color(0xFFDD0000));
    });

    test('status=null → 空文本（不渲染）', () {
      const w = StatusWidget(status: null);
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

    testWidgets('status=1 渲染「審核通過」绿色文本', (tester) async {
      await pump(tester, const StatusWidget(status: 1));
      final text = tester.widget<Text>(find.text('審核通過'));
      expect(text.style?.color, const Color(0xFF00BEAA));
    });

    testWidgets('status=null 不渲染任何 Text', (tester) async {
      await pump(tester, const StatusWidget(status: null));
      expect(find.byType(Text), findsNothing);
    });
  });
}
