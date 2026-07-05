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
      final message = data['message'];
      return '$message';
    }
    return 'Request failed';
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
