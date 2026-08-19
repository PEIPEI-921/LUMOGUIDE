import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';

/// 群组详情页：从路由参数获取 groupID，可选 groupName 用于标题。
class GroupProfileController extends GetxController {
  String groupID = '';
  String get groupName => groupInfo?.groupName ?? '';

  final _groupInfo = Rxn<V2TimGroupInfo>();
  V2TimGroupInfo? get groupInfo => _groupInfo.value;

  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments as Map;
    groupID = args['groupID'] as String;
  }

  @override
  void onReady() {
    super.onReady();
    fetchGroupInfo();
  }

  Future<void> fetchGroupInfo() async {
    _groupInfo.value = await TIMStore.to.getGroupInfo(groupID);
  }
}
