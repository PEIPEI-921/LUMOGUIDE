import 'package:flutter/gestures.dart';
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
  TapGestureRecognizer? _cityTapRecognizer;
  TapGestureRecognizer? _detailTapRecognizer;

  @override
  void dispose() {
    _cityTapRecognizer?.dispose();
    _detailTapRecognizer?.dispose();
    super.dispose();
  }

  void _onTapCityName() {
    final model = widget.model;
    final cityId = model.contentId;
    if (cityId != null && cityId > 0 && model.contentType == 'city') {
      Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': cityId});
    }
  }

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
          5.w.verticalSpace,
          // ---- 简要描述 ----
          if (model.desc?.isNotEmpty == true)
            Text(
              model.desc ?? '',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14.sp,
              ),
            ),
          Divider(
            height: 20,
            thickness: 0.5,
            color: AppColors.primaryText.withValues(alpha: 0.1),
          ),
          // ---- 正文内容（城市名高亮 + 可点击）----
          _buildContent(model),
        ],
      ).decorated(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
    );
  }

  /// 构建正文内容：城市名以 #666FFF 高亮显示，可点击跳转城市详情
  Widget _buildContent(MessageSystemModel model) {
    final content = model.content;
    final cityName = model.cityName;
    final cityNameEn = model.cityNameEn;
    final hasLinkedContent = model.hasLinkedContent;

    // 拼接城市名展示文本：「首爾 (Seoul)」
    final cityDisplay = _buildCityDisplay(cityName, cityNameEn);

    // 基础样式
    const TextStyle baseStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF162539), // AppColors.primaryText
      height: 1.5,
    );

    const TextStyle cityStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF666FFF), // 主题紫色
      height: 1.5,
    );

    // 内容富文本：如果包含城市名则高亮
    List<InlineSpan> contentSpans = [];

    if (cityName != null && cityName.isNotEmpty && content != null) {
      // 在正文中定位城市名，拆分为前、城市名、后三段
      _buildContentWithCity(content, cityName, cityDisplay, baseStyle,
          cityStyle, contentSpans);
    } else if (content?.isNotEmpty == true) {
      // 无城市名信息，纯文本显示
      contentSpans.add(TextSpan(text: content, style: baseStyle));
    }

    // 添加操作链接
    // 当城市名已高亮可点击时（contentType == 'city'），不再重复显示链接
    final showDetailLink = hasLinkedContent &&
        !(cityName != null && cityName.isNotEmpty && model.contentType == 'city');
    if (showDetailLink) {
      if (contentSpans.isNotEmpty) {
        contentSpans.add(const TextSpan(text: '  '));
      }
      _detailTapRecognizer = TapGestureRecognizer()
        ..onTap = () {
          model.openLinkedContent();
        };

      // 會員到期 → 鏈接文字用「前往會員中心」；其他類型 → 「查看詳情」
      final isMembership = model.contentType == 'membership';
      final linkText = isMembership ? '前往會員中心'.tr : '查看詳情'.tr;

      contentSpans.add(TextSpan(
        text: linkText,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF666FFF),
          height: 1.5,
        ),
        recognizer: _detailTapRecognizer,
      ));
      contentSpans.add(const WidgetSpan(
        child: Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF666FFF)),
        ),
      ));
    }

    return Text.rich(
      TextSpan(children: contentSpans),
    );
  }

  /// 在正文中定位城市名，拆分为前/中/后三段构建 TextSpan
  void _buildContentWithCity(
    String content,
    String cityName,
    String cityDisplay,
    TextStyle baseStyle,
    TextStyle cityStyle,
    List<InlineSpan> spans,
  ) {
    // 先尝试匹配「城市名 (英文名)」格式
    final fullPattern = cityDisplay;
    final fullIndex = content.indexOf(fullPattern);
    if (fullIndex >= 0) {
      // 前半部分
      if (fullIndex > 0) {
        spans.add(TextSpan(
            text: content.substring(0, fullIndex), style: baseStyle));
      }
      // 城市名（高亮 + 可点击）
      _addCitySpan(fullPattern, cityStyle, spans);
      // 后半部分
      if (fullIndex + fullPattern.length < content.length) {
        spans.add(TextSpan(
            text: content.substring(fullIndex + fullPattern.length),
            style: baseStyle));
      }
      return;
    }

    // 回退：仅匹配中文城市名
    final cnIndex = content.indexOf(cityName);
    if (cnIndex >= 0) {
      if (cnIndex > 0) {
        spans.add(
            TextSpan(text: content.substring(0, cnIndex), style: baseStyle));
      }
      final displayText =
          cityDisplay != cityName ? cityDisplay : cityName;
      _addCitySpan(displayText, cityStyle, spans);
      if (cnIndex + cityName.length < content.length) {
        spans.add(TextSpan(
            text: content.substring(cnIndex + cityName.length),
            style: baseStyle));
      }
      return;
    }

    // 完全匹配不到，纯文本
    spans.add(TextSpan(text: content, style: baseStyle));
  }

  /// 添加城市名 TextSpan（#666FFF 高亮 + 点击跳转城市详情）
  void _addCitySpan(
      String text, TextStyle cityStyle, List<InlineSpan> spans) {
    _cityTapRecognizer = TapGestureRecognizer()
      ..onTap = _onTapCityName;
    spans.add(TextSpan(
      text: text,
      style: cityStyle,
      recognizer: _cityTapRecognizer,
    ));
  }

  /// 构建城市名展示文本：「首爾 (Seoul)」
  String _buildCityDisplay(String? cityName, String? cityNameEn) {
    if (cityName == null || cityName.isEmpty) return '';
    if (cityNameEn != null && cityNameEn.isNotEmpty) {
      return '$cityName ($cityNameEn)';
    }
    return cityName;
  }
}
