import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/share_preview_dialog.dart';

class CommonDetailController extends GetxController with ApiMixin {
  final scrollController = ScrollController();
  CommonDetailType type = CommonDetailType.scenic;
  int typeId = 0;
  int cityId = 0;
  int id = 0;

  String get title => type.detailTitle;

  final _bannerIndex = 0.obs;
  int get bannerIndex => _bannerIndex.value;

  final _showPinned = false.obs;
  bool get showPinned => _showPinned.value;

  final _merchantInfo = MerchantInfo().obs;
  MerchantInfo get merchantInfo => _merchantInfo.value;

  final _evaluateCount = 0.obs;
  int get evaluateCount => _evaluateCount.value;

  final evaluateList = <EvaluateList>[].obs;

  final shareCardKey = GlobalKey();

  double get bannerHeight => 235.w;
  double get toolbarHeight => 50.0;
  double get adjustmentOffset => 15.w;

  double get expandedHeight =>
      bannerHeight - ScreenUtil().statusBarHeight - adjustmentOffset;

  double get pinThreshold =>
      bannerHeight -
      ScreenUtil().statusBarHeight -
      adjustmentOffset -
      toolbarHeight;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      typeId = args['type_id'] as int? ?? 0;
      type = CommonDetailTypeExt.fromId(typeId);
      cityId = args['city_id'] as int? ?? 0;
      id = args['id'] as int? ?? 0;
    }

    scrollController.addListener(() {
      final currentOffset = scrollController.offset;
      final shouldPin = currentOffset >= pinThreshold;
      if (_showPinned.value != shouldPin) {
        _showPinned.value = shouldPin;
      }
    });

    onRefresh();
  }

  Future<void> onRefresh() async {
    await _fetchStoreInfo();
    await _fetchEvaluateList();
  }

  void onBannerChanged(int index) {
    _bannerIndex.value = index;
  }

  void makePhoneCall() {
    if (merchantInfo.phone.isEmpty) {
      return;
    }
    try {
      launchUrl(Uri.parse('tel:${merchantInfo.phone}'));
    } catch (e) {
      log(e.toString());
    }
  }

  void sendEmail() {}

  void openWebsite() {}

  void viewAddress() {
    openAddressMap(
      name: merchantInfo.name,
      address: merchantInfo.address,
      latitude: merchantInfo.latitude,
      longitude: merchantInfo.longitude,
    );
  }

  void sendMessage() async {
    final conversation = await TIMStore.to.createOrGetConversation(
      userID: merchantInfo.userNumber,
    );
    if (conversation == null) {
      AlertUtils.error('創建會話失敗'.tr);
      return;
    }
    Get.toNamed(AppRoutes.CHAT, arguments: {'conversation': conversation});
  }

  void openCompany() async {}

  onFollowStore() async {
    Loading.show();
    final res = await post(
      ApiUrl.followShop,
      data: {
        'content_id': merchantInfo.id,
        'follow': merchantInfo.isFollow == 1 ? 0 : 1,
      },
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    _merchantInfo.update((val) {
      val?.isFollow = merchantInfo.isFollow == 1 ? 0 : 1;
    });
    if (merchantInfo.isFollow == 1) {
      Loading.success('關注成功'.tr);
    } else {
      Loading.success('已取消關注'.tr);
    }
  }

  void makeReservation() async {
    if (!UserStore.to.isLogin) {
      UserStore.to.showLogin();
      return;
    }
    MerchantShopType? shopType;
    switch (type) {
      case CommonDetailType.scenic:
        shopType = MerchantShopType.scenic;
        break;
      case CommonDetailType.restaurant:
        shopType = MerchantShopType.restaurant;
        break;
      case CommonDetailType.shopping:
        shopType = MerchantShopType.shopping;
        break;
      case CommonDetailType.hotel:
        shopType = MerchantShopType.hotel;
        break;
      case CommonDetailType.ticket:
        shopType = MerchantShopType.ticket;
        break;
      default:
        break;
    }
    if (shopType == null) {
      return;
    }
    await Get.toNamed(
      AppRoutes.BOOKING_MERCHANT,
      arguments: {'type': shopType, 'info': merchantInfo},
    );
  }

  void openComment() async {
    await Get.toNamed(
      AppRoutes.EVALUATION,
      arguments: {
        'id': id,
        'type': EvaluationType.merchant,
        'title': merchantInfo.name,
      },
    );
    _fetchEvaluateList();
  }

  onCityTap() {
    final previousRoute = Get.previousRoute;
    if (previousRoute == AppRoutes.CITY_DETAIL) {
      Get.back();
    } else {
      Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': cityId});
    }
  }

  onMoreComment() {
    Get.toNamed(
      AppRoutes.EVALUATE_LIST,
      arguments: {
        'id': id,
        'type': EvaluateListType.merchant,
        'cityId': cityId,
      },
    );
  }

  Future<void> shareMerchantCard() async {
    if (merchantInfo.id == null) return;

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
          'merchant_share_${DateTime.now().millisecondsSinceEpoch}.png';
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
      final currentMerchantInfo = merchantInfo;
      if (currentMerchantInfo.id == null) {
        log('[分享] merchantInfo 為 null，無法生成分享文本');
        return false;
      }

      final shareText =
          '${currentMerchantInfo.name ?? ''} - ${type.detailTitle}';
      bool shouldDelete = false;

      await Get.dialog(
        MerchantSharePreviewDialog(
          imageFile: file,
          shareText: shareText,
          onShareComplete: () {
            shouldDelete = true;
          },
        ),
        barrierDismissible: true,
      );

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

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

extension on CommonDetailController {
  _fetchStoreInfo() async {
    Loading.show();
    final res = await get(
      ApiUrl.cityContent,
      parameters: {'id': id, 'city_id': cityId, 'type_id': typeId},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      await AlertUtils.error(res.message);
      Get.back();
      return;
    }
    _merchantInfo.value = MerchantInfo.fromJson(res.dataJson);
  }

  _fetchEvaluateList() async {
    final res = await get(
      ApiUrl.contentEvaluate,
      parameters: {'id': id, 'city_id': cityId, 'page': 1, 'limit': 2},
    );
    if (!res.isSuccess) {
      return;
    }

    final list = res.dataJson['list'] as List<dynamic>;
    _evaluateCount.value = res.dataJson['total'] as int? ?? 0;
    evaluateList.value = list.map((e) => EvaluateList.fromJson(e)).toList();
  }
}
