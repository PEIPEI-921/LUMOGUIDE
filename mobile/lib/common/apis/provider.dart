import 'package:dio/dio.dart';
import 'index.dart';

class ApiProvider {
  static ApiProvider? _instance;
  factory ApiProvider() => _instance ??= ApiProvider._();

  late Dio dio;

  ApiProvider._() {
    final options = BaseOptions(
      baseUrl: ApiUrl.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
    );
    dio = Dio(options);

    dio.interceptors.add(AuthInterceptor());
  }

  Future<ApiResult> get(
    String path, {
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: parameters,
        options: options ?? Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(e);
    }
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
    try {
      final response = await dio.post(
        path,
        queryParameters: parameters,
        data: data,
        options: options ?? Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(e);
    }
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
    try {
      final response = await dio.put(
        path,
        queryParameters: parameters,
        data: data,
        options: options ?? Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(e);
    }
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
    try {
      final response = await dio.patch(
        path,
        queryParameters: parameters,
        data: data,
        options: options ?? Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(e);
    }
  }

  Future<ApiResult> delete(
    String path, {
    Map<String, dynamic>? parameters,
    Object? data,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        path,
        queryParameters: parameters,
        data: data,
        options: options ?? Options(headers: headers),
        cancelToken: cancelToken,
      );
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(e);
    }
  }

  Future<ApiResult> download(String path, String savePath) async {
    try {
      final response = await dio.download(path, savePath);
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(e);
    }
  }
}
