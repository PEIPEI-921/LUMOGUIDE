import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/journey_detail/widgets/template_save_dialog.dart';

class JourneyEditorController extends GetxController with ApiMixin {
  final formKey = GlobalKey<FormState>();
  final isEdit = false.obs;
  final _workId = Rxn<int>();

  // ====== 快速创建 ======
  final titleCtrl = TextEditingController();
  final adultCountCtrl = TextEditingController();
  final childCountCtrl = TextEditingController();

  // ====== 日期 & 时间 ======
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final daysCount = 0.obs; // 行程天数（响应式，供 UI 绑定）
  // 到达
  final arrDateCtrl = TextEditingController();
  final arrTimeCtrl = TextEditingController();
  final arrAirportCtrl = TextEditingController();
  // 离开
  final depDateCtrl = TextEditingController();
  final depTimeCtrl = TextEditingController();
  final depAirportCtrl = TextEditingController();
  // 航班号
  final arrFlightCtrl = TextEditingController();
  final depFlightCtrl = TextEditingController();

  // ====== 城市（从站内选） ======
  final cities = <CityList>[].obs; // 全局关联城市（从日行程汇总）
  final cityList = <CityList>[].obs; // 站内全部城市

  // ====== 旅程起止城市（地理起止点，非航班起降地）======
  final startCity = Rxn<CityList>(); // 游览起始城市
  final endCity = Rxn<CityList>();   // 游览结束城市

  // ====== 人员 ======
  final leaderNameCtrl = TextEditingController();
  final leaderPhoneCtrl = TextEditingController();
  final driverNameCtrl = TextEditingController();
  final driverPhoneCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();

  // ====== 费用 ======
  final totalPriceCtrl = TextEditingController();
  final cashAdvanceCtrl = TextEditingController();

  // ====== 应急 ======
  final agencyContactCtrl = TextEditingController();
  final agencyPhoneCtrl = TextEditingController();
  final emergencyPhoneCtrl = TextEditingController();

  // ====== 备注 ======
  final descriptionCtrl = TextEditingController();

  // ====== 日行程（每天可选不同城市） ======
  final itineraryDays = <ItineraryDay>[].obs;

  // 展开状态
  final showFlight = false.obs;
  final showItinerary = false.obs;
  final showPeople = false.obs;
  final showCost = false.obs;
  final showEmergency = false.obs;

  /// 某天的城市推荐资源
  final cityRecommendations = <int, RxList<CityResource>>{}.obs;

  /// 本工作中已被添加到行程的推荐资源 key 集合（格式: "$type:$id"）
  /// 用于过滤推荐列表，同一资源不可重复选择
  final usedResourceKeys = <String>{}.obs;

  /// 总人数（响应式）
  final totalPeople = 0.obs;

  /// 城市ID → 国家名称映射（从 systemContinents 接口加载）
  final _cityCountryMap = <int, String>{};
  /// 国家名 → 地区名映射（如 奥地利→中欧）
  final _countryRegionMap = <String, String>{};
  /// 国家名 → 洲名映射（如 奥地利→欧洲）
  final _countryContinentMap = <String, String>{};

  // ====== 草稿自动保存 ======
  Timer? _draftSaveTimer;
  bool _hasDraft = false; // 存储中是否有待恢复的草稿
  bool _draftRestored = false; // 是否已从草稿恢复
  bool _restoring = false; // 正在恢复草稿中，阻止 autoGenerateTitle 覆盖已保存标题
  bool _submitted = false; // 已成功提交，阻止 onClose 再次保存草稿

  @override
  void onInit() {
    super.onInit();
    _loadCityList();
    if (Get.arguments != null) {
      final work = Get.arguments['work'] as JourneyWork?;
      if (work != null) {
        isEdit.value = true;
        _workId.value = work.id;
        _loadWork(work);
      }
      final template = Get.arguments['template'] as JourneyTemplate?;
      if (template != null) {
        loadFromTemplate(template);
      }
    }
    startDateCtrl.addListener(_syncDays);
    endDateCtrl.addListener(_syncDays);
    adultCountCtrl.addListener(_updateTotalPeople);
    childCountCtrl.addListener(_updateTotalPeople);

    // 新建模式下检查是否有未完成的草稿
    if (!isEdit.value && Get.arguments?['template'] == null) {
      _checkExistingDraft();
      _startDraftAutoSave();
    }
  }

  void _updateTotalPeople() {
    final a = int.tryParse(adultCountCtrl.text) ?? 0;
    final c = int.tryParse(childCountCtrl.text) ?? 0;
    totalPeople.value = a + c;
  }

  Future<void> _loadCityList() async {
    try {
      final res = await get(ApiUrl.cityList, parameters: {'limit': 1000, 'page': 1});
      if (res.isSuccess) {
        final data = res.dataJson['list'] as List<dynamic>? ?? [];
        cityList.value = data.map((e) => CityList.fromJson(e)).toList();
      }
    } catch (_) {}
    // 并行加载城市→国家归属映射
    _loadSystemContinents();
  }

  /// 从 /manage/systemContinents 递归解析城市→国家映射
  Future<void> _loadSystemContinents() async {
    try {
      final res = await get(ApiUrl.systemContinents);
      debugPrint('[systemContinents] isSuccess=${res.isSuccess}');
      if (!res.isSuccess) {
        debugPrint('[systemContinents] message=${res.message}');
        return;
      }
      final data = res.dataJson;
      debugPrint('[systemContinents] data keys=${data.keys}');
      final list = data['data'] as List<dynamic>?;
      debugPrint('[systemContinents] list length=${list?.length}');
      if (list == null) return;
      for (final item in list) {
        _walkTree(item, []);
      }
      debugPrint('[systemContinents] cityMap=${_cityCountryMap.length} regionMap=${_countryRegionMap.length} continentMap=${_countryContinentMap.length}');
      // 打印前5条映射用于验证
      final entries = _cityCountryMap.entries.take(5).toList();
      for (final e in entries) {
        debugPrint('[systemContinents] cityId=${e.key} → ${e.value}');
      }
      // 映射表加载完成后，如果是新建模式且有城市数据，重新生成标题
      // （解决首次创建时 continent map 未加载导致标题缺少国家名的问题）
      if (!isEdit.value && (_hasCityData() || titleCtrl.text.trim().isNotEmpty)) {
        _autoGenerateTitle();
      }
    } catch (e) {
      debugPrint('[systemContinents] error=$e');
    }
  }

