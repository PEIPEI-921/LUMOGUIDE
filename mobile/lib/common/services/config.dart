import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../index.dart';
import 'package:dio/dio.dart' as dio;

class ConfigService extends GetxService with ApiMixin {
  static ConfigService get to => Get.find();

  bool _isFirstOpen = false;
  bool get isFirstOpen => _isFirstOpen;

  bool _isEnterApp = false;
  bool get isEnterApp => _isEnterApp;

  PackageInfo? _packageInfo;
  String get version => _packageInfo?.version ?? '';

  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;

  SystemConfig? _systemConfig;
  SystemConfig get systemConfig => _systemConfig ?? SystemConfig();

  String get packName => _packageInfo?.packageName ?? '';

  /// 類型分類
  Map<int, List<Category>> typeCategories = {};

  /// 導遊分類
  List<Category> guideCategories = [];

  Future<ConfigService> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      _androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    } else if (Platform.isIOS) {
      _iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
    }
    _loadConfig();
    return this;
  }

  _loadConfig() {
    _isFirstOpen = StorageService.to.getBool(
      STORAGE_IS_FIRST_OPEN_KEY,
      defaultValue: true,
    );
  }

  enterApp() {
    _isEnterApp = true;
    _isFirstOpen = true;
    StorageService.to.setBool(STORAGE_IS_FIRST_OPEN_KEY, false);
    loadSystemConfig();
    loadTypeCategories();
    loadGuideCategories();
  }

  Future<void> loadSystemConfig() async {
    final res = await get(ApiUrl.config);
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    _systemConfig = SystemConfig.fromJson(data);
    _cacheWelcomeImages();
  }

  Future<void> _cacheWelcomeImages() async {
    if (_systemConfig == null) return;

    final imageCacheService = ImageCacheService.to;
    final config = _systemConfig!;

    if (config.systemLogo != null && config.systemLogo!.isNotEmpty) {
      final cachedPath = await imageCacheService.downloadAndCacheImage(
        config.systemLogo!,
        'system_logo.png',
      );
      if (cachedPath != null) {
        StorageStone.setSystemLogoPath(cachedPath);
      }
    }

    if (config.systemWelcomeZh != null && config.systemWelcomeZh!.isNotEmpty) {
      final cachedPath = await imageCacheService.downloadAndCacheImage(
        config.systemWelcomeZh!,
        'system_welcome_zh.png',
      );
      if (cachedPath != null) {
        StorageStone.setSystemWelcomeZhPath(cachedPath);
      }
    }

    if (config.systemWelcomeEn != null && config.systemWelcomeEn!.isNotEmpty) {
      final cachedPath = await imageCacheService.downloadAndCacheImage(
        config.systemWelcomeEn!,
        'system_welcome_en.png',
      );
      if (cachedPath != null) {
        StorageStone.setSystemWelcomeEnPath(cachedPath);
      }
    }
  }

  Future<String> uploadFile(String path, {String ext = 'png'}) async {
    Uint8List? compressedData;
    String filename = '';
    if (ext == 'png') {
      compressedData = await compressImageToSize(File(path));
      filename = '${DateTime.now().millisecondsSinceEpoch}.png';
    } else {
      compressedData = File(path).readAsBytesSync();
      filename = path.split('/').last;
    }
    final uploadFile = dio.MultipartFile.fromBytes(
      compressedData!,
      filename: filename,
      contentType: dio.DioMediaType.parse("image/png"),
    );
    final res = await post(
      ApiUrl.fileUpload,
      data: dio.FormData.fromMap({'image': uploadFile}),
    );
    return res.dataJson['url'] ?? '';
  }

  Future<String> uploadFileDebug(String path) async {
    final compressedData = await compressImageToSize(File(path));
    final uploadFile = dio.MultipartFile.fromBytes(
      compressedData!,
      filename: '${DateTime.now().millisecondsSinceEpoch}.png',
      contentType: dio.DioMediaType.parse("image/png"),
    );
    final res = await post(
      ApiUrl.fileUpload,
      data: dio.FormData.fromMap({'image': uploadFile}),
    );
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return '';
    }
    AlertUtils.success(res.dataJson['url'] ?? '');
    return res.dataJson['url'] ?? '';
  }
}

extension DeviceInfo on ConfigService {
  String get deviceId {
    if (Platform.isAndroid) {
      return _androidDeviceInfo?.id ?? '';
    } else if (Platform.isIOS) {
      return _iosDeviceInfo?.identifierForVendor ?? '';
    }
    return '';
  }

  String get deviceName {
    if (Platform.isAndroid) {
      return _androidDeviceInfo?.model ?? '';
    } else if (Platform.isIOS) {
      return _iosDeviceInfo?.name ?? '';
    }
    return '';
  }

  String get deviceBrand {
    if (Platform.isAndroid) {
      return _androidDeviceInfo?.manufacturer ?? '';
    } else if (Platform.isIOS) {
      return _iosDeviceInfo?.name ?? '';
    }
    return '';
  }

  String get deviceModel {
    if (Platform.isAndroid) {
      return _androidDeviceInfo?.model ?? '';
    } else if (Platform.isIOS) {
      return _iosDeviceInfo?.name ?? '';
    }
    return '';
  }

  Map<String, dynamic> get deviceInfo {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_brand': deviceBrand,
      'device_model': deviceModel,
    };
  }
}

extension TypeCategory on ConfigService {
  loadGuideCategories() async {
    final res = await get(ApiUrl.guideType);
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataList;
    guideCategories = data.map((e) => Category.fromJson(e)).toList();
  }

  loadTypeCategories() async {
    // 1:景點 2:餐廳 3:購物 4:住宿 5:交通 6:設施 7:活動 8:票務
    final ids = CommonDetailType.values.map((e) => e.id).toList();
    for (var id in ids) {
      final res = await get(ApiUrl.typeClass, parameters: {'type_id': id});
      if (!res.isSuccess) {
        typeCategories[id] = [];
        continue;
      }
      final data = res.dataList;
      typeCategories[id] = data.map((e) => Category.fromJson(e)).toList();
    }
  }

  /// 景點
  List<Category> get scenicCategories =>
      getCategories(CommonDetailType.scenic.id);

  /// 餐廳
  List<Category> get restaurantCategories =>
      getCategories(CommonDetailType.restaurant.id);

  /// 購物
  List<Category> get shoppingCategories =>
      getCategories(CommonDetailType.shopping.id);

  /// 住宿
  List<Category> get hotelCategories =>
      getCategories(CommonDetailType.hotel.id);

  /// 交通
  List<Category> get trafficCategories =>
      getCategories(CommonDetailType.traffic.id);

  /// 設施
  List<Category> get facilityCategories =>
      getCategories(CommonDetailType.facility.id);

  /// 活動
  List<Category> get activityCategories =>
      getCategories(CommonDetailType.activity.id);

  /// 票務
  List<Category> get ticketCategories =>
      getCategories(CommonDetailType.ticket.id);

  /// 獲取類型分類
  List<Category> getCategories(int id) {
    return typeCategories[id] ?? [];
  }
}
