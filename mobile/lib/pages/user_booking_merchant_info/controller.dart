import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:url_launcher/url_launcher.dart';

import '../user_booking_manager/widgets/merchant.dart';

class UserBookingMerchantInfoController extends GetxController
    with ApiMixin, RefreshableMixin {
  int id = 0;

  final _merchantInfo = Rxn<UserReservationMerchant>();
  UserReservationMerchant? get merchantInfo => _merchantInfo.value;

  MerchantShopType get shopType =>
      MerchantShopTypeExt.fromId(merchantInfo?.contentType ?? 0);

  bool get canEdit => merchantInfo?.status == 1 || merchantInfo?.status == 2;

  bool get canCancel => merchantInfo?.status == 1 || merchantInfo?.status == 2;

  bool get canDelete => [3, 4, 5, 6].contains(merchantInfo?.status);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      id = Get.arguments['id'] as int? ?? 0;
    }
    initRefresh();
  }

  @override
  void onReady() {
    super.onReady();
    Loading.show();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.userReserveCompanyInfo,
      parameters: {'id': id},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    _merchantInfo.value = UserReservationMerchant.fromJson(res.dataJson);
    endLoad([]);
  }

  onTapFile() async {
    if (merchantInfo?.file?.isNotEmpty == true) {
      await launchUrl(
        Uri.parse(merchantInfo!.file!),
        mode: LaunchMode.inAppBrowserView,
      );
    }
  }

  void onEdit() async {
    final res = await Get.toNamed(
      AppRoutes.BOOKING_MERCHANT,
      arguments: {'type': shopType, 'bookInfo': merchantInfo},
    );
    if (res == true) {
      onRefresh();
    }
  }

  void onCancel() async {
    final flag = await AlertUtils.show(
      title: '取消預約'.tr,
      content: '確定要取消此預約嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) {
      return;
    }
    Loading.show();
    final res = await post(ApiUrl.userReserveCompanyCancel, data: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('取消成功'.tr);
    onRefresh();
    if (Get.isRegistered<UserBookingMerchantController>()) {
      Get.find<UserBookingMerchantController>().onRefresh();
    }
  }

  void onDeleteReservation() async {
    final flag = await AlertUtils.show(
      title: '刪除預約'.tr,
      content: '確定要刪除此預約嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) {
      return;
    }
    Loading.show();
    final res = await post(ApiUrl.userReserveCompanyDelete, data: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('刪除成功'.tr);
    await Future.delayed(const Duration(seconds: 1));
    Get.back(result: true);
  }

  void makePhoneCall() {
    if (merchantInfo?.content?.phone?.isNotEmpty == true) {
      try {
        launchUrl(Uri.parse('tel:${merchantInfo?.content?.phone}'));
      } catch (e) {}
    }
  }
}
