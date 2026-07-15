import '../extensions/map.dart';

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

  /// TODO: 对接后端 API 后移除 mock 数据
  static List<JourneyWork> mockData() {
    return [
      JourneyWork(
        id: 1,
        title: '巴黎浪漫摄影之旅',
        region: '欧洲',
        status: 1,
        peopleCount: 3,
        adultCount: 3,
        startDate: '2026-07-03',
        endDate: '2026-07-09',
        cities: ['巴黎', '里昂', '尼斯'],
        leaderName: '张领队',
        leaderPhone: '+86 13800001111',
        driverName: 'Pierre',
        driverPhone: '+33 612345678',
        vehicleInfo: '奔驰 9座',
        description: '带客户前往巴黎拍摄婚纱照，随后前往里昂和尼斯取景。',
        sourceType: 'booking',
        isFromBooking: true,
        createdAt: '2026-07-01',
        totalPrice: '€8,500',
      ),
      JourneyWork(
        id: 2,
        title: '东京动漫展会',
        region: '亚洲',
        status: 2,
        peopleCount: 5,
        adultCount: 5,
        startDate: '2026-08-15',
        endDate: '2026-08-25',
        cities: ['东京', '大阪'],
        leaderName: '李领队',
        leaderPhone: '+86 13900002222',
        description: '参加东京动漫展，带领团队进行商务交流。',
        sourceType: 'manual',
        createdAt: '2026-07-03',
      ),
      JourneyWork(
        id: 3,
        title: '罗马历史遗迹考察',
        region: '欧洲',
        status: 3,
        peopleCount: 2,
        adultCount: 2,
        startDate: '2026-06-01',
        endDate: '2026-06-10',
        cities: ['罗马', '佛罗伦萨'],
        leaderName: '王领队',
        leaderPhone: '+86 13700003333',
        driverName: 'Marco',
        driverPhone: '+39 333444555',
        vehicleInfo: '菲亚特 7座',
        sourceType: 'booking',
        isFromBooking: true,
        createdAt: '2026-05-20',
        totalPrice: '€6,200',
      ),
      JourneyWork(
        id: 4,
        title: '萨尔茨堡音乐之旅',
        region: '欧洲',
        status: 2,
        peopleCount: 12,
        adultCount: 10,
        childCount: 2,
        startDate: '2026-09-05',
        endDate: '2026-09-08',
        cities: ['萨尔茨堡', '哈尔施塔特', '圣沃尔夫冈'],
        sourceType: 'manual',
        createdAt: '2026-07-05',
        arrivalFlight: FlightInfo(
          flightNumber: 'CA841',
          dateTime: '2026-09-05 06:30',
          airport: '慕尼黑机场',
          terminal: 'T2',
        ),
        itineraryDays: [
          ItineraryDay(
            dayNumber: 1,
            date: '2026-09-05',
            theme: '抵达萨尔茨堡',
            items: [
              ItineraryItem(
                time: '06:30',
                title: '抵达慕尼黑机场',
                type: 'transport',
                description: 'CA841 航班抵达，导游机场接机',
              ),
              ItineraryItem(
                time: '10:00',
                title: '萨尔茨堡老城观光',
                type: 'attraction',
                description: '米拉贝尔花园、莫扎特故居、粮食胡同',
              ),
              ItineraryItem(
                time: '12:30',
                title: 'StPeter Stiftskulinarium',
                type: 'meal',
                description: '欧洲最古老餐厅，午餐',
              ),
            ],
            hotelName: 'Hotel Sacher Salzburg',
          ),
          ItineraryDay(
            dayNumber: 2,
            date: '2026-09-06',
            theme: '湖区一日游',
            items: [
              ItineraryItem(
                time: '08:00',
                title: '哈尔施塔特',
                type: 'attraction',
                description: '世界最美小镇，盐矿缆车',
              ),
              ItineraryItem(
                time: '14:00',
                title: '圣沃尔夫冈',
                type: 'attraction',
                description: '白马酒店、夏夫山小火车',
              ),
            ],
            hotelName: 'Hotel Sacher Salzburg',
          ),
        ],
      ),
    ];
  }
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

/// 行程中的一天
class ItineraryDay {
  int? id;
  int dayNumber;
  String? date;
  String? theme;
  int? cityId;        // 当天城市ID（站内）
  String? cityName;   // 当天城市名
  List<ItineraryItem> items;
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
    this.cityId,
    this.cityName,
    this.items = const [],
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

  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
        id: json.safeInt('id'),
        dayNumber: json.safeInt('day_number') ?? 1,
        date: json.safeString('date'),
        theme: json.safeString('theme'),
        cityId: json.safeInt('city_id'),
        cityName: json.safeString('city_name'),
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => ItineraryItem.fromJson(e))
                .toList() ??
            [],
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'day_number': dayNumber,
        'date': date,
        'theme': theme,
        'city_id': cityId,
        'city_name': cityName,
        'items': items.map((e) => e.toJson()).toList(),
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
        items: items.map((i) => i.toTemplate()).toList(),
        hotelName: hotelName,
        hotelAddress: hotelAddress,
        hotelPhone: hotelPhone,
        drivingHours: drivingHours,
      );
}
