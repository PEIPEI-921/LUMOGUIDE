import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class ScanController extends GetxController {
  Future<bool> onJoinGroupByGroupID(String groupID) async {
    if (groupID.isEmpty) return false;
    // LUMO-Chat 无自助加群接口：群成员需由群主/管理员添加
    Loading.error('無法直接加入群組，請聯繫群主邀請'.tr);
    return false;
  }
}
