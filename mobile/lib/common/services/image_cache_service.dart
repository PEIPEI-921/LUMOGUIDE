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

      final dio = Dio();
      final response = await dio.download(url, filePath);

      if (response.statusCode == 200) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String? getCachedImagePath(String fileName) {
    final filePath = path.join(_cacheDir.path, fileName);
    final file = File(filePath);
    if (file.existsSync()) {
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
