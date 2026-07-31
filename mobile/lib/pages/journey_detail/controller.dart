import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'widgets/client_itinerary_preview.dart';
import 'widgets/format_picker_dialog.dart';
import 'widgets/template_save_dialog.dart';

class JourneyDetailController extends GetxController with ApiMixin {
  final work = Rxn<JourneyWork>();
  final activeTab = 0.obs;
  int workId = 0;

  @override
  void onInit() {
    super.onInit();
    workId = Get.arguments?['id'] as int? ?? 0;
    _loadDetail(workId);
  }

  void _loadDetail(int? id) {
    // 优先使用传入的 work 对象
    final w = Get.arguments?['work'] as JourneyWork?;
    if (w != null) {
      work.value = w;
      return;
    }
    // 兜底：从 API 获取
    if (id != null) {
      _fetchFromApi(id);
    }
  }

  Future<void> _fetchFromApi(int id) async {
    final res = await get(ApiUrl.userJourneyDetail, parameters: {'id': id});
    if (res.isSuccess && res.dataJson != null) {
      work.value = JourneyWork.fromJson(res.dataJson!);
    }
  }

  void onEdit() {
    Get.toNamed(AppRoutes.JOURNEY_EDITOR, arguments: {
      'work': work.value,
    })?.then((_) => _loadDetail(work.value?.id));
  }

  // ================================================================
  // 删除工作
  // ================================================================
  void onDeleteWork() async {
    final confirm = await AlertUtils.show(
      title: '确认删除',
      content: '删除后无法恢复，确定要删除这个工作吗？',
      confirmText: '删除',
      cancelText: '取消',
    );
    if (confirm != true) return;

    Loading.show();
    final res = await post(ApiUrl.userJourneyDelete, data: {'id': workId});
    Loading.dismiss();
    if (res.isSuccess) {
      Loading.success('删除成功');
      Get.back(result: true);
    } else {
      Loading.error(res.message.isNotEmpty ? res.message : '删除失败');
    }
  }

  // ================================================================
  // 行程城市 / 内容点击跳转
  // ================================================================
  void onTapCityBlock(DayCityBlock block) {
    if (block.cityId != null && block.cityId! > 0) {
      Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': block.cityId});
    } else {
      Get.toNamed(AppRoutes.PUBLISH_CITY);
    }
  }

  void onTapItineraryItem(ItineraryItem item, int? cityId) {
    // 有 resourceId → 跳转对应详情页
    if (item.resourceId != null && item.resourceId! > 0 && item.resourceType != null) {
      final typeId = _mapResourceTypeToCommonDetailType(item.resourceType!);
      if (typeId != null) {
        Get.toNamed(AppRoutes.COMMON_DETAIL, arguments: {
          'id': item.resourceId,
          'city_id': cityId ?? 0,
          'type_id': typeId,
        });
        return;
      }
    }
    // 无 resourceId → 跳转对应发布页
    _navigateToPublishPage(item.resourceType ?? item.type ?? '');
  }

  int? _mapResourceTypeToCommonDetailType(String resourceType) {
    switch (resourceType) {
      case 'attraction':
        return CommonDetailType.scenic.id;
      case 'activity':
        return CommonDetailType.activity.id;
      case 'restaurant':
      case 'meal':
        return CommonDetailType.restaurant.id;
      case 'shopping':
        return CommonDetailType.shopping.id;
      case 'transport':
        return CommonDetailType.traffic.id;
      case 'hotel':
        return CommonDetailType.hotel.id;
      default:
        return null;
    }
  }

  void _navigateToPublishPage(String type) {
    switch (type) {
      case 'attraction':
        Get.toNamed(AppRoutes.PUBLISH_ATTRACTION);
        break;
      case 'activity':
        Get.toNamed(AppRoutes.PUBLISH_ACTIVITY);
        break;
      case 'restaurant':
      case 'meal':
        Get.toNamed(AppRoutes.PUBLISH_FACILITY);
        break;
      case 'shopping':
        Get.toNamed(AppRoutes.PUBLISH_FACILITY);
        break;
      case 'transport':
        Get.toNamed(AppRoutes.PUBLISH_TRANSPORTATION);
        break;
      default:
        break;
    }
  }

