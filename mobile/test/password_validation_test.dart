import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/extensions/string.dart';

/// 密码复杂度校验（`String.isValidPassword`）单元测试。
///
/// 规则：至少 6 位，且同时包含数字和字母。
/// 由 modify_password / password_input 两个 controller 共用（原为各自 private 实现，
/// 已抽取到 `StringRegExp` 扩展）。
void main() {
  group('isValidPassword 通过', () {
    test('6 位数字 + 字母', () {
      expect('abc123'.isValidPassword, isTrue);
    });

    test('大写字母 + 数字', () {
      expect('ABC123'.isValidPassword, isTrue);
    });

    test('超长密码数字 + 字母', () {
      expect('a1b2c3d4e5f6'.isValidPassword, isTrue);
    });

    test('数字 + 字母 + 特殊字符', () {
      expect('abc123!@#'.isValidPassword, isTrue);
    });
  });

  group('isValidPassword 拦截', () {
    test('空字符串', () {
      expect(''.isValidPassword, isFalse);
    });

    test('长度不足 6（5 位）', () {
      expect('abc12'.isValidPassword, isFalse);
    });

    test('恰好 6 位纯数字', () {
      expect('123456'.isValidPassword, isFalse);
    });

    test('恰好 6 位纯字母', () {
      expect('abcdef'.isValidPassword, isFalse);
    });

    test('纯特殊字符', () {
      expect('!@#\$%^'.isValidPassword, isFalse);
    });

    test('6 位字母 + 特殊字符（无数字）', () {
      expect('abcde!'.isValidPassword, isFalse);
    });
  });
}
