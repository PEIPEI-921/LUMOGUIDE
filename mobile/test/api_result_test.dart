import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumotrip/common/apis/result.dart';

Response _resp(int statusCode, dynamic data) => Response(
      requestOptions: RequestOptions(),
      statusCode: statusCode,
      data: data,
    );

void main() {
  group('ApiResult.success', () {
    test('code 200 成功', () {
      final r = ApiResult.success(_resp(200, {'code': 200, 'data': {'id': 1}}));
      expect(r.isSuccess, isTrue);
      expect(r.code, 200);
      expect(r.dataJson['id'], 1);
    });
    test('code 为字符串 "200"', () {
      final r = ApiResult.success(_resp(200, {'code': '200', 'data': 1}));
      expect(r.code, 200);
      expect(r.isSuccess, isTrue);
    });
    test('业务 code 500 失败', () {
      final r = ApiResult.success(_resp(200, {'code': 500, 'msg': '服务器错误'}));
      expect(r.isSuccess, isFalse);
      expect(r.message, '服务器错误');
    });
    test('HTTP 状态码非 200', () {
      final r = ApiResult.success(_resp(404, 'not found'));
      expect(r.isSuccess, isFalse);
      expect(r.code, 404);
    });
    test('data 为 JSON 字符串时解码', () {
      final r = ApiResult.success(_resp(200, '{"code":200,"data":{"id":9}}'));
      expect(r.isSuccess, isTrue);
      expect(r.dataJson['id'], 9);
    });
    test('message 优先取 msg', () {
      final r = ApiResult.success(_resp(200, {'code': 200, 'msg': 'M', 'message': 'N'}));
      expect(r.message, 'M');
    });
    test('dataJson/dataList 兜底', () {
      final rMap = ApiResult.success(_resp(200, {'code': 200, 'data': {'k': 'v'}}));
      expect(rMap.dataJson, {'k': 'v'});
      expect(rMap.dataList, isEmpty);
      final rList = ApiResult.success(_resp(200, {'code': 200, 'data': [1, 2]}));
      expect(rList.dataList, [1, 2]);
      expect(rList.dataJson, isEmpty);
    });
    test('頂層裸數組 200 響應 → 視為成功且 dataList 可讀', () {
      final r = ApiResult.success(_resp(200, [
        {'id': 1},
        {'id': 2},
      ]));
      expect(r.isSuccess, isTrue);
      expect(r.dataList.length, 2);
    });
    test('純文字 200 響應 → 視為成功且 data 保留原文', () {
      final r = ApiResult.success(_resp(200, 'plain text body'));
      expect(r.isSuccess, isTrue);
      expect(r.data, 'plain text body');
    });
    test('code 為 double 200.0 → 正常解析為成功', () {
      final r = ApiResult.success(_resp(200, {'code': 200.0, 'data': {'id': 1}}));
      expect(r.isSuccess, isTrue);
      expect(r.code, 200);
    });
    test('code 為不可解析字符串 → 不拋異常', () {
      final r = ApiResult.success(_resp(200, {'code': 'abc', 'data': 1}));
      expect(r.code, -1);
      expect(r.isSuccess, isFalse);
    });
  });

  group('ApiResult.failure', () {
    test('Map 数据提取 message', () {
      final r = ApiResult.failure(DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: _resp(500, {'message': '内部错误'}),
      ));
      expect(r.code, 500);
      expect(r.message, '内部错误');
    });
    test('Map 无 message 字段回退摘要', () {
      final r = ApiResult.failure(DioException(
        requestOptions: RequestOptions(),
        response: _resp(400, {'foo': 'bar'}),
      ));
      expect(r.message, 'Server error: foo: bar');
    });
    test('HTML 响应页', () {
      final r = ApiResult.failure(DioException(
        requestOptions: RequestOptions(),
        response: _resp(500, '<!DOCTYPE html><html>...</html>'),
      ));
      expect(r.message, contains('[HTML error page'));
    });
    test('长字符串截断', () {
      final long = 'x' * 300;
      final r = ApiResult.failure(DioException(
        requestOptions: RequestOptions(),
        response: _resp(500, long),
      ));
      expect(r.message, contains('...'));
      expect(r.message!.length, lessThan(300));
    });
    test('无 response 时用 exception.message', () {
      final r = ApiResult.failure(DioException(
        requestOptions: RequestOptions(),
        message: '网络超时',
      ));
      expect(r.message, 'Request failed [null] 网络超时');
    });
  });
}