  // ================================================================
  // 保存为模板
  // ================================================================
  void onSaveAsTemplate() {
    final w = work.value;
    if (w == null) return;

    TemplateSaveDialog.show(
      w.title ?? '',
      (name) => _doSaveAsTemplate(name, w),
    );
  }

  Future<void> _doSaveAsTemplate(String name, JourneyWork w) async {
    final template = JourneyTemplate(
      title: name,
      region: w.region,
      cities: List.from(w.cities),
      defaultDays: w.totalDays,
      defaultPeopleCount: w.peopleCount,
      itineraryDays: w.itineraryDays.map((d) => d.toJson()).toList(),
      hotels: w.hotels.map((h) => h.toJson()).toList(),
      useCount: 0,
      sourceWorkId: w.id,
      createdAt: DateTime.now().toIso8601String(),
    );

    // 从本地读取已有模板列表
    final storage = StorageService.to;
    final existingJson = storage.getString(STORAGE_JOURNEY_TEMPLATES_KEY);
    final List<dynamic> list =
        existingJson.isNotEmpty ? jsonDecode(existingJson) : [];

    // 追加并写回
    list.add(template.toJson());
    await storage.setString(STORAGE_JOURNEY_TEMPLATES_KEY, jsonEncode(list));

    Loading.success('模板保存成功');
  }

  // ================================================================
  // 生成客户行程
  // ================================================================
  void onGenerateClientItinerary() {
    final w = work.value;
    if (w == null) return;

    FormatPickerDialog.show().then((format) {
      if (format == null) return;
      _showPreviewAndShare(w, format);
    });
  }

  Future<void> _showPreviewAndShare(
    JourneyWork w,
    ClientItineraryFormat format,
  ) async {
    final previewKey = GlobalKey();
    final previewWidget = ClientItineraryPreview(
      work: w,
      repaintKey: previewKey,
    );

    final confirmed = await Get.dialog<bool>(
      _PreviewDialog(
        previewWidget: previewWidget,
        format: format,
      ),
    );

    if (confirmed != true) return;

    switch (format) {
      case ClientItineraryFormat.image:
        await _shareAsImage(previewKey);
        break;
      case ClientItineraryFormat.pdf:
        await _shareAsPdf(w);
        break;
      case ClientItineraryFormat.word:
        await _shareAsWord(w);
        break;
    }
  }

