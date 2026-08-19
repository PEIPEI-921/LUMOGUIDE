import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

/// 模板选择底部面板
class TemplatePickerSheet extends StatefulWidget {
  const TemplatePickerSheet({super.key});

  /// 弹出模板选择面板，返回选中的模板（null 表示取消）
  static Future<JourneyTemplate?> show() async {
    return await Get.bottomSheet<JourneyTemplate?>(
      const TemplatePickerSheet(),
      isScrollControlled: true,
    );
  }

  @override
  State<TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<TemplatePickerSheet> {
  List<JourneyTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    try {
      final storage = StorageService.to;
      final json = storage.getString(STORAGE_JOURNEY_TEMPLATES_KEY);
      if (json.isEmpty) {
        _templates = [];
        return;
      }
      final list = jsonDecode(json) as List<dynamic>;
      _templates = list.map((e) => JourneyTemplate.fromJson(e)).toList();
    } catch (_) {
      _templates = [];
    }
  }

  void _onDelete(JourneyTemplate template, int index) {
    Get.defaultDialog(
      title: '删除模板',
      middleText: '确定删除模板「${template.title}」？',
      textConfirm: '删除',
      textCancel: '取消',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      cancelTextColor: AppColors.assistantText,
      onConfirm: () {
        Get.back(); // 关闭对话框
        try {
          final storage = StorageService.to;
          final json = storage.getString(STORAGE_JOURNEY_TEMPLATES_KEY);
          if (json.isEmpty) return;
          final list = jsonDecode(json) as List<dynamic>;
          list.removeAt(index);
          storage.setString(STORAGE_JOURNEY_TEMPLATES_KEY, jsonEncode(list));
          Loading.success('已删除');
          setState(() => _loadTemplates());
        } catch (_) {
          Loading.error('删除失败');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
      ),
      child: Column(children: [
        // 拖拽条 + 标题
        SizedBox(height: 10.w),
        Container(
            width: 36.w,
            height: 4.w,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.w))),
        SizedBox(height: 14.w),
        Text(
          '我的模板',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText),
        ),
        SizedBox(height: 4.w),
        Text(
          '选择模板快速创建行程',
          style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
        ),
        SizedBox(height: 12.w),
        // 模板列表
        if (_templates.isEmpty)
          Expanded(
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.bookmark_outline,
                    size: 48.sp, color: Colors.grey.shade300),
                SizedBox(height: 12.w),
                Text('暂无模板',
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.assistantText)),
                SizedBox(height: 4.w),
                Text('请先在行程详情中保存模板',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
              ]),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              itemCount: _templates.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.w),
              itemBuilder: (_, i) => _TemplateCard(
                template: _templates[i],
                onTap: () => Get.back(result: _templates[i]),
                onDelete: () => _onDelete(_templates[i], i),
              ),
            ),
          ),
      ]),
    );
  }
}

/// 模板卡片
class _TemplateCard extends StatelessWidget {
  final JourneyTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cities =
        template.cities.isNotEmpty ? template.cities.join(' · ') : '未设置城市';
    final days = template.defaultDays ?? 0;
    final createdAt = template.createdAt ?? '';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.w,
              offset: Offset(0, 2.w),
            ),
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 图标
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child:
                Icon(Icons.bookmark, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.title,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 6.w),
                // tags
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.w,
                  children: [
                    if (template.region?.isNotEmpty == true)
                      _Tag(text: template.region!, color: AppColors.primary),
                    if (days > 0)
                      _Tag(text: '$days天', color: AppColors.jadeGreen),
                    _Tag(
                        text: '使用${template.useCount}次',
                        color: AppColors.assistantText),
                  ],
                ),
                SizedBox(height: 6.w),
                Text(cities,
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.assistantText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (createdAt.isNotEmpty) ...[
                  SizedBox(height: 4.w),
                  Text('创建于 $createdAt',
                      style: TextStyle(
                          fontSize: 10.sp, color: Colors.grey.shade400)),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // 使用按钮
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Text('使用',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10.sp, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
