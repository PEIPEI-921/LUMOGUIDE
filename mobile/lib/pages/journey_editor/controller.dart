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
    }
    startDateCtrl.addListener(_syncDays);
    endDateCtrl.addListener(_syncDays);
  }

  Future<void> _loadCityList() async {
    try {
      final res = await get(ApiUrl.cityList, parameters: {'limit': 1000, 'page': 1});
      if (res.isSuccess) {
        final data = res.dataJson['list'] as List<dynamic>? ?? [];
        cityList.value = data.map((e) => CityList.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  int get totalPeople {
    final a = int.tryParse(adultCountCtrl.text) ?? 0;
    final c = int.tryParse(childCountCtrl.text) ?? 0;
    return a + c;
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

  /// 加载某天城市的推荐资源
  Future<void> _loadDayRecommendations(int dayIndex, int cityId) async {
    // TODO: 对接后端 API
    final items = <CityResource>[];
    // Mock: 用站内城市名匹配资源
    final city = cityList.firstWhereOrNull((c) => c.id == cityId);
    if (city != null) {
      items.addAll([
        CityResource(type: 'attraction', label: '景点', icon: Icons.landscape_outlined, cityId: cityId),
        CityResource(type: 'activity', label: '活动', icon: Icons.festival_outlined, cityId: cityId),
        CityResource(type: 'merchant', label: '餐厅', icon: Icons.restaurant_outlined, cityId: cityId),
        CityResource(type: 'shopping', label: '购物', icon: Icons.shopping_bag_outlined, cityId: cityId),
      ]);
    }
    cityRecommendations[dayIndex] = items.obs;
  }

  Future<void> _loadDayResourcesFromApi(int cityId) async {
    // TODO: GET /city/{cityId}/resources
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
                subtitle: Text('${c.nameEn ?? ''}  ${c.areaName ?? ''}',
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
                subtitle: Text('${c.nameEn ?? ''}  ${c.areaName ?? ''}',
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
      title: resource.label,
      type: resource.type,
      description: '来自${resource.label}推荐',
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

  void _loadWork(JourneyWork work) {
    titleCtrl.text = work.title ?? '';
    adultCountCtrl.text = '${work.adultCount ?? work.peopleCount ?? 0}';
    childCountCtrl.text = '${work.childCount ?? 0}';
    startDateCtrl.text = work.startDate ?? '';
    endDateCtrl.text = work.endDate ?? '';
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

  @override
  void onClose() {
    startDateCtrl.removeListener(_syncDays);
    endDateCtrl.removeListener(_syncDays);
    super.onClose();
  }
}

/// 城市推荐资源
class CityResource {
  final String type;
  final String label;
  final IconData icon;
  final int cityId;
  CityResource({required this.type, required this.label, required this.icon, required this.cityId});
}
