import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

/// 拍照导入 / 文件导入的统一入口
///
/// 流程：
/// 拍照导入：选择照片 → 手动输入/粘贴行程文字 → 解析 → 预览 → 确认 → 返回 JourneyWork
/// 文件导入：选择 txt/json/html/doc → 读取文本 → 解析 → 预览 → 确认 → 返回 JourneyWork
class ImportSheets {
  ImportSheets._();

  /// 选择文件并读取文本（支持 txt/json/html/doc；二进制/无法解码返回 null 并提示）
  static Future<String?> pickFileText() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json', 'html', 'htm', 'doc'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.single;
      final name = file.name.toLowerCase();

      // 二进制文件（PDF/图片等）无法解析
      if (name.endsWith('.pdf')) {
        Loading.toast('暂不支持 PDF，请改用 txt/Word 文字格式');
        return null;
      }

      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        Loading.toast('文件为空，无法读取');
        return null;
      }

      // 尝试 utf8 解码，失败回退 latin1（尽量保留可读文本）
      String text;
      try {
        text = utf8.decode(bytes);
      } catch (_) {
        text = latin1.decode(bytes);
      }
      if (text.trim().isEmpty) {
        Loading.toast('未读取到文本内容');
        return null;
      }
      return text;
    } catch (e) {
      Loading.toast('读取文件失败: $e');
      return null;
    }
  }

  /// 拍照导入：传入照片路径，返回确认后的工作（null 表示取消）
  static Future<JourneyWork?> photoImport(String imagePath) async {
    final text = await PhotoImportSheet.show(imagePath);
    if (text == null || text.trim().isEmpty) return null;
    return _previewAndConfirm(JourneyImportParser.parse(text));
  }

  /// 文件导入：传入文本内容，返回确认后的工作（null 表示取消）
  static Future<JourneyWork?> fileImport(String text) async {
    return _previewAndConfirm(JourneyImportParser.parse(text));
  }

  static Future<JourneyWork?> _previewAndConfirm(JourneyImportResult result) async {
    final w = result.work;
    if (w == null) {
      Loading.toast(result.warnings.isEmpty ? '无法识别行程信息' : result.warnings.first);
      return null;
    }
    return ImportPreviewSheet.show(w, result.warnings);
  }
}

/// 拍照导入输入面板：显示照片 + 手动输入/粘贴行程文字
class PhotoImportSheet extends StatefulWidget {
  final String imagePath;

  const PhotoImportSheet({super.key, required this.imagePath});

  static Future<String?> show(String imagePath) async {
    return await Get.bottomSheet<String?>(
      PhotoImportSheet(imagePath: imagePath),
      isScrollControlled: true,
    );
  }

  @override
  State<PhotoImportSheet> createState() => _PhotoImportSheetState();
}

class _PhotoImportSheetState extends State<PhotoImportSheet> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
      ),
      padding: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        bottom: bottomPadding > 0 ? bottomPadding : 10.w,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.w),
            Center(
              child: Container(
                width: 36.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ),
            SizedBox(height: 14.w),
            Text(
              '拍照导入',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 12.w),
            // 照片预览
            ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 180.w),
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ),
            ),
            SizedBox(height: 12.w),
            Text(
              '请在下方输入或粘贴行程文字（如：团名、日期、城市、每日行程）',
              style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
            ),
            SizedBox(height: 8.w),
            TextField(
              controller: _textCtrl,
              maxLines: 6,
              style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: '团名: 奥地利7日游\n出发日期: 2026-08-01\n结束日期: 2026-08-07\n\n第1天\n城市: 维也纳\n09:00 美泉宫',
                hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            SizedBox(height: 14.w),
            SizedBox(
              width: double.infinity,
              height: 44.w,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                ),
                onPressed: () {
                  final text = _textCtrl.text.trim();
                  if (text.isEmpty) {
                    Loading.toast('请输入行程文字');
                    return;
                  }
                  Get.back(result: text);
                },
                child: Text(
                  '解析并预览',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8.w),
          ],
        ),
      ),
    );
  }
}

/// 导入预览面板：展示解析结果，确认后返回 JourneyWork
class ImportPreviewSheet extends StatefulWidget {
  final JourneyWork work;
  final List<String> warnings;

