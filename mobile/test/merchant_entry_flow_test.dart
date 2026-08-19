import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/merchant_entry/controller.dart';

import 'helpers/test_env.dart';

Map<String, dynamic> buildMerchantDraft() {
  return {
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
      'wechat': 'wx',
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
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('商家入驻草稿恢复', () {
    testWidgets('选择“继续编辑” → 恢复表单且可编辑、图片回显', (tester) async {
      await registerTestEnv(
        prefs: {'merchant_entry_draft': jsonEncode(buildMerchantDraft())},
      );
      await tester.pumpWidget(buildTestApp());
      final c = MerchantEntryController();
      Get.put(c);
      await tester.pumpAndSettle();

      expect(find.text('偵測到未完成的入駐資料，是否繼續編輯？'), findsOneWidget);
      await tester.tap(find.text('繼續編輯'));
      await tester.pumpAndSettle();

      expect(c.isReadOnly, isFalse);
      expect(c.merchantEntry.auditStatus, isNull);
      expect(c.nameController.text, '路盟旅遊公司');
      expect(c.merchantEntry.cityId, 23);
      expect(c.merchantEntry.documentsPicture, 'https://cdn.test/doc.jpg');
      expect(c.merchantPictures, contains('https://cdn.test/shop1.jpg'));
      expect(c.merchantEntry.businessType, '購物');
      expect(c.merchantEntry.typeClassId, 5);
      expect(c.merchantEntry.typeClassName, '免稅店');
    });

    testWidgets('审核通过用户点“编辑” → 重置只读并弹出草稿提示', (tester) async {
      await registerTestEnv(
        user: UserInfo(identity: 3, companyAuditStatus: 1),
      );
      await tester.pumpWidget(buildTestApp());
      final c = MerchantEntryController();
      Get.put(c);
      await tester.pumpAndSettle();

      c.merchantEntry.auditStatus = 1;
      expect(c.isReadOnly, isTrue);

      final storage = Get.find<StorageService>();
      await storage.setString('merchant_entry_draft', jsonEncode(buildMerchantDraft()));
      c.onEdit();
      await tester.pumpAndSettle();

      expect(c.isReadOnly, isFalse);
      expect(find.text('偵測到未完成的入駐資料，是否繼續編輯？'), findsOneWidget);
    });
  });

  group('商家选图即传', () {
    testWidgets('证件图上传成功 → URL 写回入驻数据并保存草稿', (tester) async {
      final config = FakeConfigService();
      final storage = await registerTestEnv(config: config);
      await tester.pumpWidget(buildTestApp());
      final c = MerchantEntryController();
      Get.put(c);
      await tester.pump();

      await c.uploadAndPersistDocuments('/tmp/doc.jpg');
      await c.saveDraft();
      await tester.pump(const Duration(milliseconds: 450));

      expect(c.merchantEntry.documentsPicture, 'https://cdn.test/uploads/doc.jpg');
      final saved = storage.getString('merchant_entry_draft');
      expect(saved, contains('https://cdn.test/uploads/doc.jpg'));
    });

    testWidgets('商家图片上传成功后本地路径替换为 URL', (tester) async {
      final config = FakeConfigService();
      await registerTestEnv(config: config);
      await tester.pumpWidget(buildTestApp());
      final c = MerchantEntryController();
      Get.put(c);
      await tester.pump();

      c.merchantPictures.add('/tmp/shop1.jpg');
      await c.uploadAndPersistMerchantPic('/tmp/shop1.jpg');
      await tester.pump(const Duration(milliseconds: 450));

      expect(c.merchantPictures, ['https://cdn.test/uploads/shop1.jpg']);
      expect(c.merchantEntry.picture, contains('https://cdn.test/uploads/shop1.jpg'));
    });

    testWidgets('上传失败 → 保持本地路径', (tester) async {
      final failing = FakeConfigService()..failUploads = true;
      await registerTestEnv(config: failing);
      await tester.pumpWidget(buildTestApp());
      final c = MerchantEntryController();
      Get.put(c);
      await tester.pump();

      c.merchantPictures.add('/tmp/shop1.jpg');
      await c.uploadAndPersistMerchantPic('/tmp/shop1.jpg');
      await tester.pump(const Duration(milliseconds: 450));

      expect(c.merchantPictures, ['/tmp/shop1.jpg']);
      expect(c.merchantEntry.picture, isNot(contains('https://cdn.test')));
    });
  });
}
