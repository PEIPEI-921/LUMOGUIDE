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

      Map<String, dynamic> json;
      if (response.data is Map) {
        json = response.data;
      } else {
        json = jsonDecode(response.data);
      }

      if (json["code"] is String) {
        code = int.parse(json["code"]);
      } else {
        code = json["code"] ?? -1;
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
