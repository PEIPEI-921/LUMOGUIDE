import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/user_booking_manager/widgets/guide.dart';

class UserBookingGuideInfoController extends GetxController
    with ApiMixin, RefreshableMixin {
  int id = 0;

  final _guideInfo = Rxn<UserReservationGuide>();
  UserReservationGuide? get guideInfo => _guideInfo.value;

  bool get canEdit => guideInfo?.status == 1 || guideInfo?.status == 2;

  bool get canCancel => guideInfo?.status == 1 || guideInfo?.status == 2;

  bool get canDelete => [3, 4, 5, 6].contains(guideInfo?.status);

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
    final res = await get(ApiUrl.userReserveGuideInfo, parameters: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    _guideInfo.value = UserReservationGuide.fromJson(res.dataJson);
    endLoad([]);
  }

  void onEdit() async {
    final res = await Get.toNamed(
      AppRoutes.BOOKING_GUIDE,
      arguments: {'bookInfo': guideInfo},
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
    final res = await post(ApiUrl.userReserveGuideCancel, data: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('取消成功'.tr);
    onRefresh();
    if (Get.isRegistered<UserBookingGuideController>()) {
      Get.find<UserBookingGuideController>().onRefresh();
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
    final res = await post(ApiUrl.userReserveGuideDelete, data: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('刪除成功'.tr);
    await Future.delayed(const Duration(seconds: 1));
    Get.back(result: true);
  }
}
