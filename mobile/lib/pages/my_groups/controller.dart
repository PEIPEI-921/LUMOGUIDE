import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';

/// 我的群聊：通过「已加入群组列表」展示，新建未发消息的群也会显示；点击进入群聊。
class MyGroupsController extends GetxController {
  final _groupList = <V2TimGroupInfo>[].obs;
  List<V2TimGroupInfo> get groupList => _groupList;

  bool _loading = false;
  bool get loading => _loading;

  @override
  void onReady() {
    super.onReady();
    loadJoinedGroups();
  }

  Future<void> loadJoinedGroups() async {
    if (!TIMStore.to.isIMLoginReady) {
      _groupList.clear();
      return;
    }
    _loading = true;
    final list = await TIMStore.to.getJoinedGroupList();
    _groupList.value = list;
    _loading = false;
  }

  Future<void> onTapGroup(V2TimGroupInfo groupInfo) async {
    final conversation = await TIMStore.to.createOrGetConversation(
      groupID: groupInfo.groupID,
    );
    if (conversation == null) return;
    await Get.toNamed(
      AppRoutes.CHAT,
      arguments: {'conversation': conversation},
    );
    await loadJoinedGroups();
  }
}
