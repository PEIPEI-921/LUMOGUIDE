import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumotrip/common/index.dart';

/// 轻量 fake UserStore：跳过真实初始化（不读 StorageStone、不发网络），
/// profile 由测试注入。继承真实类保留 GetX 生命周期契约。
class FakeUserStore extends UserStore {
  FakeUserStore({UserInfo? profile}) : _profileValue = profile ?? UserInfo();

  final UserInfo _profileValue;
  int getProfileCalls = 0;

  @override
  // 有意跳过真实初始化
  // ignore: must_call_super
  void onInit() {}

  @override
  bool get isLogin => true;

  @override
  UserInfo get profile => _profileValue;

  @override
  Future<bool> getProfile() async {
    getProfileCalls++;
    return true;
  }
}

/// 轻量 fake ConfigService：控制语言/导游分类数据，记录上传调用。
class FakeConfigService extends ConfigService {
  FakeConfigService({
    this.config,
    this.ensureConfigResult,
    List<Category>? categories,
    this.uploadResult = '',
  }) : categoriesValue = categories ?? [
          Category(id: 1, name: '導遊'),
          Category(id: 2, name: '司機導遊'),
        ];

  SystemConfig? config;

  /// ensureSystemConfig 的返回值（默认与 config 一致；可指定不同以模拟“兜底拉到数据”）
  SystemConfig? ensureConfigResult;
  final List<Category> categoriesValue;
  String uploadResult;

  /// 为 true 时 uploadFile 抛异常（模拟上传失败）
  bool failUploads = false;
  final uploadedFiles = <String>[];
  int ensureSystemConfigCalls = 0;
  int ensureGuideCategoriesCalls = 0;

  @override
  SystemConfig get systemConfig => config ?? SystemConfig();

  @override
  List<Category> get guideCategories => categoriesValue;

  @override
  Future<SystemConfig> ensureSystemConfig() async {
    ensureSystemConfigCalls++;
    return ensureConfigResult ?? config ?? SystemConfig();
  }

  // 注意：ensureGuideCategories 是 ConfigService 扩展成员，无法被覆写；
  // 此实例方法仅供同库内直接调用 fake 时使用。
  Future<List<Category>> ensureGuideCategories() async {
    ensureGuideCategoriesCalls++;
    return categoriesValue;
  }

  @override
  Future<String> uploadFile(String path) async {
    uploadedFiles.add(path);
    if (failUploads) {
      throw Exception('mock upload failure');
    }
    if (uploadResult.isNotEmpty) return uploadResult;
    final name = path.split('/').last;
    return 'https://cdn.test/uploads/$name';
  }
}

/// 注册测试所需的全局服务：StorageService(内存) + FakeUserStore + FakeConfigService。
/// 同时初始化 ScreenUtil（.w/.sp 扩展依赖），返回注册后的 storage。
Future<StorageService> registerTestEnv({
  UserInfo? user,
  FakeConfigService? config,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  Get.addTranslations(TranslationService().keys);
  final storage = StorageService();
  await storage.init();
  Get.put<StorageService>(storage);
  Get.put<UserStore>(FakeUserStore(
    profile: user ?? UserInfo(identity: 1, guideAuditStatus: 9, companyAuditStatus: 9),
  ));
  Get.put<ConfigService>(config ?? FakeConfigService());
  return storage;
}

/// 测试宿主 App：挂载 EasyLoading（Loading.show 依赖），供 pumpWidget 使用
Widget buildTestApp() {
  return GetMaterialApp(
    builder: EasyLoading.init(),
    home: ScreenUtilInit(
      designSize: const Size(375, 834),
      minTextAdapt: true,
      builder: (context, child) => const Scaffold(),
    ),
  );
}
