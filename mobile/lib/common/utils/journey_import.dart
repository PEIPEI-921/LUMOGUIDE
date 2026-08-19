import 'dart:convert';

import '../models/journey_work.dart';
import '../models/journey_template.dart';

/// 行程导入解析结果
class JourneyImportResult {
  final JourneyWork? work;
  final List<String> warnings;

  /// 解析前的原始文本预览（用于展示）
  final String rawPreview;

  JourneyImportResult({
    this.work,
    this.warnings = const [],
    this.rawPreview = '',
  });

  bool get success => work != null;
}

/// 行程导入解析器
///
/// 支持三种来源：
/// 1. **JSON** —— 本 App 的 JourneyWork / JourneyTemplate 数据格式
/// 2. **HTML** —— 本 App 导出的 Word（本质是 HTML），自动剥离标签后按文本解析
/// 3. **纯文本** —— 结构化行程文本，形如：
///    ```
///    团名: 奥地利7日游
///    出发日期: 2026-08-01
///    结束日期: 2026-08-07
///    成人: 8
///    领队: 张三
///
///    第1天 (8/1)
///    城市: 维也纳
///    09:00 美泉宫
///    12:00 午餐
///    ```
class JourneyImportParser {
  JourneyImportParser._();

  /// 归一化：去空格（含全角）、转小写，便于别名匹配
  static String _norm(String s) =>
      s.replaceAll(' ', '').replaceAll('　', '').toLowerCase();

  static bool _any(String key, List<String> candidates) =>
      candidates.any((c) => _norm(c) == key);

  /// 取字符串中的第一个整数（如 "8人" → 8）
  static int? _firstInt(String s) {
    final m = RegExp(r'\d+').firstMatch(s);
    if (m == null) return null;
    return int.tryParse(m.group(0)!);
  }

