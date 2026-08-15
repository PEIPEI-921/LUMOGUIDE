import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/index.dart';

/// 群二维码页：展示群 ID 二维码，支持保存到相册、分享。
class GroupQRPage extends StatefulWidget {
  const GroupQRPage({super.key});

  @override
  State<GroupQRPage> createState() => _GroupQRPageState();
}

class _GroupQRPageState extends State<GroupQRPage> {
  final GlobalKey _qrKey = GlobalKey();

  String get groupID => Get.arguments?['groupID'] as String? ?? '';
  String get groupName => Get.arguments?['groupName'] as String? ?? '';

  Future<Uint8List?> _captureQrImage() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _onSave() async {
    final bytes = await _captureQrImage();
    if (bytes == null || bytes.isEmpty) {
      Loading.error('保存失败'.tr);
      return;
    }
    try {
      final result = await ImageGallerySaverPlus.saveImage(bytes);
      if (result['isSuccess'] == true) {
        Loading.success('已保存到相册'.tr);
      } else {
        Loading.error('保存失败'.tr);
      }
    } catch (e) {
      Loading.error('保存失败'.tr);
    }
  }

  Future<void> _onShare() async {
    final bytes = await _captureQrImage();
    if (bytes == null || bytes.isEmpty) {
      Loading.error('分享失败'.tr);
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/group_qr_$groupID.png';
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)], text: groupName.isNotEmpty ? '群聊：$groupName' : null);
    } catch (e) {
      Loading.error('分享失败'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (groupID.isEmpty) {
      return IScaffold(
        appBar: IAppBar(title: '群二維碼'.tr),
        body: const Center(child: EmptyListWidget()),
      );
    }
    return IScaffold(
      appBar: IAppBar(title: '群二維碼'.tr),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.w),
        child: Column(
          children: [
            if (groupName.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16.w),
                child: Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.assistantText.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: AppQRCode.buildGroup(groupID),
                  version: QrVersions.auto,
                  size: 220.w,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primaryText,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.w),
            Text(
              '掃碼加入群聊'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.assistantText,
              ),
            ),
            SizedBox(height: 32.w),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _onSave,
                    icon: const Icon(Icons.save_alt, size: 20),
                    label: Text('保存'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 14.w),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onShare,
                    icon: const Icon(Icons.share, size: 20),
                    label: Text('分享'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.w),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
