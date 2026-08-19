import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../index.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageStone.token;
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  bool _isSessionExpired() {
    // 冷啟動深鏈請求可能早於 service 註冊（ConfigService 未 put），
    // 此時 Get.find 會拋異常，需先檢查是否已註冊。
    if (!getx.Get.isRegistered<ConfigService>()) return false;
    return ConfigService.to.isEnterApp;
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      if (response.statusCode == 401 || response.data['code'] == 401) {
        if (_isSessionExpired()) {
          Loading.dismiss();
          getx.Get.offAllNamed(AppRoutes.LOGIN);
          // 業務 401 是 HTTP 200 響應，調用方會經 ApiResult 得到 isSuccess=false，
          // 因此用 handler.next 讓請求正常結束，避免 Future 永久懸掛。
          handler.next(response);
          return;
        }
      }
    } catch (e) {
      log(e.toString(), name: 'AuthInterceptor');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized in error handler (validateStatus rejects non-2xx,
    // so 401 responses come through onError, not onResponse)
    if (err.response?.statusCode == 401) {
      if (_isSessionExpired()) {
        Loading.dismiss();
        getx.Get.offAllNamed(AppRoutes.LOGIN);
      }
    }
    // 無論是否處理 401，都必須結束錯誤鏈，否則請求 Future 永不完成。
    super.onError(err, handler);
  }
}
