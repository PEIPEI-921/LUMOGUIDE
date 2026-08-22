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

class _MessageListView extends StatefulWidget {
  const _MessageListView({required this.controller});

  final ChatController controller;

  @override
  State<_MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<_MessageListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// reverse 列表：offset 0 在底部（最新消息），maxScrollExtent 在顶部（最旧）。
  /// 滚到距顶部 200 内时触发加载更早消息。
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent - pos.pixels < 200) {
      widget.controller.loadOlderMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = widget.controller.messages;
      if (messages.isEmpty) {
        return const Center(child: EmptyListWidget());
      }
      final controller = widget.controller;
      final loadingOlder = controller.loadingOlder;
      final hasMore = controller.hasMore;
      // 有更多/加载中/或首次加载已达页大小（说明存在历史）时保留页脚
      final showFooter =
          hasMore || loadingOlder || messages.length >= 50;
      // reverse 列表：底部为最新消息，新消息自动贴底
      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
        itemCount: messages.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          // 列表末尾（reverse 下=顶部）的加载更早消息项
          if (index >= messages.length) {
            return _OlderLoader(loading: loadingOlder, hasMore: hasMore);
          }
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

/// 顶部「加载更早消息」项：有更多时显示加载中/轻触加载，无更多时显示提示
class _OlderLoader extends StatelessWidget {
  const _OlderLoader({required this.loading, required this.hasMore});

  final bool loading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: Center(
          child: Text(
            '沒有更多消息了'.tr,
            style: TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ─── 消息气泡 ──────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  _MessageBubble({
    super.key,
    required this.controller,
    required this.message,
  });

  final ChatController controller;
  final ChatMessage message;

  /// 用于定位气泡，长按时在其上方弹出操作条
  final GlobalKey _bubbleKey = GlobalKey();

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

    final bubble = KeyedSubtree(
      key: _bubbleKey,
      child: _buildBubble(isMine),
    );
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
      onLongPress: !message.isRecalled
          ? () => _showMessageActionBar(context)
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
        child: _ChatImageBubble(
          url: ConfigService.normalizeUploadUrl(message.content),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.content,
            style: TextStyle(fontSize: 15.sp, color: textColor, height: 1.35),
          ),
          if (message.editedAt != null)
            Padding(
              padding: EdgeInsets.only(top: 3.w),
              child: Text(
                '已編輯'.tr,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: textColor.withValues(alpha: 0.55),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 微信风格：长按后在消息气泡上方弹出操作条（转发 / 撤回[仅自己]）
  void _showMessageActionBar(BuildContext context) {
    final box = _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final overlay = Overlay.of(context);
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screenSize = MediaQuery.of(context).size;

    const barHeight = 52.0;
    const barWidth = 200.0;

    // 显示在消息上方；上方空间不足（接近顶部）时放到消息下方
    double top = pos.dy - barHeight - 10;
    if (top < MediaQuery.of(context).padding.top + 8) {
      top = pos.dy + size.height + 10;
    }
    // 水平居中于气泡，并限制在屏幕内
    double left = pos.dx + size.width / 2 - barWidth / 2;
    left = left.clamp(8.0, screenSize.width - barWidth - 8.0);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // 点击任意处关闭
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => entry.remove(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: _MessageActionBar(
              showEdit: message.isMine &&
                  !message.isRecalled &&
                  message.type == 'TEXT',
              showRecall: message.isMine && !message.isRecalled,
              onForward: () {
                entry.remove();
                _showForwardTargets();
              },
              onEdit: () {
                entry.remove();
                _showEditDialog();
              },
              onRecall: () {
                entry.remove();
                controller.recallMessage(message);
              },
            ),
          ),
        ],
      ),
    );
    overlay.insert(entry);
  }

  /// 编辑自己的文本消息：弹出输入框 → 提交修改
  void _showEditDialog() {
    final textController = TextEditingController(text: message.content);
    Get.dialog(
      AlertDialog(
        title: Text('編輯消息'.tr),
        content: TextField(
          controller: textController,
          autofocus: true,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '輸入消息...'.tr,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'.tr),
          ),
          TextButton(
            onPressed: () async {
              final content = textController.text;
              Get.back();
              await controller.editMessage(message, content);
            },
            child: Text('確定'.tr),
          ),
        ],
      ),
    );
  }

  /// 选择转发目标会话（排除当前会话）→ 发送消息内容
  void _showForwardTargets() {
    final targets = ChatStore.to.conversations
        .where((c) => c.id != message.conversationId)
        .toList();
    if (targets.isEmpty) {
      Loading.toast('暫無可轉發的會話'.tr);
      return;
    }
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              child: Text(
                '選擇轉發目標'.tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: targets.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.primaryText.withValues(alpha: 0.08)),
                itemBuilder: (context, index) {
                  final conv = targets[index];
                  return ListTile(
                    leading: Icon(
                      conv.isGroup ? Icons.groups : Icons.person,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      _forwardTargetTitle(conv),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                    onTap: () {
                      Get.back();
                      _forwardTo(conv);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 8.w),
          ],
        ),
      ),
    );
  }

  String _forwardTargetTitle(ChatConversation conv) {
    if (conv.isGroup) {
      return conv.title?.isNotEmpty ?? false ? conv.title! : '群聊'.tr;
    }
    return conv.peerUserId?.isNotEmpty ?? false ? conv.peerUserId! : '聊天'.tr;
  }

  /// 转发消息内容到目标会话
  Future<void> _forwardTo(ChatConversation target) async {
    try {
      if (message.type == 'IMAGE') {
        await ChatStore.to.sendImageMessage(target.id, message.content);
      } else {
        await ChatStore.to.sendTextMessage(target.id, message.content);
      }
      Loading.toast('已轉發'.tr);
    } catch (e) {
      Loading.error('轉發失敗'.tr);
    }
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

/// 聊天图片气泡：按图片原始宽高比显示缩略图（不裁剪成正方形）。
/// 先解析原始尺寸 → 计算等比显示尺寸（最大 180.w）→ 渲染。
class _ChatImageBubble extends StatefulWidget {
  final String url;

  const _ChatImageBubble({required this.url});

  @override
  State<_ChatImageBubble> createState() => _ChatImageBubbleState();
}

class _ChatImageBubbleState extends State<_ChatImageBubble> {
  Size? _imageSize;
  static const double _maxSide = 180;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _resolveImageSize();
  }

  @override
  void didUpdateWidget(_ChatImageBubble old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _imageSize = null;
      _resolveImageSize();
    }
  }

  @override
  void dispose() {
    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }
    super.dispose();
  }

  /// 解析图片原始尺寸（走 cached_network_image 的缓存，不重复下载）
  void _resolveImageSize() {
    try {
      final provider = CachedNetworkImageProvider(widget.url);
      final stream = provider.resolve(ImageConfiguration.empty);
      _listener = ImageStreamListener((info, _) {
        if (!mounted) return;
        setState(() {
          _imageSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }, onError: (_, __) {});
      _imageStream = stream;
      stream.addListener(_listener!);
    } catch (_) {}
  }

  /// 等比显示尺寸：最大边 180，保持原始宽高比
  Size _displaySize() {
    final s = _imageSize;
    if (s == null || s.width <= 0 || s.height <= 0) {
      return const Size(_maxSide, _maxSide);
    }
    final ratio = s.width / s.height;
    double w = _maxSide;
    double h = w / ratio;
    if (h > _maxSide) {
      h = _maxSide;
      w = h * ratio;
    }
    // 极小图（如 1×1 图标）放大到最小可见尺寸
    const minSide = 60.0;
    if (w < minSide && h < minSide) {
      if (w >= h) {
        w = minSide;
        h = w / ratio;
      } else {
        h = minSide;
        w = h * ratio;
      }
    }
    return Size(w, h);
  }

  @override
  Widget build(BuildContext context) {
    final size = _displaySize();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: widget.url,
        width: size.width,
        height: size.height,
        fit: BoxFit.fill,
        placeholder: (_, __) => Container(
          width: size.width,
          height: size.height,
          color: AppColors.backgroundBlue,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (_, __, ___) => Container(
          width: size.width,
          height: size.height,
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
    );
  }
}

/// 微信风格消息操作条：深色半透明横条，水平排列「转发」「编辑（仅自己文本）」「撤回（仅自己）」
class _MessageActionBar extends StatelessWidget {
  final bool showEdit;
  final bool showRecall;
  final VoidCallback onForward;
  final VoidCallback onEdit;
  final VoidCallback onRecall;

  const _MessageActionBar({
    required this.showEdit,
    required this.showRecall,
    required this.onForward,
    required this.onEdit,
    required this.onRecall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionItem(
            icon: Icons.forward_rounded,
            label: '轉發'.tr,
            onTap: onForward,
          ),
          if (showEdit) ...[
            Container(
              width: 1,
              height: 22,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            _ActionItem(
              icon: Icons.edit_outlined,
              label: '編輯'.tr,
              onTap: onEdit,
            ),
          ],
          if (showRecall) ...[
            Container(
              width: 1,
              height: 22,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            _ActionItem(
              icon: Icons.undo,
              label: '撤回'.tr,
              onTap: onRecall,
            ),
          ],
        ],
      ),
    );
  }
}

/// 操作条单项：图标 + 文字（竖排）
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            4.verticalSpace,
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
