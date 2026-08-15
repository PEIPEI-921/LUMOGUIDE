import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../index.dart';
import 'package:dio/dio.dart' as dio;

class ConfigService extends GetxService with ApiMixin {
  static ConfigService get to => Get.find();

  /// 最近一次文件上传的错误信息（供调用方展示给用户）
  String lastUploadError = '';

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

  /// 根据文件扩展名获取 MIME 类型
  static String _mimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'png':
      default:
        return 'image/png';
    }
  }

  /// 从 ApiResult 中提取上传后的文件 URL，兼容多种后端响应格式
  static String _extractUrl(ApiResult res) {
    // 格式1: {"code":200, "data": {"url": "https://..."}}
    if (res.dataJson['url'] is String && (res.dataJson['url'] as String).isNotEmpty) {
      return res.dataJson['url'];
    }
    // 格式2: {"code":200, "data": "https://..."} — data 直接就是 URL 字符串
    if (res.data is String && (res.data as String).startsWith('http')) {
      return res.data;
    }
    // 格式3: {"code":200, "url": "https://..."} — URL 在顶层
    if (res.rawValue != null && res.rawValue!['url'] is String) {
      return res.rawValue!['url'];
    }
    // 格式4-8: 常见变体 key 名
    for (final key in ['path', 'file_url', 'file_path', 'src', 'link']) {
      if (res.dataJson[key] is String && (res.dataJson[key] as String).isNotEmpty) {
        return res.dataJson[key];
      }
    }
    // 格式9: data 内部嵌套了另一个 data 对象，如 {"code":200, "data": {"data": {"url": "..."}}}
    if (res.dataJson['data'] is Map) {
      final inner = res.dataJson['data'] as Map;
      if (inner['url'] is String && (inner['url'] as String).isNotEmpty) {
        return inner['url'];
      }
    }
    // 格式10: 兜底 — 扫描 dataJson 中任意以 http 开头的字符串值
    for (final value in res.dataJson.values) {
      if (value is String && value.startsWith('http')) {
        return value;
      }
    }
    return '';
  }

  /// 上传文件（支持任意图片格式：PNG/JPEG/GIF/HEIC/HEIF/WebP/BMP）
  ///
  /// 策略：
  /// 1. GIF 跳过压缩，直接上传原文件（保留动画）
  /// 2. 其他格式：先尝试 flutter_image_compress 压缩为 JPEG
  /// 3. 压缩失败（HEIC 等格式）→ 回退为上传原文件
  Future<String> uploadFile(String path) async {
    try {
      final originalFilename = path.split('/').last;
      final originalExt = originalFilename.split('.').last.toLowerCase();
      final originalMime = _mimeType(originalFilename);
      final originalFile = File(path);
      final originalSize = await originalFile.length();
      if (kDebugMode) debugPrint('[uploadFile] START path=$path ext=$originalExt mime=$originalMime size=${(originalSize / 1024).toStringAsFixed(1)}KB');

      late final dio.MultipartFile upload;

      // GIF 跳过压缩，保留动画
      if (originalExt == 'gif') {
        if (kDebugMode) debugPrint('[uploadFile] GIF detected — skip compression, upload raw');
        final bytes = await originalFile.readAsBytes();
        upload = dio.MultipartFile.fromBytes(
          bytes,
          filename: originalFilename,
          contentType: dio.DioMediaType.parse(originalMime),
        );
      } else {
        // 尝试压缩（flutter_image_compress 会将 HEIC/WebP 等转为 JPEG）
        final compressed = await compressImageToSize(originalFile);
        if (compressed != null) {
          final compressedSizeKB = (compressed.length / 1024).toStringAsFixed(1);
          if (kDebugMode) debugPrint('[uploadFile] Compressed OK: $compressedSizeKB KB (from ${(originalSize / 1024).toStringAsFixed(1)} KB)');
          upload = dio.MultipartFile.fromBytes(
            compressed,
            filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
            contentType: dio.DioMediaType.parse('image/jpeg'),
          );
        } else {
          // 压缩失败（HEIC 在部分平台不支持）→ 上传原文件
          if (kDebugMode) debugPrint('[uploadFile] Compression failed — fallback to raw upload');
          final bytes = await originalFile.readAsBytes();
          upload = dio.MultipartFile.fromBytes(
            bytes,
            filename: originalFilename,
            contentType: dio.DioMediaType.parse(originalMime),
          );
        }
      }

      if (kDebugMode) debugPrint('[uploadFile] Uploading: filename=${upload.filename} mime=${upload.contentType}');
      final res = await post(
        ApiUrl.fileUpload,
        data: dio.FormData.fromMap({'image': upload}),
      );
      if (kDebugMode) debugPrint('[uploadFile] Response: isSuccess=${res.isSuccess} code=${res.code} message=${res.message}');
      if (!res.isSuccess) {
        log('[uploadFile] FAILED: code=${res.code} message=${res.message} rawValue=${res.rawValue}', name: 'uploadFile');
        lastUploadError = res.message ?? '未知錯誤';
        return '';
      }
      final url = _extractUrl(res);
      if (url.isEmpty) {
        log('[uploadFile] URL EXTRACTION FAILED: rawValue=${res.rawValue} data=${res.data} dataJson=${res.dataJson}', name: 'uploadFile');
        lastUploadError = '伺服器回應格式異常，無法提取文件鏈接';
      } else {
        lastUploadError = '';
      }
      if (kDebugMode) debugPrint('[uploadFile] SUCCESS url=$url');
      return url;
    } catch (e) {
      log('[uploadFile] EXCEPTION: $e', name: 'uploadFile');
      lastUploadError = e.toString();
      return '';
    }
  }

  Future<String> uploadFileDebug(String path) async {
    final originalFilename = path.split('/').last;
    final originalExt = originalFilename.split('.').last.toLowerCase();
    final originalMime = _mimeType(originalFilename);
    final originalFile = File(path);

    // GIF 跳过压缩
    if (originalExt == 'gif') {
      final bytes = await originalFile.readAsBytes();
      final upload = dio.MultipartFile.fromBytes(
        bytes,
        filename: originalFilename,
        contentType: dio.DioMediaType.parse(originalMime),
      );
      final res = await post(
        ApiUrl.fileUpload,
        data: dio.FormData.fromMap({'image': upload}),
      );
      if (!res.isSuccess) {
        AlertUtils.error(res.message);
        return '';
      }
      AlertUtils.success(_extractUrl(res));
      return _extractUrl(res);
    }

    final compressedData = await compressImageToSize(originalFile);
    if (compressedData == null) {
      // 压缩失败 → 回退上传原文件
      final bytes = await originalFile.readAsBytes();
      final upload = dio.MultipartFile.fromBytes(
        bytes,
        filename: originalFilename,
        contentType: dio.DioMediaType.parse(originalMime),
      );
      final res = await post(
        ApiUrl.fileUpload,
        data: dio.FormData.fromMap({'image': upload}),
      );
      if (!res.isSuccess) {
        AlertUtils.error(res.message);
        return '';
      }
      AlertUtils.success(_extractUrl(res));
      return _extractUrl(res);
    }
    final upload = dio.MultipartFile.fromBytes(
      compressedData,
      filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
      contentType: dio.DioMediaType.parse('image/jpeg'),
    );
    final res = await post(
      ApiUrl.fileUpload,
      data: dio.FormData.fromMap({'image': upload}),
    );
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return '';
    }
    AlertUtils.success(_extractUrl(res));
    return _extractUrl(res);
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

  /// 確保指定類型的分類已載入；緩存為空時即時從 API 拉取並寫回緩存。
  /// loadTypeCategories() 在 enterApp() 中 fire-and-forget，導遊打開發佈頁時
  /// 緩存可能尚未就緒，點擊分類會得到空列表——此方法保證點擊時一定有數據。
  Future<List<Category>> ensureTypeCategories(int typeId) async {
    var list = getCategories(typeId);
    if (list.isNotEmpty) return list;
    final res = await get(ApiUrl.typeClass, parameters: {'type_id': typeId});
    if (!res.isSuccess) return [];
    list = res.dataList.map((e) => Category.fromJson(e)).toList();
    typeCategories[typeId] = list;
    return list;
  }
}
