import 'package:pinyin/pinyin.dart';

/// 城市名 / 检索词统一到简体后再做子串匹配（纯 Dart，不依赖原生 OpenCC 通道）。
String chineseTextToSimplifiedForMatch(String input) {
  final t = input.trim();
  if (t.isEmpty) return '';
  return ChineseHelper.convertToSimplifiedChinese(t);
}

/// 简体检索词转繁体，用于与仍为繁体的 [CityList.name] 做子串兜底匹配。
String chineseTextToTraditionalForMatch(String input) {
  final t = input.trim();
  if (t.isEmpty) return '';
  return ChineseHelper.convertToTraditionalChinese(t);
}
