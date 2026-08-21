import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../index.dart';
import 'package:dio/dio.dart' as dio;

/// 推送服务：iOS 原生 APNs 注册 + device token 上报 LUMO-Chat + 角标 + 通知点击。
///
/// 原生通道（ios/Runner/AppDelegate.swift）：
/// - MethodChannel "lumotrip/push"
///   - 调用: register / getToken / setBadge
///   - 原生回调: onTokenReceived / onNotificationTap
class PushService extends GetxService {
  static PushService get to => Get.find();

  static const _channel = MethodChannel('lumotrip/push');

  /// 当前设备的 APNs token（缓存）
  String deviceToken = '';

  /// 通知点击回调（原生透传，供跳转处理）
  final _notificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationTap =>
      _notificationTapController.stream;

  /// 应用启动时调用：注册 APNs 授权 + 恢复 token
  Future<void> init() async {
    _channel.setMethodCallHandler(_handleNativeCall);
    try {
      final cached = await _channel.invokeMethod<String>('getToken') ?? '';
      if (cached.isNotEmpty) deviceToken = cached;
      // 申请授权（用户同意后原生回调 onTokenReceived → _uploadToken）
      await _channel.invokeMethod('register');
    } catch (e) {
      dev.log('[PushService] init error: $e');
    }
  }

  /// 处理原生回调
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onTokenReceived':
        final token = call.arguments as String? ?? '';
        if (token.isNotEmpty) {
          deviceToken = token;
          await uploadToken();
        }
        return null;
      case 'onNotificationTap':
        final data = call.arguments;
        if (data is Map) {
          _notificationTapController
              .add(data.cast<String, dynamic>());
        }
        return null;
      default:
        return null;
    }
  }

  /// 把 device token 上报给 LUMO-Chat（登录后调用；登出时移除）
  Future<void> uploadToken() async {
    if (deviceToken.isEmpty) return;
    final chatToken = StorageStone.lumoChatToken;
    if (chatToken.isEmpty) return;
    try {
      final dioClient = dio.Dio(dio.BaseOptions(
        baseUrl: ApiUrl.lumoChatBaseUrl,
        headers: {'Authorization': 'Bearer $chatToken'},
      ));
      await dioClient.post('/api/v1/users/device-token', data: {
        'platform': 'ios',
        'token': deviceToken,
      });
    } catch (e) {
      dev.log('[PushService] uploadToken error: $e');
    }
  }

  /// 登出时移除 device token
  Future<void> removeToken() async {
    if (deviceToken.isEmpty) return;
    final chatToken = StorageStone.lumoChatToken;
    if (chatToken.isEmpty) return;
    try {
      final dioClient = dio.Dio(dio.BaseOptions(
        baseUrl: ApiUrl.lumoChatBaseUrl,
        headers: {'Authorization': 'Bearer $chatToken'},
      ));
      await dioClient.delete('/api/v1/users/device-token', data: {
        'platform': 'ios',
      });
    } catch (e) {
      dev.log('[PushService] removeToken error: $e');
    }
  }

  /// 设置桌面 App 图标角标数字
  Future<void> setBadge(int count) async {
    try {
      await _channel.invokeMethod('setBadge', count);
    } catch (e) {
      // 非 iOS 环境忽略
    }
  }
}