  const ImportPreviewSheet({super.key, required this.work, this.warnings = const []});

  static Future<JourneyWork?> show(JourneyWork work, List<String> warnings) async {
    return await Get.bottomSheet<JourneyWork?>(
      ImportPreviewSheet(work: work, warnings: warnings),
      isScrollControlled: true,
    );
  }

  @override
  State<ImportPreviewSheet> createState() => _ImportPreviewSheetState();
}

class _ImportPreviewSheetState extends State<ImportPreviewSheet> {
  late final TextEditingController _titleCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.work.title ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  String get _dateRange {
    final s = widget.work.startDate ?? '';
    final e = widget.work.endDate ?? '';
    if (s.isEmpty && e.isEmpty) return '未识别日期';
    return '$s → $e  ${widget.work.totalDays > 0 ? '共${widget.work.totalDays}天' : ''}'.trim();
  }

  String get _people {
    final parts = <String>[];
    if (widget.work.adultCount != null) parts.add('成人${widget.work.adultCount}');
    if (widget.work.childCount != null) parts.add('儿童${widget.work.childCount}');
    if (parts.isEmpty && widget.work.peopleCount != null) parts.add('共${widget.work.peopleCount}人');
    return parts.isEmpty ? '未识别人数' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final work = widget.work;
    final cities = work.cities.isNotEmpty ? work.cities.join('、') : '未识别城市';
    final days = work.itineraryDays;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.w),
          Container(
            width: 36.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          SizedBox(height: 14.w),
          Text(
            '导入预览',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 12.w),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              children: [
                _Field(
                  label: '团名',
                  child: TextField(
                    controller: _titleCtrl,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.w),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.w),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
                    ),
                  ),
                ),
                _InfoRow(label: '日期', value: _dateRange),
                _InfoRow(label: '人数', value: _people),
                _InfoRow(label: '城市', value: cities),
                if (work.leaderName?.isNotEmpty == true)
                  _InfoRow(label: '领队', value: work.leaderName!),
                // 每日行程
                if (days.isNotEmpty) ...[
                  SizedBox(height: 8.w),
                  Text('每日行程', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                  SizedBox(height: 8.w),
                  for (final d in days) _DayCard(day: d),
                ],
                if (widget.warnings.isNotEmpty) ...[
                  SizedBox(height: 12.w),
                  for (final w in widget.warnings)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 14.sp, color: Colors.amber.shade700),
                          SizedBox(width: 4.w),
                          Expanded(child: Text(w, style: TextStyle(fontSize: 11.sp, color: Colors.amber.shade700))),
                        ],
                      ),
                    ),
                ],
                SizedBox(height: 16.w),
              ],
            ),
          ),
          // 底部按钮
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 10.w),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44.w,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
                      ),
                      child: Text('取消', style: TextStyle(fontSize: 14.sp, color: AppColors.assistantText)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
                      ),
                      onPressed: () {
                        work.title = _titleCtrl.text.trim();
                        Get.back(result: work);
                      },
                      child: Text('确认导入', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.w),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText)),
        SizedBox(height: 6.w),
        child,
        SizedBox(height: 12.w),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText)),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText))),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final ItineraryDay day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final city = day.cityBlocks.map((b) => b.cityName ?? '').where((n) => n.isNotEmpty).join('、');
    return Container(
      margin: EdgeInsets.only(bottom: 8.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '第${day.dayNumber}天',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              if ((day.date ?? '').isNotEmpty) ...[
                SizedBox(width: 6.w),
                Text(day.date!, style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText)),
              ],
              if (city.isNotEmpty) ...[
                SizedBox(width: 6.w),
                Expanded(
                  child: Text('📍 $city', style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText), overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
          for (final block in day.cityBlocks)
            for (final item in block.items)
              Padding(
                padding: EdgeInsets.only(top: 4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40.w,
                      child: Text(item.time ?? '', style: TextStyle(fontSize: 11.sp, color: AppColors.assistantText)),
                    ),
                    Expanded(child: Text(item.title ?? '', style: TextStyle(fontSize: 12.sp, color: AppColors.primaryText))),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
