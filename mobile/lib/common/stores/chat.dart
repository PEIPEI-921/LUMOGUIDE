import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../apis/mixin.dart';
import '../apis/urls.dart';
import '../extensions/map.dart';
import '../models/chat.dart';
import 'storage.dart';

/// LUMO-Chat（IM-as-a-Service）客户端 Store。
///
/// 替代原腾讯云 IM（TIMStore）：
/// - REST：会话/消息/群组管理（Bearer token = LUMO-Chat access_token）
/// - WebSocket：/ws namespace（send_message / new_message / server_ack / mark_read / typing…）
///
/// 协议见 LUMO-Chat 仓库 docs/API.md。
class ChatStore extends GetxController with ApiMixin {
  static ChatStore get to => Get.find();

  /// 当前登录用户的 LUMO-Chat user_id（= LUMOGUIDE user.number）
  String currentUserId = '';

  /// token 刷新进行中标记（防重入）
  bool _refreshing = false;

  final _isReady = false.obs;

  /// IM 是否已登录就绪（有 token 且已建立/可建立连接）
  bool get isReady => _isReady.value;

  final _connected = false.obs;

  /// Socket 实时连接状态
  bool get connected => _connected.value;

  /// 会话列表（响应式）
  final conversationList = <ChatConversation>[].obs;

  /// 总未读数（用于 root 消息 tab 角标；LUMO-Chat 不返回未读数，由客户端本地累计）
  final totalUnreadCount = 0.obs;

  /// 各会话未读数（内存态）
  final Map<String, int> _unreadByConv = {};

  /// 会话最后一条消息预览缓存（conversation_id -> message）
  final Map<String, ChatMessage> _lastMessageByConv = {};

  String _token = '';
  socket_io.Socket? _socket;
  Dio? _dio;

  @override
  void onInit() {
    super.onInit();
    // 冷启动恢复：已登录且有聊天 token 时自动连接
    final token = StorageStone.lumoChatToken;
    final userNumber = StorageStone.userNumber;
    if (token.isNotEmpty && userNumber.isNotEmpty) {
      init(token: token, userId: userNumber);
    } else {
      _isReady.value = true;
    }
  }

  @override
  void onClose() {
    _socket?.dispose();
    _socket = null;
    super.onClose();
  }

  // ─── 生命周期 ────────────────────────────────────────────────

  /// 登录后初始化：保存 token → 建立 WebSocket → 拉取会话列表。
  /// 失败不抛异常，UI 自动降级（聊天不可用但主流程正常）。
  Future<void> init({required String token, required String userId}) async {
    _token = token;
    currentUserId = userId;
    ChatStoreRef.currentUserId = userId;
    _isReady.value = true;

    try {
      _connectSocket();
      await refreshConversationList();
    } catch (e) {
      log('ChatStore init error: $e');
    }
  }

  void _connectSocket() {
    try {
      _socket?.dispose();
      final socket = socket_io.io(
        '${ApiUrl.lumoChatBaseUrl}/ws',
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': _token})
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(1000)
            .build(),
      );
      _socket = socket;

      socket.onConnect((_) {
        _connected.value = true;
        log('ChatStore: socket connected');
      });

      socket.onDisconnect((_) {
        _connected.value = false;
        log('ChatStore: socket disconnected');
      });

      socket.onConnectError((data) {
        _connected.value = false;
        log('ChatStore: connect error: $data');
        // token 过期/无效（3600s）→ 刷新后重连；其他错误仅记录
        final msg = data?.toString() ?? '';
        if (msg.toLowerCase().contains('auth') ||
            msg.toLowerCase().contains('token') ||
            msg.toLowerCase().contains('expired')) {
          _handleAuthFailure();
        }
      });

      socket.on('server_ack', (data) {
        _handleServerAck(data);
      });

      socket.on('new_message', (data) {
        _handleNewMessage(data);
      });

      socket.on('message_recalled', (data) {
        _handleMessageRecalled(data);
      });

      socket.on('message_edited', (data) {
        _handleMessageEdited(data);
      });

      socket.on('typing', (data) {
        _handleTyping(data);
      });

      socket.on('error', (data) {
        log('ChatStore: socket error: $data');
      });

      socket.connect();
    } catch (e) {
      log('ChatStore: _connectSocket error: $e');
    }
  }

