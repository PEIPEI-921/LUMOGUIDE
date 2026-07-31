import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class JourneyController extends GetxController with ApiMixin, RefreshableMixin {
  final _focusedMonth = DateTime.now().obs;
  DateTime get focusedMonth => _focusedMonth.value;
  Rx<DateTime> get focusedMonthRx => _focusedMonth;
  final _selectedDay = Rxn<DateTime>();
  DateTime? get selectedDay => _selectedDay.value;

  final statusFilter = 0.obs; // 0=全部, 1=进行中, 2=待出发, 3=已结束
  final showEnded = false.obs; // 全部模式下是否显示已结束行程（toggle）
  final regionFilter = '全部'.obs;
  final searchQuery = ''.obs;

  final allWorks = <JourneyWork>[].obs;
  final filteredWorks = <JourneyWork>[].obs;
  final regions = <String>['全部'].obs;

  final searchCtrl = TextEditingController();
  Worker? _searchDebounce;

  /// 城市ID → 国家名称映射（从 systemContinents 接口加载）
  final _cityCountryMap = <int, String>{};
  /// 国家名 → 洲名映射（如 奥地利→欧洲）
  final _countryContinentMap = <String, String>{};
  /// 城市名 → 大洲名映射（用于 region 兜底计算）
  final _cityNameToContinent = <String, String>{};
  /// 城市名 → 国家名映射（用于搜索）
  final _cityNameToCountry = <String, String>{};
  bool _continentsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    initRefresh();
    fetchData();
    _loadSystemContinents();
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
    // 初始占位（显示加载中）
    allWorks.value = [];
    _extractRegions();
    _applyFilters();
    endLoad([]);

    // 从后端加载用户自己的历程数据
    final res = await get(ApiUrl.userJourneyList);
    if (res.isSuccess) {
      final data = res.dataJson['list'] as List<dynamic>? ?? [];
      final list = data.map((e) => JourneyWork.fromJson(e)).toList();
      allWorks.value = list;
      _extractRegions();
      _applyFilters();
    }
  }

  void _extractRegions() {
    final set = <String>{'全部'};
    for (final w in allWorks) {
      final allCities = _allCityNames(w);
      final continent = _continentForWork(w);
      debugPrint('📌 work "${w.title}" cities=$allCities region=${w.region} → continent=$continent');
      if (continent?.isNotEmpty == true) set.add(continent!);
    }
    debugPrint('📌 regions: $set (maps: cities=${_cityNameToContinent.length}, countries=${_countryContinentMap.length})');
    regions.value = set.toList();
  }

  /// 收集工作涉及的所有城市名（从多个来源汇总）
  List<String> _allCityNames(JourneyWork w) {
    final names = <String>[...w.cities];
    if (w.departureCity?.isNotEmpty == true) names.add(w.departureCity!);
    if (w.endCity?.isNotEmpty == true) names.add(w.endCity!);
    for (final day in w.itineraryDays) {
      for (final block in day.cityBlocks) {
        if (block.cityName?.isNotEmpty == true) names.add(block.cityName!);
      }
    }
    return names;
  }

  /// 获取工作所属大洲（纯大洲级别，不含次区域）
  String? _continentForWork(JourneyWork w) {
    // 1. 从所有城市名推算大洲（汇总 cities + departureCity + endCity + cityBlocks）
    final allCities = _allCityNames(w);
    final fromCities = _continentFromCities(allCities);
    if (fromCities != null) return fromCities;

    // 2. API region 可能在 country→continent 映射中（如"奥地利"→"欧洲"）
    if (w.region?.isNotEmpty == true && _countryContinentMap.isNotEmpty) {
      final c = _countryContinentMap[w.region!];
      if (c != null && c.isNotEmpty) return c;
      // region 自身可能就是大洲名
      if (_countryContinentMap.values.toSet().contains(w.region)) return w.region;
    }

    // 3. 兜底：map 为空时直接用 API region
    if (w.region?.isNotEmpty == true && _cityNameToContinent.isEmpty && _countryContinentMap.isEmpty) {
      return w.region;
    }
    return null;
  }

  /// 从城市名推算大洲（返回首个匹配的大洲名，或 null）
  String? _continentFromCities(List<String> cityNames) {
    if (_cityNameToContinent.isEmpty || cityNames.isEmpty) return null;
    for (final cn in cityNames) {
      final c = _cityNameToContinent[cn];
      if (c != null && c.isNotEmpty) return c;
    }
    return null;
  }

  /// 从 /common/systemContinents 加载城市→国家→大洲映射
  Future<void> _loadSystemContinents() async {
    if (_continentsLoaded) return;
    try {
      final res = await get(ApiUrl.systemContinents);
      debugPrint('🌍 systemContinents API: isSuccess=${res.isSuccess}');
      if (!res.isSuccess) return;
      final data = res.dataJson;
      final list = data['data'] as List<dynamic>?;
      debugPrint('🌍 systemContinents data count: ${list?.length ?? 0}');
      if (list == null) return;
      for (final item in list) {
        _walkTree(item, []);
      }
      _continentsLoaded = true;
      // 用 CityListStore 的繁体城市名覆盖 _cityNameToContinent
      // （systemContinents 返回简体中文，工作数据是繁体中文，需通过 city ID 桥接）
      await _mergeCityNamesFromStore();
      debugPrint('🌍 _cityNameToContinent (after merge): ${_cityNameToContinent.length} entries');
      debugPrint('🌍 _countryContinentMap: ${_countryContinentMap.length} entries');
      // 重新提取区域
      _extractRegions();
      _applyFilters();
    } catch (e) {
      debugPrint('🌍 systemContinents error: $e');
    }
  }

  /// 用 CityListStore 的城市数据（app 当前语言的繁体中文）填充 _cityNameToContinent
  /// 桥梁：city ID → _cityCountryMap → country → _countryContinentMap → continent
  /// 同时填充 _cityNameToCountry：城市名 → 国家名（用于搜索）
  Future<void> _mergeCityNamesFromStore() async {
    final store = CityListStore.to;
    if (store.cityList.isEmpty) {
      await store.fetchCityList();
    }
    int added = 0;
    for (final city in store.cityList) {
      if (city.id == null || city.name == null || city.name!.isEmpty) continue;
      final country = _cityCountryMap[city.id!];
      if (country == null) continue;
      // 城市名 → 国家名（搜索用）
      _cityNameToCountry[city.name!] = country;
      // 城市名 → 大洲名（地区筛选用）
      final continent = _countryContinentMap[country];
      if (continent != null && continent.isNotEmpty) {
        if (!_cityNameToContinent.containsKey(city.name)) {
          _cityNameToContinent[city.name!] = continent;
          added++;
        }
      }
    }
    debugPrint('🌍 merged $added city names from CityListStore (total cityList: ${store.cityList.length})');
  }

  /// 递归遍历层级树，建立：
  /// - _cityCountryMap: 城市ID → 国家名
  /// - _countryContinentMap: 国家名 → 洲名
  /// - _cityNameToContinent: 城市名 → 大洲名（直接映射）
  void _walkTree(dynamic node, List<String> ancestors) {
    if (node is! Map<String, dynamic>) return;
    final name = node['name'] as String?;
    final nodeId = node['id'] as int?;
    final children = node['children'] as List<dynamic>?;

    if (children != null && children.isNotEmpty) {
      for (final child in children) {
        _walkTree(child, [...ancestors, name ?? '']);
      }
    } else if (nodeId != null && ancestors.isNotEmpty) {
      // 叶子节点 = 城市，ancestors[0] = 洲，ancestors[-1] = 国家
      final countryName = ancestors.last;
      final continentName = ancestors.first;
      _cityCountryMap[nodeId] = countryName;
      _countryContinentMap[countryName] = continentName;
      // 同时建立城市名→大洲名的直接映射
      if (name != null && continentName.isNotEmpty) {
        _cityNameToContinent[name] = continentName;
      }
    }
  }

  void _applyFilters() {
    var list = allWorks.toList();

    if (statusFilter.value != 0) {
      list = list.where((w) => w.effectiveStatusValue == statusFilter.value).toList();
    }

    // 全部模式下：默认隐藏已结束行程，toggle 后显示全部（模板除外）
    if (statusFilter.value == 0 && !showEnded.value) {
      list = list.where((w) => w.effectiveStatus != JourneyWorkStatus.ended).toList();
    }

    if (regionFilter.value != '全部') {
      list = list.where((w) => _continentForWork(w) == regionFilter.value).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final kw = searchQuery.value.trim().toLowerCase();
      list = list.where((w) => _workMatchesSearch(w, kw)).toList();
    }

    // 日期筛选：模板没有日期，始终保留
    if (_selectedDay.value != null) {
      final dayStr =
          '${_selectedDay.value!.year}-${_selectedDay.value!.month.toString().padLeft(2, '0')}-${_selectedDay.value!.day.toString().padLeft(2, '0')}';
      list = list.where((w) {
        final start = w.startDate ?? '';
        final end = w.endDate ?? '';
        return dayStr.compareTo(start) >= 0 && dayStr.compareTo(end) <= 0;
      }).toList();
    }

    // 排序：全部模式按 startDate 升序，其他状态按 startDate 升序
    if (statusFilter.value == 0) {
      list.sort((a, b) => (a.startDate ?? '').compareTo(b.startDate ?? ''));
    } else {
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
    }

    filteredWorks.value = list;
  }

  void onStatusChanged(int status) { statusFilter.value = status; _applyFilters(); }

  /// 搜索匹配：标题 + 城市名 + 国家名
  bool _workMatchesSearch(JourneyWork w, String kw) {
    // 标题
    if (w.title?.toLowerCase().contains(kw) ?? false) return true;
    // region 字段
    if (w.region?.toLowerCase().contains(kw) ?? false) return true;
    // 所有城市名
    for (final cn in _allCityNames(w)) {
      if (cn.toLowerCase().contains(kw)) return true;
      // 城市对应的国家名
      final country = _cityNameToCountry[cn];
      if (country != null && country.toLowerCase().contains(kw)) return true;
    }
    return false;
  }

  /// 分隔线「已结束」点击 toggle：展开/收起已结束行程
  void toggleShowEnded() {
    showEnded.value = !showEnded.value;
    _applyFilters();
  }
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
    Get.toNamed(AppRoutes.JOURNEY_DETAIL, arguments: {'id': work.id, 'work': work});
  }

  void onAddWork() {
    Get.toNamed(AppRoutes.JOURNEY_EDITOR)?.then((_) => onRefresh());
  }

  void syncFromBooking(Map<String, dynamic> bookingData) {}
}
