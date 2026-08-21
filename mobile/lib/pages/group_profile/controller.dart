import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/message/controller.dart';
import 'package:lumotrip/pages/select_members/purpose.dart';

/// 群组详情页（LUMO-Chat）：从路由参数获取 groupID。
class GroupProfileController extends GetxController with ApiMixin {
  String groupID = '';
  String get groupName => _groupInfo.value?.title ?? '';

  final _groupInfo = Rxn<ChatConversation>();
  ChatConversation? get groupInfo => _groupInfo.value;

  /// 群成员列表
  final _members = <ChatGroupMember>[].obs;
  List<ChatGroupMember> get members => _members;

  /// 成员昵称缓存（user_id -> 昵称）
  final _memberNicknames = <String, String>{}.obs;
  Map<String, String> get memberNicknames => _memberNicknames;

  final _loading = false.obs;
  bool get loading => _loading.value;

  /// 当前用户角色
  String get myRole => _myRole;
  String _myRole = 'MEMBER';

  bool get isOwner => _myRole == 'OWNER';
  bool get isAdmin => _myRole == 'OWNER' || _myRole == 'ADMIN';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    groupID = args['groupID'] as String? ?? '';
  }

  @override
  void onReady() {
    super.onReady();
    if (groupID.isEmpty) return;
    fetchGroupInfo();
  }

  Future<void> fetchGroupInfo() async {
    _loading.value = true;
    final info = await ChatStore.to.getGroup(groupID);
    if (info != null) {
      _groupInfo.value = info;
    }
    final memberList = await ChatStore.to.getGroupMembers(groupID);
    _members.assignAll(memberList);
    // 当前用户角色
    final me = memberList.firstWhereOrNull(
      (m) => m.userId == UserStore.to.profile.number,
    );
    _myRole = me?.role ?? 'MEMBER';
    await _resolveMemberNicknames();
    _loading.value = false;
  }

  Future<void> _resolveMemberNicknames() async {
    final need = members
        .map((m) => m.userId)
        .where((id) => id.isNotEmpty && !_memberNicknames.containsKey(id))
        .toList();
    if (need.isEmpty) return;
    await Future.wait(need.map((userId) async {
      try {
        final res = await get(
          ApiUrl.memberInfo,
          parameters: {'user_number': userId},
        );
        if (res.isSuccess) {
          final nick = res.dataJson.safeString('nickname');
          if (nick != null && nick.isNotEmpty) {
            _memberNicknames[userId] = nick;
          }
        }
      } catch (e) {
        // 静默
      }
    }));
  }

  String memberName(String userId) {
    final nick = _memberNicknames[userId];
    if (nick != null && nick.isNotEmpty) return nick;
    return userId;
  }

  /// 添加成员（进入选人页）
  void onAddMembers() {
    Get.toNamed(AppRoutes.SELECT_MEMBERS, arguments: {
      'purpose': SelectMembersPurpose.addToGroup,
      'groupID': groupID,
    })?.then((_) => fetchGroupInfo());
  }

  /// 退出群组
  Future<bool> leaveGroup() async {
    final ok = await ChatStore.to.leaveGroup(groupID);
    if (ok) {
      Get.until((route) => route.isFirst);
      _refreshMessageHall();
    }
    return ok;
  }

  /// 解散群组（仅群主）
  Future<bool> disbandGroup() async {
    final ok = await ChatStore.to.disbandGroup(groupID);
    if (ok) {
      Get.until((route) => route.isFirst);
      _refreshMessageHall();
    }
    return ok;
  }

  void _refreshMessageHall() {
    if (Get.isRegistered<MessageController>()) {
      Get.find<MessageController>().fetchData();
    }
  }

  /// 移除成员
  Future<bool> removeMember(String userId) async {
    final ok = await ChatStore.to.removeGroupMember(groupID, userId);
    if (ok) {
      _members.removeWhere((m) => m.userId == userId);
    }
    return ok;
  }

  /// 设置管理员/成员（群主）
  Future<bool> setMemberRole(String userId, String role) async {
    final ok = await ChatStore.to.updateMemberRole(groupID, userId, role);
    if (ok) {
      final idx = _members.indexWhere((m) => m.userId == userId);
      if (idx >= 0) {
        _members[idx] = ChatGroupMember(
          userId: userId,
          role: role,
          lastReadMessageId: _members[idx].lastReadMessageId,
        );
        _members.refresh();
      }
    }
    return ok;
  }

  /// 更新群公告
  Future<bool> updateAnnouncement(String text) async {
    final ok = await ChatStore.to.updateGroupAnnouncement(groupID, text);
    if (ok) {
      _groupInfo.value = _groupInfo.value?.copyWith(announcement: text);
    }
    return ok;
  }
}