  /// 登出：断开连接并清空本地状态
  Future<void> logout() async {
    try {
      _socket?.dispose();
    } catch (e) {
      log('ChatStore logout socket error: $e');
    }
    _socket = null;
    _token = '';
    currentUserId = '';
    ChatStoreRef.currentUserId = '';
    _connected.value = false;
    _isReady.value = false;
    conversationList.clear();
    _unreadByConv.clear();
    _lastMessageByConv.clear();
    totalUnreadCount.value = 0;
  }

  // ─── REST 基础 ───────────────────────────────────────────────

  Dio _client() {
    final dio = _dio ??= Dio(
      BaseOptions(
        baseUrl: ApiUrl.lumoChatBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    return dio;
  }

  /// 请求 LUMO-Chat REST（401 时自动刷新 token 并重试一次）
  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final res = await _client().request<Map<String, dynamic>>(
          path,
          queryParameters: query,
          data: body,
          options: Options(
            method: method,
            headers: {'Authorization': 'Bearer $_token'},
          ),
        );
        return _parseEnvelope(res.data);
      } on DioException catch (e) {
        // token 过期（3600s）：刷新后重试一次
        if (attempt == 0 && e.response?.statusCode == 401) {
          final ok = await _refreshToken();
          if (ok) continue;
        }
        rethrow;
      }
    }
    throw Exception('chat request failed');
  }

  Map<String, dynamic> _parseEnvelope(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    final code = data['code'];
    if (code != 0) {
      throw Exception(data['message'] ?? 'chat api error: $code');
    }
    return data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : <String, dynamic>{'value': data['data']};
  }

  /// 通过 LUMOGUIDE 后端重新换取 LUMO-Chat access_token
  Future<bool> _refreshToken() async {
    if (_refreshing) return false;
    _refreshing = true;
    try {
      final res = await get(ApiUrl.refreshChatToken);
      if (res.isSuccess) {
        final newToken = res.dataJson.safeString('lumo_chat_token') ?? '';
        if (newToken.isNotEmpty) {
          _token = newToken;
          await StorageStone.setLumoChatToken(newToken);
          log('ChatStore: token refreshed');
          return true;
        }
      }
    } catch (e) {
      log('ChatStore refreshToken error: $e');
    } finally {
      _refreshing = false;
    }
    return false;
  }

  /// 认证失败（token 过期/无效）：刷新 token 后重建连接
  Future<void> _handleAuthFailure() async {
    if (_refreshing) return;
    final ok = await _refreshToken();
    if (ok) {
      await refreshConversationList();
      _connectSocket();
    }
  }

  // ─── 会话 ────────────────────────────────────────────────────

  /// 刷新会话列表（更新响应式列表 + 补拉缺失的预览 + 加入会话房间 + 补算未读）
  Future<void> refreshConversationList() async {
    if (_token.isEmpty) return;
    try {
      final data = await _request(
        'GET',
        '/api/v1/conversations',
        query: {'limit': 50},
      );
      final raw = data['conversations'];
      final list = <ChatConversation>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            list.add(ChatConversation.fromJson(item));
          }
        }
      }
      conversationList.assignAll(list);
      _joinConversationRooms(list);
      _fetchMissingPreviews(list);
      _syncUnreadFromServer(list);
    } catch (e) {
      log('ChatStore refreshConversationList error: $e');
    }
  }

  /// 为所有会话加入 socket 房间（他人新建的会话不会自动入房，需显式 join）
  void _joinConversationRooms(List<ChatConversation> list) {
    final socket = _socket;
    if (socket == null) return;
    for (final c in list) {
      socket.emit('join_conversation', {'conversation_id': c.id});
    }
  }

  /// 补算服务端未读：本地未累计过、且存在比 last_read_message_id 更新的消息时，
  /// 按消息历史统计未读数（覆盖「他人先建会话再发消息」导致的漏计）。
  Future<void> _syncUnreadFromServer(List<ChatConversation> list) async {
    final need = list
        .where((c) =>
            c.lastMessageId != null &&
            c.lastMessageId!.isNotEmpty &&
            c.lastReadMessageId != null &&
            c.lastReadMessageId!.isNotEmpty &&
            c.lastMessageId != c.lastReadMessageId &&
            !_unreadByConv.containsKey(c.id))
        .take(10)
        .toList();
    if (need.isEmpty) return;
    await Future.wait(need.map((c) async {
      try {
        final msgs = await fetchMessages(c.id, limit: 50);
        if (msgs.isEmpty) return;
        final readId = int.tryParse(c.lastReadMessageId ?? '0') ?? 0;
        var unread = 0;
        for (final m in msgs) {
          final mid = int.tryParse(m.messageId) ?? 0;
          if (mid > readId && !m.isMine) {
            unread++;
          }
        }
        if (unread > 0) {
          _unreadByConv[c.id] = unread;
          totalUnreadCount.value =
              _unreadByConv.values.fold(0, (a, b) => a + b);
        }
      } catch (e) {
        // 静默
      }
    }));
  }

  /// 对没有预览缓存的会话拉取最新一条消息（并行、失败静默）
  Future<void> _fetchMissingPreviews(List<ChatConversation> list) async {
    final need = list
        .where((c) =>
            c.lastMessageId != null &&
            c.lastMessageId!.isNotEmpty &&
            !_lastMessageByConv.containsKey(c.id))
        .take(10)
        .toList();
    if (need.isEmpty) return;
    await Future.wait(need.map((c) async {
      try {
        final msgs = await fetchMessages(c.id, limit: 1);
        if (msgs.isNotEmpty) {
          _lastMessageByConv[c.id] = msgs.last;
        }
      } catch (e) {
        // 静默
      }
    }));
  }

  /// 获取会话列表（含预览），供消息大厅使用
  List<ChatConversation> get conversations => conversationList;

  /// 会话未读数
  int unreadCount(String conversationId) => _unreadByConv[conversationId] ?? 0;

  /// 会话最后一条消息（预览）
  ChatMessage? lastMessageOf(String conversationId) =>
      _lastMessageByConv[conversationId];

  /// 打开会话：清未读 + 上报已读
  void openConversation(String conversationId) {
    clearUnread(conversationId);
    joinConversation(conversationId);
  }

  /// 创建/获取单聊会话
  Future<ChatConversation?> getOrCreateDirect(String userId) async {
    if (_token.isEmpty) return null;
    try {
      final data = await _request(
        'POST',
        '/api/v1/conversations/direct',
        body: {'user_id': userId},
      );
      final id = (data['conversation_id'] ?? data['id']) as String? ?? '';
      if (id.isEmpty) return null;
      joinConversation(id);
      await refreshConversationList();
      return conversationList.firstWhereOrNull((c) => c.id == id) ??
          ChatConversation(id: id, type: data['type'] ?? 'DIRECT');
    } catch (e) {
      log('ChatStore getOrCreateDirect error: $e');
      return null;
    }
  }

  /// 获取会话详情
  Future<ChatConversation?> getConversation(String conversationId) async {
    if (_token.isEmpty) return null;
    try {
      final data = await _request('GET', '/api/v1/conversations/$conversationId');
      return ChatConversation(
        id: (data['conversation_id'] ?? data['id']) as String? ?? conversationId,
        type: data['type'] as String? ?? 'DIRECT',
        title: data['title'] as String?,
        announcement: data['announcement'] as String?,
        avatar: data['avatar'] as String?,
        lastMessageId: data['last_message_id'] as String?,
        updatedAt: data['updated_at'] as String?,
      );
    } catch (e) {
      log('ChatStore getConversation error: $e');
      return null;
    }
  }

  /// 删除会话（LUMO-Chat 无删除会话接口：仅从本地列表移除，下次刷新会重新出现）
  Future<bool> deleteConversation(String conversationId) async {
    conversationList.removeWhere((c) => c.id == conversationId);
    _unreadByConv.remove(conversationId);
    _lastMessageByConv.remove(conversationId);
    totalUnreadCount.value = _unreadByConv.values.fold(0, (a, b) => a + b);
    return true;
  }

  // ─── 消息 ────────────────────────────────────────────────────

  /// 拉取历史消息（返回按时间升序排列）
  Future<List<ChatMessage>> fetchMessages(
    String conversationId, {
    String? cursor,
    int limit = 30,
  }) async {
    if (_token.isEmpty) return [];
    try {
      final data = await _request(
        'GET',
        '/api/v1/conversations/$conversationId/messages',
        query: {
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': limit,
        },
      );
      final raw = data['messages'];
      final list = <ChatMessage>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            list.add(ChatMessage.fromJson(item));
          }
        }
      }
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (list.isNotEmpty) {
        _lastMessageByConv[conversationId] = list.last;
      }
      return list;
    } catch (e) {
      log('ChatStore fetchMessages error: $e');
      return [];
    }
  }

  /// 发送文本消息（幂等：client_msg_id 重试复用同一 message_id）
  Future<ChatMessage> sendTextMessage(String conversationId, String content) {
    return _sendMessage(
      conversationId: conversationId,
      type: 'TEXT',
      content: content,
    );
  }

  /// 发送图片消息（content = 媒体 URL）
  Future<ChatMessage> sendImageMessage(
    String conversationId,
    String url, {
    String? fileName,
    String? mime,
    int? size,
  }) {
    return _sendMessage(
      conversationId: conversationId,
      type: 'IMAGE',
      content: url,
      extra: {
        if (fileName != null) 'file_name': fileName,
        if (mime != null) 'mime': mime,
        if (size != null) 'size': size,
      },
    );
  }

  Future<ChatMessage> _sendMessage({
    required String conversationId,
    required String type,
    required String content,
    Map<String, dynamic>? extra,
  }) async {
    final clientMsgId = _generateClientMsgId();
    final completer = Completer<ChatMessage>();
    _ackWaiters[clientMsgId] = completer;
    final params = {
      'conversation_id': conversationId,
      'client_msg_id': clientMsgId,
      'type': type,
      'content': content,
      'extra': extra ?? {},
    };

    // 超时保护
    final timer = Timer(const Duration(seconds: 10), () {
      if (_ackWaiters.remove(clientMsgId) != null) {
        completer.completeError(Exception('發送超時，請重試'));
      }
    });

    try {
      _socket?.emit('send_message', params);
      final ack = await completer.future;
      timer.cancel();
      // server_ack 不含完整消息体，用发送参数重建本地消息（幂等复用同一 message_id）
      final msg = ChatMessage(
        messageId: ack.messageId,
        conversationId: conversationId,
        senderId: currentUserId,
        type: type,
        content: content,
        extra: extra ?? const {},
        createdAt: ack.createdAt,
        status: 'SENT',
      );
      _lastMessageByConv[conversationId] = msg;
      return msg;
    } catch (e) {
      timer.cancel();
      rethrow;
    }
  }

  static final Map<String, Completer<ChatMessage>> _ackWaiters = {};

  void _handleServerAck(dynamic data) {
    try {
      final map = (data as Map).cast<String, dynamic>();
      final clientMsgId = map['client_msg_id'] as String? ?? '';
      final completer = _ackWaiters.remove(clientMsgId);
      if (completer == null) return;
      final status = map['status'] as String? ?? 'FAILED';
      if (status == 'SENT') {
        final msgId = map['message_id'] as String? ?? '';
        final timestamp = map['timestamp'];
        completer.complete(
          _buildLocalMessage(
            messageId: msgId,
            conversationId: map['conversation_id'] as String? ?? '',
            type: map['type'] as String? ?? 'TEXT',
            content: map['content'] as String? ?? '',
            extra: map['extra'] is Map
                ? (map['extra'] as Map).cast<String, dynamic>()
                : const {},
            createdAt: timestamp is int ? timestamp : DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } else {
        completer.completeError(Exception(map['error'] ?? '消息發送失敗'));
      }
    } catch (e) {
      log('ChatStore _handleServerAck error: $e');
    }
  }

  void _handleNewMessage(dynamic data) {
    try {
      final map = (data as Map).cast<String, dynamic>();
      final msg = ChatMessage.fromJson(map);
      _lastMessageByConv[msg.conversationId] = msg;
      // 非当前打开会话则累计未读
      if (activeConversationId != msg.conversationId) {
        _incrementUnread(msg.conversationId);
      }
      // 会话列表排序：最新消息的会话置顶
      final idx = conversationList.indexWhere((c) => c.id == msg.conversationId);
      if (idx >= 0) {
        final conv = conversationList[idx];
        conversationList.removeAt(idx);
        conversationList.insert(
          0,
          conv.copyWith(
            lastMessageId: msg.messageId,
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
      }
      _newMessageController.add(msg);
    } catch (e) {
      log('ChatStore _handleNewMessage error: $e');
    }
  }

  void _handleMessageRecalled(dynamic data) {
    try {
      final map = (data as Map).cast<String, dynamic>();
      _recalledController.add(map);
    } catch (e) {
      log('ChatStore _handleMessageRecalled error: $e');
    }
  }

  void _handleMessageEdited(dynamic data) {
    try {
      final map = (data as Map).cast<String, dynamic>();
      _editedController.add(map);
    } catch (e) {
      log('ChatStore _handleMessageEdited error: $e');
    }
  }

  void _handleTyping(dynamic data) {
    try {
      final map = (data as Map).cast<String, dynamic>();
      _typingController.add(map);
    } catch (e) {
      log('ChatStore _handleTyping error: $e');
    }
  }

  // 事件流（供聊天页监听）
  final _newMessageController = StreamController<ChatMessage>.broadcast();
  final _recalledController = StreamController<Map<String, dynamic>>.broadcast();
  final _editedController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<ChatMessage> get onNewMessage => _newMessageController.stream;
  Stream<Map<String, dynamic>> get onMessageRecalled =>
      _recalledController.stream;
  Stream<Map<String, dynamic>> get onMessageEdited => _editedController.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;

  /// 当前正在打开的会话 ID（由聊天页设置，用于未读判断）
  String? activeConversationId;

  /// 撤回消息
  Future<bool> recallMessage(String messageId) async {
    try {
      await _request('POST', '/api/v1/messages/$messageId/recall');
      return true;
    } catch (e) {
      log('ChatStore recallMessage error: $e');
      return false;
    }
  }

  /// 编辑消息
  Future<bool> editMessage(String messageId, String content) async {
    try {
      await _request('PUT', '/api/v1/messages/$messageId', body: {
        'content': content,
      });
      return true;
    } catch (e) {
      log('ChatStore editMessage error: $e');
      return false;
    }
  }

  /// 上报已读
  void markRead(String conversationId, String maxReadMessageId) {
    if (_socket == null || maxReadMessageId.isEmpty) return;
    _socket?.emit('mark_read', {
      'conversation_id': conversationId,
      'max_read_message_id': maxReadMessageId,
    });
  }

  /// 加入会话房间（新会话需显式 join）
  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', {'conversation_id': conversationId});
  }

  /// 发送输入状态
  void sendTyping(String conversationId, bool isTyping) {
    _socket?.emit('typing', {
      'conversation_id': conversationId,
      'is_typing': isTyping,
    });
  }

  // ─── 群组 ────────────────────────────────────────────────────

  /// 创建群组（owner = 当前用户），返回 conversation_id
  Future<String> createGroup(String title, List<String> memberIds) async {
    if (_token.isEmpty) return '';
    try {
      final data = await _request(
        'POST',
        '/api/v1/groups',
        body: {'title': title, 'member_ids': memberIds},
      );
      final id = (data['conversation_id'] ?? data['id']) as String? ?? '';
      if (id.isNotEmpty) {
        joinConversation(id);
        await refreshConversationList();
      }
      return id;
    } catch (e) {
      log('ChatStore createGroup error: $e');
      return '';
    }
  }

  /// 已加入的群组列表（从会话列表过滤）
  Future<List<ChatConversation>> getJoinedGroups() async {
    await refreshConversationList();
    return conversationList.where((c) => c.isGroup).toList();
  }

  /// 群组信息（会话详情）
  Future<ChatConversation?> getGroup(String groupId) =>
      getConversation(groupId);

  /// 群成员列表
  Future<List<ChatGroupMember>> getGroupMembers(String groupId) async {
    if (_token.isEmpty) return [];
    try {
      final data = await _request(
        'GET',
        '/api/v1/conversations/$groupId/members',
      );
      final raw = data['value'];
      final list = <ChatGroupMember>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            list.add(ChatGroupMember.fromJson(item));
          }
        }
      }
      return list;
    } catch (e) {
      log('ChatStore getGroupMembers error: $e');
      return [];
    }
  }

  /// 添加群成员
  Future<bool> addGroupMembers(String groupId, List<String> userIds) async {
    if (userIds.isEmpty) return true;
    try {
      await _request('POST', '/api/v1/groups/$groupId/members', body: {
        'user_ids': userIds,
      });
      return true;
    } catch (e) {
      log('ChatStore addGroupMembers error: $e');
      return false;
    }
  }

  /// 移除群成员（群主/管理员；传自己 = 退群）
  Future<bool> removeGroupMember(String groupId, String userId) async {
    try {
      await _request('DELETE', '/api/v1/groups/$groupId/members', body: {
        'user_id': userId,
      });
      return true;
    } catch (e) {
      log('ChatStore removeGroupMember error: $e');
      return false;
    }
  }

  /// 退群
  Future<bool> leaveGroup(String groupId) =>
      removeGroupMember(groupId, currentUserId);

  /// 解散群（仅群主）
  Future<bool> disbandGroup(String groupId) async {
    try {
      await _request('DELETE', '/api/v1/groups/$groupId');
      conversationList.removeWhere((c) => c.id == groupId);
      return true;
    } catch (e) {
      log('ChatStore disbandGroup error: $e');
      return false;
    }
  }

  /// 更新群公告（群主/管理员）
  Future<bool> updateGroupAnnouncement(String groupId, String text) async {
    try {
      await _request(
        'PUT',
        '/api/v1/groups/$groupId/announcement',
        body: {'text': text},
      );
      return true;
    } catch (e) {
      log('ChatStore updateGroupAnnouncement error: $e');
      return false;
    }
  }

  /// 设置成员角色（群主）
  Future<bool> updateMemberRole(
    String groupId,
    String userId,
    String role,
  ) async {
    try {
      await _request(
        'PUT',
        '/api/v1/groups/$groupId/members/$userId/role',
        body: {'role': role},
      );
      return true;
    } catch (e) {
      log('ChatStore updateMemberRole error: $e');
      return false;
    }
  }

  /// 禁言成员（群主/管理员）
  Future<bool> muteMember(
    String groupId,
    String userId,
    int durationMinutes,
  ) async {
    try {
      await _request('POST', '/api/v1/groups/$groupId/mute', body: {
        'user_id': userId,
        'duration_minutes': durationMinutes,
      });
      return true;
    } catch (e) {
      log('ChatStore muteMember error: $e');
      return false;
    }
  }

  // ─── 工具 ────────────────────────────────────────────────────

  void _incrementUnread(String conversationId) {
    _unreadByConv[conversationId] = (_unreadByConv[conversationId] ?? 0) + 1;
    totalUnreadCount.value = _unreadByConv.values.fold(0, (a, b) => a + b);
  }

  void clearUnread(String conversationId) {
    if (_unreadByConv.remove(conversationId) != null) {
      totalUnreadCount.value = _unreadByConv.values.fold(0, (a, b) => a + b);
    }
  }

  ChatMessage _buildLocalMessage({
    required String messageId,
    required String conversationId,
    required String type,
    required String content,
    Map<String, dynamic> extra = const {},
    required int createdAt,
  }) {
    return ChatMessage(
      messageId: messageId,
      conversationId: conversationId,
      senderId: currentUserId,
      type: type,
      content: content,
      extra: extra,
      createdAt: createdAt,
      status: 'SENT',
    );
  }

  static String _generateClientMsgId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = (DateTime.now().microsecondsSinceEpoch % 1000000).toString();
    return 'lumo_${now}_$rand';
  }
}
