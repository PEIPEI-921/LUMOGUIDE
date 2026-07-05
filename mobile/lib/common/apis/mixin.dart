import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'index.dart';

mixin ApiMixin {
  Future<ApiResult> get(
    String path, {
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return ApiProvider().get(path,
        parameters: parameters,
        headers: headers,
        options: options,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken);
  }

  Future<ApiResult> post(
    String path, {
    Map<String, dynamic>? parameters,
    Object? data,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return await ApiProvider().post(path,
        parameters: parameters,
        data: data,
        headers: headers,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken);
  }

  Future<ApiResult> put(
    String path, {
    Map<String, dynamic>? parameters,
    Object? data,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return await ApiProvider().put(path,
        parameters: parameters,
        data: data,
        headers: headers,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken);
  }

  Future<ApiResult> patch(
    String path, {
    Map<String, dynamic>? parameters,
    Object? data,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return await ApiProvider().patch(path,
        parameters: parameters,
        data: data,
        headers: headers,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken);
  }

  Future<ApiResult> delete(
    String path, {
    Map<String, dynamic>? parameters,
    Object? data,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await ApiProvider().delete(
      path,
      parameters: parameters,
      data: data,
      headers: headers,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<ApiResult> download(String path, String savePath) async {
    return await ApiProvider().download(path, savePath);
  }
}

mixin ApiCancelableMixin on GetxController {
  final CancelToken cancelToken = CancelToken();

  @override
  void onClose() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    super.onClose();
  }
}
