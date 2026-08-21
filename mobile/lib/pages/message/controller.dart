import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MessageController extends GetxController
    with ApiMixin, RefreshableMixin, UserStoreMixin, WidgetsBindingObserver {
  final _messageList = MessageLists().obs;
  MessageLists get messageList => _messageList.value;

  /// 是否已加入至少一个群组（供「我的群聊」入口是否显示）
  final hasJoinedGroups = false.obs;

  /// 单聊对方资料缓存（peer user_id -> 认证名称/头像/城市）
  final _peerInfos = <String, PeerChatInfo>{}.obs;
  Map<String, PeerChatInfo> get peerInfos => _peerInfos;

  Timer? _messageListPollTimer;
  static const Duration _messageListPollInterval = Duration(seconds: 30);

  StreamSubscription? _chatStreamSub;

  List<MessageTopFixedModel> get topFixedList {
    final List<MessageTopFixedModel> messages = [];

    if (messageList.followMessage?.text != null) {
      messages.add(
        MessageTopFixedModel(
          topFixed: MessageTopFixed.follow,
          time: messageList.followMessage?.formatTime,
          text: messageList.followMessage?.text,
        ),
      );
    }

    if (messageList.evaluateMessage?.text != null) {
      messages.add(
        MessageTopFixedModel(
          topFixed: MessageTopFixed.evaluate,
          time: messageList.evaluateMessage?.formatTime,
          text: messageList.evaluateMessage?.text,
        ),
      );
    }

    if (messageList.reserveMessage?.text != null) {
      messages.add(
        MessageTopFixedModel(
          topFixed: MessageTopFixed.reserve,
          time: messageList.reserveMessage?.formatTime,
          text: messageList.reserveMessage?.text,
        ),
      );

      if (messageList.myReserveMessage?.text != null) {
        messages.add(
          MessageTopFixedModel(
            topFixed: MessageTopFixed.myReserve,
            time: messageList.myReserveMessage?.formatTime,
            text: messageList.myReserveMessage?.text,
          ),
        );
      }
    }

    if (ChatStore.to.isReady) {
      for (final conversation in ChatStore.to.conversationList) {
        final lastMessage = ChatStore.to.lastMessageOf(conversation.id);
        final text = _chatPreviewText(conversation, lastMessage);
        final time = _chatPreviewTime(conversation);

        messages.add(
          MessageTopFixedModel(
            topFixed: MessageTopFixed.chat,
            time: time,
            text: text,
            conversation: conversation,
          ),
        );
      }
    }

    messages.sort((a, b) {
      final isAFixed = a.topFixed != MessageTopFixed.chat;
      final isBFixed = b.topFixed != MessageTopFixed.chat;

      if (isAFixed && !isBFixed) return -1;
      if (!isAFixed && isBFixed) return 1;

      if (isAFixed && isBFixed) {
        final timeA = _getMessageTime(a);
        final timeB = _getMessageTime(b);

        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;

        return timeB.compareTo(timeA);
      }

      final timeA = _getMessageTime(a);
      final timeB = _getMessageTime(b);

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;

      return timeB.compareTo(timeA);
    });

    return messages;
  }

  /// 会话列表预览文本
  String _chatPreviewText(ChatConversation conv, ChatMessage? lastMessage) {
    if (lastMessage == null) return '';
    if (lastMessage.isRecalled) return '[${'已撤回'.tr}]';
    switch (lastMessage.type) {
      case 'TEXT':
        return lastMessage.content;
      case 'IMAGE':
        return '[${'圖片'.tr}]';
      case 'VOICE':
        return '[${'語音'.tr}]';
      case 'VIDEO':
        return '[${'視頻'.tr}]';
      case 'FILE':
        return '[${'文件'.tr}]';
      default:
        return '[${'消息'.tr}]';
    }
  }

  /// 会话列表时间（updated_at ISO 或缓存消息时间）
  String? _chatPreviewTime(ChatConversation conv) {
    final lastMessage = ChatStore.to.lastMessageOf(conv.id);
    if (lastMessage != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        lastMessage.createdAt,
      ).formatTimeAgo();
    }
    final updatedAt = conv.updatedAt;
    if (updatedAt != null && updatedAt.isNotEmpty) {
      final date = DateTime.tryParse(updatedAt);
      if (date != null) return date.formatTimeAgo();
    }
    return null;
  }

  DateTime? _getMessageTime(MessageTopFixedModel model) {
    if (model.topFixed == MessageTopFixed.chat) {
      final conversation = model.conversation as ChatConversation?;
      final lastMessage = conversation == null
          ? null
          : ChatStore.to.lastMessageOf(conversation.id);
      if (lastMessage != null) {
        return DateTime.fromMillisecondsSinceEpoch(lastMessage.createdAt);
      }
      final updatedAt = conversation?.updatedAt;
      if (updatedAt != null && updatedAt.isNotEmpty) {
        return DateTime.tryParse(updatedAt);
      }
      return null;
    }
    return _getOriginalTime(model.topFixed);
  }

  DateTime? _getOriginalTime(MessageTopFixed? topFixed) {
    switch (topFixed) {
      case MessageTopFixed.follow:
        final timeStr = messageList.followMessage?.time;
        return timeStr != null ? DateTime.tryParse(timeStr) : null;
      case MessageTopFixed.evaluate:
        final timeStr = messageList.evaluateMessage?.time;
        return timeStr != null ? DateTime.tryParse(timeStr) : null;
      case MessageTopFixed.reserve:
        final timeStr = messageList.reserveMessage?.time;
        return timeStr != null ? DateTime.tryParse(timeStr) : null;
      case MessageTopFixed.myReserve:
        final timeStr = messageList.myReserveMessage?.time;
        return timeStr != null ? DateTime.tryParse(timeStr) : null;
      default:
        return null;
    }
  }

  List<MessageCategory> get categoryList {
    if (userInfo.isGuide) {
      return [
        MessageCategory.myComment,
        MessageCategory.commentMe,
        MessageCategory.myFollow,
        MessageCategory.followMe,
        MessageCategory.system,
      ];
    }
    if (userInfo.isEnterprise) {
      return [
        MessageCategory.commentMe,
        MessageCategory.myFollow,
        MessageCategory.followMe,
        MessageCategory.system,
      ];
    }
    return [MessageCategory.myFollow, MessageCategory.system];
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initRefresh();
    fetchData();
    _startMessageListPoll();
    // 监听会话列表变化 + 新消息（刷新列表 / 未读角标）
    ChatStore.to.conversationList.listen((_) {
      update();
      _updateHasJoinedGroups();
      _resolvePeerInfos();
    });
    _chatStreamSub = ChatStore.to.onNewMessage.listen((_) {
      update();
    });
  }

  @override
  void onClose() {
    _stopMessageListPoll();
    _chatStreamSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startMessageListPoll();
      fetchData();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopMessageListPoll();
    }
  }

  void _startMessageListPoll() {
    _stopMessageListPoll();
    _messageListPollTimer = Timer.periodic(
      _messageListPollInterval,
      (_) => fetchData(),
    );
  }

  void _stopMessageListPoll() {
    _messageListPollTimer?.cancel();
    _messageListPollTimer = null;
  }

  Future<void> _updateHasJoinedGroups() async {
    final list = ChatStore.to.conversationList;
    hasJoinedGroups.value = list.any((c) => c.isGroup);
  }

  /// 为单聊会话拉取对方资料（认证名称/头像/城市，并行、失败静默）
  Future<void> _resolvePeerInfos() async {
    if (!isLogin) return;
    final peers = <String>{};
    for (final conv in ChatStore.to.conversationList) {
      if (conv.isGroup) continue;
      final peerId = conv.peerUserId;
      if (peerId == null ||
          peerId.isEmpty ||
          _peerInfos.containsKey(peerId)) {
        continue;
      }
      peers.add(peerId);
    }
    if (peers.isEmpty) return;
    await Future.wait(peers.map((peerId) async {
      try {
        final res = await get(
          ApiUrl.memberInfo,
          parameters: {'user_number': peerId},
        );
        if (res.isSuccess) {
          final member = MemberInfo.fromJson(res.dataJson);
          _peerInfos[peerId] = PeerChatInfo.fromMember(member);
        }
      } catch (e) {
        // 静默
      }
    }));
  }

  Future<void> _refreshConversationList() async {
    if (ChatStore.to.isReady) {
      await ChatStore.to.refreshConversationList();
    }
  }

  Future<void> deleteConversation(MessageTopFixedModel model) async {
    if (model.topFixed != MessageTopFixed.chat || model.conversation == null) {
      return;
    }

    final confirmed = await AlertUtils.show(
      title: '刪除會話'.tr,
      content: '確定要刪除此會話嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
      confirmTextColor: AppColors.red,
    );

    if (!confirmed) {
      return;
    }

    final conversation = model.conversation as ChatConversation;
    await ChatStore.to.deleteConversation(conversation.id);
    Loading.success('刪除成功'.tr);
  }

  int messageCount(MessageCategory category) {
    switch (category) {
      case MessageCategory.system:
        return messageList.systemCount;
      case MessageCategory.followMe:
        return messageList.followMyCount;
      case MessageCategory.commentMe:
        return messageList.evaluateMyCount;
      default:
        return 0;
    }
  }

  Future<void> onScan() async {
    final result = await Get.toNamed(AppRoutes.SCAN);
    if (result == null || result.trim().isEmpty) return;
    final payload = AppQRCode.parse(result.trim());
    if (payload == null) {
      Loading.error('未識別到有效的 LUMOGUIDE 二維碼'.tr);
      return;
    }
    await _handleQRCodePayload(payload);
  }

  Future<void> _handleQRCodePayload(AppQRCodePayload payload) async {
    switch (payload.type) {
      case AppQRCodeType.group:
        await _handleScannedGroup(payload.payload);
        break;
      case AppQRCodeType.user:
        _handleScannedUser(payload.payload);
        break;
      case AppQRCodeType.unknown:
        Loading.error('未識別到二維碼'.tr);
        break;
    }
  }

  Future<void> _handleScannedGroup(String groupID) async {
    if (groupID.isEmpty) return;
    // LUMO-Chat 无自助加群接口：群成员需由群主/管理员添加
    Loading.error('無法直接加入群組，請聯繫群主邀請'.tr);
  }

  void _handleScannedUser(String userID) {
    if (userID.isEmpty) return;
    Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': userID});
  }

  /// 創建群組：進入選擇好友頁
  void onCreateGroup() {
    Get.toNamed(AppRoutes.SELECT_MEMBERS);
  }

  onTapCategory(MessageCategory category) async {
    switch (category) {
      case MessageCategory.system:
        await Get.toNamed(AppRoutes.MESSAGE_SYSTEM);
        fetchData();
        break;
      case MessageCategory.myFollow:
        Get.toNamed(AppRoutes.FOLLOW, arguments: {'isMyFollow': true});
        break;
      case MessageCategory.followMe:
        await Get.toNamed(AppRoutes.FOLLOW, arguments: {'isMyFollow': false});
        fetchData();
        break;
      case MessageCategory.myComment:
        Get.toNamed(AppRoutes.COMMENT, arguments: {'isMyComment': true});
        break;
      case MessageCategory.commentMe:
        await Get.toNamed(AppRoutes.COMMENT, arguments: {'isMyComment': false});
        fetchData();
        break;
    }
  }

  onTapTopFixed(MessageTopFixedModel model) async {
    switch (model.topFixed) {
      case MessageTopFixed.follow:
        onTapCategory(MessageCategory.followMe);
        break;
      case MessageTopFixed.evaluate:
        onTapCategory(MessageCategory.commentMe);
        break;
      case MessageTopFixed.reserve:
        if (userInfo.isGuide) {
          Get.toNamed(AppRoutes.GUIDE_BOOKING_MANAGER);
        } else {
          Get.toNamed(AppRoutes.MERCHANT_BOOKING_MANAGER);
        }
        break;
      case MessageTopFixed.myReserve:
        Get.toNamed(AppRoutes.USER_BOOKING_MANAGER);
        break;
      case MessageTopFixed.chat:
        if (model.conversation != null) {
          await Get.toNamed(
            AppRoutes.CHAT,
            arguments: {'conversation': model.conversation},
          );
          await _refreshConversationList();
        }
        break;
      default:
        break;
    }
    fetchData();
  }

  /// 会话显示标题（单聊取认证名称/昵称，群聊取群名）
  String conversationTitle(ChatConversation conversation) {
    if (conversation.isGroup) {
      return (conversation.title?.isNotEmpty ?? false)
          ? conversation.title!
          : '群聊'.tr;
    }
    final peerId = conversation.peerUserId ?? '';
    if (peerId.isNotEmpty && _peerInfos.containsKey(peerId)) {
      final name = _peerInfos[peerId]!.name;
      if (name.isNotEmpty) return name;
    }
    return peerId.isNotEmpty ? peerId : '聊天'.tr;
  }

  /// 单聊对方头像（认证导游照片 / 公司形象照；无则空串）
  String conversationAvatar(ChatConversation conversation) {
    if (conversation.isGroup) return conversation.avatar ?? '';
    final peerId = conversation.peerUserId ?? '';
    if (peerId.isNotEmpty && _peerInfos.containsKey(peerId)) {
      return _peerInfos[peerId]!.avatar;
    }
    return '';
  }

  /// 单聊对方身份标签（导游认证类型 / 商家经营分类；无则空串）
  String conversationBadge(ChatConversation conversation) {
    if (conversation.isGroup) return '';
    final peerId = conversation.peerUserId ?? '';
    if (peerId.isNotEmpty && _peerInfos.containsKey(peerId)) {
      return _peerInfos[peerId]!.badge;
    }
    return '';
  }

  /// 单聊对方所在位置（城市 · 国家 · 大洲；无则空串）
  String conversationLocation(ChatConversation conversation) {
    if (conversation.isGroup) return '';
    final peerId = conversation.peerUserId ?? '';
    if (peerId.isNotEmpty && _peerInfos.containsKey(peerId)) {
      return _peerInfos[peerId]!.location;
    }
    return '';
  }

  @override
  Future<void> fetchData() async {
    if (!isLogin) return;
    await _refreshConversationList();
    _updateHasJoinedGroups();
    _resolvePeerInfos();
    final res = await get(ApiUrl.messageList);
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    _messageList.value = MessageLists.fromJson(res.dataJson);
    endLoad([]);
  }
}

extension on MessageController {}
