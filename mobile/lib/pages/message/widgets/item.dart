import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../controller.dart';

/// 与「我的群聊」页一致的群占位头像；非群聊则用 [model] 的 icon 图
Widget _avatarPlaceholder({
  required bool isGroup,
  required MessageTopFixedModel? model,
  required double size,
}) {
  if (isGroup) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(Icons.group, size: size * 0.52, color: Colors.white),
    );
  }
  return Image.asset(model?.topFixed?.icon ?? '', width: size, height: size);
}

class MessageItemWidget extends StatelessWidget {
  const MessageItemWidget({super.key, required this.model});
  final MessageTopFixedModel model;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();

    String title = model.topFixed?.title ?? '';
    String? avatarUrl;
    bool isChat = model.topFixed == MessageTopFixed.chat;

    int? unreadCount;
    bool isMuted = false;
    bool isPinned = false;
    bool isGroupConversation = false;
    if (isChat && model.conversation != null) {
      final conversation = model.conversation as V2TimConversation;
      unreadCount = conversation.unreadCount;
      isMuted = conversation.recvOpt != 0;
      isPinned = conversation.isPinned == true;
      isGroupConversation = conversation.type != 1; // 1=C2C 单聊, 2=群聊
      if (conversation.type == 1) {
        title = conversation.showName ?? conversation.userID ?? '--';
        avatarUrl = conversation.faceUrl;
      } else {
        title = conversation.showName ?? conversation.groupID ?? '--';
        avatarUrl = conversation.faceUrl;
      }
    }

    Widget avatarWidget;
    if (isChat && avatarUrl != null && avatarUrl.isNotEmpty) {
      avatarWidget = ClipRRect(
        borderRadius: BorderRadius.circular(23.w),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 46.w,
          height: 46.w,
          fit: BoxFit.cover,
          placeholder: (context, url) => _avatarPlaceholder(
            isGroup: isGroupConversation,
            model: model,
            size: 46.w,
          ),
          errorWidget: (context, url, error) => _avatarPlaceholder(
            isGroup: isGroupConversation,
            model: model,
            size: 46.w,
          ),
        ),
      );
    } else {
      avatarWidget = _avatarPlaceholder(
        isGroup: isGroupConversation,
        model: model,
        size: 46.w,
      );
    }

    final showUnread =
        isChat && !isMuted && unreadCount != null && unreadCount > 0;
    final count = unreadCount;
    final unreadLabel = showUnread && count != null
        ? (count > 99 ? '99+' : count.toString())
        : null;

    final rowContent =
        Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    avatarWidget,
                    if (unreadLabel != null)
                      Positioned(
                        top: -4.w,
                        right: -4.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: unreadLabel.length > 2 ? 4.w : 6.w,
                            vertical: 2.w,
                          ),
                          constraints: BoxConstraints(minWidth: 18.w),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unreadLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                10.w.horizontalSpace,
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryText,
                              ),
                            ).expanded(),
                            if (isMuted)
                              Padding(
                                padding: EdgeInsets.only(right: 6.w),
                                child: Icon(
                                  Icons.notifications_off_outlined,
                                  size: 16.w,
                                  color: AppColors.assistantText,
                                ),
                              ),
                            Text(
                              model.time ?? '',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primaryText.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          model.text ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                    .decorated(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primaryText.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                    )
                    .expanded(),
              ],
            )
            .padding(horizontal: 14.w)
            .gestures(
              onTap: () => controller.onTapTopFixed(model),
              behavior: HitTestBehavior.opaque,
            );

    final needHighlight =
        (isChat && isPinned) || model.topFixed != MessageTopFixed.chat;
    final content = needHighlight
        ? Container(color: AppColors.backgroundBlue, child: rowContent)
        : rowContent;

    if (isChat && model.conversation != null) {
      final conversation = model.conversation as V2TimConversation;
      return Slidable(
        key: ValueKey(conversation.conversationID),
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => controller.deleteConversation(model),
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '刪除'.tr,
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}
