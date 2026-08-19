import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/utils/app_qr_code.dart';

void main() {
  group('AppQRCode.parse', () {
    test('解析標準 group 碼', () {
      final p = AppQRCode.parse('LUMOTRIP:GROUP:abc123');
      expect(p, isNotNull);
      expect(p!.type, AppQRCodeType.group);
      expect(p.payload, 'abc123');
    });

    test('解析標準 user 碼', () {
      final p = AppQRCode.parse('LUMOTRIP:USER:user_01');
      expect(p, isNotNull);
      expect(p!.type, AppQRCodeType.user);
      expect(p.payload, 'user_01');
    });

    test('無前綴裸文字 → null（不再當成 group 碼）', () {
      expect(AppQRCode.parse('随便一段文字'), isNull);
      expect(AppQRCode.parse('https://example.com'), isNull);
    });

    test('未知類型 → null', () {
      expect(AppQRCode.parse('LUMOTRIP:BOGUS:xyz'), isNull);
    });

    test('空 payload → null', () {
      expect(AppQRCode.parse('LUMOTRIP:GROUP:'), isNull);
      expect(AppQRCode.parse('   '), isNull);
      expect(AppQRCode.parse(''), isNull);
    });

    test('帶前後空白可解析', () {
      final p = AppQRCode.parse('  LUMOTRIP:GROUP:g1  ');
      expect(p, isNotNull);
      expect(p!.payload, 'g1');
    });
  });
}
