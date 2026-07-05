import '../extensions/map.dart';

class MerchantList {
  MerchantList({
    this.id,
    this.name,
    this.firstPicture,
    this.phone,
    this.cityName,
    this.startTime,
    this.endTime,
    this.ticketsFree,
    this.evaluateCount,
    this.address,
    this.typeId,
    this.cityId,
  });

  int? id;
  String? name;
  String? firstPicture;
  String? phone;
  String? cityName;

  /// 开放时间
  String? startTime;
  String? endTime;

  /// 门票
  String? ticketsFree;

  /// 评价数量
  int? evaluateCount;

  String? address;

  /// 类型id
  int? typeId;

  /// 城市id
  int? cityId;

  factory MerchantList.fromJson(Map<String, dynamic> json) => MerchantList(
        id: json.safeInt('id'),
        name: json.safeString('name'),
        firstPicture: json.safeString('first_picture'),
        phone: json.safeString('phone'),
        cityName: json.safeString('city_name'),
        startTime: json.safeString('start_time'),
        endTime: json.safeString('end_time'),
        ticketsFree: json.safeString('tickets_free'),
        evaluateCount: json.safeInt('evaluate_count'),
        address: json.safeString('address'),
        typeId: json.safeInt('type_id'),
        cityId: json.safeInt('city_id'),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "first_picture": firstPicture,
        "phone": phone,
        "city_name": cityName,
        "start_time": startTime,
        "end_time": endTime,
        "tickets_free": ticketsFree,
        "evaluate_count": evaluateCount,
        "address": address,
        "type_id": typeId,
        "city_id": cityId,
      };
}
