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

/// 工作行程数据模型
class JourneyWork {
  int? id;
  String? title;
  String? region;
  int? status; // 1=进行中, 2=待出发, 3=已结束
  int? peopleCount;
  String? startDate;
  String? endDate;
  List<String> cities;
  String? departureCity;
  String? arrivalMethod;
  String? arrivalTime;
  String? arrivalLocation;
  String? endCity;
  String? departureMethod;
  String? description;
  String? createdAt;
  bool isFromBooking; // 是否来自预约同步

  JourneyWorkStatus get statusEnum => JourneyWorkStatus.fromValue(status);

  /// 根据日期动态计算实际状态（当天为基准）
  /// 进行中：startDate <= today <= endDate
  /// 待出发：startDate > today
  /// 已结束：endDate < today
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

  JourneyWork({
    this.id,
    this.title,
    this.region,
    this.status,
    this.peopleCount,
    this.startDate,
    this.endDate,
    this.cities = const [],
    this.departureCity,
    this.arrivalMethod,
    this.arrivalTime,
    this.arrivalLocation,
    this.endCity,
    this.departureMethod,
    this.description,
    this.createdAt,
    this.isFromBooking = false,
  });

  factory JourneyWork.fromJson(Map<String, dynamic> json) {
    return JourneyWork(
      id: json.safeInt('id'),
      title: json.safeString('title'),
      region: json.safeString('region'),
      status: json.safeInt('status'),
      peopleCount: json.safeInt('people_count'),
      startDate: json.safeString('start_date'),
      endDate: json.safeString('end_date'),
      cities: (json['cities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      departureCity: json.safeString('departure_city'),
      arrivalMethod: json.safeString('arrival_method'),
      arrivalTime: json.safeString('arrival_time'),
      arrivalLocation: json.safeString('arrival_location'),
      endCity: json.safeString('end_city'),
      departureMethod: json.safeString('departure_method'),
      description: json.safeString('description'),
      createdAt: json.safeString('created_at'),
      isFromBooking: json.safeBool('is_from_booking') ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'region': region,
      'status': status,
      'people_count': peopleCount,
      'start_date': startDate,
      'end_date': endDate,
      'cities': cities,
      'departure_city': departureCity,
      'arrival_method': arrivalMethod,
      'arrival_time': arrivalTime,
      'arrival_location': arrivalLocation,
      'end_city': endCity,
      'departure_method': departureMethod,
      'description': description,
      'created_at': createdAt,
      'is_from_booking': isFromBooking,
    };
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
        startDate: '2026-07-03',
        endDate: '2026-07-09',
        cities: ['巴黎', '里昂', '尼斯'],
        departureCity: '北京',
        arrivalMethod: '飞机',
        arrivalTime: '2026-07-03 08:00',
        arrivalLocation: '戴高乐机场',
        endCity: '尼斯',
        departureMethod: '飞机',
        description: '带客户前往巴黎拍摄婚纱照，随后前往里昂和尼斯取景。',
        createdAt: '2026-07-01',
        isFromBooking: true,
      ),
      JourneyWork(
        id: 2,
        title: '东京动漫展会',
        region: '亚洲',
        status: 2,
        peopleCount: 5,
        startDate: '2026-08-15',
        endDate: '2026-08-25',
        cities: ['东京', '大阪'],
        departureCity: '上海',
        arrivalMethod: '飞机',
        arrivalTime: '2026-08-15 14:00',
        arrivalLocation: '成田机场',
        endCity: '大阪',
        departureMethod: '新干线',
        description: '参加东京动漫展，带领团队进行商务交流。',
        createdAt: '2026-07-03',
        isFromBooking: false,
      ),
      JourneyWork(
        id: 3,
        title: '罗马历史遗迹考察',
        region: '欧洲',
        status: 3,
        peopleCount: 2,
        startDate: '2026-06-01',
        endDate: '2026-06-10',
        cities: ['罗马', '佛罗伦萨'],
        departureCity: '广州',
        arrivalMethod: '飞机',
        arrivalTime: '2026-06-01 10:00',
        arrivalLocation: '菲乌米奇诺机场',
        endCity: '罗马',
        departureMethod: '飞机',
        description: '历史遗迹考察工作，已完成。',
        createdAt: '2026-05-20',
        isFromBooking: true,
      ),
      JourneyWork(
        id: 4,
        title: '纽约时尚周拍摄',
        region: '北美',
        status: 2,
        peopleCount: 4,
        startDate: '2026-09-05',
        endDate: '2026-09-15',
        cities: ['纽约', '洛杉矶'],
        departureCity: '香港',
        arrivalMethod: '飞机',
        arrivalTime: '2026-09-05 06:00',
        arrivalLocation: '肯尼迪机场',
        endCity: '洛杉矶',
        departureMethod: '飞机',
        description: '参加纽约时装周，进行街拍和品牌合作。',
        createdAt: '2026-07-05',
        isFromBooking: false,
      ),
    ];
  }
}
