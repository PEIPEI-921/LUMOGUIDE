import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/message/controller.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_full_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_full_info.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';

class GroupProfileButtonAreaNoTransfer extends StatelessWidget {
  const GroupProfileButtonAreaNoTransfer({
    super.key,
    required this.groupInfo,
    required this.memberList,
  });

  final V2TimGroupInfo groupInfo;
  final List<V2TimGroupMemberFullInfo?> memberList;

  static final _sdkInstance = TIMUIKitCore.getSDKInstance();
  static final _coreInstance = TIMUIKitCore.getInstance();
  static final _chatController = TIMUIKitChatController();

  bool get _isOwner => groupInfo.owner == _coreInstance.loginUserInfo?.userID;

  void _onDidLeaveGroup() {
    Get.until((route) => route.isFirst);
    Get.find<MessageController>().fetchData();
  }

  Future<void> _clearHistory(BuildContext context) async {
    final groupID = groupInfo.groupID;
    await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('清空聊天記錄'.tr),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDefaultAction: false,
          child: Text('取消'.tr),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              if (PlatformUtils().isWeb) {
                final res = await _sdkInstance
                    .getConversationManager()
                    .deleteConversation(conversationID: 'group_$groupID');
                if (res.code == 0) {
                  _chatController.clearHistory(groupID);
                }
              } else {
                final res = await _sdkInstance
                    .getMessageManager()
                    .clearGroupHistoryMessage(groupID: groupID);
                if (res.code == 0) {
                  _chatController.clearHistory(groupID);
                }
              }
            },
            isDefaultAction: false,
            child: Text(
              '確定'.tr,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _quitGroup(BuildContext context) async {
    final groupID = groupInfo.groupID;
    await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('退出後不會接收到此群聊消息'.tr),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDefaultAction: false,
          child: Text('取消'.tr),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await _sdkInstance.quitGroup(groupID: groupID);
              if (res.code == 0) {
                await _sdkInstance.getConversationManager().deleteConversation(
                  conversationID: 'group_$groupID',
                );
                _onDidLeaveGroup();
              }
            },
            isDefaultAction: false,
            child: Text(
              '確定'.tr,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dismissGroup(BuildContext context) async {
    final groupID = groupInfo.groupID;
    await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('解散後不會接收到此群聊消息'.tr),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDefaultAction: false,
          child: Text('取消'.tr),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await _sdkInstance.dismissGroup(groupID: groupID);
              if (res.code == 0) {
                await _sdkInstance.getConversationManager().deleteConversation(
                  conversationID: 'group_$groupID',
                );
                _onDidLeaveGroup();
              }
            },
            isDefaultAction: false,
            child: Text(
              '確定'.tr,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupType = groupInfo.groupType;
    final isWork = groupType == 'Work';
    final items = <Map<String, String>>[
      {'label': '清空消息'.tr, 'id': 'clearHistory'},
      if (_isOwner && isWork) {'label': '退出群組'.tr, 'id': 'quitGroup'},
      if (_isOwner && !isWork) {'label': '解散群組'.tr, 'id': 'dismissGroup'},
      if (!_isOwner) {'label': '退出群組'.tr, 'id': 'quitGroup'},
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map(
            (e) => InkWell(
              onTap: () {
                if (e['id'] == 'clearHistory') {
                  _clearHistory(context);
                } else if (e['id'] == 'quitGroup') {
                  _quitGroup(context);
                } else if (e['id'] == 'dismissGroup') {
                  _dismissGroup(context);
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.assistantText.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Text(
                  e['label']!,
                  style: const TextStyle(color: AppColors.red, fontSize: 16),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
