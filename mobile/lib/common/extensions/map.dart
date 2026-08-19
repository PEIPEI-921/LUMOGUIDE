import 'dart:developer';

/// 安全JSON解析擴展
extension SafeJsonExt on Map<String, dynamic> {
  /// 安全解析String類型
  String? safeString(String key, {String? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    } catch (e) {
      log('安全解析String失敗: key=$key, error=$e');
      return defaultValue;
    }
  }

  /// 安全解析int類型
  int? safeInt(String key, {int? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      log('安全解析int失敗: key=$key, error=$e');
      return defaultValue;
    }
  }

  /// 安全解析double類型
  double? safeDouble(String key, {double? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      log('安全解析double失敗: key=$key, error=$e');
      return defaultValue;
    }
  }

  /// 安全解析bool類型
  bool? safeBool(String key, {bool? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        final lowerValue = value.toLowerCase();
        if (lowerValue == 'true' || lowerValue == '1') return true;
        if (lowerValue == 'false' || lowerValue == '0') return false;
      }
      return defaultValue;
    } catch (e) {
      log('安全解析bool失敗: key=$key, error=$e');
      return defaultValue;
    }
  }

  /// 安全解析List類型
  List<T>? safeList<T>(String key, {List<T>? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is List) {
        return value.cast<T>();
      }
      return defaultValue;
    } catch (e) {
      log('安全解析List失敗: key=$key, error=$e');
      return defaultValue;
    }
  }

  /// 安全解析Map類型
  Map<String, dynamic>? safeMap(String key,
      {Map<String, dynamic>? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return defaultValue;
    } catch (e) {
      log('安全解析Map失敗: key=$key, error=$e');
      return defaultValue;
    }
  }

  /// 安全解析嵌套對象
  T? safeObject<T>(String key, T Function(Map<String, dynamic>) fromJson,
      {T? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is Map<String, dynamic>) {
        return fromJson(value);
      }
      return defaultValue;
    } catch (e) {
      log('安全解析Object失敗: key=$key, error=$e');
      return defaultValue;
    }
  }

  /// 安全解析嵌套對象列表
  List<T>? safeObjectList<T>(
      String key, T Function(Map<String, dynamic>) fromJson,
      {List<T>? defaultValue}) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map((item) => fromJson(item))
            .toList();
      }
      return defaultValue;
    } catch (e) {
      log('安全解析ObjectList失敗: key=$key, error=$e');
      return defaultValue;
    }
  }
}
