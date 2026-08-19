import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class VIPCheckUtils {
  static bool check({showAlert = true}) {
    if (UserStore.to.profile.isVipExpired) {
      if (showAlert) {
        VIPCheckUtils.showAlert();
      }
      return false;
    }
    return true;
  }

  static showAlert() async {
    final flag = await AlertUtils.show(
      title: '會員已過期'.tr,
      content: '您的會員已過期，想繼續使用全部功能，請延長會員會籍'.tr,
      confirmText: '延長會籍'.tr,
      cancelText: '知道了'.tr,
    );
    if (flag) {
      Get.toNamed(AppRoutes.MEMBER_CENTER);
    }
  }
}
