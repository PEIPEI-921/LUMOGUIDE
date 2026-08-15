import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:path_provider/path_provider.dart';
import 'widgets/share_preview_dialog.dart';
import '../../pages/guide_detail/widgets/share_preview_dialog.dart'
    as guide_detail;

class InviteController extends GetxController with UserStoreMixin, ApiMixin {
  final inviteList = <Invite>[].obs;

  final shareCardKey = GlobalKey();

  final _guideInfo = Rxn<GuideList>();
  GuideList? get guideInfo => _guideInfo.value;

  final _companyInfo = Rxn<CompanyInfo>();
  CompanyInfo? get companyInfo => _companyInfo.value;

  @override
  void onInit() {
    super.onInit();
    _fetchInviteList();
  }

  onCopyInviteCode() async {
    if (userInfo.inviterCode == null) return;
    await Clipboard.setData(ClipboardData(text: userInfo.inviterCode!));
    Loading.success('複製成功'.tr);
  }

  Future<void> shareInviteCard() async {
    if (userInfo.inviteUrl == null || userInfo.inviteUrl!.isEmpty) {
      AlertUtils.error('邀請鏈接不存在'.tr);
      return;
    }

    if (userInfo.isEnterprise) {
      await _loadCompanyInfo();
      if (_companyInfo.value == null) {
        AlertUtils.error('獲取企業信息失敗'.tr);
        return;
      }
    } else if (userInfo.isGuide) {
      await _loadGuideInfo();
      if (_guideInfo.value == null) {
        AlertUtils.error('獲取導遊信息失敗'.tr);
        return;
      }
    }

    File? tempFile;
    try {
      Loading.show('正在生成分享圖片...'.tr);

      try {
        log('[分享] 步驟1: 等待初始渲染完成');
        await _waitForInitialRender();
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('分享失敗'.tr, content: '請稍後再試'.tr);
        return;
      }

      RenderRepaintBoundary renderObject;
      try {
        log('[分享] 步驟2: 獲取 RenderRepaintBoundary');
        final renderObjectNullable = await _getRenderObject();
        if (renderObjectNullable == null) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗'.tr);
          return;
        }
        renderObject = renderObjectNullable;
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }

      try {
        log('[分享] 步驟3: 等待渲染完成');
        final isRenderReady = await _waitForRenderComplete(renderObject);
        if (!isRenderReady) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗，請稍後再試'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗，請稍後再試'.tr);
        return;
      }

      ui.Image? image;
      try {
        log('[分享] 步驟4: 捕獲圖片');
        image = await _captureImage(renderObject);
        if (image == null) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }

      Uint8List? pngBytes;
      try {
        log('[分享] 步驟5: 轉換圖片為字節數據');
        pngBytes = await _convertImageToBytes(image);
        if (pngBytes == null) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }

      try {
        log('[分享] 步驟6: 保存圖片到臨時文件');
        tempFile = await _saveImageToFile(pngBytes);
        if (tempFile == null) {
          Loading.dismiss();
          AlertUtils.error('保存圖片失敗'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('保存圖片失敗'.tr);
        return;
      }

      Loading.dismiss();

      try {
        log('[分享] 步驟7: 顯示分享預覽');
        final shouldDelete = await _showSharePreview(tempFile);
        log('[分享] 步驟8: 清理臨時文件');
        await _cleanupTempFile(tempFile, shouldDelete);
      } catch (e) {
        log('[分享] 步驟7或8失敗: $e');
        AlertUtils.error('分享失敗'.tr);
        await _cleanupTempFile(tempFile, false);
      }
    } catch (e, stackTrace) {
      log('[分享] 發生未捕獲的錯誤: $e');
      log('[分享] 堆棧跟踪: $stackTrace');
      Loading.dismiss();
      AlertUtils.error('分享失敗'.tr);

      if (tempFile != null) {
        await _cleanupTempFile(tempFile, false);
      }
    }
  }

