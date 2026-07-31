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

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      if (response.statusCode == 401 || response.data['code'] == 401) {
        if (ConfigService.to.isEnterApp) {
          Loading.dismiss();
          getx.Get.offAllNamed(AppRoutes.LOGIN);
          return;
        }
      }
    } catch (e) {
      print(e.toString());
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized in error handler (validateStatus rejects non-2xx,
    // so 401 responses come through onError, not onResponse)
    if (err.response?.statusCode == 401) {
      if (ConfigService.to.isEnterApp) {
        Loading.dismiss();
        getx.Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }
    }
    super.onError(err, handler);
  }
}
