import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class ChatController extends GetxController with ApiMixin, UserStoreMixin {
  late ChatConversation conversation;

  String? get conversationID => conversation.id;

  /// 消息历史（时间升序）
  final _messages = <ChatMessage>[].obs;
  List<ChatMessage> get messages => _messages;

  /// 更早消息分页游标（= 当前最旧消息的 message_id）
  String? _nextCursor;

  /// 是否还有更早消息
  final _hasMore = false.obs;
  bool get hasMore => _hasMore.value;

  /// 正在加载更早消息
  final _loadingOlder = false.obs;
  bool get loadingOlder => _loadingOlder.value;

  final _peerInfo = Rxn<MemberInfo>();
  MemberInfo? get memberInfo => _peerInfo.value;

  /// 对方是否正在输入
  final peerTyping = false.obs;

  /// 群聊成员展示名称缓存（user_id -> 认证名称/昵称）
  final _memberNames = <String, String>{};

  /// 会话标题（单聊 = 对方名称，群聊 = 群名）
  final _title = ''.obs;
  String get title => _title.value;

  final TextEditingController inputController = TextEditingController();

  /// 输入内容（响应式，用于发送按钮可用态）
  final _inputText = ''.obs;
  String get inputText => _inputText.value;

  StreamSubscription? _newMsgSub;
  StreamSubscription? _recalledSub;
  StreamSubscription? _editedSub;
  StreamSubscription? _typingSub;

  Timer? _typingStopTimer;
  Timer? _typingDebounceTimer;
  bool _sending = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is! Map) {
      Get.back();
      return;
    }
    final args = Get.arguments as Map;
    conversation = args['conversation'] as ChatConversation;
    _resolveTitle();
  }

  @override
  void onReady() {
    super.onReady();
    ChatStore.to.activeConversationId = conversationID;
    ChatStore.to.openConversation(conversationID!);
    // 上报当前打开的会话（在线推送判断：正在看该会话则不推）
    ChatStore.to.setActiveConversation(conversationID);
    _loadMessages();
    _subscribeEvents();
    if (conversation.isGroup) {
      _loadGroupMemberNames();
    } else {
      fetchPeerInfo();
    }
  }

  @override
  void onClose() {
    // 离开对话页 → 上报 null（之后收到的消息要推送）
    ChatStore.to.setActiveConversation(null);
    ChatStore.to.activeConversationId = null;
    _newMsgSub?.cancel();
    _recalledSub?.cancel();
    _editedSub?.cancel();
    _typingSub?.cancel();
    _typingStopTimer?.cancel();
    _typingDebounceTimer?.cancel();
    inputController.dispose();
    super.onClose();
  }

  void _resolveTitle() {
    if (conversation.isGroup) {
      _title.value =
          (conversation.title?.isNotEmpty ?? false)
              ? conversation.title!
              : '群聊'.tr;
    } else {
      _title.value =
          (conversation.peerUserId?.isNotEmpty ?? false)
              ? conversation.peerUserId!
              : '聊天'.tr;
    }
  }

  /// 拉取历史消息并上报已读
  Future<void> _loadMessages() async {
    final page = await ChatStore.to.fetchMessagePage(
      conversationID!,
      limit: 50,
    );
    _messages.assignAll(page.messages);
    _nextCursor = page.nextCursor;
    _hasMore.value = page.hasMore;
    if (page.messages.isNotEmpty) {
      await ChatStore.to.markRead(conversationID!, page.messages.last.messageId);
    }
  }

  /// 上滑到顶部时加载更早消息（cursor 分页，防重入）
  Future<void> loadOlderMessages() async {
    if (_loadingOlder.value || !_hasMore.value) return;
    final cursor = _nextCursor;
    if (cursor == null || cursor.isEmpty) return;
    _loadingOlder.value = true;
    try {
      final page = await ChatStore.to.fetchMessagePage(
        conversationID!,
        cursor: cursor,
        limit: 30,
      );
      if (page.messages.isNotEmpty) {
        _messages.insertAll(0, page.messages);
      }
      _nextCursor = page.nextCursor;
      _hasMore.value = page.hasMore;
    } finally {
      _loadingOlder.value = false;
    }
  }

  void _subscribeEvents() {
    _newMsgSub = ChatStore.to.onNewMessage.listen((msg) {
      if (msg.conversationId != conversationID) return;
      _messages.add(msg);
      ChatStore.to.markRead(conversationID!, msg.messageId);
    });

    _recalledSub = ChatStore.to.onMessageRecalled.listen((data) {
      final msgId = data['message_id'] as String? ?? '';
      final idx = _messages.indexWhere((m) => m.messageId == msgId);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(isRecalled: true);
        _messages.refresh();
      }
    });

    _editedSub = ChatStore.to.onMessageEdited.listen((data) {
      final msgId = data['message_id'] as String? ?? '';
      final content = data['content'] as String? ?? '';
      final editedAt = data['edited_at'];
      final idx = _messages.indexWhere((m) => m.messageId == msgId);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(
          content: content,
          editedAt: editedAt is int ? editedAt : null,
        );
        _messages.refresh();
      }
    });

    _typingSub = ChatStore.to.onTyping.listen((data) {
      if (data['conversation_id'] != conversationID) return;
      if (data['user_id'] == userInfo.number) return;
      peerTyping.value = data['is_typing'] == true;
    });
  }

  /// 获取单聊对方资料（用于标题/头像/跳转）
  Future<void> fetchPeerInfo() async {
    final peerId = conversation.peerUserId;
    if (peerId == null || peerId.isEmpty) return;
    final res = await get(
      ApiUrl.memberInfo,
      parameters: {'user_number': peerId},
    );
    if (!res.isSuccess) return;
    _peerInfo.value = MemberInfo.fromJson(res.dataJson);
    // 单聊标题用认证名称（导游/公司），否则用昵称
    final info = PeerChatInfo.fromMember(_peerInfo.value!);
    if (info.name.isNotEmpty) {
      _title.value = info.name;
    }
  }

  /// 对方展示头像（认证导游照片 / 公司形象照；无则空串）
  String get peerAvatar {
    final info = memberInfo;
    if (info == null) return '';
    return PeerChatInfo.fromMember(info).avatar;
  }

  /// 对方所在城市（认证导游/公司常駐城市；无则空串）
  String get peerCity {
    final info = memberInfo;
    if (info == null) return '';
    return PeerChatInfo.fromMember(info).city;
  }

  /// 群聊：预取成员展示名称（认证导游/公司名称，失败回退用户 ID）
  Future<void> _loadGroupMemberNames() async {
    final members = await ChatStore.to.getGroupMembers(conversationID!);
    await Future.wait(members.map((m) async {
      if (m.userId == userInfo.number) return;
      if (_memberNames.containsKey(m.userId)) return;
      try {
        final res = await get(
          ApiUrl.memberInfo,
          parameters: {'user_number': m.userId},
        );
        if (res.isSuccess) {
          final info = PeerChatInfo.fromMember(
            MemberInfo.fromJson(res.dataJson),
          );
          _memberNames[m.userId] = info.name.isNotEmpty
              ? info.name
              : m.userId;
        }
      } catch (e) {
        // 静默
      }
    }));
  }

  /// 消息发送者展示名称（群聊用缓存，单聊返回空）
  String senderName(String senderId) {
    if (!conversation.isGroup) return '';
    return _memberNames[senderId] ?? senderId;
  }

  // ─── 发送 ────────────────────────────────────────────────────

  Future<void> sendText() async {
    final content = inputController.text.trim();
    if (content.isEmpty || _sending) return;
    _sending = true;
    try {
      final msg = await ChatStore.to.sendTextMessage(conversationID!, content);
      _appendSentMessage(msg);
      inputController.clear();
      _inputText.value = '';
      ChatStore.to.sendTyping(conversationID!, false);
    } catch (e) {
      Loading.error(e.toString());
    } finally {
      _sending = false;
    }
  }

  /// 选择并发送图片
  Future<void> sendImage() async {
    final imagePath = await ImagePickerUtil.selectImageFromGallery(
      Get.context!,
      canEdit: false,
    );
    if (imagePath.isEmpty) return;
    Loading.show('上傳中...'.tr);
    final url = await ConfigService.to.uploadFile(imagePath);
    Loading.dismiss();
    if (url.isEmpty) {
      Loading.error('圖片上傳失敗'.tr);
      return;
    }
    try {
      final msg = await ChatStore.to.sendImageMessage(conversationID!, url);
      _appendSentMessage(msg);
    } catch (e) {
      Loading.error(e.toString());
    }
  }

  /// 发送者收不到 new_message 广播，需本地追加自己发出的消息
  void _appendSentMessage(ChatMessage msg) {
    final idx = _messages.indexWhere((m) => m.messageId == msg.messageId);
    if (idx >= 0) {
      _messages[idx] = msg;
    } else {
      _messages.add(msg);
    }
    _messages.refresh();
  }

  /// 输入变化：防抖上报输入状态（避免每次按键都 emit socket）
  void onInputChanged(String value) {
    _inputText.value = value;
    final convId = conversationID;
    if (convId == null) return;
    _typingStopTimer?.cancel();
    // 停顿 400ms 后上报一次「正在输入」，随后 2 秒内无输入自动停止
    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      ChatStore.to.sendTyping(convId, true);
      _typingStopTimer = Timer(const Duration(seconds: 2), () {
        ChatStore.to.sendTyping(convId, false);
      });
    });
  }

  // ─── 交互 ────────────────────────────────────────────────────

  /// 群聊右上角更多 → 群组详情
  Future<void> onMore() async {
    if (!conversation.isGroup) return;
    await Get.toNamed(
      AppRoutes.GROUP_PROFILE,
      arguments: {'groupID': conversationID},
    );
    final updated = await ChatStore.to.getConversation(conversationID!);
    if (updated != null) {
      conversation = updated;
      _resolveTitle();
    }
  }

  /// 对方所在位置（城市 · 国家 · 地區；聊天页标题下方展示）
  String get peerLocation {
    final info = memberInfo;
    if (info == null) return '';
    return PeerChatInfo.fromMember(info).locationArea;
  }

  /// 对方身份标签（导游认证类型 / 商家经营分类；聊天页标题名称后展示）
  String get peerBadge {
    final info = memberInfo;
    if (info == null) return '';
    return PeerChatInfo.fromMember(info).badge;
  }

  /// 本人认证身份头像（导游照片/公司形象照；普通用户用个人头像）
  String get myCertifiedAvatar {
    final info = UserStore.to.profile;
    if (info.identity == 2) {
      final photo = info.guideInfo?.photo ?? '';
      if (photo.isNotEmpty) return photo;
    } else if (info.identity == 3) {
      final pic = info.companyInfo?.picture ?? '';
      if (pic.isNotEmpty) return pic;
    }
    return info.avatar ?? '';
  }

  /// 点击头像：自己的头像 → 对应身份详情页；对方头像 → 导游/公司详情页
  /// （单聊已预取资料；群聊懒加载，普通用户无公开详情页则提示）
  Future<void> onTapAvatar(String userID, TapDownDetails tapDetails) async {
    // 自己的头像 → 本人认证身份详情页（普通用户 → 修改资料页）
    if (userID.isEmpty || userInfo.number == userID) {
      _openMyDetail();
      return;
    }

    final info = memberInfo;
    if (info != null) {
      _openPeerDetail(info);
      return;
    }

    // 群聊场景：按需拉取对方资料
    final res = await get(
      ApiUrl.memberInfo,
      parameters: {'user_number': userID},
    );
    if (!res.isSuccess) return;
    _openPeerDetail(MemberInfo.fromJson(res.dataJson));
  }

  /// 本人身份详情页：导游 → 导游详情；公司 → 公司详情；普通用户 → 修改资料
  void _openMyDetail() {
    final info = UserStore.to.profile;
    if (info.identity == 2 && (info.guideInfo?.id ?? 0) > 0) {
      Get.toNamed(
        AppRoutes.GUIDE_DETAIL,
        arguments: {'id': info.guideInfo?.id},
      );
    } else if (info.identity == 3 && (info.companyInfo?.id ?? 0) > 0) {
      Get.toNamed(
        AppRoutes.COMPANY_INFO,
        arguments: {'id': info.companyInfo?.id},
      );
    } else {
      Get.toNamed(AppRoutes.PROFILE);
    }
  }

  void _openPeerDetail(MemberInfo info) {
    if (info.identity == 2) {
      final previousRoute = Get.previousRoute;
      if (previousRoute == AppRoutes.GUIDE_DETAIL) {
        Get.back();
        return;
      }
      if (info.guideId != null && info.guideId! > 0) {
        Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': info.guideId});
      }
    } else if (info.identity == 3) {
      if (info.companyId != null && info.companyId! > 0) {
        Get.toNamed(
          AppRoutes.COMPANY_INFO,
          arguments: {'id': info.companyId},
        );
      }
    } else {
      Loading.toast('暫無詳細信息'.tr);
    }
  }

  /// 撤回自己的消息
  Future<void> recallMessage(ChatMessage message) async {
    if (!message.isMine) return;
    final ok = await ChatStore.to.recallMessage(message.messageId);
    if (ok) {
      final idx = _messages.indexWhere((m) => m.messageId == message.messageId);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(isRecalled: true);
        _messages.refresh();
      }
    } else {
      Loading.error('撤回失敗'.tr);
    }
  }

  /// 编辑自己的消息（仅文本）
  Future<void> editMessage(ChatMessage message, String newContent) async {
    if (!message.isMine || message.isRecalled) return;
    final content = newContent.trim();
    if (content.isEmpty || content == message.content) return;
    final ok = await ChatStore.to.editMessage(message.messageId, content);
    if (ok) {
      final idx = _messages.indexWhere((m) => m.messageId == message.messageId);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(
          content: content,
          editedAt: DateTime.now().millisecondsSinceEpoch,
        );
        _messages.refresh();
      }
    } else {
      Loading.error('修改失敗'.tr);
    }
  }
}