  Future<void> _waitForInitialRender() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      for (int i = 0; i < 3; i++) {
        await SchedulerBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      log('[分享] 初始渲染等待完成');
    } catch (e) {
      log('[分享] 等待初始渲染失敗: $e');
      rethrow;
    }
  }

  Future<RenderRepaintBoundary?> _getRenderObject() async {
    try {
      final renderObject =
          shareCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (renderObject == null) {
        log('[分享] RenderRepaintBoundary 為 null');
      } else {
        log('[分享] 成功獲取 RenderRepaintBoundary');
      }
      return renderObject;
    } catch (e) {
      log('[分享] 獲取 RenderRepaintBoundary 失敗: $e');
      rethrow;
    }
  }

  Future<bool> _waitForRenderComplete(
    RenderRepaintBoundary renderObject,
  ) async {
    try {
      int retryCount = 0;
      const maxRetries = 20;

      bool needsPaint = false;
      try {
        needsPaint = renderObject.debugNeedsPaint;
      } catch (e) {
        log('[分享] debugNeedsPaint 不可用（可能是 release 模式），使用固定等待時間');
        needsPaint = false;
      }

      while (needsPaint && retryCount < maxRetries) {
        await Future.delayed(const Duration(milliseconds: 50));
        await SchedulerBinding.instance.endOfFrame;
        retryCount++;
        log('[分享] 等待渲染完成，重試次數: $retryCount');

        try {
          needsPaint = renderObject.debugNeedsPaint;
        } catch (e) {
          needsPaint = false;
          break;
        }
      }

      if (retryCount >= maxRetries) {
        log('[分享] 等待渲染超時，但繼續嘗試捕獲圖片');
      }

      log('[分享] 渲染等待完成，重試次數: $retryCount');
      return true;
    } catch (e) {
      log('[分享] 等待渲染完成失敗: $e');
      rethrow;
    }
  }

  Future<ui.Image?> _captureImage(RenderRepaintBoundary renderObject) async {
    try {
      final image = await renderObject.toImage(pixelRatio: 3.0);
      log('[分享] 圖片捕獲成功，尺寸: ${image.width}x${image.height}');
      return image;
    } catch (e) {
      log('[分享] 捕獲圖片失敗: $e');
      rethrow;
    }
  }

  Future<Uint8List?> _convertImageToBytes(ui.Image image) async {
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        log('[分享] 圖片轉換為字節數據失敗: byteData 為 null');
        return null;
      }
      final pngBytes = byteData.buffer.asUint8List();
      log('[分享] 圖片轉換成功，大小: ${pngBytes.length} bytes');
      return pngBytes;
    } catch (e) {
      log('[分享] 轉換圖片為字節數據失敗: $e');
      rethrow;
    }
  }

  Future<File?> _saveImageToFile(Uint8List pngBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'invite_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      final exists = await file.exists();
      log(
        '[分享] 圖片已保存: ${file.path}, 大小: ${pngBytes.length} bytes, 文件存在: $exists',
      );

      if (!exists) {
        log('[分享] 文件保存後不存在，可能保存失敗');
        return null;
      }

      return file;
    } catch (e) {
      log('[分享] 保存圖片到文件失敗: $e');
      rethrow;
    }
  }

  Future<bool> _showSharePreview(File file) async {
    try {
      bool shouldDelete = false;

      if (userInfo.isEnterprise) {
        final shareText =
            '${_companyInfo.value?.fullName ?? userInfo.nickname ?? ''} - ${'企業詳情'.tr}';
        await Get.dialog(
          guide_detail.SharePreviewDialog(
            imageFile: file,
            shareText: shareText,
            onShareComplete: () {
              shouldDelete = true;
            },
          ),
          barrierDismissible: true,
        );
      } else if (userInfo.isGuide) {
        final shareText =
            '${_guideInfo.value?.fullName ?? userInfo.nickname ?? ''} - ${'導遊詳情'.tr}';
        await Get.dialog(
          guide_detail.SharePreviewDialog(
            imageFile: file,
            shareText: shareText,
            onShareComplete: () {
              shouldDelete = true;
            },
          ),
          barrierDismissible: true,
        );
      } else {
        final shareText = '${userInfo.nickname ?? ''}${'邀請您加入 LUMOGUIDE'.tr}';
        await Get.dialog(
          InviteSharePreviewDialog(
            imageFile: file,
            shareText: shareText,
            onShareComplete: () {
              shouldDelete = true;
            },
          ),
          barrierDismissible: true,
        );
      }

      log('[分享] 預覽對話框關閉，shouldDelete: $shouldDelete');
      return shouldDelete;
    } catch (e) {
      log('[分享] 顯示分享預覽失敗: $e');
      rethrow;
    }
  }

  Future<void> _cleanupTempFile(File file, bool shouldDelete) async {
    try {
      if (shouldDelete) {
        log('[分享] 用戶已分享，延遲5秒後刪除文件');
        await Future.delayed(const Duration(seconds: 5));
      } else {
        log('[分享] 用戶取消分享，延遲3秒後刪除文件');
        await Future.delayed(const Duration(seconds: 3));
      }

      if (await file.exists()) {
        await file.delete();
        log('[分享] 臨時文件已刪除: ${file.path}');
      } else {
        log('[分享] 臨時文件不存在，無需刪除: ${file.path}');
      }
    } catch (e) {
      log('[分享] 清理臨時文件失敗: $e');
    }
  }
}

extension on InviteController {
  _fetchInviteList() async {
    final res = await get(
      ApiUrl.inviteLog,
      parameters: {'page': 1, 'limit': 100},
    );
    if (!res.isSuccess) {
      return;
    }
    final list = res.dataJson['list'] as List<dynamic>;
    inviteList.value = list.map((e) => Invite.fromJson(e)).toList();
  }

  Future<void> _loadGuideInfo() async {
    final guideId = userInfo.guideInfo?.id;
    if (guideId == null) {
      log('[分享] 導遊ID不存在');
      return;
    }
    try {
      final res = await get(
        ApiUrl.guideInfo,
        parameters: {'guide_id': guideId},
      );
      if (res.isSuccess) {
        _guideInfo.value = GuideList.fromJson(res.dataJson);
        log('[分享] 導遊信息加載成功');
      } else {
        log('[分享] 導遊信息加載失敗: ${res.message}');
      }
    } catch (e) {
      log('[分享] 導遊信息加載異常: $e');
    }
  }

  Future<void> _loadCompanyInfo() async {
    final companyId = userInfo.companyInfo?.id;
    if (companyId == null) {
      log('[分享] 企業ID不存在');
      return;
    }
    try {
      final res = await get(
        ApiUrl.companyInfo,
        parameters: {'company_id': companyId},
      );
      if (res.isSuccess) {
        _companyInfo.value = CompanyInfo.fromJson(res.dataJson);
        log('[分享] 企業信息加載成功');
      } else {
        log('[分享] 企業信息加載失敗: ${res.message}');
      }
    } catch (e) {
      log('[分享] 企業信息加載異常: $e');
    }
  }
}
