import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/index.dart';
import 'package:path_provider/path_provider.dart';

import '../guide_detail/widgets/share_preview_dialog.dart' as guide_detail;

class NewsDetailController extends GetxController with ApiMixin {
  int id = 0;

  final _news = News().obs;
  News get news => _news.value;

  final _evaluateCount = 0.obs;
  int get evaluateCount => _evaluateCount.value;

  final evaluateList = <EvaluateList>[].obs;

  /// 分享卡片的 RepaintBoundary key（頁面內隱形卡片，用於截圖生成分享圖）
  final shareCardKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      id = Get.arguments['id'] ?? 0;
    }
    fetchNewsDetail();
    fetchNewsEvaluate();
  }

  onMoreEvaluate() async {
    Get.toNamed(
      AppRoutes.EVALUATE_LIST,
      arguments: {'id': id, 'type': EvaluateListType.news},
    );
  }

  onEvaluate() async {
    await Get.toNamed(
      AppRoutes.EVALUATION,
      arguments: {'id': id, 'type': EvaluationType.news},
    );
    fetchNewsEvaluate();
  }

  onUserTap() async {
    await Get.toNamed(
      AppRoutes.GUIDE_DETAIL,
      arguments: {'id': news.user?.guideId},
    );
  }

  onCityTap() async {
    await Get.toNamed(
      AppRoutes.CITY_DETAIL,
      arguments: {'id': news.user?.cityId},
    );
  }

  // ================================================================
  // 分享資訊（生成分享卡片圖片 → 預覽 → 系統分享）
  // ================================================================
  Future<void> shareNewsCard() async {
    if (news.id == null || news.id == 0) return;

    File? tempFile;
    try {
      Loading.show('正在生成分享圖片...'.tr);
      await _waitInitRender();
      final renderObj =
          shareCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (renderObj == null) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }
      await _awaitPaint(renderObj);
      final image = await renderObj.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'news_share_${DateTime.now().millisecondsSinceEpoch}.png';
      tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      Loading.dismiss();

      final shareText = '${news.title ?? ''} - ${'資訊詳情'.tr}';
      bool shouldDelete = false;

      await Get.dialog(
        guide_detail.SharePreviewDialog(
          imageFile: tempFile,
          shareText: shareText,
          onShareComplete: () => shouldDelete = true,
        ),
        barrierDismissible: true,
      );

      await _cleanupTemp(tempFile, shouldDelete);
    } catch (e, stackTrace) {
      log('shareNewsCard error: $e $stackTrace');
      Loading.dismiss();
      AlertUtils.error('分享失敗'.tr);
      if (tempFile != null) await _cleanupTemp(tempFile, false);
    }
  }

  Future<void> _waitInitRender() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < 3; i++) {
      await SchedulerBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<bool> _awaitPaint(RenderRepaintBoundary renderObj) async {
    const maxRetries = 20;
    for (int i = 0; i < maxRetries; i++) {
      bool needsPaint;
      try {
        needsPaint = renderObj.debugNeedsPaint;
      } catch (_) {
        needsPaint = false;
      }
      if (!needsPaint) return true;
      await Future.delayed(const Duration(milliseconds: 50));
      await SchedulerBinding.instance.endOfFrame;
    }
    return true;
  }

  Future<void> _cleanupTemp(File file, bool shouldDelete) async {
    try {
      await Future.delayed(Duration(seconds: shouldDelete ? 5 : 3));
      if (await file.exists()) await file.delete();
    } catch (e) {
      log('cleanup temp file error: $e');
    }
  }
}

extension NewsDetailApiExt on NewsDetailController {
  fetchNewsDetail() async {
    Loading.show();
    final res = await get(ApiUrl.informationInfo, parameters: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      return;
    }
    _news.value = News.fromJson(res.dataJson);
  }

  fetchNewsEvaluate() async {
    final res = await get(
      ApiUrl.informationEvaluate,
      parameters: {'id': id, 'page': 1, 'limit': 2},
    );
    if (!res.isSuccess) {
      return;
    }
    final list = res.dataJson['list'] as List<dynamic>? ?? [];
    _evaluateCount.value = res.dataJson['total'] as int? ?? 0;
    evaluateList.value = list
        .whereType<Map<String, dynamic>>()
        .map((e) => EvaluateList.fromJson(e))
        .toList();
  }
}
