import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class JourneyController extends GetxController with ApiMixin, RefreshableMixin {
  final _focusedMonth = DateTime.now().obs;
  DateTime get focusedMonth => _focusedMonth.value;
  final _selectedDay = Rxn<DateTime>();
  DateTime? get selectedDay => _selectedDay.value;

  final statusFilter = 0.obs; // 0=全部, 1=进行中, 2=待出发, 3=已结束
  final regionFilter = '全部'.obs;
  final searchQuery = ''.obs;

  final allWorks = <JourneyWork>[].obs;
  final filteredWorks = <JourneyWork>[].obs;
  final regions = <String>['全部'].obs;

  final searchCtrl = TextEditingController();
  Worker? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    initRefresh();
    fetchData();
    searchCtrl.addListener(() => searchQuery.value = searchCtrl.text);
    _searchDebounce = debounce<String>(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchCtrl.removeListener(() {});
    _searchDebounce?.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  @override
  Future<void> fetchData() async {
    List<JourneyWork> list = JourneyWork.mockData();
    allWorks.value = list;
    _extractRegions();
    _applyFilters();
    endLoad(list);

    final res = await get(ApiUrl.userJourneyList);
    if (res.isSuccess) {
      final data = res.dataJson['list'] as List<dynamic>? ?? [];
      list = data.map((e) => JourneyWork.fromJson(e)).toList();
      allWorks.value = list;
      _extractRegions();
      _applyFilters();
    }
  }

  void _extractRegions() {
    final set = <String>{'全部'};
    for (final w in allWorks) {
      if (w.region?.isNotEmpty == true) set.add(w.region!);
    }
    regions.value = set.toList();
  }

  void _applyFilters() {
    var list = allWorks.toList();

    if (statusFilter.value != 0) {
      list = list.where((w) => w.effectiveStatusValue == statusFilter.value).toList();
    }

    if (regionFilter.value != '全部') {
      list = list.where((w) => w.region == regionFilter.value).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final kw = searchQuery.value.trim().toLowerCase();
      list = list.where((w) => (w.title?.toLowerCase().contains(kw) ?? false)).toList();
    }

    if (_selectedDay.value != null) {
      final dayStr =
          '${_selectedDay.value!.year}-${_selectedDay.value!.month.toString().padLeft(2, '0')}-${_selectedDay.value!.day.toString().padLeft(2, '0')}';
      list = list.where((w) {
        final start = w.startDate ?? '';
        final end = w.endDate ?? '';
        return dayStr.compareTo(start) >= 0 && dayStr.compareTo(end) <= 0;
      }).toList();
    }

    // 时间线排序：已结束(过去) → 进行中(现在) → 待出发(未来)
    list.sort((a, b) {
      int p(JourneyWorkStatus s) {
        if (s == JourneyWorkStatus.ended) return 0;
        if (s == JourneyWorkStatus.inProgress) return 1;
        return 2;
      }
      final pa = p(a.effectiveStatus);
      final pb = p(b.effectiveStatus);
      if (pa != pb) return pa - pb;
      if (pa == 0) return (b.startDate ?? '').compareTo(a.startDate ?? '');
      return (a.startDate ?? '').compareTo(b.startDate ?? '');
    });

    filteredWorks.value = list;
  }

  void onStatusChanged(int status) { statusFilter.value = status; _applyFilters(); }
  void onRegionChanged(String region) { regionFilter.value = region; _applyFilters(); }
  void onMonthChanged(DateTime month) => _focusedMonth.value = month;

  void onDaySelected(DateTime day) {
    if (_selectedDay.value != null && _selectedDay.value!.year == day.year &&
        _selectedDay.value!.month == day.month && _selectedDay.value!.day == day.day) {
      _selectedDay.value = null;
    } else {
      _selectedDay.value = day;
    }
    _applyFilters();
  }

  void onTapWork(JourneyWork work) {
    Get.toNamed(AppRoutes.JOURNEY_DETAIL, arguments: {'id': work.id});
  }

  void onAddWork() {
    Get.toNamed(AppRoutes.JOURNEY_EDITOR)?.then((_) => onRefresh());
  }

  void syncFromBooking(Map<String, dynamic> bookingData) {}
}
