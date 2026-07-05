import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/message/controller.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_role.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/life_cycle/group_profile_life_cycle.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitGroupProfile/group_profile_widget.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_profile_widget.dart';

import 'controller.dart';
import 'widgets/custom_member_tile.dart';
import 'widgets/group_profile_button_area.dart';

/// 群组详情页：使用 IM UIKit 的 TIMUIKitGroupProfile，通过 profileWidgetBuilder 自定义部分数据与入口。
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
      body: TIMUIKitGroupProfile(
        groupID: controller.groupID,
        backGroundColor: Colors.transparent,
        profileWidgetBuilder: _buildProfileWidgetBuilder(controller),
        profileWidgetsOrder: _profileWidgetsOrder,
        lifeCycle: GroupProfileLifeCycle(
          didLeaveGroup: () async {
            Get.until((route) => route.isFirst);
            Get.find<MessageController>().fetchData();
          },
        ),
      ),
    );
  }

  /// 自定义顺序：在详情卡下方插入「群二维码」等自定义入口
  static const List<GroupProfileWidgetEnum> _profileWidgetsOrder = [
    GroupProfileWidgetEnum.detailCard,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.memberListTile,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.customBuilderOne,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.customBuilderTwo,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.customBuilderThree,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.groupNotice,
    GroupProfileWidgetEnum.groupManage,
    // GroupProfileWidgetEnum.groupJoiningModeBar,
    // GroupProfileWidgetEnum.groupTypeBar,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.pinedConversationBar,
    GroupProfileWidgetEnum.muteGroupMessageBar,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.nameCardBar,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.buttonArea,
  ];

  GroupProfileWidgetBuilder _buildProfileWidgetBuilder(
    GroupProfileController controller,
  ) {
    return GroupProfileWidgetBuilder(
      operationDivider: () => Container(color: Colors.transparent, height: 10),
      detailCard: (groupInfo, _) => TIMUIKitGroupProfileWidget.detailCard(
        groupInfo: groupInfo,
        isHavePermission: false,
      ),
      memberListTile: (_) => const CustomMemberTile(),
      customBuilderOne: (groupInfo, _) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0.w),
          tileColor: Colors.white,
          title: Text('群二維碼'.tr),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.assistantText,
          ),
          onTap: () {
            Get.toNamed(
              AppRoutes.GROUP_QR,
              arguments: {
                'groupID': groupInfo.groupID,
                'groupName': groupInfo.groupName ?? '',
              },
            );
          },
        );
      },
      customBuilderTwo: (groupInfo, _) {
        final role = groupInfo.role;
        final canEdit =
            role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER ||
            role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
        if (!canEdit) return const SizedBox.shrink();
        return Builder(
          builder: (ctx) => ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 0.w,
            ),
            tileColor: Colors.white,
            title: Text('修改群名稱'.tr),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.assistantText,
            ),
            onTap: () =>
                GroupProfilePage._showEditGroupNameBottomSheet(ctx, groupInfo),
          ),
        );
      },
      customBuilderThree: (groupInfo, _) {
        final role = groupInfo.role;
        final canEdit =
            role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER ||
            role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
        if (!canEdit) return const SizedBox.shrink();
        return Builder(
          builder: (ctx) => ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 0.w,
            ),
            tileColor: Colors.white,
            title: Text('修改群頭像'.tr),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.assistantText,
            ),
            onTap: () =>
                GroupProfilePage._handleEditGroupAvatar(ctx, groupInfo),
          ),
        );
      },
      buttonArea: (groupInfo, memberList) => GroupProfileButtonAreaNoTransfer(
        groupInfo: groupInfo,
        memberList: memberList,
      ),
      searchMessage: () {
        return Builder(
          builder: (ctx) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 0.w,
              ),
              tileColor: Colors.white,
              title: Text('搜索聊天記錄'.tr),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.assistantText,
              ),
              onTap: () async {
                final conv = await TIMStore.to.createOrGetConversation(
                  groupID: controller.groupID,
                );
                if (!ctx.mounted || conv == null) return;
                Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => IScaffold(
                      appBar: IAppBar(title: '搜索聊天記錄'.tr),
                      body: TIMUIKitSearchMsgDetail(
                        currentConversation: conv,
                        keyword: '',
                        onTapConversation: (_, __) => Navigator.of(ctx).pop(),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static void _showEditGroupNameBottomSheet(
    BuildContext context,
    V2TimGroupInfo groupInfo,
  ) {
    final controller = TextEditingController(text: groupInfo.groupName ?? '');
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
                  color: AppColors.assistantText.withOpacity(0.2),
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
                          fillColor: AppColors.assistantText.withOpacity(0.08),
                          isDense: true,
                          hintText: '修改群名稱'.tr,
                        ),
                        autofocus: true,
                        maxLength: 30,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '修改群名稱'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.assistantText,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = controller.text.trim();
                            if (name.isEmpty) return;
                            final model = Provider.of<TUIGroupProfileModel>(
                              context,
                              listen: false,
                            );
                            final res = await model.setGroupName(name);
                            Navigator.pop(ctx);
                            if (context.mounted &&
                                res != null &&
                                res.code != 0) {
                              AlertUtils.error('修改失敗'.tr);
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

  static Future<void> _handleEditGroupAvatar(
    BuildContext context,
    V2TimGroupInfo groupInfo,
  ) async {
    final path = await ImagePickerUtil.selectImage(context);
    if (path.isEmpty || !context.mounted) return;
    Loading.show();
    final url = await ConfigService.to.uploadFile(path);
    if (!context.mounted) {
      Loading.dismiss();
      return;
    }
    if (url.isEmpty) {
      Loading.dismiss();
      AlertUtils.error('圖片上傳失敗'.tr);
      return;
    }
    final sdk = TIMUIKitCore.getSDKInstance();
    final info = V2TimGroupInfo(
      groupID: groupInfo.groupID,
      groupType: groupInfo.groupType,
    )..faceUrl = url;
    final res = await sdk.getGroupManager().setGroupInfo(info: info);
    Loading.dismiss();
    if (!context.mounted) return;
    if (res.code != 0) {
      AlertUtils.error('修改失敗'.tr);
      return;
    }
    final model = Provider.of<TUIGroupProfileModel>(context, listen: false);
    model.loadData(groupInfo.groupID);
  }
}
