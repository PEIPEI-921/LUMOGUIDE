import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_role_enum.dart';

import 'purpose.dart';

/// 选择成员页：创建群聊选人 / 群内添加成员。仅展示互相关注用户，支持多选，上限 200。
/// [addToGroup] 时需传 groupID，且不展示已在群内的用户。
class SelectMembersController extends GetxController
    with ApiMixin, RefreshableMixin<FollowUser>, UserStoreMixin {
  static const int maxSelectCount = 200;

  final _selected = <FollowUser>[].obs;
  List<FollowUser> get selected => _selected;

  final _searchKeyword = ''.obs;
  String get searchKeyword => _searchKeyword.value;

  /// 加人场景下已在群内的 userID，不参与可选列表
  final _excludedUserIDs = <String>[].obs;
  List<String> get excludedUserIDs => _excludedUserIDs;

  TextEditingController? _searchTc;
  TextEditingController get searchTc => _searchTc ??= TextEditingController();

  int get selectedCount => _selected.length;

  /// 用途：建群 / 加人
  SelectMembersPurpose get purpose => _purpose;
  late SelectMembersPurpose _purpose;

  /// 加人场景下的群 ID
  String? get groupID => _groupID;
  String? _groupID;

  bool isSelected(FollowUser user) =>
      _selected.any((e) => e.userId == user.userId);

  bool get canSelectMore => _selected.length < maxSelectCount;

  /// 列表按昵称过滤，且加人时排除已在群内的用户
  List<FollowUser> get filteredItems {
    final keyword = _searchKeyword.value.trim().toLowerCase();
    var list = items;
    if (_purpose == SelectMembersPurpose.addToGroup &&
        _excludedUserIDs.isNotEmpty) {
      list = list
          .where((u) => !_excludedUserIDs.contains(u.userId.toString()))
          .toList();
    }
    if (keyword.isEmpty) return list;
    return list
        .where(
          (u) => (u.userNickname?.toLowerCase().contains(keyword) ?? false),
        )
        .toList();
  }

  void onSearchChanged(String value) => _searchKeyword.value = value;

  @override
  void onClose() {
    _searchTc?.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    initRefresh(limit: 200, isLoadMore: true);
    final args = Get.arguments as Map? ?? {};
    _purpose =
        args['purpose'] as SelectMembersPurpose? ??
        SelectMembersPurpose.createGroup;
    _groupID = args['groupID'] as String?;
  }

  @override
  void onReady() {
    super.onReady();
    fetchData();
    if (_purpose == SelectMembersPurpose.addToGroup &&
        _groupID != null &&
        _groupID!.isNotEmpty) {
      _loadExcludedUserIDs();
    }
  }

  Future<void> _loadExcludedUserIDs() async {
    final ids = await TIMStore.to.getGroupMemberUserIDs(_groupID!);
    _excludedUserIDs.assignAll(ids.toList());
  }

  @override
  Future<void> fetchData() async {
    final url = userInfo.isEnterprise
        ? ApiUrl.messageFollowMyShop
        : ApiUrl.messageFollowMe;
    final res = await get(
      url,
      parameters: {
        'continents_id': 0,
        'area_id': 0,
        'page': page,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    final users = data.map((e) => FollowUser.fromJson(e)).toList();
    endLoad(users);
  }


  void toggleSelect(FollowUser user) {
    if (isSelected(user)) {
      _selected.removeWhere((e) => e.userId == user.userId);
    } else {
      if (!canSelectMore) return;
      _selected.add(user);
    }
    _selected.refresh();
  }

  void removeSelected(FollowUser user) {
    _selected.removeWhere((e) => e.userId == user.userId);
    _selected.refresh();
  }

  /// 根据已选成员生成默认群名：1 人「与 XX 的群聊」，2 人「A、B」，3+ 人「A、B等N人」，总长限制 30 字
  String _defaultGroupName() {
    const maxLen = 30;
    final names = selected
        .map((e) => (e.userNickname ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (names.isEmpty) return '群聊'.tr;
    if (names.length == 1) {
      final s = '与@X的群聊'.trParams({'X': names[0]});
      return s.length > maxLen ? '${s.substring(0, maxLen - 2)}…' : s;
    }
    if (names.length == 2) {
      final s = '${names[0]}、${names[1]}';
      return s.length > maxLen ? '${s.substring(0, maxLen - 2)}…' : s;
    }
    final head = '${names[0]}、${names[1]}';
    final tail = '等@N人'.trParams({'N': '${names.length}'});
    final s = '$head$tail';
    if (s.length <= maxLen) return s;
    final headMax = maxLen - tail.length - 1;
    return '${head.length > headMax ? head.substring(0, headMax) : head}…$tail';
  }

  /// 下一步：建群则创建群聊并进入会话；加人则邀请入群并返回
  void onNextStep() async {
    if (_purpose == SelectMembersPurpose.addToGroup) {
      await _inviteToGroup();
      return;
    }
    await onCreateGroup();
  }

  Future<void> _inviteToGroup() async {
    if (_groupID == null || _groupID!.isEmpty) return;
    Loading.show();
    final userList = selected.map((e) => e.userNumber ?? '').toList();
    if (userList.isEmpty) return;
    final ok = await TIMStore.to.inviteUserToGroup(_groupID!, userList);
    Loading.dismiss();
    if (ok) {
      Loading.success('添加成功'.tr);
      Get.back();
    } else {
      Loading.error('添加群成员失败'.tr);
    }
  }

  onCreateGroup() async {
    Loading.show();
    final groupName = _defaultGroupName();
    final memberList = selected
        .map(
          (e) => V2TimGroupMember(
            userID: e.userNumber ?? '',
            role: GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER,
          ),
        )
        .toList();
    final groupID = await TIMStore.to.createGroup(groupName, memberList);
    Loading.dismiss();
    if (groupID.isEmpty) {
      Loading.error('创建群组失败'.tr);
      return;
    }
    final conversation = await TIMStore.to.createOrGetConversation(
      groupID: groupID,
    );
    Get.offNamed(AppRoutes.CHAT, arguments: {'conversation': conversation});
  }
}
