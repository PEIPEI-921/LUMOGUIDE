import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/guide_certification/controller.dart';
import 'package:lumotrip/pages/guide_certification/page.dart';
import 'package:lumotrip/pages/merchant_entry/controller.dart';
import 'package:lumotrip/pages/merchant_entry/page.dart';

import 'helpers/test_env.dart';

Map<String, dynamic> buildDraft() {
  return {
    'form': {
      'name': '張三',
      'name_en': 'Zhang San',
      'phone': '+8613800000000',
      'email': 'zhang@example.com',
      'bill_address': 'Vienna 1010',
      'wechat': '',
      'whats_app': '',
      'line': '',
      'other_contact': '',
      'invite_code': '',
      'photo': 'https://cdn.test/photo.jpg',
      'year': '2020',
      'identity_type': '導遊',
      'introduction': '十年帶團經驗',
      'business_contact': '張三',
      'have_vehicle': 0,
      'vehicle_rent': 0,
      'vehicle_info': '',
      'other_type': '',
      'certificate_picture': '',
      'passport_picture': '',
      'driver_license_front': '',
      'driver_license_back': '',
      'resident_city_id': 1,
      'resident_city_name': '巴黎',
      'is_new_city': 0,
      'new_city_name': '',
      'new_city_name_en': '',
      'new_city_continents_id': null,
      'new_city_continents_name': null,
      'new_city_area_id': null,
      'new_city_area_name': null,
      'new_city_country_id': null,
      'new_city_country_name': null,
    },
    'selectedLangs': ['中文'],
    'selectedTypes': ['導遊'],
    'photoPreview': 'https://cdn.test/photo.jpg',
    'carPics': ['https://cdn.test/car1.jpg'],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.reset());
  tearDown(() => Get.reset());

  testWidgets('复现：真实页面 + 草稿恢复后出现 GuideCertificationController not found',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
      prevOnError?.call(details);
    };

    await registerTestEnv(
      prefs: {'guide_certify_draft': jsonEncode(buildDraft())},
    );
    await tester.pumpWidget(
      GetMaterialApp(
        builder: EasyLoading.init(),
        home: ScreenUtilInit(
          designSize: const Size(375, 834),
          minTextAdapt: true,
          builder: (context, child) => const Scaffold(),
        ),
      ),
    );

    // 模拟真实导航进入认证页
    Get.to(() => const GuideCertificationPage());
    await tester.pumpAndSettle();
    debugPrint('EXC after nav: ${tester.takeException()}');
    debugPrint('registered: ${Get.isRegistered<GuideCertificationController>()}');
    debugPrint('dialog found: ${find.text('偵測到未完成的認證資料，是否繼續編輯？').evaluate().length}');

    expect(find.text('偵測到未完成的認證資料，是否繼續編輯？'), findsOneWidget,
        reason: '草稿弹窗应出现');

    await tester.tap(find.text('繼續編輯'));
    await tester.pumpAndSettle();
    debugPrint('EXC after restore: ${tester.takeException()}');
    debugPrint('registered after restore: ${Get.isRegistered<GuideCertificationController>()}');

    final controller = Get.find<GuideCertificationController>();
    expect(controller.nameController.text, '張三');

    // 检查是否有 GetX “not found” 异常
    final notFound = errors.where((e) =>
        e.exception.toString().contains('GuideCertificationController') &&
        e.exception.toString().contains('not found'));
    expect(notFound, isEmpty,
        reason: '草稿恢复后不应出现控制器未注册异常：${errors.map((e) => e.exception).toList()}');
  });

  testWidgets('复现：企业入驻页草稿恢复后 MerchantEntryController 不应丢失', (tester) async {
    await registerTestEnv(
      prefs: {
        'merchant_entry_draft': jsonEncode({
          'form': {
            'name': '路盟旅遊公司',
            'name_en': 'Lumo Travel GmbH',
            'contact_name': '',
            'phone': '+436600000000',
            'email': 'lumo@example.com',
            'country': '',
            'address': 'Salzburg 5020',
            'introduction': '奧地利地接社',
            'city_id': '23',
            'tax_id': 'ATU12345678',
            'website': 'www.lumo.at',
            'wechat': '',
            'whats_app': '',
            'line': '',
            'other_contact': '',
            'contact_phone': '',
            'contact_email': '',
            'photo': 'https://cdn.test/doc.jpg',
            'license': '',
            'id_card_front': '',
            'id_card_back': '',
          },
          'selectedTypes': ['購物'],
          'typeId': 3,
          'typeClassId': 5,
          'typeClassName': '免稅店',
          'storePics': ['https://cdn.test/shop1.jpg'],
        }),
      },
    );
    await tester.pumpWidget(
      GetMaterialApp(
        builder: EasyLoading.init(),
        home: ScreenUtilInit(
          designSize: const Size(375, 834),
          minTextAdapt: true,
          builder: (context, child) => const Scaffold(),
        ),
      ),
    );

    Get.to(() => const MerchantEntryPage());
    await tester.pumpAndSettle();
    expect(find.text('偵測到未完成的入駐資料，是否繼續編輯？'), findsOneWidget,
        reason: '草稿弹窗应出现');

    await tester.tap(find.text('繼續編輯'));
    await tester.pumpAndSettle();

    expect(Get.isRegistered<MerchantEntryController>(), isTrue,
        reason: '恢复后控制器应仍被注册');
    final controller = Get.find<MerchantEntryController>();
    expect(controller.nameController.text, '路盟旅遊公司');
  });
}
