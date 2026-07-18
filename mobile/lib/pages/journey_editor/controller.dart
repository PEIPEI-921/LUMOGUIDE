import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

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

  /// 总人数（响应式）
  final totalPeople = 0.obs;

  /// 城市ID → 国家名称映射（从 systemContinents 接口加载）
  final _cityCountryMap = <int, String>{};

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
        _walkTree(item, null);
      }
      debugPrint('[systemContinents] map size=${_cityCountryMap.length}');
      // 打印前5条映射用于验证
      final entries = _cityCountryMap.entries.take(5).toList();
      for (final e in entries) {
        debugPrint('[systemContinents] cityId=${e.key} → ${e.value}');
      }
    } catch (e) {
      debugPrint('[systemContinents] error=$e');
    }
  }

  /// 递归遍历层级树，叶子节点=城市，其父节点名称=国家
  void _walkTree(dynamic node, String? parentName) {
    if (node is! Map<String, dynamic>) return;
    final name = node['name'] as String?;
    final nodeId = node['id'] as int?;
    final children = node['children'] as List<dynamic>?;

    if (children != null && children.isNotEmpty) {
      // 非叶子节点：当前 name 作为 parentName 传给子节点
      for (final child in children) {
        _walkTree(child, name);
      }
    } else if (parentName != null && nodeId != null) {
      // 叶子节点：parentName 即为国家
      _cityCountryMap[nodeId] = parentName;
      // 同时通过名称匹配 cityList 建立映射（兜底 ID 不一致的情况）
      if (name != null && name.isNotEmpty) {
        final match = cityList.firstWhereOrNull(
          (c) => c.id == nodeId || c.name == name || c.nameEn == name,
        );
        if (match != null && match.id != null) {
          _cityCountryMap[match.id!] = parentName;
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

  /// 为某天设置城市
  void setDayCity(int dayIndex, CityList city) {
    final day = itineraryDays[dayIndex];
    day.cityId = city.id;
    day.cityName = city.name;
    itineraryDays.refresh();
    _loadDayRecommendations(dayIndex, city.id!);
  }

  /// 加载某天城市的推荐资源（调用真实 API）
  Future<void> _loadDayRecommendations(int dayIndex, int cityId) async {
    final items = <CityResource>[];

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
      // 网络异常等，走兜底
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

    cityRecommendations[dayIndex] = items.obs;
  }

  // ====== 日行程管理 ======
  void _syncDays() {
    final start = DateTime.tryParse(startDateCtrl.text.trim());
    final end = DateTime.tryParse(endDateCtrl.text.trim());
    if (start == null || end == null) return;
    final days = end.difference(start).inDays + 1;
    if (days <= 0 || days > 90) return;
    if (itineraryDays.isNotEmpty && itineraryDays.length == days &&
        itineraryDays.any((d) => d.items.isNotEmpty)) return;

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
  void _autoGenerateTitle() {
    // 仅新建模式自动填充（编辑模式保留原标题）
    if (isEdit.value) return;

    final start = DateTime.tryParse(startDateCtrl.text.trim());
    final end = DateTime.tryParse(endDateCtrl.text.trim());
    if (start == null || end == null) return;
    final days = end.difference(start).inDays + 1;
    if (days <= 0) return;

    // 获取城市所属国家名（优先 city.country → systemContinents 映射 → 城市名）
    String countryOfName(String cityName) {
      // 在 cityList 中查找匹配的城市
      final c = cityList.firstWhereOrNull(
        (cl) => cl.name == cityName || cl.nameEn == cityName,
      );
      if (c != null) {
        return cityCountry(c);
      }
      return cityName; // 查不到就用城市名
    }

    // 收集所有行程涉及的城市名（去重保序）
    final seen = <String>{};
    final allCityNames = <String>[];
    void addCity(String? name) {
      if (name != null && name.isNotEmpty && seen.add(name)) {
        allCityNames.add(name);
      }
    }

    // 起始/结束城市
    addCity(startCity.value?.name);
    addCity(endCity.value?.name);

    // 每日行程中选的城市
    for (final day in itineraryDays) {
      addCity(day.cityName);
    }

    if (allCityNames.isEmpty) {
      titleCtrl.text = '$days日游';
      return;
    }

    // 城市名 → 国家名 → 去重保序
    final seenCountries = <String>{};
    final countries = <String>[];
    for (final cn in allCityNames) {
      final country = countryOfName(cn);
      if (country.isNotEmpty && seenCountries.add(country)) {
        countries.add(country);
      }
    }

    String title;
    if (countries.isEmpty) {
      // 无国家信息，用城市名拼接
      title = '${allCityNames.join('')}$days日游';
    } else {
      title = '${countries.join('')}$days日游';
    }
    titleCtrl.text = title;
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

  void addDayItem(int dayIndex) {
    final day = itineraryDays[dayIndex];
    day.items = [...day.items, ItineraryItem(time: '', title: '')];
    itineraryDays.refresh();
  }

  void removeDayItem(int dayIndex, int itemIndex) {
    final day = itineraryDays[dayIndex];
    final newItems = List<ItineraryItem>.from(day.items)..removeAt(itemIndex);
    day.items = newItems;
    itineraryDays.refresh();
  }

  void updateDayItem(int dayIndex, int itemIndex, String field, String value) {
    final items = itineraryDays[dayIndex].items;
    switch (field) {
      case 'time': items[itemIndex].time = value;
      case 'title': items[itemIndex].title = value;
    }
    itineraryDays.refresh();
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

  Future<void> pickItemTime(BuildContext context, int dayIndex, int itemIndex) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      updateDayItem(dayIndex, itemIndex, 'time',
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
                  setDayCity(dayIndex, c);
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
  void addResourceToDay(int dayIndex, CityResource resource) {
    final item = ItineraryItem(
      time: '',
      title: resource.name ?? resource.label,
      type: resource.type,
      description: resource.name ?? resource.label,
      resourceId: resource.id,
      resourceType: resource.type,
      imageUrl: resource.imageUrl,
    );
    final day = itineraryDays[dayIndex];
    day.items = [...day.items, item];
    itineraryDays.refresh();
  }

  // ====== 提交 ======
  Future<void> onSubmit() async {
    if (titleCtrl.text.trim().isEmpty) { Loading.error('请输入团名'); return; }
    if (startDateCtrl.text.trim().isEmpty) { Loading.error('请选择出发日期'); return; }
    Loading.success(isEdit.value ? '修改成功' : '创建成功');
    Get.back(result: true);
  }

  Future<void> onSaveAsTemplate() async {
    Loading.success('已保存为模板');
    Get.back(result: true);
  }

  CityList? _findCity(String name) {
    return cityList.firstWhereOrNull((c) => c.name == name);
  }

  void _loadWork(JourneyWork work) {
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
