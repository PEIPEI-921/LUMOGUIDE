import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/alert.dart';
import '../values/colors.dart';

class ImagePickerUtil {
  /// image_cropper 不支持 macOS 桌面端，桌面端跳过裁剪
  static bool get _supportsCrop => !Platform.isMacOS && !Platform.isWindows && !Platform.isLinux;

  static Future<String> selectImageFromGallery(
    BuildContext context, {
    bool canEdit = true,
  }) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
      }
    } else {
    }

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return '';
    if (!canEdit || !_supportsCrop) return file.path;

    final cropperFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        IOSUiSettings(doneButtonTitle: '完成'.tr, cancelButtonTitle: '取消'.tr),
        AndroidUiSettings(),
      ],
    );
    if (cropperFile == null) return '';
    return cropperFile.path;
  }

  /// 仅从相机拍照选择，不弹 sheet
  static Future<String> selectImageFromCamera(
    BuildContext context, {
    bool canEdit = true,
  }) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (file == null) return '';
    if (!canEdit) return file.path;
    final cropperFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        IOSUiSettings(doneButtonTitle: '完成'.tr, cancelButtonTitle: '取消'.tr),
        AndroidUiSettings(),
      ],
    );
    if (cropperFile == null) return '';
    return cropperFile.path;
  }

  static Future<String> selectImage(
    BuildContext context, {
    bool canEdit = true,
  }) async {
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
    if (source == ImageSource.camera) {
    }
    if (source == ImageSource.gallery) {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+ 使用 Photo Picker，无需权限
        } else {
          
        }
      } else {
        
      }
    }
    XFile? file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );
    if (file == null) return '';
    if (!canEdit || !_supportsCrop) return file.path;

    final cropperFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        IOSUiSettings(doneButtonTitle: '完成'.tr, cancelButtonTitle: '取消'.tr),
        AndroidUiSettings(),
      ],
    );
    if (cropperFile == null) return '';
    return cropperFile.path;
  }

  static Future<List<String>> selectImages(
    BuildContext context, {
    int limit = 9,
    bool canEdit = true,
  }) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
      }
    } else {
      // iOS 需要请求权限
    }
    final files = await ImagePicker().pickMultiImage(limit: limit);
    if (files.isEmpty) return [];
    final paths = files.map((e) => e.path).toList();
    if (!canEdit || !_supportsCrop) return paths;

    List<String> editedPaths = [];
    for (final file in files) {
      final cropperFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          IOSUiSettings(doneButtonTitle: '完成'.tr, cancelButtonTitle: '取消'.tr),
          AndroidUiSettings(),
        ],
      );
      if (cropperFile != null) {
        editedPaths.add(cropperFile.path);
      }
    }

    return editedPaths;
    // final cropperFiles = await ImageCropper().cropImages(
  }
}
