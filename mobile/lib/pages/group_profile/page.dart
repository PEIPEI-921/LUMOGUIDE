import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'controller.dart';

/// 群组详情页（LUMO-Chat 自实现）：群名/公告/成员管理/退出解散。
class GroupProfilePage extends StatelessWidget {
  const GroupProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupProfileController());
    if (controller.groupID.isEmpty) {
      return IScaffold(
        appBar: IAppBar(title: '群組詳情'.tr),
        body: const Center(child: EmptyListWidget()),
      );
    }
    return IScaffold(
      appBar: IAppBar(title: '群組詳情'.tr),
      body: Obx(() {
        if (controller.loading && controller.groupInfo == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
          children: [
            _GroupInfoCard(controller: controller),
            10.w.verticalSpace,
            _AnnouncementCard(controller: controller),
            10.w.verticalSpace,
            _MemberCard(controller: controller),
            10.w.verticalSpace,
            _QRCard(controller: controller),
            10.w.verticalSpace,
            _OperationCard(controller: controller),
          ],
        );
      }),
    );
  }
}

// ─── 群信息卡 ──────────────────────────────────────────────────

class _GroupInfoCard extends StatelessWidget {
  const _GroupInfoCard({required this.controller});

  final GroupProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Icon(Icons.group, size: 30.w, color: Colors.white),
          ),
          14.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.groupName.isNotEmpty
                      ? controller.groupName
                      : '群聊'.tr,
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                6.w.verticalSpace,
                Text(
                  '成員數: ${controller.members.length}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.assistantText,
                  ),
                ),
              ],
            ),
          ),
          if (controller.isOwner || controller.isAdmin)
            TextButton(
              onPressed: () => _showEditGroupNameSheet(context),
              child: Text('修改群名稱'.tr),
            ),
        ],
      ),
    );
  }

  void _showEditGroupNameSheet(BuildContext context) {
    final controller = TextEditingController(
      text: this.controller.groupName,
    );
    showModalBottomSheet<void>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      context: context,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '修改群名稱'.tr,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(
                  height: 2,
                  color: AppColors.assistantText.withValues(alpha: 0.2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    20 + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppColors.assistantText.withValues(alpha: 0.08),
                          isDense: true,
                          hintText: '修改群名稱'.tr,
                        ),
                        autofocus: true,
                        maxLength: 30,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;
                            Navigator.pop(ctx);
                            final ok = await this
                                .controller
                                .updateGroupTitle(text);
                            if (ok) {
                              Loading.success('修改成功'.tr);
                            } else {
                              Loading.error('修改失敗'.tr);
                            }
                          },
                          child: Text('確定'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── 群公告 ────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.controller});

  final GroupProfileController controller;

  @override
  Widget build(BuildContext context) {
    final announcement = controller.groupInfo?.announcement ?? '';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          Icons.campaign_outlined,
          size: 22.w,
          color: AppColors.primary,
        ),
        title: Text('群公告'.tr),
        subtitle: announcement.isNotEmpty
            ? Text(
                announcement,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.secondaryText,
                ),
              )
            : null,
        trailing: (controller.isOwner || controller.isAdmin)
            ? Icon(
                Icons.chevron_right,
                size: 22.w,
                color: AppColors.assistantText,
              )
            : null,
        onTap: (controller.isOwner || controller.isAdmin)
            ? () => _showEditAnnouncementSheet(context)
            : null,
      ),
    );
  }

  void _showEditAnnouncementSheet(BuildContext context) {
    final controller = TextEditingController(
      text: this.controller.groupInfo?.announcement ?? '',
    );
    showModalBottomSheet<void>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      context: context,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '修改群公告'.tr,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(
                  height: 2,
                  color: AppColors.assistantText.withValues(alpha: 0.2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    20 + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: AppColors.assistantText.withValues(alpha: 0.08),
                          hintText: '輸入群公告'.tr,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;
                            final ok = await this
                                .controller
                                .updateAnnouncement(text);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (ok) {
                              Loading.success('修改成功'.tr);
                            } else {
                              Loading.error('修改失敗'.tr);
                            }
                          },
                          child: Text('確定'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── 成员列表 ──────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.controller});

  final GroupProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '群成員'.tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (controller.isOwner || controller.isAdmin)
                TextButton.icon(
                  onPressed: controller.onAddMembers,
                  icon: Icon(
                    Icons.person_add_alt,
                    size: 18.w,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    '添加成員'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (controller.members.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.w),
              child: Center(
                child: Text(
                  '暫無成員'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.assistantText,
                  ),
                ),
              ),
            )
          else
            ...controller.members.map((member) {
              final isMe = member.userId == UserStore.to.profile.number;
              final roleLabel = member.role == 'OWNER'
                  ? '群主'.tr
                  : member.role == 'ADMIN'
                  ? '管理員'.tr
                  : null;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 18.w,
                  backgroundColor: AppColors.backgroundBlue,
                  child: Text(
                    controller.memberName(member.userId).characters.first,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(
                  '${controller.memberName(member.userId)}${isMe ? '（我）'.tr : ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                trailing: roleLabel != null
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
                onTap: isMe || !controller.isOwner
                    ? null
                    : () => _showMemberActions(context, member),
              );
            }),
        ],
      ),
    );
  }

  void _showMemberActions(
    BuildContext context,
    ChatGroupMember member,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (ctx) {
        final isAdmin = member.role == 'ADMIN';
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  isAdmin ? Icons.person_remove : Icons.admin_panel_settings,
                  color: AppColors.primary,
                ),
                title: Text(isAdmin ? '取消管理員'.tr : '設置為管理員'.tr),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await controller.setMemberRole(
                    member.userId,
                    isAdmin ? 'MEMBER' : 'ADMIN',
                  );
                  if (ok) {
                    Loading.success('操作成功'.tr);
                  } else {
                    Loading.error('操作失敗'.tr);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove, color: AppColors.red),
                title: Text('移除成員'.tr),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await controller.removeMember(member.userId);
                  if (ok) {
                    Loading.success('已移除'.tr);
                  } else {
                    Loading.error('移除失敗'.tr);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── 群二维码 ──────────────────────────────────────────────────

class _QRCard extends StatelessWidget {
  const _QRCard({required this.controller});

  final GroupProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          Icons.qr_code_2,
          size: 22.w,
          color: AppColors.primary,
        ),
        title: Text('群二維碼'.tr),
        trailing: Icon(
          Icons.chevron_right,
          size: 22.w,
          color: AppColors.assistantText,
        ),
        onTap: () {
          Get.toNamed(
            AppRoutes.GROUP_QR,
            arguments: {
              'groupID': controller.groupID,
              'groupName': controller.groupName,
            },
          );
        },
      ),
    );
  }
}

// ─── 操作按钮（退出/解散） ────────────────────────────────────

class _OperationCard extends StatelessWidget {
  const _OperationCard({required this.controller});

  final GroupProfileController controller;

  @override
  Widget build(BuildContext context) {
    final label = controller.isOwner ? '解散群組'.tr : '退出群組'.tr;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        title: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.sp, color: AppColors.red),
        ),
        onTap: () => _confirmOperation(context),
      ),
    );
  }

  void _confirmOperation(BuildContext context) {
    final isOwner = controller.isOwner;
    AlertUtils.show(
      title: isOwner ? '解散群組'.tr : '退出群組'.tr,
      content: isOwner
          ? '解散後不會接收到此群聊消息'.tr
          : '退出後不會接收到此群聊消息'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
      confirmTextColor: AppColors.red,
    ).then((confirmed) async {
      if (confirmed != true) return;
      if (isOwner) {
        await controller.disbandGroup();
      } else {
        await controller.leaveGroup();
      }
    });
  }
}