  /// 是否有城市数据（用于判断是否需要重新生成标题）
  bool _hasCityData() {
    if (startCity.value != null || endCity.value != null) return true;
    for (final day in itineraryDays) {
      for (final block in day.cityBlocks) {
        if (block.cityId != null) return true;
      }
    }
    return false;
  }

  /// 递归遍历层级树，同时建立三张映射：
  /// - _cityCountryMap: 城市ID → 国家名
  /// - _countryRegionMap: 国家名 → 地区名（4层结构时有值）
  /// - _countryContinentMap: 国家名 → 洲名
  ///
  /// 树结构可能是 3 层（洲→国家→城市）或 4 层（洲→地区→国家→城市）
  /// ancestors 链: [洲, (地区), 国家]，叶子节点=城市
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
      // 叶子节点 = 城市，ancestors 最后一项 = 国家名
      final countryName = ancestors.last;
      _cityCountryMap[nodeId] = countryName;

      // 国家→地区：4 层结构时 ancestors[-2] 即地区，3 层时无地区
      if (ancestors.length >= 3) {
        final regionName = ancestors[ancestors.length - 2];
        if (!_countryRegionMap.containsKey(countryName)) {
          _countryRegionMap[countryName] = regionName;
        }
      }
      // 国家→洲：ancestors[0] 始终是洲
      if (!_countryContinentMap.containsKey(countryName)) {
        _countryContinentMap[countryName] = ancestors.first;
      }

