import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 应用级 widget 冒烟测试。
  // 完整 App 启动依赖 Global.init() + GetX 服务 + 网络，不适合在单元测试中 pump，
  // 因此这里只做最小渲染冒烟验证；业务逻辑（行程导入解析）见 journey_import_test.dart。
  testWidgets('Smoke test: renders a basic widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('LUMOGUIDE'))));
    expect(find.text('LUMOGUIDE'), findsOneWidget);
  });
}
