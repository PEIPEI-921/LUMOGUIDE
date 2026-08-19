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
      final infoArg = Get.arguments['info'];
      merchantInfo = infoArg is MerchantInfo ? infoArg : MerchantInfo();
      final typeArg = Get.arguments['type'];
      // 缺 'type' key 或類型不匹配時給默認值，避免強轉崩潰
      shopType = typeArg is MerchantShopType
          ? typeArg
          : MerchantShopType.scenic;
      final bookArg = Get.arguments['bookInfo'];
      bookInfo = bookArg is UserReservationMerchant ? bookArg : null;
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
      // 用 tryParse 避免後端時間格式異常導致打開編輯頁即崩潰
      _arriveTime.value = DateTime.tryParse(bookInfo!.arrivalTime ?? '');
      _checkInTime.value = DateTime.tryParse(bookInfo!.arrivalTime ?? '');
      _checkOutTime.value = DateTime.tryParse(bookInfo!.leaveTime ?? '');
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
  }

  bool _submitting = false;

  onSubmit() async {
    // 防重複提交
    if (_submitting) return;
    _submitting = true;
    try {
      await _doSubmit();
    } finally {
      _submitting = false;
    }
  }

  Future<void> _doSubmit() async {
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

    // 合併備註與其他要求，避免同 key 重複覆蓋
    final mergedRemark = [
      if (remarksController.text.trim().isNotEmpty)
        remarksController.text.trim(),
      if (otherRequirementsController.text.trim().isNotEmpty)
        otherRequirementsController.text.trim(),
    ].join('\n');

    final fileUrl = await _uploadFile();
    final url = isEdit
        ? ApiUrl.userReserveCompanyEdit
        : ApiUrl.addContentReserve;

    // 酒店場景用 checkIn/checkOut 作 arrival/leave，其他類型用到達時間，
    // 避免 payload 中同 key 重複（後者覆蓋前者導致數據丟失）。
    final isHotel = shopType == MerchantShopType.hotel;
    final arrival = isHotel ? checkInTime : arriveTime;
    final leave = isHotel ? checkOutTime : null;

    final res = await post(
      url,
      data: {
        'content_id': merchantInfo.id,
        if (arrival != null) 'arrival_time': arrival,
        if (leave != null) 'leave_time': leave,
        'number': peopleCountController.text.trim(),
        'room_number': roomCountController.text.trim(),
        'tickets_type': ticketTypeController.text.trim(),
        if (mergedRemark.isNotEmpty) 'remark': mergedRemark,
        'contact': contactNameController.text.trim(),
        'email': contactEmailController.text.trim(),
        'phone': contactPhoneController.text.trim(),
        'other': otherContactController.text.trim(),
        // 編輯模式未重新選文件時回傳原附件，避免後端清空
        if (fileUrl.isNotEmpty) 'file': fileUrl,
        if (isEdit && fileUrl.isEmpty) 'file': bookInfo?.file ?? '',
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
