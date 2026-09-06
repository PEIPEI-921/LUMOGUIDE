import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../values/colors.dart';
import '../widgets/image_crop_page.dart';

class ImagePickerUtil {
  /// 裁剪走純 Flutter 的 [ImageCropPage]（原 ucrop 已移除：修復 Android 15/16
  /// 兼容警告 + 大圖全解析記憶體問題）。桌面端與原行為一致：跳過裁剪。
  static bool get _supportsCrop =>
      !Platform.isMacOS && !Platform.isWindows && !Platform.isLinux;

  /// 打開裁剪頁對 [sourcePath] 做 1:1 裁剪；取消返回 ''，成功返回裁剪檔路徑。
  static Future<String> _cropSquare(
    NavigatorState navigator,
    String sourcePath,
  ) async {
    final file = File(sourcePath);
    if (!file.existsSync()) return '';
    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      return '';
    }
    if (bytes.isEmpty) return '';
    final result = await navigator.push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => ImageCropPage(imageBytes: bytes, aspectRatio: 1),
      ),
    );
    if (result == null) return '';
    return _writeTempFile(result);
  }

  static Future<String> _writeTempFile(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.${_extOf(bytes)}',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return '';
    }
  }

  static String _extOf(Uint8List bytes) {
    if (bytes.length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50) {
      return 'png';
    }
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'jpg';
    }
    return 'png';
  }

  static Future<String> selectImageFromGallery(
    BuildContext context, {
    bool canEdit = true,
  }) async {
    final navigator = Navigator.of(context);
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return '';
    if (!canEdit || !_supportsCrop) return file.path;

    return _cropSquare(navigator, file.path);
  }

  /// 仅从相机拍照选择，不弹 sheet
  static Future<String> selectImageFromCamera(
    BuildContext context, {
    bool canEdit = true,
  }) async {
    final navigator = Navigator.of(context);
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (file == null) return '';
    if (!canEdit || !_supportsCrop) return file.path;
    return _cropSquare(navigator, file.path);
  }

  static Future<String> selectImage(
    BuildContext context, {
    bool canEdit = true,
  }) async {
    final navigator = Navigator.of(context);
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
              child: Text(
                '相機'.tr,
                style: const TextStyle(color: AppColors.primary, fontSize: 16),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
              child: Text(
                '相簿'.tr,
                style: const TextStyle(color: AppColors.primary, fontSize: 16),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '取消'.tr,
              style: const TextStyle(
                color: AppColors.assistantText,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
    if (source == null) return '';
    XFile? file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );
    if (file == null) return '';
    if (!canEdit || !_supportsCrop) return file.path;

    return _cropSquare(navigator, file.path);
  }

  static Future<List<String>> selectImages(
    BuildContext context, {
    int limit = 9,
    bool canEdit = true,
  }) async {
    final navigator = Navigator.of(context);
    final files = await ImagePicker().pickMultiImage(limit: limit);
    if (files.isEmpty) return [];
    final paths = files.map((e) => e.path).toList();
    if (!canEdit || !_supportsCrop) return paths;

    final editedPaths = <String>[];
    for (final file in files) {
      final cropped = await _cropSquare(navigator, file.path);
      if (cropped.isNotEmpty) {
        editedPaths.add(cropped);
      }
    }
    return editedPaths;
  }
}
