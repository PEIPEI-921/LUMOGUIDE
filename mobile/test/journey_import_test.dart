import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/models/journey_template.dart';
import 'package:lumotrip/common/models/journey_work.dart';
import 'package:lumotrip/common/utils/journey_import.dart';

void main() {
  group('JourneyImportParser', () {
    test('空内容返回失败', () {
      final r = JourneyImportParser.parse('   ');
      expect(r.success, isFalse);
      expect(r.work, isNull);
    });

    test('解析 JSON（JourneyWork 格式）', () {
      final w = JourneyWork(
        title: '奥地利7日游',
        startDate: '2026-08-01',
        endDate: '2026-08-07',
        adultCount: 8,
        childCount: 2,
        cities: ['维也纳'],
      );
      final r = JourneyImportParser.parse(jsonEncode(w.toJson()));
      expect(r.success, isTrue);
      expect(r.work!.title, '奥地利7日游');
      expect(r.work!.startDate, '2026-08-01');
      expect(r.work!.adultCount, 8);
      expect(r.work!.childCount, 2);
    });

    test('解析模板 JSON', () {
      final tpl = JourneyTemplate(
        title: '欧洲经典线',
        cities: ['维也纳', '萨尔茨堡'],
        defaultDays: 5,
        defaultPeopleCount: 10,
        itineraryDays: [
          {
            'day_number': 1,
            'city_blocks': [
              {
                'city_name': '维也纳',
                'items': [
                  {'time': '09:00', 'title': '美泉宫', 'type': 'other'},
                ],
              }
            ],
          }
        ],
      );
      final r = JourneyImportParser.parse(jsonEncode(tpl.toJson()));
      expect(r.success, isTrue);
      expect(r.work!.title, '欧洲经典线');
      expect(r.work!.isTemplate, isFalse);
      expect(r.work!.itineraryDays, isNotEmpty);
      expect(r.work!.itineraryDays.first.cityBlocks.first.cityName, '维也纳');
    });

    test('解析 HTML（剥离标签）', () {
      const html =
          '<html><body><p>团名: 奥地利7日游</p><p>出发日期: 2026-08-01</p><p>结束日期: 2026-08-07</p></body></html>';
      final r = JourneyImportParser.parse(html);
      expect(r.success, isTrue);
      expect(r.work!.title, '奥地利7日游');
      expect(r.work!.startDate, '2026-08-01');
    });

    test('解析结构化文本（字段 + 日期段 + 城市 + 项目）', () {
      const text = '''
团名: 奥地利7日游
出发日期: 2026-08-01
结束日期: 2026-08-07
成人: 8
儿童: 2
领队: 张三

第1天 (8/1)
城市: 维也纳
09:00 美泉宫
12:00 午餐

第2天 (8/2)
城市: 萨尔茨堡
09:00 米拉贝尔花园
''';
      final r = JourneyImportParser.parse(text);
      expect(r.success, isTrue);
      expect(r.work!.title, '奥地利7日游');
      expect(r.work!.startDate, '2026-08-01');
      expect(r.work!.endDate, '2026-08-07');
      expect(r.work!.adultCount, 8);
      expect(r.work!.childCount, 2);
      expect(r.work!.leaderName, '张三');
      expect(r.work!.itineraryDays.length, 2);
      expect(r.work!.itineraryDays[0].cityBlocks.first.cityName, '维也纳');
      final items = r.work!.itineraryDays[0].cityBlocks.first.items;
      expect(items.length, 2);
      expect(items[0].time, '09:00');
      expect(items[0].title, '美泉宫');
      expect(r.work!.cities, contains('维也纳'));
      expect(r.work!.cities, contains('萨尔茨堡'));
    });

    test('解析中文全角冒号', () {
      const text = '团名：法意瑞12日游\n出发日期：2026-09-01';
      final r = JourneyImportParser.parse(text);
      expect(r.success, isTrue);
      expect(r.work!.title, '法意瑞12日游');
      expect(r.work!.startDate, '2026-09-01');
    });

    test('解析多种日期格式', () {
      const text = '团名: 测试\n出发日期: 2026年8月1日\n结束日期: 2026/8/7';
      final r = JourneyImportParser.parse(text);
      expect(r.work!.startDate, '2026-08-01');
      expect(r.work!.endDate, '2026-08-07');
    });

    test('总人数字段解析', () {
      const text = '团名: 测试\n人数: 20';
      final r = JourneyImportParser.parse(text);
      expect(r.work!.peopleCount, 20);
    });

    test('时间行不被误判为键值字段', () {
      const text = '团名: 测试\n09:00 美泉宫\n12:00 午餐';
      final r = JourneyImportParser.parse(text);
      expect(r.success, isTrue);
      expect(r.work!.title, '测试');
      // 时间行应被识别为行程项（归入第 1 天）
      expect(r.work!.itineraryDays, isNotEmpty);
      expect(r.work!.itineraryDays.first.cityBlocks.first.items.length, 2);
      expect(r.work!.itineraryDays.first.cityBlocks.first.items[0].time, '09:00');
    });

    test('无法识别时回退到备注并给出警告', () {
      const text = '这是一段无法解析的自由文本';
      final r = JourneyImportParser.parse(text);
      expect(r.success, isTrue);
      expect(r.work!.description, '这是一段无法解析的自由文本');
      expect(r.warnings, isNotEmpty);
    });

    test('无结构内容为空字符串返回失败', () {
      final r = JourneyImportParser.parse('   \n  \n');
      expect(r.success, isFalse);
    });
  });
}
