import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/extensions/string.dart';

void main() {
  group('StringExt 编码', () {
    test('base64 编解码往返', () {
      const s = 'hello world 你好';
      expect(s.base64Encoded.base64Decoded, s);
    });
    test('url 编解码往返', () {
      const s = 'a b+c';
      expect(s.urlEncoded.urlDecoded, s);
    });
  });

  group('StringExt 脱敏', () {
    test('手机号', () {
      expect('13812345678'.phoneFormatted, '138****5678');
      expect('138****5678'.phoneFormatted, '138****5678'); // 已脱敏
      expect('12345'.phoneFormatted, '12345'); // 长度不对
    });
    test('身份证 18 位', () {
      final masked = '11010519491231002X'.idCardFormatted;
      expect(masked.length, 18);
      expect(masked.startsWith('11'), isTrue);
      expect(masked.endsWith('2X'), isTrue);
    });
    test('身份证 15 位', () {
      final masked = '110105194912310'.idCardFormatted;
      expect(masked.length, 15);
      expect(masked.startsWith('11'), isTrue);
      expect(masked.endsWith('10'), isTrue);
    });
    test('银行卡', () {
      expect('6222021234567890123'.bankcardFormatted, '**** **** **** 0123');
      expect('123'.bankcardFormatted, '**** **** **** 123');
    });
  });

  group('StringRegExp 校验', () {
    test('isMobile', () {
      expect('13812345678'.isMobile, isTrue);
      expect('12345678901'.isMobile, isFalse);
    });
    test('isIdCard', () {
      expect('11010519491231002X'.isIdCard, isTrue); // 18 位
      expect('110105194912310'.isIdCard, isTrue); // 15 位
      expect('abc'.isIdCard, isFalse);
    });
    test('isChinese', () {
      expect('测试'.isChinese, isTrue);
      expect('abc'.isChinese, isFalse);
    });
    test('isLetter', () {
      expect('abcXYZ'.isLetter, isTrue);
      expect('abc123'.isLetter, isFalse);
      expect('a-b'.isLetter, isFalse); // 修复 A-z 后连字符不匹配
    });
    test('isMoney', () {
      expect('123'.isMoney, isTrue);
      expect('123.45'.isMoney, isTrue);
      expect('123.456'.isMoney, isFalse);
      expect('abc'.isMoney, isFalse);
    });
    test('isNumber', () {
      expect('123'.isNumber, isTrue);
      expect('12a'.isNumber, isFalse);
    });
  });
}
