import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumotrip/common/index.dart';

class GuideBookingManagerController extends GetxController
    with ApiMixin, RefreshableMixin {
  final _focusedDay = DateTime.now().obs;
  DateTime get focusedDay => _focusedDay.value;

  final _selectedDay = Rxn<DateTime>();
  DateTime? get selectedDay => _selectedDay.value;

  final _isAllMode = false.obs;
  bool get isAllMode => _isAllMode.value;

  final _startTime = Rxn<DateTime>();
  final _endTime = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _selectedDay.value = DateTime.now();
    Loading.show();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    String startTime = '';
    String endTime = '';

    if (_startTime.value != null && _endTime.value != null) {
      startTime = DateFormat('yyyy-MM-dd').format(_startTime.value!);
      endTime = DateFormat('yyyy-MM-dd').format(_endTime.value!);
    } else if (!isAllMode) {
      final day = selectedDay ?? DateTime.now();
      startTime = DateFormat('yyyy-MM-dd').format(day);
      endTime = startTime;
    }

    final res = await get(
      ApiUrl.guideReserve,
      parameters: {
        'page': page,
        'limit': limit,
        if (startTime.isNotEmpty) 'start_time': startTime,
        if (endTime.isNotEmpty) 'end_time': endTime,
      },
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    final list = data.map((e) => GuideReservation.fromJson(e)).toList();
    endLoad(list);
  }

  onDateSelected(DateTime startDate, DateTime endDate, bool allMode) {
    _isAllMode.value = allMode;
    if (allMode) {
      _startTime.value = null;
      _endTime.value = null;
      _selectedDay.value = null;
      _focusedDay.value = DateTime.now();
    } else {
      _selectedDay.value = startDate;
      _focusedDay.value = startDate;
      _startTime.value = startDate;
      _endTime.value = endDate;
    }
    Loading.show();
    onRefresh();
  }

  onTapItem(GuideReservation item) async {
    if (item.isRead == 0) {
      item.isRead = 1;
      refreshItems();
    }
    final res = await Get.toNamed(
      AppRoutes.GUIDE_BOOKING_DETAIL,
      arguments: {'id': item.id},
    );
    if (res == true) {
      onRefresh();
    }
  }
}