  // --- 图片分享 ---
  Future<void> _shareAsImage(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Loading.error('生成失败');
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) {
        Loading.error('生成失败');
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/client_itinerary_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)]);
    } catch (e) {
      Loading.error('生成失败: $e');
    }
  }

  // --- PDF 分享 ---
  Future<void> _shareAsPdf(JourneyWork w) async {
    Loading.show();
    try {
      final pdfDoc = await _buildPdfDocument(w);
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/client_itinerary_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdfDoc.save());
      Loading.dismiss();
      await Share.shareXFiles([XFile(path, mimeType: 'application/pdf')]);
    } catch (e) {
      Loading.dismiss();
      Loading.error('PDF 生成失败: $e');
    }
  }

  Future<pw.Document> _buildPdfDocument(JourneyWork w) async {
    final logoBytes =
        (await rootBundle.load(Assets.iconLogo)).buffer.asUint8List();
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Stack(children: [
          // 主内容
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(children: [
                pw.Image(pw.MemoryImage(logoBytes), height: 22),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Text(w.title ?? '',
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#666FFF'))),
                ),
              ]),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColor.fromHex('#666FFF33')),
              pw.SizedBox(height: 10),
              // 每日行程
              ...w.itineraryDays.expand((day) => [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#666FFF14'),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        '第${day.dayNumber}天  ${day.date ?? ''}',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#666FFF')),
                      ),
                    ),
                    if (day.theme?.isNotEmpty == true)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 3),
                        child: pw.Text(day.theme!,
                            style: pw.TextStyle(
                                fontSize: 11,
                                color: const PdfColor(0.4, 0.4, 0.4))),
                      ),
                    pw.SizedBox(height: 6),
                    // 每个城市块
                    ...day.cityBlocks.expand((block) => [
                      if (block.cityName?.isNotEmpty == true)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
                          child: pw.Row(children: [
                            pw.Container(
                              width: 6, height: 6,
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#666FFF'),
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            pw.Text(block.cityName!,
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#666FFF'))),
                          ]),
                        ),
                      ...block.items.map((item) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: 48,
                                  child: pw.Text(item.time ?? '',
                                      style: pw.TextStyle(
                                          fontSize: 9,
                                          color: PdfColor.fromHex('#666FFF'),
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Container(
                                  width: 1,
                                  height: 28,
                                  color: PdfColor.fromHex('#666FFF26'),
                                ),
                                pw.SizedBox(width: 6),
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(item.title ?? '',
                                          style: pw.TextStyle(
                                              fontSize: 11,
                                              fontWeight: pw.FontWeight.bold)),
                                      if (item.description?.isNotEmpty == true)
                                        pw.Text(item.description!,
                                            style: const pw.TextStyle(
                                                fontSize: 9,
                                                color: const PdfColor(
                                                    0.4, 0.4, 0.4))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ]),
                    if (day.hotelName?.isNotEmpty == true)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Row(children: [
                          pw.SizedBox(width: 48),
                          pw.Container(width: 1),
                          pw.SizedBox(width: 6),
                          pw.Text(day.hotelName!,
                              style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: const PdfColor(0.6, 0.6, 0.6))),
                        ]),
                      ),
                    pw.SizedBox(height: 8),
                  ]),
              pw.SizedBox(height: 4),
              pw.Divider(color: PdfColor.fromHex('#666FFF33')),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  '生成日期: ${_todayStr()}',
                  style: const pw.TextStyle(
                      fontSize: 9, color: const PdfColor(0.6, 0.6, 0.6)),
                ),
              ),
            ],
          ),
          // 水印 — 居中倾斜 LUMO
          pw.Center(
            child: pw.Transform.rotate(
              angle: -45 / 57.3,
              child: pw.Opacity(
                opacity: 0.08,
                child: pw.Text('LUMO',
                    style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#666FFF'),
                        letterSpacing: 6)),
              ),
            ),
          ),
        ]),
      ),
    );

    return doc;
  }

  // --- Word/HTML 分享 ---
  Future<void> _shareAsWord(JourneyWork w) async {
    Loading.show();
    try {
      final logoBytes =
          (await rootBundle.load(Assets.iconLogo)).buffer.asUint8List();
      final logoBase64 = base64Encode(logoBytes);
      final html = _buildHtmlDocument(w, logoBase64);

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/client_itinerary_${DateTime.now().millisecondsSinceEpoch}.doc';
      await File(path).writeAsString(html);
      Loading.dismiss();
      await Share.shareXFiles(
          [XFile(path, mimeType: 'application/msword')]);
    } catch (e) {
      Loading.dismiss();
      Loading.error('Word 生成失败: $e');
    }
  }

  String _buildHtmlDocument(JourneyWork w, String logoBase64) {
    final daysHtml = w.itineraryDays.map((day) {
      final blocksHtml = day.cityBlocks.map((block) {
        final cityHeader = block.cityName?.isNotEmpty == true
            ? '<div class="city-block-header">📍 ${block.cityName}</div>'
            : '';
        final itemsHtml = block.items.map((item) => '''
        <div class="item-row">
          <div class="item-time">${item.time ?? ''}</div>
          <div class="item-line"></div>
          <div class="item-content">
            <div class="item-title">${item.title ?? ''}</div>
            ${item.description?.isNotEmpty == true ? '<div class="item-desc">${item.description}</div>' : ''}
          </div>
        </div>
      ''').join();
        return '$cityHeader$itemsHtml';
      }).join();

      final hotelHtml = day.hotelName?.isNotEmpty == true
          ? '<div class="hotel">🏨 ${day.hotelName}</div>'
          : '';

      return '''
        <div class="day-header">
          <span class="day-num">第${day.dayNumber}天</span>
          <span class="day-date">${day.date ?? ''}</span>
        </div>
        ${day.theme?.isNotEmpty == true ? '<div class="day-theme">${day.theme}</div>' : ''}
        $blocksHtml
        $hotelHtml
      ''';
    }).join();

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${w.title ?? ''} - LUMOGUIDE</title>
  <style>
    body { font-family: 'PingFang SC', -apple-system, sans-serif; padding: 20px; color: #162539; }
    .header { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
    .header img { height: 28px; }
    .header .title { font-size: 18px; font-weight: bold; color: #666FFF; }
    .divider { border-top: 1px solid #666FFF33; margin: 12px 0; }
    .day-header { background: #666FFF10; padding: 6px 10px; border-radius: 8px; margin: 12px 0 6px; }
    .day-num { color: #666FFF; font-weight: bold; font-size: 13px; }
    .day-date { color: #999; font-size: 12px; margin-left: 8px; }
    .day-theme { font-size: 13px; color: #666; margin-bottom: 6px; }
    .city-block-header { font-size: 12px; color: #666FFF; font-weight: 600; margin: 8px 0 4px 0; padding-left: 8px; border-left: 3px solid #666FFF; }
    .item-row { display: flex; margin-bottom: 6px; align-items: flex-start; }
    .item-time { width: 60px; color: #666FFF; font-size: 12px; font-weight: 500; flex-shrink: 0; }
    .item-line { width: 2px; min-height: 30px; background: #666FFF26; margin-right: 10px; flex-shrink: 0; }
    .item-content .item-title { font-weight: 600; font-size: 14px; }
    .item-content .item-desc { font-size: 12px; color: #666; margin-top: 2px; }
    .hotel { font-size: 12px; color: #999; margin-top: 6px; padding-left: 72px; }
    .footer { font-size: 12px; color: #999; margin-top: 20px; text-align: center; }
    .watermark { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%) rotate(-45deg); opacity: 0.08; pointer-events: none; z-index: 9999; }
    .watermark .wm-text { font-size: 36px; color: #666FFF; font-weight: 900; letter-spacing: 6px; }
  </style>
</head>
<body>
  <div class="watermark">
    <div class="wm-text">LUMO</div>
  </div>

  <div class="header">
    <img src="data:image/png;base64,$logoBase64">
    <div class="title">${w.title ?? ''}</div>
  </div>

  <div class="divider"></div>

  $daysHtml

  <div class="divider"></div>
  <div class="footer">生成日期: ${_todayStr()}</div>
</body>
</html>
    ''';
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void onViewBooking() {
    Get.toNamed(AppRoutes.USER_BOOKING_MANAGER);
  }

  void onViewCity(String city) {
    Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'city': city});
  }
}

/// 预览弹窗
class _PreviewDialog extends StatelessWidget {
  final Widget previewWidget;
  final ClientItineraryFormat format;

  const _PreviewDialog({required this.previewWidget, required this.format});

  String get formatLabel {
    switch (format) {
      case ClientItineraryFormat.image:
        return '图片';
      case ClientItineraryFormat.pdf:
        return 'PDF';
      case ClientItineraryFormat.word:
        return 'Word 文档';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundBlue,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.w)),
            ),
            child: Row(children: [
              Icon(Icons.remove_red_eye_outlined,
                  size: 16.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                '预览 ($formatLabel)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: 18.sp, color: AppColors.assistantText),
              ),
            ]),
          ),
          // 预览内容（可滚动）
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(14.w),
              child: previewWidget,
            ),
          ),
          // 按钮栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 14.sp, color: AppColors.assistantText),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.w)),
                    padding: EdgeInsets.symmetric(vertical: 12.w),
                  ),
                  child: Text(
                    '分享',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
