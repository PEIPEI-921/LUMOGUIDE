import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class ApiResult<T> {
  int code = -1;
  String? message;
  // bool success = false;

  dynamic data;

  Map<String, dynamic>? rawValue;

  ApiError? error;

  bool get isSuccess => code == 200;

  Map<String, dynamic> get dataJson {
    if (data is Map<String, dynamic>) {
      return data as Map<String, dynamic>;
    }
    return {};
  }

  List<dynamic> get dataList {
    if (data is List<dynamic>) {
      return data as List<dynamic>;
    }
    return [];
  }

  ApiResult.success(Response response) {
    try {
      if (response.statusCode != 200) {
        message = response.statusMessage;
        code = response.statusCode ?? -1;
        return;
      }

      dynamic body = response.data;
      if (body is! Map) {
        // 響應體可能是頂層數組/純文字/JSON 字符串：
        // 嘗試解析，失敗時保留原始數據但視為成功（HTTP 200）。
        if (body is String) {
          try {
            final decoded = jsonDecode(body);
            if (decoded is Map) {
              body = decoded;
            } else {
              data = decoded;
              code = 200;
              rawValue = {'data': decoded};
              return;
            }
          } catch (_) {
            // 非 JSON 純文字響應
            data = body;
            code = 200;
            rawValue = {'data': body};
            return;
          }
        } else {
          // 非 Map 對象（數組等）
          data = body;
          code = 200;
          rawValue = {'data': body};
          return;
        }
      }

      final json = body as Map<String, dynamic>;
      // 安全解析 code：兼容數字(double/int)/字符串，異常時不誤判整批響應失敗
      final rawCode = json["code"];
      if (rawCode is int) {
        code = rawCode;
      } else if (rawCode is double) {
        code = rawCode.toInt();
      } else if (rawCode is String) {
        code = int.tryParse(rawCode) ?? -1;
      } else {
        code = -1;
      }
      message = json["msg"] ?? json["message"];
      data = json["data"];
      rawValue = json;
    } catch (e) {
      message = e.toString();
      log(e.toString());
    }
  }

  ApiResult.bytes(Response response) {
    code = response.statusCode ?? -1;
    message = response.statusMessage;
    if (response.statusCode == 200) {
      data = response.data;
    }
  }

  ApiResult.failure(DioException exception) {
    error = ApiError(
      code: exception.response?.statusCode ?? -1,
      message: _getBasicErrorMessage(exception),
    );
    code = exception.response?.statusCode ?? -1;
    message = _getBasicErrorMessage(exception);
  }

  String _getBasicErrorMessage(DioException exception) {
    if (exception.response?.data is Map) {
      final data = exception.response?.data as Map<String, dynamic>;
      final message = data['message'] ?? data['msg'] ?? data['error'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
      // If no recognizable message field, return the raw data as string
      return 'Server error: ${_truncateMap(data)}';
    }
    final statusCode = exception.response?.statusCode;
    final data = exception.response?.data;
    // Truncate long string responses (e.g., HTML error pages) to keep toasts readable
    String detail;
    if (data is String) {
      if (data.trimLeft().startsWith('<!DOCTYPE') || data.trimLeft().startsWith('<html')) {
        detail = '[HTML error page — check server logs for details]';
      } else if (data.length > 200) {
        detail = '${data.substring(0, 200)}...';
      } else {
        detail = data;
      }
    } else if (data != null) {
      detail = data.toString().length > 200 ? '${data.toString().substring(0, 200)}...' : data.toString();
    } else {
      detail = exception.message ?? '';
    }
    return 'Request failed [$statusCode] $detail';
  }

  /// Truncate map to a readable single-line summary for error display
  String _truncateMap(Map<String, dynamic> map) {
    final entries = map.entries.take(5).map((e) => '${e.key}: ${e.value}').join(', ');
    if (map.length > 5) return '$entries...';
    return entries;
  }
}

class ApiError {
  int code = -1;
  String? message;

  ApiError({
    this.code = -1,
    this.message,
  });

  @override
  String toString() {
    return 'ApiError{code: $code, message: $message}';
  }
}
