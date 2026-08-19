import '../extensions/map.dart';

/// 可复用的行程模板
class JourneyTemplate {
  int? id;
  String title;
  String? region;
  List<String> cities;
  int? defaultDays;
  int? defaultPeopleCount;
  List<dynamic>? itineraryDays; // 使用 dynamic 避免循环引用 journey_work 中的 ItineraryDay
  List<dynamic>? hotels;
  int useCount;
  int? sourceWorkId;
  String? createdAt;
  String? updatedAt;

  JourneyTemplate({
    this.id,
    required this.title,
    this.region,
    this.cities = const [],
    this.defaultDays,
    this.defaultPeopleCount,
    this.itineraryDays,
    this.hotels,
    this.useCount = 0,
    this.sourceWorkId,
    this.createdAt,
    this.updatedAt,
  });

  factory JourneyTemplate.fromJson(Map<String, dynamic> json) =>
      JourneyTemplate(
        id: json.safeInt('id'),
        title: json.safeString('title') ?? '',
        region: json.safeString('region'),
        cities: (json['cities'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        defaultDays: json.safeInt('default_days'),
        defaultPeopleCount: json.safeInt('default_people_count'),
        itineraryDays: json['itinerary_days'] as List<dynamic>?,
        hotels: json['hotels'] as List<dynamic>?,
        useCount: json.safeInt('use_count') ?? 0,
        sourceWorkId: json.safeInt('source_work_id'),
        createdAt: json.safeString('created_at'),
        updatedAt: json.safeString('updated_at'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'region': region,
        'cities': cities,
        'default_days': defaultDays,
        'default_people_count': defaultPeopleCount,
        'itinerary_days': itineraryDays,
        'hotels': hotels,
        'use_count': useCount,
        'source_work_id': sourceWorkId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
