import '../extensions/map.dart';
import 'member_info.dart';

/// LUMO-Chat 会话（对应 GET /api/v1/conversations 返回的 conversation 对象）
class ChatConversation {
  final String id;
  final String type; // DIRECT | GROUP
  final String? title;
  final String? announcement;
  final String? avatar;
  final String? lastMessageId;
  final String? updatedAt; // ISO 8601
  final String? role; // OWNER | ADMIN | MEMBER
  final String? lastReadMessageId;
  final String? mutedUntil;
  final String? peerUserId; // DIRECT 会话的对方 user_id

  bool get isGroup => type == 'GROUP';

  ChatConversation({
    required this.id,
    required this.type,
    this.title,
    this.announcement,
    this.avatar,
    this.lastMessageId,
    this.updatedAt,
    this.role,
    this.lastReadMessageId,
    this.mutedUntil,
    this.peerUserId,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json.safeString('id') ?? json.safeString('conversation_id') ?? '',
      type: json.safeString('type') ?? 'DIRECT',
      title: json.safeString('title'),
      announcement: json.safeString('announcement'),
      avatar: json.safeString('avatar'),
      lastMessageId: json.safeString('last_message_id'),
      updatedAt: json.safeString('updated_at'),
      role: json.safeString('role'),
      lastReadMessageId: json.safeString('last_read_message_id'),
      mutedUntil: json.safeString('muted_until'),
      peerUserId: json.safeString('peer_user_id'),
    );
  }

  ChatConversation copyWith({
    String? title,
    String? announcement,
    String? avatar,
    String? lastMessageId,
    String? updatedAt,
    String? role,
    String? lastReadMessageId,
  }) {
    return ChatConversation(
      id: id,
      type: type,
      title: title ?? this.title,
      announcement: announcement ?? this.announcement,
      avatar: avatar ?? this.avatar,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      mutedUntil: mutedUntil,
      peerUserId: peerUserId,
    );
  }
}

/// LUMO-Chat 消息（对应消息历史 / new_message 事件）
class ChatMessage {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String type; // TEXT | IMAGE | VOICE | FILE | VIDEO | CUSTOM
  final String content;
  final Map<String, dynamic> extra;
  final bool isRecalled;
  final int? editedAt; // 毫秒
  final Map<String, dynamic> reactions;
  final int createdAt; // 毫秒时间戳
  final String status; // SENT | DELIVERED | READ

  bool get isMine => senderId == ChatStoreRef.currentUserId;

  ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.content,
    this.extra = const {},
    this.isRecalled = false,
    this.editedAt,
    this.reactions = const {},
    required this.createdAt,
    this.status = 'SENT',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json.safeString('message_id') ?? '',
      conversationId: json.safeString('conversation_id') ?? '',
      senderId: json.safeString('sender_id') ?? '',
      type: json.safeString('type') ?? 'TEXT',
      content: json.safeString('content') ?? '',
      extra: json.safeMap('extra') ?? const {},
      isRecalled: json.safeBool('is_recalled') ?? false,
      editedAt: json.safeInt('edited_at'),
      reactions: json.safeMap('reactions') ?? const {},
      createdAt: json.safeInt('created_at') ?? 0,
      status: json.safeString('status') ?? 'SENT',
    );
  }

  ChatMessage copyWith({
    bool? isRecalled,
    String? content,
    int? editedAt,
    String? status,
    Map<String, dynamic>? reactions,
  }) {
    return ChatMessage(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      content: content ?? this.content,
      extra: extra,
      isRecalled: isRecalled ?? this.isRecalled,
      editedAt: editedAt ?? this.editedAt,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

/// LUMO-Chat 会话成员（对应 GET /api/v1/conversations/:id/members）
class ChatGroupMember {
  final String userId;
  final String role; // OWNER | ADMIN | MEMBER
  final String? lastReadMessageId;

  ChatGroupMember({
    required this.userId,
    required this.role,
    this.lastReadMessageId,
  });

  factory ChatGroupMember.fromJson(Map<String, dynamic> json) {
    return ChatGroupMember(
      userId: json.safeString('user_id') ?? '',
      role: json.safeString('role') ?? 'MEMBER',
      lastReadMessageId: json.safeString('last_read_message_id'),
    );
  }
}

/// LUMO-Chat 消息分页结果（消息升序 + 游标 + 是否还有更早消息）
class ChatMessagePage {
  final List<ChatMessage> messages;
  final String? nextCursor;
  final bool hasMore;

  const ChatMessagePage({
    this.messages = const [],
    this.nextCursor,
    this.hasMore = false,
  });

  static const empty = ChatMessagePage();
}

/// 占位引用：避免模型与 store 循环依赖，运行时由 ChatStore 注入当前用户 ID。
class ChatStoreRef {
  static String currentUserId = '';
}

/// 单聊对方的展示资料：认证导游/公司名称 + 头像 + 所在城市/国家/大洲/地區 + 身份标签
class PeerChatInfo {
  final String name;
  final String avatar;
  final String city;
  final String country;
  final String continent;
  final String area;

  /// 身份标签：导游 = 认证类型（如 Local guide），商家 = 经营分类（如 餐廳）
  final String badge;

  PeerChatInfo({
    this.name = '',
    this.avatar = '',
    this.city = '',
    this.country = '',
    this.continent = '',
    this.area = '',
    this.badge = '',
  });

  /// 完整地理位置：「城市 · 国家 · 大洲」（逐级拼接，缺失部分省略）
  String get location {
    final parts = [city, country, continent].where((s) => s.isNotEmpty);
    return parts.join(' · ');
  }

  /// 聊天页用：「城市 · 国家 · 地區」
  String get locationArea {
    final parts = [city, country, area].where((s) => s.isNotEmpty);
    return parts.join(' · ');
  }

  factory PeerChatInfo.fromMember(MemberInfo member) {
    // 认证导游：优先英文名，头像取导游照片，城市取常駐城市，标签取认证类型
    if (member.identity == 2) {
      final guide = member.guideInfo;
      final name = (guide?.nameEn?.isNotEmpty ?? false)
          ? guide!.nameEn!
          : (guide?.name ?? '');
      return PeerChatInfo(
        name: name,
        avatar: guide?.photo ?? '',
        city: guide?.cityName ?? '',
        country: member.cityCountry ?? '',
        continent: member.cityContinent ?? '',
        area: member.cityArea ?? '',
        badge: guide?.identityTypeName ?? '',
      );
    }
    // 认证企业：优先英文名，头像取公司形象照，城市取公司城市，标签取经营分类
    if (member.identity == 3) {
      final company = member.companyInfo;
      final name = (company?.nameEn?.isNotEmpty ?? false)
          ? company!.nameEn!
          : (company?.name ?? '');
      return PeerChatInfo(
        name: name,
        avatar: company?.picture ?? '',
        city: company?.cityName ?? '',
        country: member.cityCountry ?? '',
        continent: member.cityContinent ?? '',
        area: member.cityArea ?? '',
        badge: company?.businessType ?? '',
      );
    }
    // 普通用户：昵称/头像
    return PeerChatInfo(
      name: member.nickname ?? '',
      avatar: member.avatar ?? '',
    );
  }
}
