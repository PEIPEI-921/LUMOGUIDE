import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/extensions/map.dart';

/// 强制字面量为 Map<String, dynamic>，使 SafeJsonExt 扩展可应用。
Map<String, dynamic> _json(Map<String, dynamic> m) => m;

int _idOf(Map<String, dynamic> m) => m['id'] as int;

void main() {
  group('SafeJsonExt.safeString', () {
    test('正常字符串', () {
      expect(_json({'a': 'hello'}).safeString('a'), 'hello');
    });
    test('null 返回 null', () {
      expect(_json({'a': null}).safeString('a'), isNull);
    });
    test('非字符串转 toString', () {
      expect(_json({'a': 123}).safeString('a'), '123');
    });
    test('缺失键返回默认值', () {
      expect(_json({}).safeString('a'), isNull);
      expect(_json({}).safeString('a', defaultValue: 'd'), 'd');
    });
  });

  group('SafeJsonExt.safeInt', () {
    test('正常 int', () => expect(_json({'a': 42}).safeInt('a'), 42));
    test('double 转 int', () => expect(_json({'a': 3.9}).safeInt('a'), 3));
    test('数字字符串', () => expect(_json({'a': '42'}).safeInt('a'), 42));
    test('非法字符串返回 null', () => expect(_json({'a': 'abc'}).safeInt('a'), isNull));
    test('null/缺失', () {
      expect(_json({'a': null}).safeInt('a'), isNull);
      expect(_json({}).safeInt('a'), isNull);
    });
  });

  group('SafeJsonExt.safeDouble', () {
    test('double', () => expect(_json({'a': 3.14}).safeDouble('a'), 3.14));
    test('int 转 double', () => expect(_json({'a': 3}).safeDouble('a'), 3.0));
    test('字符串', () => expect(_json({'a': '3.14'}).safeDouble('a'), 3.14));
    test('非法返回 null', () => expect(_json({'a': 'x'}).safeDouble('a'), isNull));
  });

  group('SafeJsonExt.safeBool', () {
    test('bool', () => expect(_json({'a': true}).safeBool('a'), isTrue));
    test('int 1/0', () {
      expect(_json({'a': 1}).safeBool('a'), isTrue);
      expect(_json({'a': 0}).safeBool('a'), isFalse);
    });
    test('字符串 true/false/1/0', () {
      expect(_json({'a': 'true'}).safeBool('a'), isTrue);
      expect(_json({'a': 'false'}).safeBool('a'), isFalse);
      expect(_json({'a': '1'}).safeBool('a'), isTrue);
      expect(_json({'a': '0'}).safeBool('a'), isFalse);
    });
    test('非法返回 null', () => expect(_json({'a': 'yes'}).safeBool('a'), isNull));
  });

  group('SafeJsonExt.safeList', () {
    test('正常 List', () => expect(_json({'a': [1, 2]}).safeList<int>('a'), [1, 2]));
    test('null/非 List 返回 null', () {
      expect(_json({'a': null}).safeList('a'), isNull);
      expect(_json({'a': 'x'}).safeList('a'), isNull);
    });
  });

  group('SafeJsonExt.safeMap', () {
    test('正常 Map', () => expect(_json({'a': {'b': 1}}).safeMap('a'), {'b': 1}));
    test('非 Map 返回 null', () => expect(_json({'a': [1]}).safeMap('a'), isNull));
  });

  group('SafeJsonExt.safeObject', () {
    test('嵌套对象', () {
      expect(_json({'a': _json({'id': 7})}).safeObject<int>('a', _idOf), 7);
    });
    test('null/非 Map 返回 null', () {
      expect(_json({'a': null}).safeObject<int>('a', _idOf), isNull);
      expect(_json({'a': 'x'}).safeObject<int>('a', _idOf), isNull);
    });
  });

  group('SafeJsonExt.safeObjectList', () {
    test('对象列表', () {
      final r = _json({
        'a': [
          _json({'id': 1}),
          _json({'id': 2}),
        ]
      }).safeObjectList<int>('a', _idOf);
      expect(r, [1, 2]);
    });
    test('null/非 List 返回 null', () {
      expect(_json({'a': null}).safeObjectList<int>('a', _idOf), isNull);
      expect(_json({'a': 'x'}).safeObjectList<int>('a', _idOf), isNull);
    });
  });
}
