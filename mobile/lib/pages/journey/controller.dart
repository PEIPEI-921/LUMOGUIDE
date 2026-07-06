import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class JourneyController extends GetxController with ApiMixin, RefreshableMixin {
  // 日历
  final _focusedMonth = DateTime.now().obs;
  DateTime get focusedMonth => _focusedMonth.value;
  final _selectedDay = Rxn<DateTime>();
  DateTime? get selectedDay => _selectedDay.value;

  // 筛选
  final statusFilter = 0.obs; // 0=全部, 1=进行中, 2=待出发, 3=已结束
  final regionFilter = '全部'.obs;
  final searchQuery = ''.obs;

  // 原始数据 & 过滤后数据
  final allWorks = <JourneyWork>[].obs;
  final filteredWorks = <JourneyWork>[].obs;

  // 可用区域列表
  final regions = <String>['全部'].obs;

  // 搜索控制器
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
    // 先用 mock 数据立即渲染，避免白屏等待
    // TODO: 对接后端 API: GET /user/journeyList
    List<JourneyWork> list = JourneyWork.mockData();
    allWorks.value = list;
    _extractRegions();
    _applyFilters();
    endLoad(list);

    // 后台尝试 API 请求，成功后替换数据
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

    // 状态筛选
    if (statusFilter.value != 0) {
      list = list
          .where((w) => w.effectiveStatusValue == statusFilter.value)
          .toList();
    }

    // 区域筛选
    if (regionFilter.value != '全部') {
      list = list.where((w) => w.region == regionFilter.value).toList();
    }

    // 关键词搜索
    if (searchQuery.value.trim().isNotEmpty) {
      final kw = searchQuery.value.trim().toLowerCase();
      list = list.where((w) =>
          (w.title?.toLowerCase().contains(kw) ?? false)).toList();
    }

    // 日期筛选（选中某天时）
    if (_selectedDay.value != null) {
      final dayStr =
          '${_selectedDay.value!.year}-${_selectedDay.value!.month.toString().padLeft(2, '0')}-${_selectedDay.value!.day.toString().padLeft(2, '0')}';
      list = list.where((w) {
        final start = w.startDate ?? '';
        final end = w.endDate ?? '';
        return dayStr.compareTo(start) >= 0 && dayStr.compareTo(end) <= 0;
      }).toList();
    }

    // 按开始日期排序
    list.sort((a, b) => (a.startDate ?? '').compareTo(b.startDate ?? ''));

    filteredWorks.value = list;
  }

  void onStatusChanged(int status) {
    statusFilter.value = status;
    _applyFilters();
  }

  void onRegionChanged(String region) {
    regionFilter.value = region;
    _applyFilters();
  }

  void onMonthChanged(DateTime month) {
    _focusedMonth.value = month;
  }

  void onDaySelected(DateTime day) {
    if (_selectedDay.value != null &&
        _selectedDay.value!.year == day.year &&
        _selectedDay.value!.month == day.month &&
        _selectedDay.value!.day == day.day) {
      _selectedDay.value = null; // 再次点击取消选择
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

  /// 来自预约同步时调用（外部入口）
  void syncFromBooking(Map<String, dynamic> bookingData) {
    // TODO: 对接后端 API: POST /user/journeySync
  }
}
