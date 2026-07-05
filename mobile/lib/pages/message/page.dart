import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/category.dart';
import 'widgets/item.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageController());
    return IScaffold(
      appBar: IAppBar(
        title: '消息'.tr,
        showBackButton: false,
        actions: [
          Obx(
            () => UserStore.to.profile.isVip && !UserStore.to.profile.inAudit
                ? MessageMoreMenuButton(controller: controller)
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(
        () => Column(
          children: [
            const MessageCategoryWidget(),
            10.w.verticalSpace,
            const _MyGroupsEntry(),
            IRefresh(
              controller: controller,
              child: controller.topFixedList.isEmpty
                  ? const EmptyListWidget()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) => MessageItemWidget(
                        model: controller.topFixedList[index],
                      ),
                      itemCount: controller.topFixedList.length,
                      itemExtent: 73.w,
                    ).decorated(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
            ).expanded(),
          ],
        ),
      ),
    );
  }
}

class MessageMoreMenuButton extends StatelessWidget {
  const MessageMoreMenuButton({super.key, required this.controller});

  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add, size: 24.w, color: AppColors.primaryText),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      onPressed: () => _showMenu(context),
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) return;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    const double gap = 6;
    final double menuTop = topLeft.dy + button.size.height + gap;
    final RelativeRect position = RelativeRect.fromLTRB(
      topLeft.dx,
      menuTop,
      overlay.size.width - (topLeft.dx + button.size.width),
      overlay.size.height - menuTop - 1,
    );

    showMenu<_MessageMenuAction>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      color: Colors.white,
      elevation: 8,
      surfaceTintColor: Colors.transparent,
      items: [
        PopupMenuItem<_MessageMenuAction>(
          value: _MessageMenuAction.scan,
          height: 40.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
          child: _MessageMenuRow(icon: Icons.qr_code_scanner, label: '掃一掃'.tr),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<_MessageMenuAction>(
          value: _MessageMenuAction.createGroup,
          height: 40.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
          child: _MessageMenuRow(icon: Icons.group_add, label: '創建群組'.tr),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case _MessageMenuAction.scan:
          controller.onScan();
          break;
        case _MessageMenuAction.createGroup:
          controller.onCreateGroup();
          break;
      }
    });
  }
}

class _MessageMenuRow extends StatelessWidget {
  const _MessageMenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 100.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.w, color: AppColors.primaryText),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 我的群聊入口：有群组时才显示，tab 下方、列表上方
class _MyGroupsEntry extends StatelessWidget {
  const _MyGroupsEntry();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return Obx(() {
      if (UserStore.to.profile.inAudit) return const SizedBox.shrink();
      if (!controller.hasJoinedGroups.value) return const SizedBox.shrink();
      return Row(
            children: [
              Icon(Icons.group, size: 22.w, color: AppColors.primary),
              10.w.horizontalSpace,
              Text(
                '我的群聊'.tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: 22.w,
                color: AppColors.assistantText,
              ),
            ],
          )
          .padding(horizontal: 14.w, vertical: 12.w)
          .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
          )
          .padding(horizontal: 13.w)
          .gestures(
            onTap: () => Get.toNamed(AppRoutes.MY_GROUPS),
            behavior: HitTestBehavior.opaque,
          )
          .padding(bottom: 10.w);
    });
  }
}

enum _MessageMenuAction { scan, createGroup }
