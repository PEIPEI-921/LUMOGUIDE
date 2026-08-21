import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

/// 我的群聊：通过「会话列表中的群会话」展示；点击进入群聊。
class MyGroupsController extends GetxController {
  final _groupList = <ChatConversation>[].obs;
  List<ChatConversation> get groupList => _groupList;

  bool _loading = false;
  bool get loading => _loading;

  @override
  void onReady() {
    super.onReady();
    loadJoinedGroups();
  }

  Future<void> loadJoinedGroups() async {
    if (!ChatStore.to.isReady) {
      _groupList.clear();
      return;
    }
    _loading = true;
    final list = await ChatStore.to.getJoinedGroups();
    _groupList.value = list;
    _loading = false;
  }

  Future<void> onTapGroup(ChatConversation group) async {
    await Get.toNamed(
      AppRoutes.CHAT,
      arguments: {'conversation': group},
    );
    await loadJoinedGroups();
  }
}
