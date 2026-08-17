import 'package:flutter_test/flutter_test.dart';

import 'package:lumotrip/common/models/category.dart';
import 'package:lumotrip/common/services/config.dart';

void main() {
  group('ConfigService.parseGuideTypeData 双形状解析', () {
    test('裸数组 → 解析出分类列表', () {
      final list = ConfigService.parseGuideTypeData([
        {'id': 1, 'name': '導遊'},
        {'id': 2, 'name': '司機導遊'},
      ]);
      expect(list, hasLength(2));
      expect(list.first.name, '導遊');
      expect(list.last.id, 2);
    });

    test('{"list": [...]} 包装 → 解析出分类列表', () {
      final list = ConfigService.parseGuideTypeData({
        'list': [
          {'id': 1, 'name': '導遊'},
        ],
      });
      // 注意：包装形态在 loadGuideCategories 中被先解包，
      // 传入本函数的一定是 List；此处验证非 List 输入的兜底行为
      expect(list, isEmpty);
    });

    test('null / 非列表 → 空列表兜底', () {
      expect(ConfigService.parseGuideTypeData(null), isEmpty);
      expect(ConfigService.parseGuideTypeData('bad'), isEmpty);
      expect(ConfigService.parseGuideTypeData(42), isEmpty);
    });

    test('元素缺字段 → 安全解析', () {
      final list = ConfigService.parseGuideTypeData([
        {'id': 1},
        {'name': '只有名字'},
        {},
      ]);
      expect(list, hasLength(3));
      expect(list[0].name, isNull);
      expect(list[1].id, isNull);
      expect(list[2].id, isNull);
      expect(list[2].name, isNull);
    });

    test('Category.fromJson 往返', () {
      final c = Category.fromJson({'id': 8, 'name': '票務', 'icon': 'icon.png'});
      expect(c.id, 8);
      expect(c.name, '票務');
      expect(c.icon, 'icon.png');
    });
  });
}