  static String _fmt(int y, int mo, int d) =>
      '$y-${mo.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  /// 解析日期为 yyyy-MM-dd；无法解析返回 null
  static String? _normalizeDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final m1 = RegExp(r'(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})').firstMatch(s);
    if (m1 != null) {
      return _fmt(int.parse(m1.group(1)!), int.parse(m1.group(2)!), int.parse(m1.group(3)!));
    }
    final m2 = RegExp(r'(\d{4})年(\d{1,2})月(\d{1,2})日?').firstMatch(s);
    if (m2 != null) {
      return _fmt(int.parse(m2.group(1)!), int.parse(m2.group(2)!), int.parse(m2.group(3)!));
    }
    final m3 = RegExp(r'(\d{1,2})月(\d{1,2})日?').firstMatch(s);
    if (m3 != null) {
      return _fmt(DateTime.now().year, int.parse(m3.group(1)!), int.parse(m3.group(2)!));
    }
    final m4 = RegExp(r'(\d{1,2})[-/.](\d{1,2})').firstMatch(s);
    if (m4 != null) {
      return _fmt(DateTime.now().year, int.parse(m4.group(1)!), int.parse(m4.group(2)!));
    }
    return null;
  }

  /// 预览前若干字符
  static String _preview(String s) {
    final one = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return one.length <= 200 ? one : '${one.substring(0, 200)}…';
  }

  /// 是否含有可用的行程内容
  static bool _workHasContent(JourneyWork w) {
    return (w.title ?? '').isNotEmpty ||
        (w.startDate ?? '').isNotEmpty ||
        (w.endDate ?? '').isNotEmpty ||
        w.cities.isNotEmpty ||
        w.itineraryDays.any((d) =>
            d.cityBlocks.any((b) => (b.cityName?.isNotEmpty == true) || b.items.isNotEmpty)) ||
        (w.description ?? '').isNotEmpty;
  }

  /// 剥离 HTML 标签为纯文本
  static String _stripHtml(String s) {
    var out = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    out = out.replaceAll(RegExp(r'<(br|BR)\s*/?>'), '\n');
    out = out.replaceAll(RegExp(r'</(p|div|li|tr|h[1-6])>'), '\n');
    out = out.replaceAll(RegExp(r'<[^>]+>'), '');
    out = out.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    out = out.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return out.trim();
  }

  /// 拆分键值行；时间行（如 "09:00 ..."）不作为键值
  static (String, String)? _splitKeyValue(String line) {
    final idx = line.indexOf(':');
    final idxCn = line.indexOf('：');
    int sep;
    if (idx == -1 && idxCn == -1) return null;
    if (idx == -1) {
      sep = idxCn;
    } else if (idxCn == -1) {
      sep = idx;
    } else {
      sep = idx < idxCn ? idx : idxCn;
    }
    if (sep <= 0) return null;
    final key = line.substring(0, sep).trim();
    final value = line.substring(sep + 1).trim();
    if (key.isEmpty || value.isEmpty) return null;
    if (RegExp(r'^\d{1,2}$').hasMatch(key)) return null; // 时间行
    return (key, value);
  }

  /// 形如 "key：value" 的前缀取值（用于城市/酒店等段内字段）
  static String? _prefixedValue(String line, List<String> keys) {
    for (final k in keys) {
      if (line.startsWith(k)) {
        final rest = line.substring(k.length);
        if (rest.startsWith(':') || rest.startsWith('：')) {
          return rest.substring(1).trim();
        }
      }
    }
    return null;
  }

  /// 匹配日期段头，返回天数
  static int? _matchDayHeader(String line) {
    final r1 = RegExp(r'^第\s*(\d+)\s*[天日]').firstMatch(line);
    if (r1 != null) return int.tryParse(r1.group(1)!);
    final r2 = RegExp(r'^[Dd][Aa][Yy]\s*(\d+)').firstMatch(line);
    if (r2 != null) return int.tryParse(r2.group(1)!);
    final r3 = RegExp(r'^[Dd]\s*(\d+)').firstMatch(line);
    if (r3 != null) return int.tryParse(r3.group(1)!);
    final r4 = RegExp(r'^\s*(\d+)\s*[.、．]\s*$').firstMatch(line);
    if (r4 != null) return int.tryParse(r4.group(1)!);
    return null;
  }

  /// 解析行程项（需带项目符号/编号/时间前缀，避免把正文误判为行程）
  static ItineraryItem? _parseItem(String line) {
    var s = line.trim();
    if (s.isEmpty) return null;

    final hasBullet = RegExp(r'^[-•*·●◦‣–—]').hasMatch(s);
    final hasNumber = RegExp(r'^\d{1,2}[.、．]\s*\S').hasMatch(s);
    final hasTime = RegExp(r'^\d{1,2}:\d{2}').hasMatch(s);
    if (!hasBullet && !hasNumber && !hasTime) return null;

    s = s.replaceFirst(RegExp(r'^[-•*·●◦‣–—]+'), '');
    s = s.replaceFirst(RegExp(r'^\d{1,2}[.、．]\s*'), '');
    s = s.trim();
    if (s.isEmpty) return null;

    final t = RegExp(r'^(\d{1,2}):(\d{2})\s*[-—~～:]?\s*').firstMatch(s);
    String? time;
    if (t != null) {
      time = '${t.group(1)}:${t.group(2)}';
      s = s.substring(t.end).trim();
    }
    if (s.isEmpty) return null;
    return ItineraryItem(time: time, title: s, type: 'other');
  }

  /// 字段赋值（键值行 → JourneyWork）
  static void _assignField(JourneyWork work, String key, String value) {
    final k = _norm(key);
    final v = value.trim();
    if (v.isEmpty) return;
    if (_any(k, ['团名', '團名', '标题', '標題', '行程名称', '行程名稱', '主题', '主題', '工作名称', '工作名稱', 'title', 'name'])) {
      work.title = v;
    } else if (_any(k, ['出发日期', '出發日期', '开始日期', '開始日期', '起始日期', '出发时间', '出發時間', 'startdate', 'start'])) {
      work.startDate = _normalizeDate(v) ?? v;
    } else if (_any(k, ['结束日期', '結束日期', '返回日期', '回程日期', '返程日期', '结束时间', '結束時間', 'enddate', 'end'])) {
      work.endDate = _normalizeDate(v) ?? v;
    } else if (_any(k, ['成人', '成人人数', '成人數', 'adult', 'adults'])) {
      work.adultCount = _firstInt(v);
    } else if (_any(k, ['儿童', '兒童', '儿童人数', '兒童人數', 'child', 'children'])) {
      work.childCount = _firstInt(v);
    } else if (_any(k, ['人数', '人數', '总人数', '總人數', 'people', 'peoplecount'])) {
      work.peopleCount = _firstInt(v);
    } else if (_any(k, ['领队', '領隊', '导游', '導遊', '领队姓名', '領隊姓名', 'leader', 'leadername'])) {
      work.leaderName = v;
    } else if (_any(k, ['领队电话', '領隊電話', '领队手机', '領隊手機', 'leaderphone'])) {
      work.leaderPhone = v;
    } else if (_any(k, ['司机', '司機', '司机姓名', '司機姓名', 'driver', 'drivername'])) {
      work.driverName = v;
    } else if (_any(k, ['司机电话', '司機電話', 'driverphone'])) {
      work.driverPhone = v;
    } else if (_any(k, ['车型', '車型', '车辆', '車輛', 'vehicle', 'vehicleinfo'])) {
      work.vehicleInfo = v;
    } else if (_any(k, ['备注', '備註', '说明', '說明', '简介', '簡介', 'description', 'note', 'notes', 'remark'])) {
      work.description = v;
    } else if (_any(k, ['紧急电话', '緊急電話', '应急电话', '應急電話', 'emergency', 'emergencyphone'])) {
      work.emergencyPhone = v;
    } else if (_any(k, ['组团社', '組團社', 'agency', 'agencycontact'])) {
      work.agencyContact = v;
    } else if (_any(k, ['组团社电话', '組團社電話', 'agencyphone', 'agencycontactphone'])) {
      work.agencyContactPhone = v;
    }
  }

  /// 主入口
  static JourneyImportResult parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return JourneyImportResult(warnings: ['内容为空，无法解析']);
    }

    // 1) JSON
    if (text.startsWith('{') || text.startsWith('[')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic>) {
          final work = JourneyWork.fromJson(decoded);
          if (_workHasContent(work)) {
            return JourneyImportResult(work: work, rawPreview: _preview(text));
          }
          // 兼容模板 JSON
          final tpl = JourneyTemplate.fromJson(decoded);
          final w2 = JourneyWork.fromTemplate(tpl)..isTemplate = false;
          if (_workHasContent(w2)) {
            return JourneyImportResult(work: w2, rawPreview: _preview(text));
          }
        } else if (decoded is List &&
            decoded.isNotEmpty &&
            decoded.first is Map<String, dynamic>) {
          final work = JourneyWork.fromJson(decoded.first as Map<String, dynamic>);
          if (_workHasContent(work)) {
            return JourneyImportResult(work: work, rawPreview: _preview(text));
          }
        }
      } catch (_) {
        // 不是有效 JSON，继续按文本处理
      }
    }

    // 2) HTML 剥离
    final plain = _stripHtml(text);
    final work = JourneyWork();
    final warnings = <String>[];
    final lines = plain.split('\n');

    ItineraryDay? currentDay;
    final days = <ItineraryDay>[];
    final prose = <String>[]; // 段外未归类的自由文本
    var hasStructured = false;

    void flushDay() {
      if (currentDay != null) {
        days.add(currentDay!);
        currentDay = null;
      }
    }

    ItineraryDay ensureDay() {
      return currentDay ??= ItineraryDay(dayNumber: days.length + 1);
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // 日期段头
      final dayNum = _matchDayHeader(line);
      if (dayNum != null) {
        flushDay();
        currentDay = ItineraryDay(dayNumber: dayNum, date: _normalizeDate(line));
        hasStructured = true;
        continue;
      }

      // 城市（段内）
      final city = _prefixedValue(line, ['城市', '城市名', 'city']);
      if (city != null) {
        final d = ensureDay();
        d.cityBlocks = [...d.cityBlocks, DayCityBlock(cityName: city)];
        hasStructured = true;
        continue;
      }

      // 酒店（段内）
      final hotel = _prefixedValue(line, ['酒店', '饭店', '住宿', '宾馆', '賓館', 'hotel']);
      if (hotel != null) {
        ensureDay().hotelName = hotel;
        hasStructured = true;
        continue;
      }

      // 键值字段（仅在段外作为全局字段）
      final kv = _splitKeyValue(line);
      if (kv != null && currentDay == null) {
        _assignField(work, kv.$1, kv.$2);
        hasStructured = true;
        continue;
      }

      // 行程项（带前缀，可出现在段外自动归入第 1 天）
      final item = _parseItem(line);
      if (item != null) {
        final d = ensureDay();
        if (d.cityBlocks.isEmpty) {
          d.cityBlocks = [DayCityBlock()];
        }
        final block = d.cityBlocks.last;
        block.items = [...block.items, item];
        hasStructured = true;
        continue;
      }

      // 其余段外自由文本 → 备注
      if (currentDay == null) {
        prose.add(line);
      }
    }
    flushDay();

    work.itineraryDays = days;

    // 汇总城市列表
    final cityNames = <String>[];
    for (final d in days) {
      for (final b in d.cityBlocks) {
        if (b.cityName != null && b.cityName!.isNotEmpty && !cityNames.contains(b.cityName!)) {
          cityNames.add(b.cityName!);
        }
      }
    }
    work.cities = cityNames;

    // 缺省标题
    if ((work.title ?? '').isEmpty && work.totalDays > 0) {
      work.title = '${work.totalDays}日游';
    }

    if (hasStructured) {
      if ((work.description ?? '').isEmpty && prose.isNotEmpty) {
        work.description = prose.join('\n');
      }
      return JourneyImportResult(work: work, warnings: warnings, rawPreview: _preview(text));
    }

    // 兜底：无结构化信息，把整段文本放入备注
    if (plain.isNotEmpty) {
      work.description = plain.trim();
      return JourneyImportResult(
        work: work,
        warnings: ['仅识别到一段文本，已放入备注，请在编辑器中手动整理行程'],
        rawPreview: _preview(text),
      );
    }

    return JourneyImportResult(
      warnings: ['未能从内容中识别出行程信息'],
      rawPreview: _preview(text),
    );
  }
}
