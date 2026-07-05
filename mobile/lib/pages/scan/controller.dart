import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class ScanController extends GetxController {
  Future<bool> onJoinGroupByGroupID(String groupID) async {
    if (groupID.isEmpty) return false;
    final info = await TIMStore.to.getGroupInfo(groupID);
    if (info == null) {
      Loading.error('群組不存在或已解散'.tr);
      return false;
    }
    Loading.show();
    final res = await TIMStore.to.joinGroup(
      groupID: groupID,
      message: '',
      groupType: info.groupType,
    );
    Loading.dismiss();
    if (res.code == 0) {
      Loading.success('加入成功'.tr);
      Get.back();
      Get.toNamed(AppRoutes.GROUP_PROFILE, arguments: {'groupID': groupID});
      return true;
    }
    final msg = res.desc.isNotEmpty ? res.desc : '加入失敗'.tr;
    Loading.error(msg);
    return false;
  }
}
