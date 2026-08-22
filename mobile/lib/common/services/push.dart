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

  /// 应用启动时调用：注册 APNs 授权 + 恢复 token + 订阅通知点击
  Future<void> init() async {
    _channel.setMethodCallHandler(_handleNativeCall);
    // 订阅通知点击（需在 register 之前，确保冷启动补发的通知不丢失）
    _notificationTapController.stream.listen(handleNotificationTap);
    try {
      final cached = await _channel.invokeMethod<String>('getToken') ?? '';
      if (cached.isNotEmpty) deviceToken = cached;
      // 主动拉取冷启动通知（原生补发可能早于 Dart 就绪而丢失，这里兜底）
      try {
        final pending = await _channel.invokeMethod<Map>('getPendingNotification');
        if (pending is Map && pending.isNotEmpty) {
          handleNotificationTap(pending.cast<String, dynamic>());
        }
      } catch (_) {}
      // 申请授权（用户同意后原生回调 onTokenReceived → _uploadToken）
      await _channel.invokeMethod('register');
    } catch (e) {
      dev.log('[PushService] init error: $e');
    }
  }

  /// 待处理的点击通知（App 未就绪时缓存，就绪后重试）
  Map<String, dynamic>? _pendingTap;

  /// 通知点击 → 跳转对应会话内容。
  /// 推送 data 中含 conversation_id（聊天消息推送）→ 打开聊天页。
  /// App 未就绪（冷启动早期/未登录）时缓存，由 [retryPendingTap] 稍后处理。
  Future<void> handleNotificationTap(Map<String, dynamic> data) async {
    try {
      if (!_isReadyForNavigation()) {
        _pendingTap = data;
        return;
      }
      await _processTap(data);
    } catch (e) {
      dev.log('[PushService] handleNotificationTap error: $e');
    }
  }

  /// App 初始化/登录完成后再调用，处理之前缓存的点击通知。
  Future<void> retryPendingTap() async {
    final pending = _pendingTap;
    if (pending == null) return;
    if (!_isReadyForNavigation()) return;
    // 守卫：主导航（welcome → ROOT/LOGIN）进行中时保留 pending，
    // 否则 push 的页面会被随后的 Get.offAll(ROOT) 清掉（回到首页）。
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.WELCOME ||
        currentRoute == AppRoutes.LOGIN) {
      return;
    }
    _pendingTap = null;
    await _processTap(pending);
  }

  /// 导航/登录是否就绪（冷启动早期 UserStore/ChatStore 尚未注册）
  bool _isReadyForNavigation() {
    return Get.isRegistered<UserStore>() &&
        Get.isRegistered<ChatStore>() &&
        UserStore.to.isLogin &&
        Get.context != null;
  }

  /// 解析会话并跳转聊天页
  Future<void> _processTap(Map<String, dynamic> data) async {
    // APNs userInfo 结构：{aps: {...}, data: {message_id, conversation_id, ...}}
    // 兼容 conversation_id 在顶层或 data 嵌套层
    final inner = data['data'];
    final innerMap = inner is Map
        ? Map<String, dynamic>.from(inner)
        : const <String, dynamic>{};
    final convId =
        (data['conversation_id'] ?? innerMap['conversation_id']) as String? ??
            '';
    if (convId.isEmpty) return;
    // 优先用内存会话对象，缺失时拉取会话详情；仍失败则用最小会话对象跳转
    ChatConversation? conv = ChatStore.to.conversationList
        .firstWhereOrNull((c) => c.id == convId);
    conv ??= await ChatStore.to.getConversation(convId);
    conv ??= ChatConversation(id: convId, type: 'DIRECT');
    await Get.toNamed(
      AppRoutes.CHAT,
      arguments: {'conversation': conv},
    );
  }  /// 处理原生回调
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
