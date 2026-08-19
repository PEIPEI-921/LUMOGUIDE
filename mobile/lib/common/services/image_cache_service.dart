import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCacheService extends GetxService {
  static ImageCacheService get to => Get.find();

  static const String _cacheDirName = 'welcome_images';
  late Directory _cacheDir;

  Future<ImageCacheService> init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory(path.join(appDocDir.path, _cacheDirName));
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
    return this;
  }

  Future<String?> downloadAndCacheImage(String url, String fileName) async {
    if (url.isEmpty) return null;

    try {
      final filePath = path.join(_cacheDir.path, fileName);

      // 已有有效緩存（非空檔案）則跳過下載，避免每次啟動重複拉取
      final existing = File(filePath);
      if (existing.existsSync() && existing.lengthSync() > 0) {
        return filePath;
      }

      final dio = Dio();
      // 圖床慢/掛時不能無限阻塞：加超時
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      // 先下載到 .tmp，成功後再 rename，避免失敗殘留半截檔案被誤判為有效緩存
      final tmpPath = '$filePath.tmp';
      final response = await dio.download(url, tmpPath);

      if (response.statusCode == 200 && File(tmpPath).lengthSync() > 0) {
        await File(tmpPath).rename(filePath);
        return filePath;
      }
      // 下載失敗：清理殘留 tmp
      if (File(tmpPath).existsSync()) {
        try {
          await File(tmpPath).delete();
        } catch (_) {}
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String? getCachedImagePath(String fileName) {
    final filePath = path.join(_cacheDir.path, fileName);
    final file = File(filePath);
    // 僅當檔案存在且非空時才視為有效緩存（防止半截檔案）
    if (file.existsSync() && file.lengthSync() > 0) {
      return filePath;
    }
    return null;
  }

  Future<void> clearCache() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
    }
  }
}
