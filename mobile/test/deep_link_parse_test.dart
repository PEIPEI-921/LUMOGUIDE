import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/services/deep_link.dart';

/// 深链 URI 解析（`DeepLinkService.parseDeepLinkUri`）单元测试。
///
/// 覆盖两种格式（自定义 scheme + Universal/App Link）、invite 无 id、
/// 以及历史 bug 场景（非数字 id、缺 id、非法 host/path）。
void main() {
  group('parseDeepLinkUri 有效输入', () {
    test('自定义 scheme guide', () {
      final r = DeepLinkService.parseDeepLinkUri(
        Uri.parse('lumoguide://share?c=ABC&t=guide&i=123'),
      );
      expect(r, isNotNull);
      expect(r!.code, 'ABC');
      expect(r.type, 'guide');
      expect(r.id, 123);
    });

    test('自定义 scheme 无邀请码', () {
      final r = DeepLinkService.parseDeepLinkUri(
        Uri.parse('lumoguide://share?t=city&i=45'),
      );
      expect(r, isNotNull);
      expect(r!.code, '');
      expect(r.type, 'city');
      expect(r.id, 45);
    });

    test('Universal Link https', () {
      final r = DeepLinkService.parseDeepLinkUri(
        Uri.parse('https://lumoguide.com/share?c=XYZ&t=trip&i=7'),
      );
      expect(r, isNotNull);
      expect(r!.code, 'XYZ');
      expect(r.type, 'trip');
      expect(r.id, 7);
    });

    test('Universal Link /share.html 路径', () {
      final r = DeepLinkService.parseDeepLinkUri(
        Uri.parse('https://lumoguide.com/share.html?c=XYZ&t=content&i=9'),
      );
      expect(r, isNotNull);
      expect(r!.code, 'XYZ');
      expect(r.type, 'content');
      expect(r.id, 9);
    });

    test('invite 类型无需 id（id 恒为 0）', () {
      final r = DeepLinkService.parseDeepLinkUri(
        Uri.parse('lumoguide://share?c=INV&t=invite'),
      );
      expect(r, isNotNull);
      expect(r!.code, 'INV');
      expect(r.type, 'invite');
      expect(r.id, 0);
    });

    test('invite 类型带多余 id 也被忽略', () {
      final r = DeepLinkService.parseDeepLinkUri(
        Uri.parse('https://lumoguide.com/share?c=INV&t=invite&i=99'),
      );
      expect(r, isNotNull);
      expect(r!.type, 'invite');
      expect(r.id, 0);
    });
  });

  group('parseDeepLinkUri 无效输入（返回 null）', () {
    test('非法 host', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('lumoguide://other?t=guide&i=1'),
        ),
        isNull,
      );
    });

    test('非法域名', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('https://evil.com/share?t=guide&i=1'),
        ),
        isNull,
      );
    });

    test('非法 path', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('https://lumoguide.com/other?t=guide&i=1'),
        ),
        isNull,
      );
    });

    test('缺 type', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('lumoguide://share?c=A&i=5'),
        ),
        isNull,
      );
    });

    test('非 invite 缺 id', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('lumoguide://share?c=A&t=guide'),
        ),
        isNull,
      );
    });

    test('id 为 0', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('lumoguide://share?c=A&t=guide&i=0'),
        ),
        isNull,
      );
    });

    test('id 为负数', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('lumoguide://share?c=A&t=guide&i=-3'),
        ),
        isNull,
      );
    });

    test('id 非数字（历史 FormatException 场景）', () {
      expect(
        DeepLinkService.parseDeepLinkUri(
          Uri.parse('lumoguide://share?c=A&t=guide&i=abc'),
        ),
        isNull,
      );
    });
  });
}
