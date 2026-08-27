import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/message_system/detail.dart';

import 'helpers/test_env.dart';

/// 回归测试：系統消息詳情頁城市名稱點擊跳轉城市詳情。
///
/// 背景：後端 city 類型消息把城市 ID 存在 city_id 欄位（content_id 恆為 0），
/// 舊代碼在 _buildChip 里對 city 類型取 model.contentId（=0）→ onTap 為 null，
/// 點擊城市名稱無反應。修復後應優先取 model.cityId。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await registerTestEnv();
  });

  tearDown(() {
    Get.reset();
  });

  Widget host(String? Function(String) onPush, MessageSystemModel model) {
    return GetMaterialApp(
      navigatorObservers: [
        _NavRecorder((route) => onPush(route)),
      ],
      getPages: [
        GetPage(
          name: AppRoutes.CITY_DETAIL,
          page: () => const Scaffold(body: Text('city-detail-stub')),
        ),
      ],
      home: ScreenUtilInit(
        designSize: const Size(375, 834),
        minTextAdapt: true,
        builder: (context, child) => MessageSystemDetailPage(model: model),
      ),
    );
  }

  group('MessageSystemDetailPage 城市名稱跳轉', () {
    testWidgets('city 類型消息（city_id=177, content_id=0）：點擊城市 chip 跳轉 CITY_DETAIL(id=177)', (tester) async {
      final model = MessageSystemModel.fromJson({
        'title': '發布城市',
        'content': '恭喜您,發布的城市（哈爾濱 Harbin）已通過審核,快去看看吧',
        'desc': '恭喜您,發布的城市（哈爾濱 Harbin）已通過審核,快去看看吧',
        'content_type': 'city',
        'city_id': 177,
        'content_id': 0,
        'city_content_type': 0,
        'is_read': 1,
        'time': '2026-08-25 21:45:17',
      });

      String? navigatedRoute;
      await tester.pumpWidget(host((r) => navigatedRoute = r, model));
      navigatedRoute = null; // 忽略初始路由 '/'

      // 城市名 chip 應渲染為可點擊按鈕（顯示城市名）
      expect(find.text('哈爾濱 Harbin'), findsOneWidget);

      await tester.tap(find.text('哈爾濱 Harbin'));
      await tester.pumpAndSettle();

      expect(navigatedRoute, AppRoutes.CITY_DETAIL);
      expect(Get.arguments, {'id': 177});
    });

    testWidgets('city_content 類型消息：第一個括號為城市名，點擊跳轉 CITY_DETAIL(id=23)', (tester) async {
      final model = MessageSystemModel.fromJson({
        'title': '城市內容發布',
        'content': '恭喜您,發布的城市內容（薩爾茨堡 Salzburg）的（Parking）的（最方便也相對便宜的停車場）已通過審核,快去看看吧',
        'desc': '恭喜您,發布的城市內容（薩爾茨堡 Salzburg）的（Parking）的（最方便也相對便宜的停車場）已通過審核,快去看看吧',
        'content_type': 'city_content',
        'city_id': 23,
        'content_id': 174,
        'city_content_type': 5,
        'is_read': 1,
        'time': '2026-08-25 21:45:35',
      });

      String? navigatedRoute;
      await tester.pumpWidget(host((r) => navigatedRoute = r, model));
      navigatedRoute = null; // 忽略初始路由 '/'

      expect(find.text('薩爾茨堡 Salzburg'), findsOneWidget);

      await tester.tap(find.text('薩爾茨堡 Salzburg'));
      await tester.pumpAndSettle();

      expect(navigatedRoute, AppRoutes.CITY_DETAIL);
      expect(Get.arguments, {'id': 23});
    });

    testWidgets('city 類型消息 city_id=0：城市名不可點擊（不跳轉、不報錯）', (tester) async {
      final model = MessageSystemModel.fromJson({
        'title': '發布城市',
        'content': '很抱歉,您提交的城市（hhh dbj）沒有通過,原因是:,請重新填寫資料',
        'desc': '很抱歉,您提交的城市（hhh dbj）沒有通過,原因是:,請重新填寫資料',
        'content_type': 'city',
        'city_id': 0,
        'content_id': 0,
        'city_content_type': 0,
        'is_read': 1,
        'time': '2026-08-23 21:12:28',
      });

      String? navigatedRoute;
      await tester.pumpWidget(host((r) => navigatedRoute = r, model));
      navigatedRoute = null; // 忽略初始路由 '/'

      await tester.tap(find.text('hhh dbj'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(navigatedRoute, isNull);
    });
  });
}

/// 记录路由跳转的 NavigatorObserver（不依赖真实页面注册）
class _NavRecorder extends NavigatorObserver {
  _NavRecorder(this._onPush);
  final void Function(String route) _onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onPush(route.settings.name ?? '');
    super.didPush(route, previousRoute);
  }
}
