import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'controller.dart';

/// 聊天页：基于 LUMO-Chat 的自定义聊天 UI（消息气泡 + 输入栏）。
class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    return IScaffold(
      appBar: IAppBar(
        centerTitle: false,
        toolbarHeight: 56,
        titleWidget: Obx(() {
          final isGroup = controller.conversation.isGroup;
          final location = isGroup ? '' : controller.peerLocation;
          final badge = isGroup ? '' : controller.peerBadge;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      controller.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badge.isNotEmpty) ...[
                    6.w.horizontalSpace,
                    IdentityBadge(label: badge),
                  ],
                ],
              ),
              if (location.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 1.w),
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.assistantText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          );
        }),
        actions: [
          if (controller.conversation.isGroup)
            IconButton(
              onPressed: controller.onMore,
              icon: const Icon(Icons.more_horiz),
            ).paddingOnly(right: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _MessageListView(controller: controller)),
          Obx(
            () => controller.peerTyping.value
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          '對方正在輸入...'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.assistantText,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          _InputBar(controller: controller),
        ],
      ),
    );
  }
}

// ─── 消息列表 ──────────────────────────────────────────────────

class _MessageListView extends StatelessWidget {
  const _MessageListView({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = controller.messages;
      if (messages.isEmpty) {
        return const Center(child: EmptyListWidget());
      }
      // reverse 列表：底部为最新消息，新消息自动贴底
      return ListView.builder(
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[messages.length - 1 - index];
          return _MessageBubble(
            key: ValueKey(msg.messageId),
            controller: controller,
            message: msg,
          );
        },
      );
    });
  }
}

// ─── 消息气泡 ──────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    super.key,
    required this.controller,
    required this.message,
  });

  final ChatController controller;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final isGroup = controller.conversation.isGroup;

    // 撤回消息：居中浅灰胶囊提示
    if (message.isRecalled) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.w),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: AppColors.assistantText.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              isMine ? '你撤回了一條消息'.tr : '對方撤回了一條消息'.tr,
              style: TextStyle(fontSize: 13.sp, color: AppColors.assistantText),
            ),
          ),
        ),
      );
    }

    final bubble = _buildBubble(isMine);
    final time = _formatTime(message.createdAt);

    final row = Row(
      mainAxisAlignment:
          isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMine) _PeerAvatar(controller: controller),
        if (!isMine) 8.w.horizontalSpace,
        Flexible(
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // 群聊：对方消息上方显示发送者名称（靠左）
              if (!isMine && isGroup)
                Padding(
                  padding: EdgeInsets.only(left: 2.w, bottom: 3.w),
                  child: Text(
                    _senderName(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.assistantText,
                    ),
                  ),
                ),
              bubble,
              if (time != null)
                Padding(
                  padding: EdgeInsets.only(top: 3.w),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.assistantText,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isMine) 8.w.horizontalSpace,
        if (isMine) _MyAvatar(controller: controller),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: isMine && message.type == 'TEXT' && !message.isRecalled
          ? () => _showActionSheet(context)
          : null,
      child: Padding(padding: EdgeInsets.symmetric(vertical: 6.w), child: row),
    );
  }

  /// 群聊中对方消息的发送者名称：优先认证名称，其次用户 ID
  String _senderName() {
    if (controller.conversation.isGroup) {
      return controller.senderName(message.senderId);
    }
    return '';
  }

  Widget _buildBubble(bool isMine) {
    final bubbleColor = isMine ? AppColors.primary : Colors.white;
    final textColor = isMine ? Colors.white : AppColors.primaryText;

    if (message.type == 'IMAGE') {
      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.PHOTO_VIEW, arguments: {
          'pictures': [ConfigService.normalizeUploadUrl(message.content)],
          'index': 0,
        }),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(
            imageUrl: ConfigService.normalizeUploadUrl(message.content),
            width: 180.w,
            height: 180.w,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 180.w,
              height: 180.w,
              color: AppColors.backgroundBlue,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 180.w,
              height: 180.w,
              color: AppColors.backgroundBlue,
              alignment: Alignment.center,
              child: Text(
                '圖片加載失敗'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.assistantText,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 240.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.w),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.r),
          topRight: Radius.circular(14.r),
          bottomLeft: Radius.circular(isMine ? 14.r : 4.r),
          bottomRight: Radius.circular(isMine ? 4.r : 14.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: TextStyle(fontSize: 15.sp, color: textColor, height: 1.35),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.undo, color: AppColors.primary),
              title: Text('撤回'.tr),
              onTap: () {
                Get.back();
                controller.recallMessage(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _formatTime(int ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final hhmm =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (day == today) return hhmm;
    if (date.year == now.year) {
      return '${date.month}/${date.day} $hhmm';
    }
    return '${date.year}/${date.month}/${date.day} $hhmm';
  }
}

// ─── 头像 ──────────────────────────────────────────────────────

class _PeerAvatar extends StatelessWidget {
  const _PeerAvatar({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final photo = controller.peerAvatar;
    return GestureDetector(
      onTapDown: (details) {
        final peerId = controller.conversation.peerUserId;
        if (peerId != null && peerId.isNotEmpty) {
          controller.onTapAvatar(peerId, details);
        }
      },
      child: ClipOval(
        child: photo.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photo,
                width: 38.w,
                height: 38.w,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _avatarPlaceholder(),
              )
            : _avatarPlaceholder(),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 38.w,
      height: 38.w,
      color: AppColors.backgroundBlue,
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: 22.w,
        color: AppColors.assistantText,
      ),
    );
  }
}

class _MyAvatar extends StatelessWidget {
  const _MyAvatar({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    // 本人头像：认证身份头像（导游照片/公司形象照），否则个人头像
    final avatar = controller.myCertifiedAvatar;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 点自己的头像进入对应身份的详情页
        controller.onTapAvatar(
          UserStore.to.profile.number ?? '',
          TapDownDetails(),
        );
      },
      child: ClipOval(
        child: avatar.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatar,
                width: 38.w,
                height: 38.w,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 38.w,
      height: 38.w,
      color: AppColors.backgroundBlue,
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: 22.w,
        color: AppColors.assistantText,
      ),
    );
  }
}

// ─── 输入栏 ────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryText.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 上传图片按钮：圆形浅紫底
            Padding(
              padding: EdgeInsets.only(left: 6.w, bottom: 4.w),
              child: GestureDetector(
                onTap: controller.sendImage,
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 22.w,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlue,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: TextField(
                  controller: controller.inputController,
                  onChanged: controller.onInputChanged,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '輸入消息...'.tr,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.assistantText,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 10.w,
                    ),
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            // 发送按钮：圆形箭头，空输入置灰
            Padding(
              padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 4.w),
              child: Obx(() {
                final hasText = controller.inputText.trim().isNotEmpty;
                return GestureDetector(
                  onTap: hasText ? controller.sendText : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: hasText
                          ? AppColors.primary
                          : AppColors.assistantText.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: 20.w,
                      color: hasText ? Colors.white : AppColors.assistantText,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
