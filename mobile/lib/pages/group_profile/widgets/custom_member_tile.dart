import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/select_members/purpose.dart';
import 'package:provider/provider.dart';
import 'package:tencent_chat_i18n_tool/tencent_chat_i18n_tool.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_role.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_full_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_full_info.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitGroupProfile/group_member/tui_delete_group_member.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitGroupProfile/group_member/tui_group_member_list.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/avatar.dart';

/// 自定义群成员区块：公开群/会议群下，群主或管理员也显示「添加成员」按钮（UIKit 默认仅 Work/Private 显示）。
class CustomMemberTile extends StatelessWidget {
  const CustomMemberTile({super.key});

  static List<V2TimGroupMemberFullInfo?> _getMemberList(
    List<V2TimGroupMemberFullInfo?> memberList,
    int showRange,
  ) {
    if (memberList.length > showRange) {
      return memberList.getRange(0, showRange).toList();
    }
    return memberList;
  }

  static String _getShowName(V2TimGroupMemberFullInfo? item) {
    final friendRemark = item?.friendRemark ?? "";
    final nickName = item?.nickName ?? "";
    final userID = item?.userID;
    final showName = nickName.isNotEmpty ? nickName : (userID ?? "");
    return friendRemark.isNotEmpty ? friendRemark : showName;
  }

  void _navigateToMemberList(
    BuildContext context,
    TUIGroupProfileModel model,
    List<V2TimGroupMemberFullInfo?> memberList,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GroupProfileMemberListPage(model: model, memberList: memberList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TUIGroupProfileModel>(context);
    final groupInfo = model.groupInfo;
    final memberList = model.groupMemberList;
    final memberAmount = groupInfo?.memberCount ?? memberList.length;
    final option1 = memberAmount.toString();

    final groupType = groupInfo?.groupType ?? "";
    // role 为原生整型：200=成员，300=管理员，400=群主（非 Dart 枚举 index）
    final role = groupInfo?.role;
    final isOwner =
        role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER; // 400
    final isAdmin =
        role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN; // 300
    final isPublicOrMeeting =
        groupType == GroupType.Public || groupType == GroupType.Meeting;

    const showAdd = true;
    final showDelete = model.canKickOffMember();

    // 第一行总格子数约 8：头像数 + 加号(若有) + 减号(若有)
    final int showRange = 8 - (showAdd ? 1 : 0) - (showDelete ? 1 : 0);

    final theme = Theme.of(context);
    final weakColor = theme.colorScheme.onSurface.withOpacity(0.5);
    final darkColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _navigateToMemberList(context, model, memberList),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TIM_t("群成员"),
                    style: TextStyle(color: darkColor, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        TIM_t_para("{{option1}}人", "$option1人")(
                          option1: option1,
                        ),
                        style: TextStyle(color: darkColor, fontSize: 16),
                      ),
                      Icon(Icons.keyboard_arrow_right, color: weakColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: [
                ..._getMemberList(memberList, showRange).map((element) {
                  final faceUrl = element?.faceUrl ?? "";
                  final showName = _getShowName(element);
                  return InkWell(
                    onTapDown: (details) {
                      if (model.onClickUser != null &&
                          element?.userID != null) {
                        model.onClickUser!(element!, details);
                      }
                    },
                    child: SizedBox(
                      width: 60,
                      height: 76,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Avatar(
                              faceUrl: faceUrl,
                              showName: showName,
                              type: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            showName,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: weakColor, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (showAdd)
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(4.5),
                    color: weakColor,
                    dashPattern: const [6, 3],
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        onPressed: () async {
                          await Get.toNamed(
                            AppRoutes.SELECT_MEMBERS,
                            arguments: {
                              'purpose': SelectMembersPurpose.addToGroup,
                              'groupID': model.groupID,
                            },
                          );
                          if (context.mounted) {
                            model.loadData(model.groupID);
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        color: weakColor,
                      ),
                    ),
                  ),
                if (showDelete)
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(4.5),
                    color: weakColor,
                    dashPattern: const [6, 3],
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DeleteGroupMemberPage(model: model),
                            ),
                          );
                          if (context.mounted) {
                            model.loadData(model.groupID);
                          }
                        },
                        icon: const Icon(Icons.remove, size: 18),
                        color: weakColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (memberList.length > showRange)
            InkWell(
              onTap: () => _navigateToMemberList(context, model, memberList),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 16),
                child: Text(
                  TIM_t("查看更多群成员"),
                  style: TextStyle(color: weakColor, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