      // 同时通过名称匹配 cityList 建立城市映射（兜底 ID 不一致的情况）
      if (name != null && name.isNotEmpty) {
        final match = cityList.firstWhereOrNull(
          (c) => c.id == nodeId || c.name == name || c.nameEn == name,
        );
        if (match != null && match.id != null) {
          _cityCountryMap[match.id!] = countryName;
        }
      }
    }
  }

  // ====== 城市国家名（优先 city.country → systemContinents 映射 → areaName）======
  String cityCountry(CityList c) {
    if (c.country?.isNotEmpty == true) return c.country!;
    if (c.id != null && _cityCountryMap.containsKey(c.id)) return _cityCountryMap[c.id!]!;
    return c.areaName ?? '';
  }

  // ====== 城市选择 ======
  void addCity(CityList city) {
    if (!cities.any((c) => c.id == city.id)) {
      cities.add(city);
    }
  }

  void removeCity(CityList city) => cities.removeWhere((c) => c.id == city.id);

  /// 为某天添加城市块
  void addDayCity(int dayIndex, CityList city) {
    final day = itineraryDays[dayIndex];
    final exists = day.cityBlocks.any((b) => b.cityId == city.id);
    if (city.id != null && !exists) {
      day.cityBlocks = [...day.cityBlocks, DayCityBlock(cityId: city.id, cityName: city.name)];
      itineraryDays.refresh();
      _loadDayRecommendations(dayIndex, day.cityBlocks.map((b) => b.cityId!).where((id) => id != null).toList());
      _autoGenerateTitle();
    }
  }

  /// 从某天移除城市块
  void removeDayCity(int dayIndex, int blockIndex) {
    final day = itineraryDays[dayIndex];
    if (blockIndex < day.cityBlocks.length) {
      // 释放该城市块中所有推荐资源的 key
      for (final item in day.cityBlocks[blockIndex].items) {
        final key = _itemResourceKey(item);
        if (key != null) usedResourceKeys.remove(key);
      }

      final newBlocks = List<DayCityBlock>.from(day.cityBlocks)..removeAt(blockIndex);
      day.cityBlocks = newBlocks;
      itineraryDays.refresh();
      if (day.cityBlocks.isNotEmpty) {
        _loadDayRecommendations(dayIndex, day.cityBlocks.where((b) => b.cityId != null).map((b) => b.cityId!).toList());
      } else {
        cityRecommendations.remove(dayIndex);
      }
      _autoGenerateTitle();
    }
  }

  /// 加载某天所有城市的推荐资源（支持多城市）
  Future<void> _loadDayRecommendations(int dayIndex, List<int> cityIds) async {
    final items = <CityResource>[];

    for (final cityId in cityIds) {
      try {
        // 1) 景点
        final attrRes = await get(ApiUrl.cityAttraction, parameters: {
          'city_id': cityId, 'page': 1, 'limit': 10,
        });
        if (attrRes.isSuccess) {
          final list = (attrRes.dataJson['list'] as List<dynamic>? ?? [])
              .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
              .toList();
          for (final m in list) {
            items.add(CityResource(
              type: 'attraction', label: m.name ?? '景点',
              icon: Icons.landscape_outlined, cityId: cityId,
              id: m.id, name: m.name, imageUrl: m.firstPicture,
            ));
          }
        }

        // 2) 活动（过滤已过期）
        final actRes = await get(ApiUrl.cityActivity, parameters: {
          'city_id': cityId, 'page': 1, 'limit': 10,
        });
        if (actRes.isSuccess) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final list = (actRes.dataJson['list'] as List<dynamic>? ?? [])
              .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
              .where((m) {
                if (m.endTime == null || m.endTime!.isEmpty) return true;
                final endDate = DateTime.tryParse(m.endTime!);
                if (endDate == null) return true;
                return !endDate.isBefore(today);
              })
              .toList();
          for (final m in list) {
            items.add(CityResource(
              type: 'activity', label: m.name ?? '活动',
              icon: Icons.festival_outlined, cityId: cityId,
              id: m.id, name: m.name, imageUrl: m.firstPicture,
              startTime: m.startTime, endTime: m.endTime,
            ));
          }
        }

        // 3) 餐厅
        final restRes = await get(ApiUrl.cityRestaurant, parameters: {
          'city_id': cityId, 'page': 1, 'limit': 10,
        });
        if (restRes.isSuccess) {
          final list = (restRes.dataJson['list'] as List<dynamic>? ?? [])
              .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
              .toList();
          for (final m in list) {
            items.add(CityResource(
              type: 'merchant', label: m.name ?? '餐厅',
              icon: Icons.restaurant_outlined, cityId: cityId,
              id: m.id, name: m.name, imageUrl: m.firstPicture,
            ));
          }
        }

        // 4) 购物
        final shopRes = await get(ApiUrl.cityShopping, parameters: {
          'city_id': cityId, 'page': 1, 'limit': 10,
        });
        if (shopRes.isSuccess) {
          final list = (shopRes.dataJson['list'] as List<dynamic>? ?? [])
              .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
              .toList();
          for (final m in list) {
            items.add(CityResource(
              type: 'shopping', label: m.name ?? '购物',
              icon: Icons.shopping_bag_outlined, cityId: cityId,
              id: m.id, name: m.name, imageUrl: m.firstPicture,
            ));
          }
        }
      } catch (_) {
        // 单个城市请求失败，继续下一个
      }

      // 兜底：API 全部失败或返回空时仍显示 4 个通用标签
      if (items.isEmpty) {
        items.addAll([
          CityResource(type: 'attraction', label: '景点', icon: Icons.landscape_outlined, cityId: cityId),
          CityResource(type: 'activity', label: '活动', icon: Icons.festival_outlined, cityId: cityId),
          CityResource(type: 'merchant', label: '餐厅', icon: Icons.restaurant_outlined, cityId: cityId),
          CityResource(type: 'shopping', label: '购物', icon: Icons.shopping_bag_outlined, cityId: cityId),
        ]);
      }
    }

    cityRecommendations[dayIndex] = items.obs;
  }

  // ====== 日行程管理 ======
  void _syncDays() {
    if (_restoring) return; // 恢复草稿期间不自动生成
    final start = DateTime.tryParse(startDateCtrl.text.trim());
    final end = DateTime.tryParse(endDateCtrl.text.trim());
    if (start == null || end == null) return;
    final days = end.difference(start).inDays + 1;
    if (days <= 0 || days > 90) return;
    // 已有内容则不覆盖
    if (itineraryDays.isNotEmpty && itineraryDays.length == days &&
        itineraryDays.any((d) => d.cityBlocks.any((b) => b.items.isNotEmpty))) return;

    itineraryDays.value = List.generate(days, (i) {
      final d = start.add(Duration(days: i));
      return ItineraryDay(
        dayNumber: i + 1,
        date: '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      );
    });
    showItinerary.value = days > 0;
    daysCount.value = days;

    // 自动生成团名
    _autoGenerateTitle();
  }

  // ====== 日期范围选择（单一日历框选起止） ======
  Future<void> pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialStart = DateTime.tryParse(startDateCtrl.text.trim()) ?? now;
    final initialEnd = DateTime.tryParse(endDateCtrl.text.trim()) ??
        initialStart.add(const Duration(days: 1));

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: '选择出发和结束日期',
      saveText: '确定',
      fieldStartHintText: '出发日期',
      fieldEndHintText: '结束日期',
    );

    if (picked != null) {
      startDateCtrl.text = _fmtDate(picked.start);
      endDateCtrl.text = _fmtDate(picked.end);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ====== 团名自动生成 ======
  /// 规则：
  /// - 1国：国家全名 + N日游
  /// - 2-3国：取每个国家首字拼接 + N日游
  /// - 4-5国：取国家所属地区首字拼接 + N国 + N日游
  /// - 6国及以上：取洲名 + N日游
  void _autoGenerateTitle() {
    // 仅新建模式自动填充（编辑模式保留原标题）
    if (isEdit.value) return;
    // 恢复草稿期间保留已保存的标题
    if (_restoring) return;

    final start = DateTime.tryParse(startDateCtrl.text.trim());
    final end = DateTime.tryParse(endDateCtrl.text.trim());
    if (start == null || end == null) return;
    final days = end.difference(start).inDays + 1;
    if (days <= 0) return;

    // ---- 收集所有行程涉及的城市名（去重保序）----
    final seen = <String>{};
    final allCityNames = <String>[];
    void addCity(String? name) {
      if (name != null && name.isNotEmpty && seen.add(name)) {
        allCityNames.add(name);
      }
    }
    addCity(startCity.value?.name);
    addCity(endCity.value?.name);
    for (final day in itineraryDays) {
      for (final block in day.cityBlocks) {
        addCity(block.cityName);
        // 从每个城市块的 items 标题中提取涉及的城市名
        for (final item in block.items) {
          _extractCityFromTitle(item.title, seen, allCityNames);
          _extractCityFromTitle(item.description, seen, allCityNames);
        }
      }
    }

    if (allCityNames.isEmpty) {
      titleCtrl.text = '$days日游';
      return;
    }

    // ---- 城市名 → 国家名 → 去重保序 ----
    String countryOf(String cityName) {
      final c = cityList.firstWhereOrNull(
        (cl) => cl.name == cityName || cl.nameEn == cityName,
      );
      if (c != null) return cityCountry(c);
      return cityName; // 查不到就用城市名兜底
    }

    final seenCountries = <String>{};
    final countries = <String>[];
    for (final cn in allCityNames) {
      final country = countryOf(cn);
      if (country.isNotEmpty && seenCountries.add(country)) {
        countries.add(country);
      }
    }

    if (countries.isEmpty) {
      titleCtrl.text = '$days日游';
      return;
    }

    final n = countries.length;
    String title;

    if (n == 1) {
      // 1国：奥地利7日游
      title = '${countries[0]}$days日游';
    } else if (n <= 3) {
      // 2-3国：取首字拼接 → 奥匈7日游 / 奥捷匈7日游
      final abbr = countries.map((c) => c.characters.first).join();
      title = '$abbr$days日游';
    } else if (n <= 5) {
      // 4-5国：取地区首字拼接 → 中东欧四国7日游
      final seenRegions = <String>{};
      final regionNames = <String>[];
      for (final country in countries) {
        final region = _countryRegionMap[country] ??
            _countryContinentMap[country] ??
            country;
        if (region.isNotEmpty && seenRegions.add(region)) {
          regionNames.add(region);
        }
      }
      final regionAbbr = regionNames.map((r) => r.characters.first).join();
      title = '$regionAbbr${n}国$days日游';
    } else {
      // 6国及以上：取洲名
      final seenContinents = <String>{};
      final continentNames = <String>[];
      for (final country in countries) {
        final continent = _countryContinentMap[country] ?? '';
        if (continent.isNotEmpty && seenContinents.add(continent)) {
          continentNames.add(continent);
        }
      }
      if (continentNames.length == 1) {
        title = '${continentNames[0]}$days日游';
      } else {
        // 跨洲 → 取前3国首字 + 等多国
        final abbr = countries.take(3).map((c) => c.characters.first).join();
        title = '$abbr等多国$days日游';
      }
    }

    titleCtrl.text = title;
  }

  /// 从文本中提取已知城市名（匹配 cityList 中的中/英文名）
  void _extractCityFromTitle(
      String? text, Set<String> seen, List<String> allCityNames) {
    if (text == null || text.isEmpty) return;
    for (final c in cityList) {
      if (c.name != null && c.name!.isNotEmpty && text.contains(c.name!)) {
        if (seen.add(c.name!)) allCityNames.add(c.name!);
      }
      if (c.nameEn != null && c.nameEn!.isNotEmpty && text.contains(c.nameEn!)) {
        if (seen.add(c.nameEn!)) allCityNames.add(c.nameEn!);
      }
    }
  }

  // ====== 游览起始/结束城市选择器 ======
  void showStartCityPicker(BuildContext context) =>
      _showCityPickerSheet(context, '选择游览起始城市', (c) => startCity.value = c);

  void showEndCityPicker(BuildContext context) =>
      _showCityPickerSheet(context, '选择游览结束城市', (c) => endCity.value = c);

  void _showCityPickerSheet(
    BuildContext context,
    String title,
    void Function(CityList) onSelected,
  ) {
    final searchCtrl = TextEditingController();
    final filtered = <CityList>[].obs;
    filtered.value = List.from(cityList);
    searchCtrl.addListener(() {
      final kw = searchCtrl.text.toLowerCase();
      filtered.value = cityList
          .where((c) =>
              (c.name?.toLowerCase().contains(kw) ?? false) ||
              (c.nameEn?.toLowerCase().contains(kw) ?? false))
          .toList();
    });

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
        ),
        child: Column(children: [
          SizedBox(height: 10.w),
          Container(
              width: 36.w,
              height: 4.w,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.w))),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索城市',
                prefixIcon:
                    Icon(Icons.search, size: 18.sp),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.w),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(vertical: 10.w),
              ),
            ),
          ),
          SizedBox(height: 8.w),
          Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      return ListTile(
                        leading: CircleAvatar(
                            radius: 16.w,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.08),
                            child: Icon(Icons.location_on_outlined,
                                size: 16.sp, color: AppColors.primary)),
                        title: Text(c.name ?? '',
                            style: TextStyle(fontSize: 14.sp)),
                        subtitle: Text(
                            '${c.nameEn ?? ''}  ${cityCountry(c)}',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.secondaryText)),
                        onTap: () {
                          onSelected(c);
                          _autoGenerateTitle();
                          Get.back();
                        },
                      );
                    },
                  ))),
        ]),
      ),
      isScrollControlled: true,
    );
  }

  void updateDayField(int dayIndex, String field, String value) {
    final day = itineraryDays[dayIndex];
    switch (field) {
      case 'hotel_name': day.hotelName = value;
      case 'driving_hours': day.drivingHours = value;
      case 'theme': day.theme = value;
      case 'day_note': day.dayNote = value;
    }
    itineraryDays.refresh();
  }

  void addDayItem(int dayIndex, int blockIndex) {
    final block = itineraryDays[dayIndex].cityBlocks[blockIndex];
    block.items = [...block.items, ItineraryItem(time: '', title: '')];
    itineraryDays.refresh();
    _autoGenerateTitle();
  }

  void removeDayItem(int dayIndex, int blockIndex, int itemIndex) {
    final block = itineraryDays[dayIndex].cityBlocks[blockIndex];
    final removed = block.items[itemIndex];
    final newItems = List<ItineraryItem>.from(block.items)..removeAt(itemIndex);
    block.items = newItems;
    itineraryDays.refresh();

    // 如果该行程项来自推荐资源，释放其 key 使其可重新被选择
    final key = _itemResourceKey(removed);
    if (key != null) usedResourceKeys.remove(key);
    _autoGenerateTitle();
  }

  void updateDayItem(int dayIndex, int blockIndex, int itemIndex, String field, String value) {
    final items = itineraryDays[dayIndex].cityBlocks[blockIndex].items;
    switch (field) {
      case 'time': items[itemIndex].time = value;
      case 'title': items[itemIndex].title = value;
    }
    itineraryDays.refresh();
    if (field == 'title') _autoGenerateTitle();
  }

  // ====== 日期 & 时间选择 ======
  Future<void> pickDate(BuildContext context, TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.tryParse(ctrl.text) ?? now,
      firstDate: DateTime(2020), lastDate: DateTime(2035),
    );
    if (picked != null) {
      ctrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> pickTime(BuildContext context, TextEditingController ctrl) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      ctrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> pickItemTime(BuildContext context, int dayIndex, int blockIndex, int itemIndex) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      updateDayItem(dayIndex, blockIndex, itemIndex, 'time',
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  // ====== 显示城市选择器 ======
  void showCityPicker(BuildContext context) {
    final searchCtrl = TextEditingController();
    final filtered = <CityList>[].obs;
    filtered.value = List.from(cityList);
    searchCtrl.addListener(() {
      final kw = searchCtrl.text.toLowerCase();
      filtered.value = cityList.where((c) =>
        (c.name?.toLowerCase().contains(kw) ?? false) ||
        (c.nameEn?.toLowerCase().contains(kw) ?? false)
      ).toList();
    });

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
        ),
        child: Column(children: [
          SizedBox(height: 10.w),
          Container(width: 36.w, height: 4.w, decoration: BoxDecoration(
            color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.w))),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索城市',
                prefixIcon: Icon(Icons.search, size: 18.sp),
                filled: true, fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(vertical: 10.w),
              ),
            ),
          ),
          Expanded(child: Obx(() => ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final c = filtered[i];
              return ListTile(
                leading: CircleAvatar(radius: 16.w,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  child: Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.primary)),
                title: Text(c.name ?? '', style: TextStyle(fontSize: 14.sp)),
                subtitle: Text('${c.nameEn ?? ''}  ${cityCountry(c)}',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
                onTap: () {
                  addCity(c);
                  Get.back();
                },
              );
            },
          ))),
        ]),
      ),
      isScrollControlled: true,
    );
  }

  void showDayCityPicker(BuildContext context, int dayIndex) {
    final searchCtrl = TextEditingController();
    final filtered = <CityList>[].obs;
    filtered.value = List.from(cityList);
    searchCtrl.addListener(() {
      final kw = searchCtrl.text.toLowerCase();
      filtered.value = cityList.where((c) =>
        (c.name?.toLowerCase().contains(kw) ?? false) ||
        (c.nameEn?.toLowerCase().contains(kw) ?? false)
      ).toList();
    });

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
        ),
        child: Column(children: [
          SizedBox(height: 10.w),
          Container(width: 36.w, height: 4.w, decoration: BoxDecoration(
            color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.w))),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索城市',
                prefixIcon: Icon(Icons.search, size: 18.sp),
                filled: true, fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(vertical: 10.w),
              ),
            ),
          ),
          Expanded(child: Obx(() => ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final c = filtered[i];
              return ListTile(
                leading: CircleAvatar(radius: 16.w,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  child: Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.primary)),
                title: Text(c.name ?? '', style: TextStyle(fontSize: 14.sp)),
                subtitle: Text('${c.nameEn ?? ''}  ${cityCountry(c)}',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
                onTap: () {
                  addDayCity(dayIndex, c);
                  Get.back();
                },
              );
            },
          ))),
        ]),
      ),
      isScrollControlled: true,
    );
  }

  // ====== 来自推荐资源添加活动 ======
  void addResourceToDay(int dayIndex, int blockIndex, CityResource resource) {
    final item = ItineraryItem(
      time: '',
      title: resource.name ?? resource.label,
      type: resource.type,
      description: resource.name ?? resource.label,
      resourceId: resource.id,
      resourceType: resource.type,
      imageUrl: resource.imageUrl,
    );
    final block = itineraryDays[dayIndex].cityBlocks[blockIndex];
    block.items = [...block.items, item];
    itineraryDays.refresh();

    // 标记该推荐资源已使用（同一工作中不可重复添加）
    _markResourceUsed(resource);
    _autoGenerateTitle();
  }

  /// 构建资源的唯一 key
  String _resourceKey(CityResource r) => '${r.type}:${r.id ?? r.name}';

  /// 检查推荐资源是否已被本工作使用（外部可访问）
  bool isResourceUsed(CityResource r) => usedResourceKeys.contains(_resourceKey(r));

  /// 标记推荐资源已使用
  void _markResourceUsed(CityResource r) {
    usedResourceKeys.add(_resourceKey(r));
  }

  /// 从行程项中提取资源 key（用于还原草稿/移除时重新计算）
  String? _itemResourceKey(ItineraryItem item) {
    if (item.resourceType == null || item.resourceId == null) return null;
    return '${item.resourceType}:${item.resourceId}';
  }

  // ====== 草稿自动保存 & 恢复 ======

  /// 检查存储中是否有未完成的草稿
  void _checkExistingDraft() {
    final draftJson = StorageService.to.getString(STORAGE_JOURNEY_DRAFT_KEY);
    if (draftJson.isEmpty) return;
    try {
      final json = jsonDecode(draftJson) as Map<String, dynamic>;
      // 验证草稿中至少有一些内容
      final hasContent = (json['title'] as String?)?.isNotEmpty == true ||
          (json['startDate'] as String?)?.isNotEmpty == true ||
          (json['startCityName'] as String?)?.isNotEmpty == true;
      if (hasContent) {
        _hasDraft = true;
      } else {
        _clearDraft();
      }
    } catch (_) {
      _clearDraft();
    }
  }

  /// 启动定时自动保存（每 30 秒保存一次）
  void _startDraftAutoSave() {
    _draftSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _saveDraft());
  }

  /// 页面 build 后调用：弹出是否继续编辑的提示
  void checkDraftAndPrompt(BuildContext context) {
    if (!_hasDraft || _draftRestored) return;
    _hasDraft = false; // 只提示一次

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
        title: Row(children: [
          Icon(Icons.edit_note, size: 22.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text('发现未完成的行程', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
        ]),
        content: Text('上次编辑的行程还未完成，是否继续编辑？',
            style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () {
              _clearDraft();
              Get.back();
            },
            child: Text('重新开始', style: TextStyle(fontSize: 13.sp, color: AppColors.assistantText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
            ),
            onPressed: () {
              _loadDraft();
              _draftRestored = true;
              Get.back();
            },
            child: Text('继续编辑', style: TextStyle(fontSize: 13.sp, color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 将当前表单状态序列化为 JSON
  Map<String, dynamic> _toDraftJson() {
    return {
      'title': titleCtrl.text.trim(),
      'adultCount': adultCountCtrl.text.trim(),
      'childCount': childCountCtrl.text.trim(),
      'startDate': startDateCtrl.text.trim(),
      'endDate': endDateCtrl.text.trim(),
      'startCityId': startCity.value?.id,
      'startCityName': startCity.value?.name ?? '',
      'startCityCountry': startCity.value != null ? _safeCityCountry(startCity.value!) : '',
      'endCityId': endCity.value?.id,
      'endCityName': endCity.value?.name ?? '',
      'endCityCountry': endCity.value != null ? _safeCityCountry(endCity.value!) : '',
      'arrFlight': arrFlightCtrl.text.trim(),
      'arrDate': arrDateCtrl.text.trim(),
      'arrTime': arrTimeCtrl.text.trim(),
      'arrAirport': arrAirportCtrl.text.trim(),
      'depFlight': depFlightCtrl.text.trim(),
      'depDate': depDateCtrl.text.trim(),
      'depTime': depTimeCtrl.text.trim(),
      'depAirport': depAirportCtrl.text.trim(),
      'leaderName': leaderNameCtrl.text.trim(),
      'leaderPhone': leaderPhoneCtrl.text.trim(),
      'driverName': driverNameCtrl.text.trim(),
      'driverPhone': driverPhoneCtrl.text.trim(),
      'vehicle': vehicleCtrl.text.trim(),
      'totalPrice': totalPriceCtrl.text.trim(),
      'cashAdvance': cashAdvanceCtrl.text.trim(),
      'agencyContact': agencyContactCtrl.text.trim(),
      'agencyPhone': agencyPhoneCtrl.text.trim(),
      'emergencyPhone': emergencyPhoneCtrl.text.trim(),
      'description': descriptionCtrl.text.trim(),
      'showFlight': showFlight.value,
      'showItinerary': showItinerary.value,
      'showPeople': showPeople.value,
      'showCost': showCost.value,
      'showEmergency': showEmergency.value,
      'itineraryDays': itineraryDays.map((d) => d.toJson()).toList(),
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 安全获取城市国家名（忽略 _cityCountryMap 未加载的情况）
  String _safeCityCountry(CityList c) {
    try {
      return cityCountry(c);
    } catch (_) {
      return c.country ?? c.areaName ?? '';
    }
  }

  /// 检查当前表单是否有任何填写内容
  bool _hasContent() {
    return titleCtrl.text.trim().isNotEmpty ||
        startDateCtrl.text.trim().isNotEmpty ||
        endDateCtrl.text.trim().isNotEmpty ||
        startCity.value != null ||
        endCity.value != null ||
        adultCountCtrl.text.trim().isNotEmpty ||
        childCountCtrl.text.trim().isNotEmpty ||
        itineraryDays.any((d) => d.cityBlocks.any((b) => b.items.isNotEmpty || b.cityName?.isNotEmpty == true)) ||
        descriptionCtrl.text.trim().isNotEmpty ||
        arrFlightCtrl.text.trim().isNotEmpty ||
        depFlightCtrl.text.trim().isNotEmpty ||
        leaderNameCtrl.text.trim().isNotEmpty ||
        driverNameCtrl.text.trim().isNotEmpty;
  }

  /// 保存草稿到 SharedPreferences
  void _saveDraft() {
    if (!_hasContent()) return;
    final json = _toDraftJson();
    StorageService.to.setString(STORAGE_JOURNEY_DRAFT_KEY, jsonEncode(json));
  }

  /// 从 SharedPreferences 加载草稿并填充表单
  void _loadDraft() {
    final draftJson = StorageService.to.getString(STORAGE_JOURNEY_DRAFT_KEY);
    if (draftJson.isEmpty) return;
    try {
      final json = jsonDecode(draftJson) as Map<String, dynamic>;
      _restoreFromDraft(json);
    } catch (_) {}
  }

  void _restoreFromDraft(Map<String, dynamic> json) {
    _restoring = true;

    titleCtrl.text = json['title'] as String? ?? '';
    adultCountCtrl.text = json['adultCount'] as String? ?? '';
    childCountCtrl.text = json['childCount'] as String? ?? '';

    // 还原游览起始城市
    final sCityId = json['startCityId'] as int?;
    final sCityName = json['startCityName'] as String?;
    if (sCityId != null && sCityName != null && sCityName.isNotEmpty) {
      startCity.value = _findCity(sCityName) ??
          CityList(id: sCityId, name: sCityName, country: json['startCityCountry'] as String?);
    }

    // 还原游览结束城市
    final eCityId = json['endCityId'] as int?;
    final eCityName = json['endCityName'] as String?;
    if (eCityId != null && eCityName != null && eCityName.isNotEmpty) {
      endCity.value = _findCity(eCityName) ??
          CityList(id: eCityId, name: eCityName, country: json['endCityCountry'] as String?);
    }

    // 还原每日行程（必须在日期之前，避免 _syncDays 触发空覆盖）
    final daysList = json['itineraryDays'] as List<dynamic>?;
    if (daysList != null && daysList.isNotEmpty) {
      itineraryDays.value = daysList
          .map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
          .toList();
      if (itineraryDays.isNotEmpty) showItinerary.value = true;
    }

    // 日期放在行程之后设置（虽然有 _restoring 保护，保持逻辑正确）
    startDateCtrl.text = json['startDate'] as String? ?? '';
    endDateCtrl.text = json['endDate'] as String? ?? '';

    arrFlightCtrl.text = json['arrFlight'] as String? ?? '';
    arrDateCtrl.text = json['arrDate'] as String? ?? '';
    arrTimeCtrl.text = json['arrTime'] as String? ?? '';
    arrAirportCtrl.text = json['arrAirport'] as String? ?? '';
    depFlightCtrl.text = json['depFlight'] as String? ?? '';
    depDateCtrl.text = json['depDate'] as String? ?? '';
    depTimeCtrl.text = json['depTime'] as String? ?? '';
    depAirportCtrl.text = json['depAirport'] as String? ?? '';
    leaderNameCtrl.text = json['leaderName'] as String? ?? '';
    leaderPhoneCtrl.text = json['leaderPhone'] as String? ?? '';
    driverNameCtrl.text = json['driverName'] as String? ?? '';
    driverPhoneCtrl.text = json['driverPhone'] as String? ?? '';
    vehicleCtrl.text = json['vehicle'] as String? ?? '';
    totalPriceCtrl.text = json['totalPrice'] as String? ?? '';
    cashAdvanceCtrl.text = json['cashAdvance'] as String? ?? '';
    agencyContactCtrl.text = json['agencyContact'] as String? ?? '';
    agencyPhoneCtrl.text = json['agencyPhone'] as String? ?? '';
    emergencyPhoneCtrl.text = json['emergencyPhone'] as String? ?? '';
    descriptionCtrl.text = json['description'] as String? ?? '';

    showFlight.value = json['showFlight'] as bool? ?? false;
    showItinerary.value = json['showItinerary'] as bool? ?? false;
    showPeople.value = json['showPeople'] as bool? ?? false;
    showCost.value = json['showCost'] as bool? ?? false;
    showEmergency.value = json['showEmergency'] as bool? ?? false;

    _updateTotalPeople();
    // 同步天数
    final start = DateTime.tryParse(startDateCtrl.text.trim());
    final end = DateTime.tryParse(endDateCtrl.text.trim());
    if (start != null && end != null) {
      daysCount.value = end.difference(start).inDays + 1;
    }

    _restoring = false;

    // 恢复后为有城市块的每一天加载推荐资源
    _restoreDayRecommendations();
  }

  /// 为从草稿恢复的每天城市块加载推荐资源
  void _restoreDayRecommendations() {
    // 重建已使用资源集合（从恢复的行程项中提取）
    usedResourceKeys.clear();
    for (final day in itineraryDays) {
      for (final block in day.cityBlocks) {
        for (final item in block.items) {
          final key = _itemResourceKey(item);
          if (key != null) usedResourceKeys.add(key);
        }
      }
    }

    for (int di = 0; di < itineraryDays.length; di++) {
      final day = itineraryDays[di];
      final cityIds = <int>[];
      for (final block in day.cityBlocks) {
        if (block.cityId != null) cityIds.add(block.cityId!);
      }
      if (cityIds.isNotEmpty) {
        _loadDayRecommendations(di, cityIds);
      }
    }
  }

  /// 清除草稿
  void _clearDraft() {
    StorageService.to.remove(STORAGE_JOURNEY_DRAFT_KEY);
  }

  // ====== 提交 ======
  Future<void> onSubmit() async {
    if (titleCtrl.text.trim().isEmpty) { Loading.error('请输入团名'); return; }
    if (startDateCtrl.text.trim().isEmpty) { Loading.error('请选择出发日期'); return; }

    debugPrint('[JourneyEditor] onSubmit: isEdit=$isEdit, _workId=${_workId.value}');
    Loading.show();
    try {
      final payload = _buildSubmitPayload();
      ApiResult res;
      if (isEdit.value && _workId.value != null) {
        payload['id'] = _workId.value;
        debugPrint('[JourneyEditor] → PUT userJourneyUpdate id=${_workId.value}');
        res = await put(ApiUrl.userJourneyUpdate, data: payload);
      } else {
        debugPrint('[JourneyEditor] → POST userJourneyCreate (isEdit=$isEdit, id=${_workId.value})');
        res = await post(ApiUrl.userJourneyCreate, data: payload);
      }
      Loading.dismiss();

      if (res.isSuccess) {
        _submitted = true;
        _clearDraft();
        Loading.success(isEdit.value ? '修改成功' : '创建成功');
        Get.back(result: true);
      } else {
        debugPrint('[JourneyEditor] API error: code=${res.code}, message=${res.message}');
        debugPrint('[JourneyEditor] error: ${res.error}');
        Loading.error(res.message.isNotEmpty ? res.message : '保存失败，请重试');
      }
    } catch (e) {
      Loading.dismiss();
      if (e is DioException) {
        debugPrint('[JourneyEditor] DioException:');
        debugPrint('  type: ${e.type}');
        debugPrint('  statusCode: ${e.response?.statusCode}');
        debugPrint('  statusMessage: ${e.response?.statusMessage}');
        debugPrint('  data: ${e.response?.data}');
        debugPrint('  message: ${e.message}');
        debugPrint('  error: ${e.error}');
      } else {
        debugPrint('[JourneyEditor] exception: $e');
      }
      Loading.error('保存失败: $e');
    }
  }

  /// 删除工作（仅编辑模式可用）
  Future<void> onDeleteWork() async {
    if (!isEdit.value || _workId.value == null) return;

    final confirm = await AlertUtils.show(
      title: '确认删除',
      content: '删除后无法恢复，确定要删除这个工作吗？',
      confirmText: '删除',
      cancelText: '取消',
    );
    if (confirm != true) return;

    Loading.show();
    final res = await post(ApiUrl.userJourneyDelete, data: {'id': _workId.value});
    Loading.dismiss();
    if (res.isSuccess) {
      _clearDraft();
      Loading.success('删除成功');
      Get.back(result: true);
    } else {
      Loading.error(res.message.isNotEmpty ? res.message : '删除失败');
    }
  }

  /// 根据城市集合计算所属大洲/地区
  String? _computeRegion(Set<String> cityNames) {
    final seenContinents = <String>{};
    for (final cn in cityNames) {
      final c = cityList.firstWhereOrNull(
        (cl) => cl.name == cn || cl.nameEn == cn,
      );
      if (c != null) {
        final country = cityCountry(c);
        final continent = _countryContinentMap[country];
        if (continent != null && continent.isNotEmpty) {
          seenContinents.add(continent);
        }
      }
    }
    if (seenContinents.isEmpty) return null;
    if (seenContinents.length == 1) return seenContinents.first;
    // 多洲 → 用地区拼接
    final seenRegions = <String>{};
    for (final cn in cityNames) {
      final c = cityList.firstWhereOrNull(
        (cl) => cl.name == cn || cl.nameEn == cn,
      );
      if (c != null) {
        final country = cityCountry(c);
        final region = _countryRegionMap[country] ?? _countryContinentMap[country];
        if (region != null && region.isNotEmpty) seenRegions.add(region);
      }
    }
    return seenRegions.isNotEmpty ? seenRegions.join('·') : seenContinents.join('·');
  }

  /// 构建提交数据
  Map<String, dynamic> _buildSubmitPayload() {
    final peopleCount = totalPeople.value > 0 ? totalPeople.value : null;

    // 收集所有涉及的城市名（用于 cities 字段 & region 字段）
    final cityNames = <String>{};
    if (startCity.value?.name?.isNotEmpty == true) cityNames.add(startCity.value!.name!);
    if (endCity.value?.name?.isNotEmpty == true) cityNames.add(endCity.value!.name!);
    for (final day in itineraryDays) {
      for (final block in day.cityBlocks) {
        if (block.cityName?.isNotEmpty == true) cityNames.add(block.cityName!);
      }
    }

    return {
      'title': titleCtrl.text.trim(),
      'region': _computeRegion(cityNames),
      'cities': cityNames.toList(),
      'people_count': peopleCount,
      'adult_count': int.tryParse(adultCountCtrl.text.trim()),
      'child_count': int.tryParse(childCountCtrl.text.trim()),
      'start_date': startDateCtrl.text.trim(),
      'end_date': endDateCtrl.text.trim(),
      'departure_city': startCity.value?.name,
      'departure_city_country': startCity.value != null ? _safeCityCountry(startCity.value!) : null,
      'end_city': endCity.value?.name,
      'end_city_country': endCity.value != null ? _safeCityCountry(endCity.value!) : null,
      'description': descriptionCtrl.text.trim().isEmpty ? null : descriptionCtrl.text.trim(),
      'leader_name': leaderNameCtrl.text.trim().isEmpty ? null : leaderNameCtrl.text.trim(),
      'leader_phone': leaderPhoneCtrl.text.trim().isEmpty ? null : leaderPhoneCtrl.text.trim(),
      'driver_name': driverNameCtrl.text.trim().isEmpty ? null : driverNameCtrl.text.trim(),
      'driver_phone': driverPhoneCtrl.text.trim().isEmpty ? null : driverPhoneCtrl.text.trim(),
      'vehicle_info': vehicleCtrl.text.trim().isEmpty ? null : vehicleCtrl.text.trim(),
      'arrival_flight': _buildFlightJson(arrFlightCtrl, arrDateCtrl, arrTimeCtrl, arrAirportCtrl),
      'departure_flight': _buildFlightJson(depFlightCtrl, depDateCtrl, depTimeCtrl, depAirportCtrl),
      'itinerary_days': itineraryDays.map((d) => d.toJson()).toList(),
      'total_price': totalPriceCtrl.text.trim().isEmpty ? null : totalPriceCtrl.text.trim(),
      'cash_advance': cashAdvanceCtrl.text.trim().isEmpty ? null : cashAdvanceCtrl.text.trim(),
      'agency_contact': agencyContactCtrl.text.trim().isEmpty ? null : agencyContactCtrl.text.trim(),
      'agency_contact_phone': agencyPhoneCtrl.text.trim().isEmpty ? null : agencyPhoneCtrl.text.trim(),
      'emergency_phone': emergencyPhoneCtrl.text.trim().isEmpty ? null : emergencyPhoneCtrl.text.trim(),
      'source_type': isEdit.value ? 'manual' : (Get.arguments?['template'] != null ? 'template' : 'manual'),
    };
  }

  Map<String, dynamic>? _buildFlightJson(TextEditingController flight,
      TextEditingController date, TextEditingController time, TextEditingController airport) {
    final fn = flight.text.trim();
    final d = date.text.trim();
    final t = time.text.trim();
    final ap = airport.text.trim();
    if (fn.isEmpty && d.isEmpty && t.isEmpty && ap.isEmpty) return null;
    return {
      'flight_number': fn.isEmpty ? null : fn,
      'date_time': '${d.isEmpty ? '' : d} ${t.isEmpty ? '' : t}'.trim(),
      'airport': ap.isEmpty ? null : ap,
    };
  }

  /// 保存当前编辑内容为模板
  Future<void> onSaveAsTemplate() async {
    // 收集行程涉及的城市名
    final cityNames = <String>{};
    if (startCity.value?.name?.isNotEmpty == true) cityNames.add(startCity.value!.name!);
    if (endCity.value?.name?.isNotEmpty == true) cityNames.add(endCity.value!.name!);
    for (final day in itineraryDays) {
      for (final block in day.cityBlocks) {
        if (block.cityName?.isNotEmpty == true) cityNames.add(block.cityName!);
      }
    }

    // 收集酒店信息
    final hotels = <Map<String, dynamic>>[];
    for (final day in itineraryDays) {
      if (day.hotelName?.isNotEmpty == true) {
        hotels.add({'day': day.dayNumber, 'name': day.hotelName});
      }
    }

    final initialName = titleCtrl.text.trim().isNotEmpty
        ? titleCtrl.text.trim()
        : '${daysCount.value}日游';

    // 确保 dialog 在 GetX 上下文中展示
    TemplateSaveDialog.show(
      initialName,
      (name) async {
        final template = JourneyTemplate(
          title: name,
          region: _computeRegion(cityNames),
          cities: cityNames.toList(),
          defaultDays: daysCount.value > 0 ? daysCount.value : null,
          defaultPeopleCount: totalPeople.value > 0 ? totalPeople.value : null,
          itineraryDays: itineraryDays.map((d) => d.toJson()).toList(),
          hotels: hotels,
          useCount: 0,
          createdAt: DateTime.now().toIso8601String(),
        );

        // 保存到本地 SharedPreferences
        final storage = StorageService.to;
        final existingJson = storage.getString(STORAGE_JOURNEY_TEMPLATES_KEY);
        final List<dynamic> list =
            existingJson.isNotEmpty ? jsonDecode(existingJson) : [];
        list.add(template.toJson());
        await storage.setString(STORAGE_JOURNEY_TEMPLATES_KEY, jsonEncode(list));

        Loading.success('模板保存成功');
        Get.back(result: true);
      },
    );
  }

  CityList? _findCity(String name) {
    return cityList.firstWhereOrNull((c) => c.name == name);
  }

  void _loadWork(JourneyWork work) {
    debugPrint('[JourneyEditor] _loadWork: id=${work.id}, title=${work.title}');
    titleCtrl.text = work.title ?? '';
    adultCountCtrl.text = '${work.adultCount ?? work.peopleCount ?? 0}';
    childCountCtrl.text = '${work.childCount ?? 0}';
    _updateTotalPeople();
    startDateCtrl.text = work.startDate ?? '';
    endDateCtrl.text = work.endDate ?? '';

    // 还原旅程起止城市
    if (work.departureCity?.isNotEmpty == true) {
      startCity.value = _findCity(work.departureCity!) ??
          CityList(name: work.departureCity, country: work.departureCityCountry);
    }
    if (work.endCity?.isNotEmpty == true) {
      endCity.value = _findCity(work.endCity!) ??
          CityList(name: work.endCity, country: work.endCityCountry);
    }

    arrFlightCtrl.text = work.arrivalFlight?.flightNumber ?? '';
    arrDateCtrl.text = work.arrivalFlight?.dateTime?.split(' ').first ?? '';
    arrTimeCtrl.text = work.arrivalFlight?.dateTime?.split(' ').last ?? '';
    arrAirportCtrl.text = work.arrivalFlight?.airport ?? '';
    depFlightCtrl.text = work.departureFlight?.flightNumber ?? '';
    depDateCtrl.text = work.departureFlight?.dateTime?.split(' ').first ?? '';
    depTimeCtrl.text = work.departureFlight?.dateTime?.split(' ').last ?? '';
    depAirportCtrl.text = work.departureFlight?.airport ?? '';
    leaderNameCtrl.text = work.leaderName ?? '';
    leaderPhoneCtrl.text = work.leaderPhone ?? '';
    driverNameCtrl.text = work.driverName ?? '';
    driverPhoneCtrl.text = work.driverPhone ?? '';
    vehicleCtrl.text = work.vehicleInfo ?? '';
    totalPriceCtrl.text = work.totalPrice ?? '';
    cashAdvanceCtrl.text = work.cashAdvance ?? '';
    agencyContactCtrl.text = work.agencyContact ?? '';
    agencyPhoneCtrl.text = work.agencyContactPhone ?? '';
    emergencyPhoneCtrl.text = work.emergencyPhone ?? '';
    descriptionCtrl.text = work.description ?? '';
    if (work.itineraryDays.isNotEmpty) {
      itineraryDays.value = List.from(work.itineraryDays);
      showItinerary.value = true;
    }
    _syncDays();
  }

  /// 从模板加载数据到编辑器
  void loadFromTemplate(JourneyTemplate template) {
    titleCtrl.text = template.title;
    adultCountCtrl.text = '${template.defaultPeopleCount ?? 0}';
    childCountCtrl.text = '0';
    _updateTotalPeople();

    // 涉及城市
    cities.value = template.cities
        .map((name) => CityList(name: name))
        .toList();

    // 行程天数
    if (template.itineraryDays != null && template.itineraryDays!.isNotEmpty) {
      itineraryDays.value = template.itineraryDays!
          .map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
          .toList();
      showItinerary.value = true;
    }

    // 区域
    if (template.region?.isNotEmpty == true) {
      // region 信息存入备注作为参考
    }
  }

  @override
  void onClose() {
    _draftSaveTimer?.cancel();
    // 新建模式下如果有内容则保存草稿（编辑模式不保存草稿）
    // 已成功提交的不要重新保存草稿，否则下次打开又会提示继续编辑
    if (!isEdit.value && !_submitted && _hasContent()) {
      _saveDraft();
    }
    startDateCtrl.removeListener(_syncDays);
    endDateCtrl.removeListener(_syncDays);
    adultCountCtrl.removeListener(_updateTotalPeople);
    childCountCtrl.removeListener(_updateTotalPeople);
    super.onClose();
  }
}

/// 城市推荐资源
class CityResource {
  final String type;
  final String label;
  final IconData icon;
  final int cityId;
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? startTime;
  final String? endTime;
  CityResource({
    required this.type,
    required this.label,
    required this.icon,
    required this.cityId,
    this.id,
    this.name,
    this.imageUrl,
    this.startTime,
    this.endTime,
  });
}
