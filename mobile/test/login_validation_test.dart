import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/pages/login/controller.dart';

/// 登录表单校验（`LoginController.validateForm`）单元测试。
///
/// 覆盖邮箱/密码/协议勾选的各项校验及优先级顺序。
void main() {
  group('validateForm 通过', () {
    test('合法邮箱 + 密码 + 已同意 → null', () {
      expect(
        LoginController.validateForm('user@example.com', 'secret', true),
        isNull,
      );
    });
  });

  group('validateForm 拦截', () {
    test('空邮箱 → 提示输入邮箱', () {
      expect(
        LoginController.validateForm('', 'secret', true),
        '請輸入郵箱',
      );
    });

    test('非法邮箱 → 提示邮箱格式错误', () {
      expect(
        LoginController.validateForm('not-an-email', 'secret', true),
        '請輸入正確的郵箱',
      );
    });

    test('空密码 → 提示输入密码', () {
      expect(
        LoginController.validateForm('user@example.com', '', true),
        '請輸入密碼',
      );
    });

    test('未同意协议 → 提示同意', () {
      expect(
        LoginController.validateForm('user@example.com', 'secret', false),
        '請先閱讀並同意用戶協議和隱私政策',
      );
    });

    test('校验优先级：空邮箱优先于空密码', () {
      expect(
        LoginController.validateForm('', '', false),
        '請輸入郵箱',
      );
    });

    test('校验优先级：非法邮箱优先于未同意协议', () {
      expect(
        LoginController.validateForm('bad', 'secret', false),
        '請輸入正確的郵箱',
      );
    });
  });
}
