import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/guide_certification/controller.dart';
import 'package:lumotrip/pages/guide_certification/value.dart';

import 'helpers/test_env.dart';

Map<String, dynamic> buildDraft() {
  return {
    'form': {
      'name': '張三',
      'name_en': 'Zhang San',
      'phone': '+8613800000000',
      'email': 'zhang@example.com',
      'bill_address': 'Vienna 1010',
      'wechat': 'wx123',
      'whats_app': '',
      'line': '',
      'other_contact': '',
      'invite_code': '',
      'photo': 'https://cdn.test/photo.jpg',
      'year': '2020',
      'identity_type': '導遊',
      'introduction': '十年帶團經驗',
      'business_contact': '張三',
      'have_vehicle': 1,
      'vehicle_rent': 0,
      'vehicle_info': '五座車(2輛)',
      'other_type': '',
      'certificate_picture': 'https://cdn.test/cert.jpg',
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

  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('语言选择', () {
    testWidgets('语言列表为空 → 点击时兜底拉取并显示选项', (tester) async {
      final config = FakeConfigService(
        config: SystemConfig(), // languages 为空
        ensureConfigResult: SystemConfig(languages: ['中文', 'English']),
      );
      await registerTestEnv(config: config);
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pump();

      c.onSelectLanguage();
      await tester.pumpAndSettle();

      expect(config.ensureSystemConfigCalls, 1);
      expect(find.text('中文'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('语言列表已有数据 → 不触发兜底拉取', (tester) async {
      final config = FakeConfigService(
        config: SystemConfig(languages: ['中文', 'English']),
      );
      await registerTestEnv(config: config);
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pump();

      c.onSelectLanguage();
      await tester.pumpAndSettle();

      expect(config.ensureSystemConfigCalls, 0);
      expect(find.text('中文'), findsOneWidget);
    });
  });

  group('草稿恢复', () {
    testWidgets('选择“继续编辑” → 恢复表单且处于可编辑状态（不再全灰）', (tester) async {
      await registerTestEnv(
        prefs: {'guide_certify_draft': jsonEncode(buildDraft())},
      );
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pumpAndSettle();

      // 草稿提示弹窗出现
      expect(find.text('偵測到未完成的認證資料，是否繼續編輯？'), findsOneWidget);

      await tester.tap(find.text('繼續編輯'));
      await tester.pumpAndSettle();

      // 关键断言：可编辑 + 数据/图片恢复
      expect(c.isReadOnly, isFalse);
      expect(c.certification.auditStatus, isNull);
      expect(c.nameController.text, '張三');
      expect(c.certification.language, ['中文']);
      expect(c.certification.photo, 'https://cdn.test/photo.jpg');
      expect(c.certification.certificatePicture, 'https://cdn.test/cert.jpg');
      expect(c.carPictures, contains('https://cdn.test/car1.jpg'));
      expect(c.certification.carPictures, contains('https://cdn.test/car1.jpg'));
      expect(c.certification.residentCityId, 1);
      expect(c.certification.industryType, ['導遊']);
    });

    testWidgets('选择“重新填写” → 清除草稿，表单保持空白', (tester) async {
      final storage = await registerTestEnv(
        prefs: {'guide_certify_draft': jsonEncode(buildDraft())},
      );
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pumpAndSettle();

      await tester.tap(find.text('重新填寫'));
      await tester.pumpAndSettle();

      expect(c.nameController.text, isEmpty);
      expect(storage.getString('guide_certify_draft'), isEmpty);
    });

    testWidgets('审核通过用户点“编辑” → 重置只读并弹出草稿提示', (tester) async {
      await registerTestEnv(
        user: UserInfo(identity: 2, guideAuditStatus: 1),
      );
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pumpAndSettle();

      // 模拟已通过状态（页面只读）
      c.certification.auditStatus = 1;
      expect(c.isReadOnly, isTrue);

      // 写入草稿后点编辑
      final storage = Get.find<StorageService>();
      await storage.setString('guide_certify_draft', jsonEncode(buildDraft()));
      c.onEdit();
      await tester.pumpAndSettle();

      expect(c.isReadOnly, isFalse);
      expect(c.certification.auditStatus, isNull);
      expect(find.text('偵測到未完成的認證資料，是否繼續編輯？'), findsOneWidget);

      await tester.tap(find.text('繼續編輯'));
      await tester.pumpAndSettle();
      expect(c.nameController.text, '張三');
    });
  });

  group('选图即传（图片持久化）', () {
    testWidgets('photo 选图后立即上传 → URL 写回认证数据并保存草稿', (tester) async {
      final config = FakeConfigService();
      final storage = await registerTestEnv(config: config);
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pump();

      // 通过 dynamic 调用私有方法（库私有仅编译期约束）
      await c.uploadAndPersist(GuidePhotoType.photo, '/tmp/photo.jpg');
      await c.saveDraft();
      await tester.pump(const Duration(milliseconds: 450));

      expect(config.uploadedFiles, contains('/tmp/photo.jpg'));
      expect(c.certification.photo, 'https://cdn.test/uploads/photo.jpg');
      final saved = storage.getString('guide_certify_draft');
      expect(saved, contains('https://cdn.test/uploads/photo.jpg'));
    });

    testWidgets('车辆图片上传成功后本地路径替换为 URL', (tester) async {
      final config = FakeConfigService();
      await registerTestEnv(config: config);
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pump();

      c.carPictures.add('/tmp/car1.jpg');
      await c.uploadAndPersistCar('/tmp/car1.jpg');
      await tester.pump(const Duration(milliseconds: 450));

      expect(c.carPictures, ['https://cdn.test/uploads/car1.jpg']);
      expect(c.certification.carPictures, contains('https://cdn.test/uploads/car1.jpg'));
    });

    testWidgets('上传失败 → 保持本地路径，认证数据不写入空 URL', (tester) async {
      final failing = FakeConfigService()..failUploads = true;
      await registerTestEnv(config: failing);
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pump();

      c.carPictures.add('/tmp/car1.jpg');
      await c.uploadAndPersistCar('/tmp/car1.jpg');
      await c.uploadAndPersist(GuidePhotoType.photo, '/tmp/photo.jpg');
      await tester.pump(const Duration(milliseconds: 450));

      // 上传失败：本地预览保留，URL 不写入
      expect(c.carPictures, ['/tmp/car1.jpg']);
      expect(c.certification.carPictures, isNot(contains('/tmp/car1.jpg')));
      expect(c.certification.photo, isNull);
      expect(failing.uploadedFiles, contains('/tmp/car1.jpg'));
    });
  });

  group('从业类型加载', () {
    testWidgets('guideTypes 异步补齐后 selectedGuideTypes 同步重建', (tester) async {
      final config = FakeConfigService(
        categories: [
          Category(id: 1, name: '導遊'),
          Category(id: 2, name: '司機導遊'),
        ],
      );
      await registerTestEnv(config: config);
      await tester.pumpWidget(buildTestApp());
      final c = GuideCertificationController();
      Get.put(c);
      await tester.pumpAndSettle();

      expect(c.guideTypes, hasLength(2));
      // 设置已选类型后触发同步
      c.certification.industryType = ['導遊'];
      c.syncSelectedGuideTypes();
      expect(c.selectedGuideTypes.map((e) => e.name), ['導遊']);
    });
  });
}
