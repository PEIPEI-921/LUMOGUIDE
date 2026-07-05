import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';

class ProfileController extends GetxController with ApiMixin, UserStoreMixin {
  @override
  void onInit() {
    super.onInit();
    reloadUserInfo();
  }

  onEditAvatar() {
    Get.toNamed(
      AppRoutes.USER_AVATAR,
      arguments: {'avatarUrl': userInfo.avatar},
    );
  }

  onEditNickname() {
    Get.toNamed(AppRoutes.NICKNAME);
  }

  onBindPhone() {
    if (userInfo.phone.isNotEmpty) {
      return;
    }
    Get.toNamed(AppRoutes.MODIFY_PHONE);
  }

  onEditBirthdate() async {
    final date = await DatePicker.show(
      title: '選擇出生日期'.tr,
      selected: DateTime.now(),
      maxDate: DateTime.now(),
    );
    if (date == null) {
      return;
    }
    Loading.show();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final res = await UserStore.to.modifyProfile({'birthday': dateStr});
    Loading.dismiss();
    if (!res) {
      AlertUtils.error('修改失敗'.tr);
      return;
    }
  }
}
