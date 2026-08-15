import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/models/journey_work.dart';

String _fmt(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _date(int offsetDays) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return _fmt(today.add(Duration(days: offsetDays)));
}

void main() {
  group('JourneyWorkStatus.fromValue', () {
    test('null 回退到 pending', () {
      expect(JourneyWorkStatus.fromValue(null), JourneyWorkStatus.pending);
    });
    test('1/2/3 映射', () {
      expect(JourneyWorkStatus.fromValue(1), JourneyWorkStatus.inProgress);
      expect(JourneyWorkStatus.fromValue(2), JourneyWorkStatus.pending);
      expect(JourneyWorkStatus.fromValue(3), JourneyWorkStatus.ended);
    });
    test('未知值回退到 pending', () {
      expect(JourneyWorkStatus.fromValue(99), JourneyWorkStatus.pending);
    });
  });

  group('JourneyWork.effectiveStatus', () {
    test('进行中（今天在区间内）', () {
      final w = JourneyWork(startDate: _date(-2), endDate: _date(2));
      expect(w.effectiveStatus, JourneyWorkStatus.inProgress);
    });
    test('待出发（今天在开始前）', () {
      final w = JourneyWork(startDate: _date(1), endDate: _date(3));
      expect(w.effectiveStatus, JourneyWorkStatus.pending);
    });
    test('已结束（今天在结束后）', () {
      final w = JourneyWork(startDate: _date(-3), endDate: _date(-1));
      expect(w.effectiveStatus, JourneyWorkStatus.ended);
    });
    test('单日（开始=结束=今天）', () {
      final w = JourneyWork(startDate: _date(0), endDate: _date(0));
      expect(w.effectiveStatus, JourneyWorkStatus.inProgress);
    });
    test('非法日期回退 statusEnum', () {
      final w = JourneyWork(startDate: 'bad', endDate: 'bad', status: 3);
      expect(w.effectiveStatus, JourneyWorkStatus.ended);
    });
  });

  group('JourneyWork.totalDays', () {
    test('跨 3 天', () {
      expect(JourneyWork(startDate: _date(0), endDate: _date(2)).totalDays, 3);
    });
    test('单日', () {
      expect(JourneyWork(startDate: _date(0), endDate: _date(0)).totalDays, 1);
    });
    test('非法/缺失日期返回 0', () {
      expect(JourneyWork(startDate: 'x', endDate: 'y').totalDays, 0);
      expect(JourneyWork(startDate: null, endDate: null).totalDays, 0);
    });
  });

  group('JourneyWork.fromJson 资源列表容错', () {
    test('字符串数字列表转 int', () {
      final w = JourneyWork.fromJson({
        'attraction_ids': ['1', '2', '3'],
        'activity_ids': [4, 5],
        'merchant_ids': ['6'],
      });
      expect(w.attractionIds, [1, 2, 3]);
      expect(w.activityIds, [4, 5]);
      expect(w.merchantIds, [6]);
    });
    test('非法元素被过滤', () {
      final w = JourneyWork.fromJson({
        'attraction_ids': ['1', 'abc', 2],
      });
      expect(w.attractionIds, [1, 2]);
    });
    test('null/缺失为 null', () {
      expect(JourneyWork.fromJson({}).attractionIds, isNull);
    });
  });

  group('ItineraryDay.fromJson', () {
    test('新版 city_blocks', () {
      final d = ItineraryDay.fromJson({
        'day_number': 1,
        'city_blocks': [
          {
            'city_id': 1,
            'city_name': '维也纳',
            'items': [
              {'title': '美泉宫'},
            ],
          },
        ],
      });
      expect(d.dayNumber, 1);
      expect(d.cityBlocks.length, 1);
      expect(d.cityBlocks.first.cityName, '维也纳');
      expect(d.cityBlocks.first.items.first.title, '美泉宫');
    });
    test('旧版 city_ids/city_names/items 迁移', () {
      final d = ItineraryDay.fromJson({
        'day_number': 2,
        'city_ids': [10, 20],
        'city_names': ['维也纳', '萨尔茨堡'],
        'items': [
          {'time': '09:00', 'title': '美泉宫'},
          {'time': '12:00', 'title': '午餐'},
        ],
      });
      expect(d.cityBlocks.length, 2);
      expect(d.cityBlocks[0].cityId, 10);
      expect(d.cityBlocks[0].cityName, '维也纳');
      expect(d.cityBlocks[0].items.length, 2); // items 归入第一个城市
      expect(d.cityBlocks[1].cityId, 20);
      expect(d.cityBlocks[1].cityName, '萨尔茨堡');
      expect(d.cityBlocks[1].items, isEmpty);
    });
    test('旧版仅 items（无城市）', () {
      final d = ItineraryDay.fromJson({
        'items': [
          {'title': '自由活动'},
        ],
      });
      expect(d.cityBlocks.length, 1);
      expect(d.cityBlocks.first.items.first.title, '自由活动');
    });
  });

  group('JourneyWork 序列化往返', () {
    test('toJson → fromJson 保留关键字段', () {
      final w = JourneyWork(
        id: 7,
        title: '奥地利7日游',
        status: 1,
        adultCount: 8,
        childCount: 2,
        startDate: '2026-08-01',
        endDate: '2026-08-07',
        cities: ['维也纳'],
        attractionIds: [1, 2, 3],
        itineraryDays: [
          ItineraryDay(
            dayNumber: 1,
            cityBlocks: [
              DayCityBlock(
                cityId: 10,
                cityName: '维也纳',
                items: [ItineraryItem(title: '美泉宫')],
              ),
            ],
          ),
        ],
      );
      final r = JourneyWork.fromJson(w.toJson());
      expect(r.id, 7);
      expect(r.title, '奥地利7日游');
      expect(r.adultCount, 8);
      expect(r.attractionIds, [1, 2, 3]);
      expect(r.itineraryDays.first.cityBlocks.first.cityName, '维也纳');
    });
  });
}
