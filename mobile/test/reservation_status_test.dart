import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/models/guide_reservation.dart';
import 'package:lumotrip/common/models/merchant_reservation.dart';
import 'package:lumotrip/common/models/user_reservation.dart';

void main() {
  group('isGrey 状态判断（status≥3 为灰色）', () {
    test('UserReservationGuide', () {
      for (var s = 1; s <= 6; s++) {
        expect(UserReservationGuide(status: s).isGrey, s >= 3, reason: 'status=$s');
      }
    });
    test('UserReservationMerchant', () {
      for (var s = 1; s <= 6; s++) {
        expect(UserReservationMerchant(status: s).isGrey, s >= 3, reason: 'status=$s');
      }
    });
    test('GuideReservation', () {
      for (var s = 1; s <= 6; s++) {
        expect(GuideReservation(status: s).isGrey, s >= 3, reason: 'status=$s');
      }
    });
    test('MerchantReservation', () {
      for (var s = 1; s <= 6; s++) {
        expect(MerchantReservation(status: s).isGrey, s >= 3, reason: 'status=$s');
      }
    });
  });
}
