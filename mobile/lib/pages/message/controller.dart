import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

import '../index.dart';

class MessageController extends GetxController
    with ApiMixin, RefreshableMixin, UserStoreMixin, WidgetsBindingObserver {
  final _messageList = MessageLists().obs;
  MessageLists get messageList => _messageList.value;

  /// 是否已加入至少一个群组（供「我的群聊」入口是否显示）
  final hasJoinedGroups = false.obs;

  Timer? _messageListPollTimer;
  static const Duration _messageListPollInterval = Duration(seconds: 30);

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

    if (TIMStore.to.isIMLoginReady) {
      for (final conversation in TIMStore.to.conversationList) {
        final lastMessage = conversation.lastMessage;
        String? text;
        if (lastMessage != null) {
          if (lastMessage.textElem != null) {
            text = lastMessage.textElem?.text;
            if (text != null && text.contains('[TUIEmoji_')) {
              text = '[${'表情'.tr}]';
            }
          } else if (lastMessage.customElem != null) {
            text = '[${'自定義消息'.tr}]';
          } else if (lastMessage.imageElem != null) {
            text = '[${'圖片'.tr}]';
          } else if (lastMessage.videoElem != null) {
            text = '[${'視頻'.tr}]';
          } else if (lastMessage.soundElem != null) {
            text = '[${'語音'.tr}]';
          } else if (lastMessage.fileElem != null) {
            text = '[${'文件'.tr}]';
          } else {
            text = '[${'消息'.tr}]';
          }
        }

        String? time;
        if (lastMessage?.timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            lastMessage!.timestamp! * 1000,
          );
          time = date.formatTimeAgo();
        }

        messages.add(
          MessageTopFixedModel(
            topFixed: MessageTopFixed.chat,
            time: time,
            text: text ?? '',
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

      final isAPinned = (a.conversation)?.isPinned == true;
      final isBPinned = (b.conversation)?.isPinned == true;
      if (isAPinned && !isBPinned) return -1;
      if (!isAPinned && isBPinned) return 1;
      return timeB.compareTo(timeA);
    });

    return messages;
  }

  DateTime? _getMessageTime(MessageTopFixedModel model) {
    if (model.topFixed == MessageTopFixed.chat) {
      final conversation = model.conversation as V2TimConversation?;
      final lastMessage = conversation?.lastMessage;
      if (lastMessage?.timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          lastMessage!.timestamp! * 1000,
        );
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
    TIMStore.to.conversationList.listen((_) {
      update();
      _updateHasJoinedGroups();
    });
  }

  @override
  void onClose() {
    _stopMessageListPoll();
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
    if (!TIMStore.to.isIMLoginReady) {
      hasJoinedGroups.value = false;
      return;
    }
    final list = await TIMStore.to.getJoinedGroupList();
    hasJoinedGroups.value = list.isNotEmpty;
  }

  Future<void> _refreshConversationList() async {
    if (TIMStore.to.isIMLoginReady) {
      await TIMStore.to.refreshConversationList();
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

    final conversation = model.conversation as V2TimConversation;
    final conversationID = conversation.conversationID;
    if (conversationID.isEmpty) {
      return;
    }
    final success = await TIMStore.to.deleteConversation(conversationID);
    if (success) {
      Loading.success('刪除成功'.tr);
    } else {
      Loading.error('刪除失敗'.tr);
    }
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
    if (payload == null) return;
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
    final info = await TIMStore.to.getGroupInfo(groupID);
    if (info == null) {
      Loading.error('群組不存在或已解散'.tr);
      return;
    }
    Loading.show();
    final res = await TIMStore.to.joinGroup(
      groupID: groupID,
      message: '',
      groupType: info.groupType,
    );
    Loading.dismiss();
    if (res.code == 0) {
      Loading.success('加入成功'.tr);
      final conversation = await TIMStore.to.createOrGetConversation(
        groupID: groupID,
      );
      Get.toNamed(AppRoutes.CHAT, arguments: {'conversation': conversation});
      fetchData();
    } else {
      final msg = res.desc.isNotEmpty ? res.desc : '加入失敗'.tr;
      Loading.error(msg);
    }
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

  @override
  Future<void> fetchData() async {
    if (!isLogin) return;
    await _refreshConversationList();
    _updateHasJoinedGroups();
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
