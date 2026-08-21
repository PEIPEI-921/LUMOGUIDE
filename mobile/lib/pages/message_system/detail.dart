import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MessageSystemDetailPage extends StatefulWidget {
  const MessageSystemDetailPage({super.key, required this.model});
  final MessageSystemModel model;

  @override
  State<MessageSystemDetailPage> createState() =>
      _MessageSystemDetailPageState();
}

class _MessageSystemDetailPageState extends State<MessageSystemDetailPage> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return IScaffold(
      title: '消息詳情'.tr,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.w),
        children: [
          // ---- 标题行 ----
          Row(
            children: [
              Text(
                model.title ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ).expanded(),
              Text(
                model.time ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryText.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            thickness: 0.5,
            color: AppColors.primaryText.withValues(alpha: 0.1),
          ),
          // ---- 正文内容（城市/分类/内容解析为可点击按钮）----
          _buildContent(model),
        ],
      ).decorated(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
    );
  }

  /// 构建正文：把内容中的（城市）（分类）（内容）解析成可点击的按钮，
  /// 去掉括号；会员到期消息在末尾附「前往會員中心」按钮。
  Widget _buildContent(MessageSystemModel model) {
    final content = model.content ?? '';
    const TextStyle baseStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF162539), // AppColors.primaryText
      height: 1.6,
    );

    // 会员到期：纯文本 + 「前往會員中心」按钮
    if (model.contentType == 'membership') {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Text(content, style: baseStyle),
          _ActionChip(
            label: '前往會員中心'.tr,
            onTap: () => Get.toNamed(AppRoutes.MEMBER_CENTER),
          ),
        ],
      );
    }

    // 解析（xxx）模式：第一个 = 城市，第二个 = 分类，第三个 = 内容名
    final regex = RegExp(r'（([^（）]*)）');
    final matches = regex.allMatches(content).toList();
    if (matches.isEmpty) {
      return Text(content, style: baseStyle);
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      if (m.start > cursor) {
        spans.add(TextSpan(
          text: _stripParens(content.substring(cursor, m.start)),
          style: baseStyle,
        ));
      }
      final label = m.group(1) ?? '';
      if (label.isNotEmpty) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildChip(label, i, model),
        ));
      }
      cursor = m.end;
    }
    if (cursor < content.length) {
      spans.add(TextSpan(
        text: _stripParens(content.substring(cursor)),
        style: baseStyle,
      ));
    }

    return Text.rich(TextSpan(children: spans), style: baseStyle);
  }

  /// 解析出的括号内容 → 可点击按钮（城市/分类/内容名）
  Widget _buildChip(String label, int index, MessageSystemModel model) {
    VoidCallback? onTap;
    // 第一个括号 = 城市名 → 城市详情
    if (index == 0) {
      final cityId = model.contentType == 'city'
          ? model.contentId
          : model.cityId;
      if (cityId != null && cityId > 0) {
        onTap = () =>
            Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': cityId});
      }
    } else {
      // 分类 / 内容名 → 内容详情（需 content_id + city_id + type_id）
      final contentId = model.contentId;
      final cityId = model.cityId;
      final typeId = model.cityContentType;
      if (model.contentType == 'city_content' &&
          contentId != null &&
          contentId > 0 &&
          cityId != null &&
          cityId > 0 &&
          typeId != null &&
          typeId > 0) {
        onTap = () => Get.toNamed(AppRoutes.COMMON_DETAIL, arguments: {
          'id': contentId,
          'city_id': cityId,
          'type_id': typeId,
        });
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 0.6,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 去掉文本中残留的（ ）字符
  String _stripParens(String text) => text.replaceAll(RegExp(r'[（）]'), '');
}

/// 行动按钮（会员中心跳转等）
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: Colors.white),
            ),
            4.w.horizontalSpace,
            Icon(Icons.arrow_forward_ios,
                size: 11.sp, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
