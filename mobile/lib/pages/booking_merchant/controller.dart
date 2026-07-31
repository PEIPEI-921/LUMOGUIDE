import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';

class BookingMerchantController extends GetxController
    with ApiMixin, UserStoreMixin {
  late MerchantInfo merchantInfo;
  late MerchantShopType shopType;
  UserReservationMerchant? bookInfo;

  final peopleCountController = TextEditingController();
  final remarksController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactEmailController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final otherContactController = TextEditingController();

  // 酒店专用字段
  final checkInTimeController = TextEditingController();
  final checkOutTimeController = TextEditingController();
  final roomCountController = TextEditingController();
  final otherRequirementsController = TextEditingController();

  // 景点专用字段
  final ticketTypeController = TextEditingController();

  final _file = Rxn<PlatformFile>();
  PlatformFile? get file => _file.value;

  String? get fileName => file?.name ?? bookInfo?.file?.split('/').last;

  // 时间选择
  final _arriveTime = Rxn<DateTime>();
  final _checkInTime = Rxn<DateTime>();
  final _checkOutTime = Rxn<DateTime>();

  String? get arriveTime => _arriveTime.value != null
      ? DateFormat('yyyy-MM-dd HH:mm').format(_arriveTime.value!)
      : null;

  String? get checkInTime => _checkInTime.value != null
      ? DateFormat('yyyy-MM-dd HH:mm').format(_checkInTime.value!)
      : null;

  String? get checkOutTime => _checkOutTime.value != null
      ? DateFormat('yyyy-MM-dd HH:mm').format(_checkOutTime.value!)
      : null;

  bool get isEdit => bookInfo != null;

  @override
  onInit() {
    super.onInit();
    if (Get.arguments != null) {
      merchantInfo = Get.arguments['info'] as MerchantInfo? ?? MerchantInfo();
      shopType = Get.arguments['type'] as MerchantShopType;
      bookInfo = Get.arguments['bookInfo'] as UserReservationMerchant?;
      if (bookInfo != null) {
        merchantInfo = bookInfo!.content ?? MerchantInfo();
      }
    }
    if (isEdit) {
      peopleCountController.text = bookInfo!.number ?? '';
      remarksController.text = bookInfo!.remark ?? '';
      contactNameController.text = bookInfo!.contact ?? '';
      contactEmailController.text = bookInfo!.email ?? '';
      contactPhoneController.text = bookInfo!.phone ?? '';
      otherContactController.text = bookInfo!.other ?? '';
      _arriveTime.value = bookInfo!.arrivalTime != null
          ? DateTime.parse(bookInfo!.arrivalTime!)
          : null;
      _checkInTime.value = bookInfo!.arrivalTime != null
          ? DateTime.parse(bookInfo!.arrivalTime!)
          : null;
      _checkOutTime.value = bookInfo!.leaveTime != null
          ? DateTime.parse(bookInfo!.leaveTime!)
          : null;
    } else {
      contactEmailController.text = userInfo.email ?? '';
      contactPhoneController.text = userInfo.phone ?? '';
    }
  }

  @override
  void onClose() {
    peopleCountController.dispose();
    remarksController.dispose();
    contactNameController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    otherContactController.dispose();
    checkInTimeController.dispose();
    checkOutTimeController.dispose();
    roomCountController.dispose();
    otherRequirementsController.dispose();
    ticketTypeController.dispose();
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

  onSelectCheckInTime() async {
    DateTime selected = _checkInTime.value ?? DateTime.now();
    if (selected.isBefore(DateTime.now())) {
      selected = DateTime.now();
    }
    final res = await DateTimePicker.show(
      title: '請選擇入住時間'.tr,
      selected: selected,
    );
    if (res != null) {
      _checkInTime.value = res;
    }
  }

  onSelectCheckOutTime() async {
    DateTime selected = _checkOutTime.value ?? DateTime.now();
    if (selected.isBefore(DateTime.now())) {
      selected = DateTime.now();
    }
    final res = await DateTimePicker.show(
      title: '請選擇離店時間'.tr,
      selected: selected,
    );
    if (res != null) {
      _checkOutTime.value = res;
    }
  }

  onSelectFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'xlsx',
        'xls',
        'csv',
        'pdf',
        'doc',
        'docx',
        'txt',
        'md',
        'pdf',
      ],
    );
    if (res == null) {
      return;
    }
    _file.value = res.files.single;
    print(file);
  }

  onSubmit() async {
    // 通用验证
    if (peopleCountController.text.trim().isEmpty) {
      Loading.toast('請輸入人數'.tr);
      return;
    }

    // 类型特定验证
    switch (shopType) {
      case MerchantShopType.restaurant:
      case MerchantShopType.shopping:
      case MerchantShopType.scenic:
        if (arriveTime == null) {
          Loading.toast('請選擇預計到達時間'.tr);
          return;
        }
        break;
      case MerchantShopType.hotel:
        if (checkInTime == null) {
          Loading.toast('請選擇入住時間'.tr);
          return;
        }
        if (checkOutTime == null) {
          Loading.toast('請選擇離店時間'.tr);
          return;
        }
        if (roomCountController.text.trim().isEmpty) {
          Loading.toast('請輸入房間數'.tr);
          return;
        }
        break;
      case MerchantShopType.ticket:
        if (ticketTypeController.text.trim().isEmpty) {
          Loading.toast('請輸入門票類型'.tr);
          return;
        }
        break;
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

    Loading.show();

    final fileUrl = await _uploadFile();
    final url = isEdit
        ? ApiUrl.userReserveCompanyEdit
        : ApiUrl.addContentReserve;

    final res = await post(
      url,
      data: {
        'content_id': merchantInfo.id,
        if (arriveTime != null) 'arrival_time': arriveTime,
        if (checkInTime != null) 'arrival_time': checkInTime,
        if (checkOutTime != null) 'leave_time': checkOutTime,
        'number': peopleCountController.text.trim(),
        'room_number': roomCountController.text.trim(),
        'tickets_type': ticketTypeController.text.trim(),
        if (remarksController.text.trim().isNotEmpty)
          'remark': remarksController.text.trim(),
        if (otherRequirementsController.text.trim().isNotEmpty)
          'remark': otherRequirementsController.text.trim(),
        'contact': contactNameController.text.trim(),
        'email': contactEmailController.text.trim(),
        'phone': contactPhoneController.text.trim(),
        'other': otherContactController.text.trim(),
        if (fileUrl.isNotEmpty) 'file': fileUrl,
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
      title: '預約成功，請等待商家確認~'.tr,
      confirmText: '關閉'.tr,
    );
    Get.back(result: true);
  }

  Future<String> _uploadFile() async {
    if (file == null) {
      return '';
    }
    final path = await ConfigService.to.uploadFile(file!.path!);
    return path;
  }
}
