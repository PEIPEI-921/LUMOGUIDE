import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';

class BookingGuideController extends GetxController
    with ApiMixin, UserStoreMixin {
  late GuideList guideInfo;

  UserReservationGuide? bookInfo;

  final peopleCountController = TextEditingController();
  final itineraryController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactEmailController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final otherContactController = TextEditingController();

  final _arriveTime = Rxn<DateTime>();
  String? get arriveTime => _arriveTime.value != null
      ? DateFormat('yyyy-MM-dd HH:mm').format(_arriveTime.value!)
      : null;

  bool get isEdit => bookInfo != null;

  @override
  onInit() {
    super.onInit();
    if (Get.arguments != null) {
      guideInfo = Get.arguments['info'] as GuideList? ?? GuideList();
      bookInfo = Get.arguments['bookInfo'] as UserReservationGuide?;
      if (bookInfo != null) {
        guideInfo = bookInfo!.guide ?? GuideList();
      }
    }
    if (bookInfo != null) {
      peopleCountController.text = bookInfo!.number ?? '';
      itineraryController.text = bookInfo!.remark ?? '';
      contactNameController.text = bookInfo!.contact ?? '';
      contactEmailController.text = bookInfo!.email ?? '';
      contactPhoneController.text = bookInfo!.phone ?? '';
      otherContactController.text = bookInfo!.other ?? '';
      _arriveTime.value = bookInfo!.arrivalTime != null
          ? DateTime.parse(bookInfo!.arrivalTime!)
          : null;
    } else {
      contactEmailController.text = userInfo.email ?? '';
      contactPhoneController.text = userInfo.phone ?? '';
    }
  }

  @override
  void onClose() {
    peopleCountController.dispose();
    itineraryController.dispose();
    contactNameController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    otherContactController.dispose();
    super.onClose();
  }

  onSelectArriveTime() async {
    DateTime selected = _arriveTime.value ?? DateTime.now();
    if (selected.isBefore(DateTime.now())) {
      selected = DateTime.now();
    }
    final res = await DateTimePicker.show(
      title: '請選擇預計到達時間'.tr,
      selected: selected,
    );
    if (res != null) {
      _arriveTime.value = res;
    }
  }

  onSubmit() async {
    if (arriveTime == null) {
      Loading.toast('請選擇預計到達時間'.tr);
      return;
    }
    if (peopleCountController.text.trim().isEmpty) {
      Loading.toast('請輸入人數'.tr);
      return;
    }
    if (contactNameController.text.trim().isEmpty) {
      Loading.toast('請輸入聯繫人姓名'.tr);
      return;
    }
    if (contactEmailController.text.trim().isEmpty) {
      Loading.toast('請輸入聯繫人郵箱'.tr);
      return;
    }
    if (contactPhoneController.text.trim().isEmpty) {
      Loading.toast('請輸入聯繫電話'.tr);
      return;
    }

    final url = isEdit ? ApiUrl.userReserveGuideEdit : ApiUrl.reserveGuide;
    Loading.show();
    final res = await post(
      url,
      data: {
        'guide_id': guideInfo.id,
        'city_id': guideInfo.cityId,
        'arrival_time': arriveTime,
        'number': peopleCountController.text.trim(),
        'remark': itineraryController.text.trim(),
        'contact': contactNameController.text.trim(),
        'email': contactEmailController.text.trim(),
        'phone': contactPhoneController.text.trim(),
        'other': otherContactController.text.trim(),
        if (isEdit) 'id': bookInfo!.id,
      },
    );
    Loading.dismiss();

    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    await AlertUtils.customAlert(
      assets: Assets.iconReview,
      imageSize: Size(50.w, 50.w),
      title: '預約成功，請等待導遊確認~'.tr,
      confirmText: '關閉'.tr,
    );
    Get.back(result: true);
  }
}
