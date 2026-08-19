import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:url_launcher/url_launcher.dart';

import '../index.dart';

class MerchantBookingDetailController extends GetxController
    with ApiMixin, RefreshableMixin {
  int id = 0;

  final _merchantInfo = Rxn<MerchantReservation>();
  MerchantReservation? get merchantInfo => _merchantInfo.value;

  MerchantShopType get shopType =>
      MerchantShopTypeExt.fromId(merchantInfo?.contentType ?? 0);

  bool get canConfirm => merchantInfo?.status == 1;
  bool get canComplete => merchantInfo?.status == 2;
  bool get canReject => merchantInfo?.status == 1;
  bool get canDelete => [4, 5, 6].contains(merchantInfo?.status);

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
    final res = await get(ApiUrl.companyReserveInfo, parameters: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    _merchantInfo.value = MerchantReservation.fromJson(res.dataJson);
    endLoad([]);
  }

  void confirmReservation() async {
    if (merchantInfo?.status == 3) {
      return;
    }
    final flag = await AlertUtils.show(
      title: merchantInfo?.status == 1 ? '確認預約'.tr : '完成預約'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) {
      return;
    }
    Loading.show();
    final res = await post(
      ApiUrl.merchantConfirmReserve,
      data: {'id': id, 'status': merchantInfo?.status == 1 ? 2 : 3},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    if (merchantInfo?.status == 1) {
      Loading.success('預約已確認'.tr);
    } else {
      Loading.success('預約已完成'.tr);
    }
    if (Get.isRegistered<MerchantBookingManagerController>()) {
      Get.find<MerchantBookingManagerController>().onRefresh();
    }
    onRefresh();
  }

  void rejectReservation() async {
    if (!canReject) return;
    final reason = await RejectReasonSheet.show(
      title: '拒絕預約'.tr,
      hintText: '請輸入拒絕理由'.tr,
    );
    if (reason == null) return;
    final flag = await AlertUtils.show(
      title: '拒絕預約'.tr,
      content: '確定要拒絕此預約嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) return;
    Loading.show();
    final res = await post(
      ApiUrl.merchantRejectReserve,
      data: {'id': id, 'reason': reason},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('已拒絕'.tr);
    if (Get.isRegistered<MerchantBookingManagerController>()) {
      Get.find<MerchantBookingManagerController>().onRefresh();
    }
    onRefresh();
  }

  void deleteReservation() async {
    if (!canDelete) return;
    final flag = await AlertUtils.show(
      title: '刪除預約'.tr,
      content: '確定要刪除此預約嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) return;
    Loading.show();
    final res = await post(ApiUrl.merchantDeleteReserve, data: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('刪除成功'.tr);
    await Future.delayed(const Duration(milliseconds: 600));
    Get.back(result: true);
    if (Get.isRegistered<MerchantBookingManagerController>()) {
      Get.find<MerchantBookingManagerController>().onRefresh();
    }
  }

  onTapFile() async {
    if (merchantInfo?.file?.isNotEmpty == true) {
      await launchUrl(
        Uri.parse(merchantInfo!.file!),
        mode: LaunchMode.inAppBrowserView,
      );
    }
  }
}
