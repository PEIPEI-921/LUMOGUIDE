import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';

/// 純 Flutter 方形裁剪頁（取代原生 ucrop，根治 Android 15/16 兼容警告）。
///
/// 以 [Navigator.push] 開啟，回傳裁切後的圖片位元組；用戶取消（返回 null）則
/// 在呼叫端視為「放棄本次裁剪」（與原 ucrop 取消行為一致）。
class ImageCropPage extends StatefulWidget {
  const ImageCropPage({super.key, required this.imageBytes, this.aspectRatio = 1});

  final Uint8List imageBytes;
  final double aspectRatio;

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  final CropController _controller = CropController();
  bool _cropping = false;

  Future<void> _onCrop() async {
    if (_cropping) return;
    setState(() => _cropping = true);
    _controller.crop();
  }

  void _onCropped(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        // 避免 dispose 後 setState
        if (mounted) {
          Navigator.of(context).pop<Uint8List>(croppedImage);
        }
        break;
      case CropFailure():
        setState(() => _cropping = false);
        AlertUtils.error('裁剪失敗，請重試'.tr);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('移動 / 縮放，調整裁剪範圍'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '取消'.tr,
        ),
        actions: [
          TextButton(
            onPressed: _cropping ? null : _onCrop,
            child: Text(
              '完成'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Center(
        child: Crop(
          image: widget.imageBytes,
          controller: _controller,
          onCropped: _onCropped,
          aspectRatio: widget.aspectRatio,
          interactive: true,
          maskColor: Colors.black.withValues(alpha: 0.6),
          baseColor: Colors.white,
          progressIndicator: const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}
