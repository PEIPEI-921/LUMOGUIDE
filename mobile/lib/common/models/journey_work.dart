import '../extensions/map.dart';
import 'journey_template.dart';

/// 工作行程状态
enum JourneyWorkStatus {
  inProgress(1, '进行中'),
  pending(2, '待出发'),
  ended(3, '已结束');

  const JourneyWorkStatus(this.value, this.label);
  final int value;
  final String label;

  static JourneyWorkStatus fromValue(int? v) {
    return JourneyWorkStatus.values.firstWhere(
      (e) => e.value == v,
      orElse: () => pending,
    );
  }
}

/// 创建来源
enum JourneySourceType {
  manual('manual', '手动创建'),
  template('template', '模板复用'),
  scan('scan', '扫描导入'),
  booking('booking', '预约同步');

  const JourneySourceType(this.value, this.label);
  final String value;
  final String label;
}

/// 航班信息
class FlightInfo {
  String? flightNumber;
  String? dateTime;
  String? airport;
  String? terminal;

  FlightInfo({this.flightNumber, this.dateTime, this.airport, this.terminal});

  factory FlightInfo.fromJson(Map<String, dynamic> json) => FlightInfo(
        flightNumber: json.safeString('flight_number'),
        dateTime: json.safeString('date_time'),
        airport: json.safeString('airport'),
        terminal: json.safeString('terminal'),
      );

  Map<String, dynamic> toJson() => {
        'flight_number': flightNumber,
        'date_time': dateTime,
        'airport': airport,
        'terminal': terminal,
      };
}

/// 酒店信息
class HotelInfo {
  String? name;
  String? address;
  String? phone;
  String? city;
  String? checkInDate;
  String? checkOutDate;

  HotelInfo({
    this.name,
    this.address,
    this.phone,
    this.city,
    this.checkInDate,
    this.checkOutDate,
  });

  factory HotelInfo.fromJson(Map<String, dynamic> json) => HotelInfo(
        name: json.safeString('name'),
        address: json.safeString('address'),
        phone: json.safeString('phone'),
        city: json.safeString('city'),
        checkInDate: json.safeString('check_in_date'),
        checkOutDate: json.safeString('check_out_date'),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
        'city': city,
        'check_in_date': checkInDate,
        'check_out_date': checkOutDate,
      };
}

/// 工作行程数据模型（完整版）
class JourneyWork {
  // ========== 基本信息 ==========
  int? id;
  String? title; // 团名/标题
  String? region; // 区域
  int? status; // 1=进行中, 2=待出发, 3=已结束
  int? peopleCount; // 总人数
  int? adultCount; // 成人
  int? childCount; // 儿童
  String? startDate;
  String? endDate;
  List<String> cities;
  String? description;

  // ========== 人员信息 ==========
  String? leaderName; // 领队
  String? leaderPhone;
  String? driverName; // 司机
  String? driverPhone;
  String? vehicleInfo; // 车型/车牌/座位数

  // ========== 航班信息 ==========
  FlightInfo? arrivalFlight;
  FlightInfo? departureFlight;

  // ========== 行程明细 ==========
  List<ItineraryDay> itineraryDays;

  // ========== 酒店列表 ==========
  List<HotelInfo> hotels;

  // ========== 起止城市（旅程地理起止点，非航班起降地）==========
  String? departureCity; // 旅程出发城市名
  String? departureCityCountry; // 出发城市所在国家
  String? endCity; // 旅程结束城市名
  String? endCityCountry; // 结束城市所在国家

  // ========== 费用信息 ==========
  String? totalPrice; // 团款总额
  String? cashAdvance; // 备用金
  String? ticketBudget; // 门票预算
  String? mealBudget; // 餐费预算

  // ========== 应急联系 ==========
  String? agencyContact; // 组团社联系人
  String? agencyContactPhone;
  String? localContact; // 地接社联系人
  String? localContactPhone;
  String? emergencyPhone; // 紧急电话

