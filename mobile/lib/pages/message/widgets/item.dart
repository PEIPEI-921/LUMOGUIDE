import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
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
    bool isGroupConversation = false;
    String location = '';
    String badge = '';
    ChatConversation? conversation;
    if (isChat && model.conversation != null) {
      conversation = model.conversation as ChatConversation;
      unreadCount = ChatStore.to.unreadCount(conversation.id);
      isGroupConversation = conversation.isGroup;
      title = controller.conversationTitle(conversation);
      avatarUrl = controller.conversationAvatar(conversation);
      location = controller.conversationLocation(conversation);
      badge = controller.conversationBadge(conversation);
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
    } else if (isChat && conversation != null && !conversation.isGroup) {
      // 单聊：对方名称首字头像
      final name = controller.conversationTitle(conversation);
      avatarWidget = Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(23.w),
        ),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name.characters.first : '?',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
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

    final showUnread = isChat && unreadCount != null && unreadCount > 0;
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
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.primaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (badge.isNotEmpty) ...[
                              6.w.horizontalSpace,
                              IdentityBadge(label: badge),
                            ],
                            6.w.horizontalSpace,
                            Text(
                              model.time ?? '',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primaryText.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        if (location.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 1.w),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12.w,
                                  color: AppColors.assistantText,
                                ),
                                2.w.horizontalSpace,
                                Flexible(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.assistantText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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
                          color: AppColors.primaryText.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                    )
                    .expanded(),
              ],
            )
            .padding(horizontal: 14.w, vertical: 6.w)
            .gestures(
              onTap: () => controller.onTapTopFixed(model),
              behavior: HitTestBehavior.opaque,
            );

    final needHighlight = model.topFixed != MessageTopFixed.chat;
    final content = needHighlight
        ? Container(color: AppColors.backgroundBlue, child: rowContent)
        : rowContent;

    if (isChat && conversation != null) {
      return Slidable(
        key: ValueKey(conversation.id),
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
