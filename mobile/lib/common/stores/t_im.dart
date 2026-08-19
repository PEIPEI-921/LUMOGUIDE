import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tencent_cloud_chat_push/common/tim_push_listener.dart';
import 'package:tencent_cloud_chat_push/common/tim_push_message.dart';
import 'package:tencent_cloud_chat_push/tencent_cloud_chat_push.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_add_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_filter_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_uikit/data_services/core/core_services.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';

import '../langs/translation_service.dart';
import '../services/localization.dart';
import 'storage.dart';
import 'user.dart';

class TIMStore extends GetxController {
  static TIMStore get to => Get.find();

  final coreInstance = TIMUIKitCore.getInstance();
  final sdkInstance = TIMUIKitCore.getSDKInstance();

  bool _isInitIMSDK = false;

  final _isIMLoginReady = false.obs;
  bool get isIMLoginReady => _isIMLoginReady.value;

  final conversationList = <V2TimConversation>[].obs;

  /// 总未读消息数（用于 root 消息 tab 角标）
  final totalUnreadCount = 0.obs;

  /// 响应式好友列表
  final friendList = <V2TimFriendInfo>[].obs;

  TIMPushListener? _timPushListener;

  AppLifecycleListener? _lifecycleListener;



  /// 会话监听器
  V2TimConversationListener? _conversationListener;
  bool _isConversationListenerRegistered = false;

  final int sdkAppId = 1600121769;

  @override
  void onInit() async {
    super.onInit();

    await _initIMSDK();
    _addLifecycleListener();
  }

  static LanguageEnum _timLanguageFromApp() {
    final appLang = LocalizationService.to.language;
    switch (appLang) {
      case LanguageType.zh:
        return LanguageEnum.zhHans;
      case LanguageType.tw:
        return LanguageEnum.zhHant;
      case LanguageType.en:
        return LanguageEnum.en;
    }
  }

  _initIMSDK() async {
    if (_isInitIMSDK) {
      return;
    }
    final res = await coreInstance.init(
      sdkAppID: sdkAppId,
      loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
      listener: _createSDKListener(),
      language: _timLanguageFromApp(),
      onTUIKitCallbackListener: (callback) async {
        log(
          'TIMStore: onTUIKitCallbackListener: ${callback.errorMsg} ${callback.errorCode}',
        );
      },
    );
    if (res == null || !res) {
      _isIMLoginReady.value = true;
      return;
    }
    _isInitIMSDK = true;

    final account = StorageStone.userNumber;
    if (account.isEmpty) {
      _isIMLoginReady.value = true;
      return;
    }
    final userSig = StorageStone.userSig;
    await login(account, userSig);
  }

  _onNotificationClicked({
    required String ext,
    String? userID,
    String? groupID,
  }) {
    log("_onNotificationClicked: $ext, userID: $userID, groupID: $groupID");
    if (userID != null || groupID != null) {
      // 根据 userID 或 groupID 跳转至对应 Message 页面.
    } else {
      // 根据 ext 字段, 自己写解析方式, 跳转至对应页面.
    }
  }

  @override
  void onClose() {
    super.onClose();
    _lifecycleListener?.dispose();
    _removeConversationListener();
  }
}

extension TIMStoreExt on TIMStore {
  /// 登录
  Future login(String account, String userSig) async {
    final res = await coreInstance.login(userID: account, userSig: userSig);
    if (res.code == 0) {
      final pushRes = await TencentCloudChatPush().registerPush(
        onNotificationClicked: _onNotificationClicked,
        // apnsCertificateID: kDebugMode ? 47933 : 37932,
        apnsCertificateID: defaultTargetPlatform == TargetPlatform.iOS
            ? 47932
            : 46135,
      );
      log('TIMStore: registerPush: ${pushRes.toString()}');
      _addPushListener();
      TencentCloudChatPush().disablePostNotificationInForeground(disable: true);
      _isIMLoginReady.value = true;
      await refreshFriendList();
      await refreshConversationList();
      _addConversationListener();
      _updateTotalUnreadCount();
    } else {
      _isIMLoginReady.value = true;
    }
    return res;
  }

  /// 登出
  Future logout() async {
    _removePushListener();
    friendList.clear();
    return await coreInstance.logout();
  }

  /// 添加黑名单
  Future<bool> addBlackList(String account) async {
    final res = await sdkInstance.v2TIMFriendshipManager.addToBlackList(
      userIDList: [account],
    );
    return res.code == 0;
  }

  /// 获取好友列表（不更新响应式列表）
  Future<List<V2TimFriendInfo>> getFriendList() async {
    final res = await sdkInstance.v2TIMFriendshipManager.getFriendList();
    if (res.code == 0 && res.data != null) {
      log('TIMStore: getFriendList: ${res.data!.toString()}');
      return res.data!;
    }
    return [];
  }