  // ========== 创建来源 ==========
  String? sourceType; // 'manual' | 'template' | 'scan' | 'booking'
  int? sourceTemplateId;
  int? sourceBookingId;
  String? sourceBookingType;
  bool isFromBooking;

  // ========== 关联资源 ==========
  List<int>? attractionIds;
  List<int>? activityIds;
  List<int>? merchantIds;

  // ========== 客户行程 ==========
  bool hasClientItinerary;
  String? clientItineraryShareCode;

  // ========== 元数据 ==========
  String? createdAt;
  String? updatedAt;

  // ========== 模板标识 ==========
  bool isTemplate; // 是否来自模板（直接显示在列表中）
  JourneyTemplate? templateSource; // 原始模板数据（点击时用于跳转编辑器）

  JourneyWorkStatus get statusEnum => JourneyWorkStatus.fromValue(status);

  /// 根据日期动态计算实际状态
  JourneyWorkStatus get effectiveStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime.tryParse(startDate ?? '');
    final end = DateTime.tryParse(endDate ?? '');
    if (start == null || end == null) return statusEnum;
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    if (!today.isBefore(s) && !today.isAfter(e)) {
      return JourneyWorkStatus.inProgress;
    }
    if (today.isBefore(s)) {
      return JourneyWorkStatus.pending;
    }
    return JourneyWorkStatus.ended;
  }

  int get effectiveStatusValue => effectiveStatus.value;

  /// 自动计算天数
  int get totalDays {
    final start = DateTime.tryParse(startDate ?? '');
    final end = DateTime.tryParse(endDate ?? '');
    if (start == null || end == null) return 0;
    return end.difference(start).inDays + 1;
  }

  JourneyWork({
    this.id,
    this.title,
    this.region,
    this.status,
    this.peopleCount,
    this.adultCount,
    this.childCount,
    this.startDate,
    this.endDate,
    this.cities = const [],
    this.description,
    this.departureCity,
    this.departureCityCountry,
    this.endCity,
    this.endCityCountry,
    this.leaderName,
    this.leaderPhone,
    this.driverName,
    this.driverPhone,
    this.vehicleInfo,
    this.arrivalFlight,
    this.departureFlight,
    this.itineraryDays = const [],
    this.hotels = const [],
    this.totalPrice,
    this.cashAdvance,
    this.ticketBudget,
    this.mealBudget,
    this.agencyContact,
    this.agencyContactPhone,
    this.localContact,
    this.localContactPhone,
    this.emergencyPhone,
    this.sourceType = 'manual',
    this.sourceTemplateId,
    this.sourceBookingId,
    this.sourceBookingType,
    this.isFromBooking = false,
    this.attractionIds,
    this.activityIds,
    this.merchantIds,
    this.hasClientItinerary = false,
    this.clientItineraryShareCode,
    this.createdAt,
    this.updatedAt,
    this.isTemplate = false,
    this.templateSource,
  });

  factory JourneyWork.fromJson(Map<String, dynamic> json) {
    return JourneyWork(
      // 基本信息
      id: json.safeInt('id'),
      title: json.safeString('title'),
      region: json.safeString('region'),
      status: json.safeInt('status'),
      peopleCount: json.safeInt('people_count'),
      adultCount: json.safeInt('adult_count'),
      childCount: json.safeInt('child_count'),
      startDate: json.safeString('start_date'),
      endDate: json.safeString('end_date'),
      cities: (json['cities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json.safeString('description'),
      // 起止城市
      departureCity: json.safeString('departure_city'),
      departureCityCountry: json.safeString('departure_city_country'),
      endCity: json.safeString('end_city'),
      endCityCountry: json.safeString('end_city_country'),
      // 人员
      leaderName: json.safeString('leader_name'),
      leaderPhone: json.safeString('leader_phone'),
      driverName: json.safeString('driver_name'),
      driverPhone: json.safeString('driver_phone'),
      vehicleInfo: json.safeString('vehicle_info'),
      // 航班
      arrivalFlight: json['arrival_flight'] != null
          ? FlightInfo.fromJson(json['arrival_flight'])
          : null,
      departureFlight: json['departure_flight'] != null
          ? FlightInfo.fromJson(json['departure_flight'])
          : null,
      // 日行程
      itineraryDays: (json['itinerary_days'] as List<dynamic>?)
              ?.map((e) => ItineraryDay.fromJson(e))
              .toList() ??
          [],
      // 酒店
      hotels: (json['hotels'] as List<dynamic>?)
              ?.map((e) => HotelInfo.fromJson(e))
              .toList() ??
          [],
      // 费用
      totalPrice: json.safeString('total_price'),
      cashAdvance: json.safeString('cash_advance'),
      ticketBudget: json.safeString('ticket_budget'),
      mealBudget: json.safeString('meal_budget'),
      // 应急
      agencyContact: json.safeString('agency_contact'),
      agencyContactPhone: json.safeString('agency_contact_phone'),
      localContact: json.safeString('local_contact'),
      localContactPhone: json.safeString('local_contact_phone'),
      emergencyPhone: json.safeString('emergency_phone'),
      // 来源
      sourceType: json.safeString('source_type') ?? 'manual',
      sourceTemplateId: json.safeInt('source_template_id'),
      sourceBookingId: json.safeInt('source_booking_id'),
      sourceBookingType: json.safeString('source_booking_type'),
      isFromBooking: json.safeBool('is_from_booking') ?? false,
      // 资源
      attractionIds: (json['attraction_ids'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      activityIds: (json['activity_ids'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      merchantIds: (json['merchant_ids'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      // 客户行程
      hasClientItinerary: json.safeBool('has_client_itinerary') ?? false,
      clientItineraryShareCode:
          json.safeString('client_itinerary_share_code'),
      // 元数据
      createdAt: json.safeString('created_at'),
      updatedAt: json.safeString('updated_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'region': region,
      'status': status,
      'people_count': peopleCount,
      'adult_count': adultCount,
      'child_count': childCount,
      'start_date': startDate,
      'end_date': endDate,
      'cities': cities,
      'description': description,
      'departure_city': departureCity,
      'departure_city_country': departureCityCountry,
      'end_city': endCity,
      'end_city_country': endCityCountry,
      'leader_name': leaderName,
      'leader_phone': leaderPhone,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_info': vehicleInfo,
      'arrival_flight': arrivalFlight?.toJson(),
      'departure_flight': departureFlight?.toJson(),
      'itinerary_days': itineraryDays.map((e) => e.toJson()).toList(),
      'hotels': hotels.map((e) => e.toJson()).toList(),
      'total_price': totalPrice,
      'cash_advance': cashAdvance,
      'ticket_budget': ticketBudget,
      'meal_budget': mealBudget,
      'agency_contact': agencyContact,
      'agency_contact_phone': agencyContactPhone,
      'local_contact': localContact,
      'local_contact_phone': localContactPhone,
      'emergency_phone': emergencyPhone,
      'source_type': sourceType,
      'source_template_id': sourceTemplateId,
      'source_booking_id': sourceBookingId,
      'source_booking_type': sourceBookingType,
      'is_from_booking': isFromBooking,
      'attraction_ids': attractionIds,
      'activity_ids': activityIds,
      'merchant_ids': merchantIds,
      'has_client_itinerary': hasClientItinerary,
      'client_itinerary_share_code': clientItineraryShareCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 创建一个精简副本（用于模板保存）
  JourneyWork toTemplate() {
    return JourneyWork(
      title: title,
      region: region,
      cities: List.from(cities),
      itineraryDays: itineraryDays.map((d) => d.toTemplate()).toList(),
      hotels: hotels.map((h) => HotelInfo(
            name: h.name, address: h.address, phone: h.phone, city: h.city,
          )).toList(),
      sourceType: 'template',
    );
  }

  /// 从模板创建展示用的 JourneyWork（显示在历程列表中）
  factory JourneyWork.fromTemplate(JourneyTemplate template) {
    // 将 dynamic 类型的 itineraryDays/hotels 转为强类型
    final days = (template.itineraryDays ?? [])
        .map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
        .toList();
    final hotels = (template.hotels ?? [])
        .map((e) => HotelInfo.fromJson(e as Map<String, dynamic>))
        .toList();

    return JourneyWork(
      title: template.title,
      region: template.region,
      peopleCount: template.defaultPeopleCount,
      cities: List.from(template.cities),
      itineraryDays: days,
      hotels: hotels,
      sourceType: 'template',
      createdAt: template.createdAt,
      isTemplate: true,
      templateSource: template,
    );
  }


  /// 已对接后端 API，不再提供 mock 数据
  static List<JourneyWork> mockData() => [];

}

// ============================================================
// ItineraryDay / ItineraryItem — 下面新建独立文件后删掉此处
// ============================================================

/// 行程项目类型
enum ItineraryItemType {
  attraction('attraction'),
  activity('activity'),
  meal('meal'),
  transport('transport'),
  hotel('hotel'),
  free('free'),
  other('other');

  const ItineraryItemType(this.value);
  final String value;

  static ItineraryItemType fromValue(String? v) {
    return ItineraryItemType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => other,
    );
  }
}

/// 单个行程项目
class ItineraryItem {
  String? time;
  String? title;
  String? type; // attraction / activity / meal / transport / free / other
  String? description;
  String? imageUrl;
  int? resourceId;
  String? resourceType;
  String? duration;
  String? note;

  ItineraryItem({
    this.time,
    this.title,
    this.type,
    this.description,
    this.imageUrl,
    this.resourceId,
    this.resourceType,
    this.duration,
    this.note,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) => ItineraryItem(
        time: json.safeString('time'),
        title: json.safeString('title'),
        type: json.safeString('type'),
        description: json.safeString('description'),
        imageUrl: json.safeString('image_url'),
        resourceId: json.safeInt('resource_id'),
        resourceType: json.safeString('resource_type'),
        duration: json.safeString('duration'),
        note: json.safeString('note'),
      );

  Map<String, dynamic> toJson() => {
        'time': time,
        'title': title,
        'type': type,
        'description': description,
        'image_url': imageUrl,
        'resource_id': resourceId,
        'resource_type': resourceType,
        'duration': duration,
        'note': note,
      };

  /// 创建模板副本（清除日期相关）
  ItineraryItem toTemplate() => ItineraryItem(
        time: time,
        title: title,
        type: type,
        description: description,
        resourceId: resourceId,
        resourceType: resourceType,
        duration: duration,
      );
}

/// 每日行程中的单个城市块（独立城市 + 其下的活动列表）
class DayCityBlock {
  int? cityId;
  String? cityName;
  List<ItineraryItem> items;

  DayCityBlock({
    this.cityId,
    this.cityName,
    this.items = const [],
  });

  factory DayCityBlock.fromJson(Map<String, dynamic> json) => DayCityBlock(
        cityId: json.safeInt('city_id'),
        cityName: json.safeString('city_name'),
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => ItineraryItem.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'city_id': cityId,
        'city_name': cityName,
        'items': items.map((e) => e.toJson()).toList(),
      };

  DayCityBlock toTemplate() => DayCityBlock(
        cityId: cityId,
        cityName: cityName,
        items: items.map((i) => i.toTemplate()).toList(),
      );
}

/// 行程中的一天
class ItineraryDay {
  int? id;
  int dayNumber;
  String? date;
  String? theme;
  List<DayCityBlock> cityBlocks; // 每个城市一个独立块
  String? hotelName;
  String? hotelAddress;
  String? hotelPhone;
  String? meals;
  String? weatherTip;
  String? transportTip;
  String? drivingHours;
  String? optionalItems;
  String? dayNote;

  ItineraryDay({
    this.id,
    required this.dayNumber,
    this.date,
    this.theme,
    this.cityBlocks = const [],
    this.hotelName,
    this.hotelAddress,
    this.hotelPhone,
    this.meals,
    this.weatherTip,
    this.transportTip,
    this.drivingHours,
    this.optionalItems,
    this.dayNote,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    List<DayCityBlock> blocks;

    // 优先解析新版 city_blocks
    if (json['city_blocks'] != null) {
      blocks = (json['city_blocks'] as List<dynamic>)
          .map((e) => DayCityBlock.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // 兼容旧版数据：从 city_ids / city_names / items 迁移
      final List<int> oldCityIds;
      final dynamic rawCityIds = json['city_ids'] ?? json['city_id'];
      if (rawCityIds is List) {
        oldCityIds = rawCityIds.map<int>((e) => e as int).toList();
      } else if (rawCityIds is int) {
        oldCityIds = [rawCityIds];
      } else {
        oldCityIds = [];
      }

      final List<String> oldCityNames;
      final dynamic rawCityNames = json['city_names'] ?? json['city_name'];
      if (rawCityNames is List) {
        oldCityNames = rawCityNames.map<String>((e) => e.toString()).toList();
      } else if (rawCityNames is String && rawCityNames.isNotEmpty) {
        oldCityNames = [rawCityNames];
      } else {
        oldCityNames = [];
      }
      final oldItems = (json['items'] as List<dynamic>?)
              ?.map((e) => ItineraryItem.fromJson(e))
              .toList() ??
          [];

      // 迁移：每个旧城市建一个 block，items 归入第一个有城市的 block
      if (oldCityNames.isNotEmpty) {
        blocks = List.generate(oldCityNames.length, (i) => DayCityBlock(
          cityId: i < oldCityIds.length ? oldCityIds[i] : null,
          cityName: oldCityNames[i],
          items: i == 0 ? oldItems : [],
        ));
      } else if (oldItems.isNotEmpty) {
        blocks = [DayCityBlock(items: oldItems)];
      } else {
        blocks = [];
      }
    }

    return ItineraryDay(
      id: json.safeInt('id'),
      dayNumber: json.safeInt('day_number') ?? 1,
      date: json.safeString('date'),
      theme: json.safeString('theme'),
      cityBlocks: blocks,
      hotelName: json.safeString('hotel_name'),
      hotelAddress: json.safeString('hotel_address'),
      hotelPhone: json.safeString('hotel_phone'),
      meals: json.safeString('meals'),
      weatherTip: json.safeString('weather_tip'),
      transportTip: json.safeString('transport_tip'),
      drivingHours: json.safeString('driving_hours'),
      optionalItems: json.safeString('optional_items'),
      dayNote: json.safeString('day_note'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day_number': dayNumber,
        'date': date,
        'theme': theme,
        'city_blocks': cityBlocks.map((e) => e.toJson()).toList(),
        'hotel_name': hotelName,
        'hotel_address': hotelAddress,
        'hotel_phone': hotelPhone,
        'meals': meals,
        'weather_tip': weatherTip,
        'transport_tip': transportTip,
        'driving_hours': drivingHours,
        'optional_items': optionalItems,
        'day_note': dayNote,
      };

  /// 模板副本（清除具体日期）
  ItineraryDay toTemplate() => ItineraryDay(
        dayNumber: dayNumber,
        theme: theme,
        cityBlocks: cityBlocks.map((b) => b.toTemplate()).toList(),
        hotelName: hotelName,
        hotelAddress: hotelAddress,
        hotelPhone: hotelPhone,
        drivingHours: drivingHours,
      );

  /// 便捷获取所有城市名
  List<String> get allCityNames =>
      cityBlocks.map((b) => b.cityName ?? '').where((n) => n.isNotEmpty).toList();
}
