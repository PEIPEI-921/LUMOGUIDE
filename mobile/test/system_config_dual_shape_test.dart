import 'package:flutter_test/flutter_test.dart';

import 'package:lumotrip/common/models/system_config.dart';

void main() {
  group('SystemConfig.languages 双形状解析', () {
    test('后端返回 JSON 数组 → 直接解析为列表', () {
      final c = SystemConfig.fromJson({
        'languages': ['中文', 'English', '法語(Français)'],
        'business_type': ['景點'],
      });
      expect(c.languages, ['中文', 'English', '法語(Français)']);
    });

    test('后端返回逗号字符串（旧格式）→ 拆分并去除空白', () {
      final c = SystemConfig.fromJson({
        'languages': '中文,English, 法語(Français) ,日本語',
      });
      expect(c.languages, ['中文', 'English', '法語(Français)', '日本語']);
    });

    test('空字符串 → 空列表', () {
      final c = SystemConfig.fromJson({'languages': ''});
      expect(c.languages, isEmpty);
    });

    test('字段缺失/null → 空列表', () {
      expect(SystemConfig.fromJson({}).languages, isEmpty);
      expect(SystemConfig.fromJson({'languages': null}).languages, isEmpty);
    });

    test('列表内含非字符串元素 → 转字符串', () {
      final c = SystemConfig.fromJson({
        'languages': ['中文', 123],
      });
      expect(c.languages, ['中文', '123']);
    });
  });
}