  /// 刷新好友列表（更新响应式列表）
  Future<void> refreshFriendList() async {
    final list = await getFriendList();
    friendList.value = list;
    log('TIMStore: refreshFriendList: ${list.length} friends');
  }

  /// 刷新会话列表（更新响应式列表）
  Future<void> refreshConversationList() async {
    final list = await getConversationList();
    conversationList.value = list;
    log('TIMStore: refreshConversationList: ${list.length} conversations');
  }

  Future<List<V2TimConversation>> getConversationList() async {
    final res = await sdkInstance.getConversationManager().getConversationList(
      nextSeq: '0',
      count: 1000,
    );
    if (res.code == 0 && res.data != null) {
      log(
        'TIMStore: getConversationList: ${res.data?.conversationList?.length ?? 0}',
      );
      return res.data?.conversationList ?? [];
    }
    return [];
  }

  /// 获取会话
  Future<V2TimConversation?> getConversation(String conversationID) async {
    final res = await sdkInstance.getConversationManager().getConversation(
      conversationID: conversationID,
    );
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  /// 删除会话
  Future<bool> deleteConversation(String conversationID) async {
    final res = await sdkInstance.getConversationManager().deleteConversation(
      conversationID: conversationID,
    );
    if (res.code == 0) {
      await refreshConversationList();
      return true;
    }
    return false;
  }

  /// 通过用户ID或群组ID创建或获取会话
  /// [userID] 用户ID，用于创建单聊会话
  /// [groupID] 群组ID，用于创建群聊会话
  /// 返回会话ID，如果会话已存在则返回现有会话，否则返回会话ID供后续使用
  Future<V2TimConversation?> createOrGetConversation({
    String? userID,
    String? groupID,
  }) async {
    if (userID == null && groupID == null) {
      return null;
    }

    if (userID != null && groupID != null) {
      return null;
    }

    String conversationID;
    if (userID != null) {
      conversationID = 'c2c_$userID';
    } else {
      conversationID = 'group_$groupID';
    }

    return await getConversation(conversationID);
  }

  /// 创建群聊（公开群：邀请直接进 + 扫码直接进）
  /// - [addOpt] ANY=扫码/申请直接进群
  /// - [approveOpt] ANY=邀请直接进群（公开群默认禁止，必须显式传）
  /// - 使用 Public 才支持「设置管理员」及开放加群；Work 仅支持成员邀请、无管理员角色
  Future<String> createGroup(
    String groupName,
    List<V2TimGroupMember> memberList, {
    GroupAddOptTypeEnum addOpt = GroupAddOptTypeEnum.V2TIM_GROUP_ADD_AUTH,
    GroupAddOptTypeEnum approveOpt = GroupAddOptTypeEnum.V2TIM_GROUP_ADD_FORBID,
  }) async {
    final res = await sdkInstance.getGroupManager().createGroup(
      groupName: groupName,
      groupType: GroupType.Work,
      memberList: memberList,
      addOpt: addOpt,
      approveOpt: approveOpt,
    );
    if (res.code == 0) {
      return res.data!;
    }
    return "";
  }

  /// 获取当前用户已加入的群组列表（含未发过消息的群，不依赖会话列表）
  Future<List<V2TimGroupInfo>> getJoinedGroupList() async {
    final res = await sdkInstance.getGroupManager().getJoinedGroupList();
    if (res.code == 0 && res.data != null) {
      return res.data!;
    }
    return [];
  }

  /// 获取群组信息
  Future<V2TimGroupInfo?> getGroupInfo(String groupID) async {
    final res = await sdkInstance.getGroupManager().getGroupsInfo(
      groupIDList: [groupID],
    );
    if (res.code == 0 && res.data != null) {
      return res.data![0].groupInfo;
    }
    return null;
  }

  /// 获取群成员 userID 列表（用于加人时排除已在群内的用户，分页拉取最多 200）
  Future<Set<String>> getGroupMemberUserIDs(String groupID) async {
    final out = <String>{};
    String nextSeq = '0';
    const count = 100;
    for (var i = 0; i < 2; i++) {
      final res = await sdkInstance.getGroupManager().getGroupMemberList(
        groupID: groupID,
        filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
        nextSeq: nextSeq,
        count: count,
      );
      if (res.code != 0 || res.data == null) break;
      final data = res.data!;
      final list = data.memberInfoList ?? [];
      for (final m in list) {
        final uid = m.userID;
        if (uid.isNotEmpty) out.add(uid);
      }
      nextSeq = data.nextSeq ?? '0';
      if (nextSeq == '0' || list.length < count) break;
    }
    return out;
  }

  /// 邀请用户入群
  Future<bool> inviteUserToGroup(String groupID, List<String> userList) async {
    if (userList.isEmpty) return true;
    final res = await sdkInstance.getGroupManager().inviteUserToGroup(
      groupID: groupID,
      userList: userList,
    );
    return res.code == 0;
  }

  /// 通过群 ID 申请加群（群二维码扫码加群）
  Future<V2TimCallback> joinGroup({
    required String groupID,
    String message = '',
    String? groupType,
  }) async {
    return sdkInstance.joinGroup(
      groupID: groupID,
      message: message,
      groupType: groupType,
    );
  }

  /// 主动刷新总未读数（如进入消息 tab 时调用，供 root 消息 tab 角标更新）
  Future<void> refreshTotalUnreadCount() async {
    await _updateTotalUnreadCount();
  }
}

extension on TIMStore {
  V2TimSDKListener _createSDKListener() => V2TimSDKListener(
    onConnectSuccess: () {
      log('TIMStore: onConnectSuccess');
    },
    onConnectFailed: (code, error) {
      log('TIMStore: onConnectFailed: $code, $error');
    },
    onConnecting: () {
      log('TIMStore: onConnecting');
    },
    onKickedOffline: () {
      log('TIMStore: onKickedOffline');
      UserStore.to.logout();
    },
    onSelfInfoUpdated: (info) {
      log('TIMStore: onSelfInfoUpdated: $info');
    },
    onUserSigExpired: () {
      log('TIMStore: onUserSigExpired');
      UserStore.to.logout();
    },
  );
}

extension on TIMStore {
  _addLifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _checkIfConnected();
        _setOfflinePushStatus(AppStatus.foreground);
      },
      onPause: () {
        _setOfflinePushStatus(AppStatus.background);
      },
      onInactive: () {
        _setOfflinePushStatus(AppStatus.background);
      },
      onHide: () {
        _setOfflinePushStatus(AppStatus.background);
      },
      onDetach: () {
        _setOfflinePushStatus(AppStatus.background);
      },
    );
  }

  _setOfflinePushStatus(AppStatus status) async {
    final count = await _getTotalUnreadCount();
    totalUnreadCount.value = count ?? 0;
    coreInstance.setOfflinePushStatus(status: status, totalCount: count);
  }

  Future<int?> _getTotalUnreadCount() async {
    final res = await sdkInstance
        .getConversationManager()
        .getTotalUnreadMessageCount();
    if (res.code == 0) {
      return res.data ?? 0;
    }
    return null;
  }

  /// 更新总未读数（会话变化或恢复前台时调用，供 root 消息 tab 角标使用）
  Future<void> _updateTotalUnreadCount() async {
    final count = await _getTotalUnreadCount();
    totalUnreadCount.value = count ?? 0;
  }

  Future<void> _checkIfConnected() async {
    final res = await TencentImSDKPlugin.v2TIMManager.getLoginUser();
    if (res.data != null && res.data!.isNotEmpty) {
      return;
    }
    if (res.data == null) {
      return;
    }
    if (res.data!.isEmpty) {
      return;
    }
  }

  void _addConversationListener() {
    if (_isConversationListenerRegistered) return;
    _conversationListener = V2TimConversationListener(
      onConversationChanged: (conversationList) {
        log('TIMStore: onConversationChanged: ${conversationList.length}');
        refreshConversationList();
        _updateTotalUnreadCount();
      },
      onNewConversation: (conversationList) {
        log('TIMStore: onNewConversation: ${conversationList.length}');
        refreshConversationList();
        _updateTotalUnreadCount();
      },
    );
    sdkInstance.getConversationManager().addConversationListener(
      listener: _conversationListener!,
    );
    _isConversationListenerRegistered = true;
    log('TIMStore: Conversation listener registered');
  }

  void _removeConversationListener() {
    if (!_isConversationListenerRegistered || _conversationListener == null) {
      return;
    }
    sdkInstance.getConversationManager().removeConversationListener(
      listener: _conversationListener!,
    );
    _isConversationListenerRegistered = false;
    _conversationListener = null;
    log('TIMStore: Conversation listener removed');
  }
}

extension on TIMStore {
  _addPushListener() {
    _timPushListener = TIMPushListener(
      onRecvPushMessage: (TimPushMessage message) {
        String messageLog = message.toLogString();
        log("message: $messageLog");
      },
      onRevokePushMessage: (String messageId) {
        log("message: $messageId");
      },
      onNotificationClicked: (String ext) {
        log("ext: $ext");
      },
    );
    TencentCloudChatPush().addPushListener(listener: _timPushListener!);
  }

  _removePushListener() {
    if (_timPushListener == null) return;
    TencentCloudChatPush().removePushListener(listener: _timPushListener!);
  }
}
