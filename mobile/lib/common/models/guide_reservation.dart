import 'index.dart';
import '../extensions/map.dart';

class GuideReservation {
  UserInfo? user;

  int? id;

  /// 预计时间
  String? arrivalTime;

  /// 人数
  String? number;

  /// 状态 1新預約/2已确认/3已完成/4已取消/5已拒絕/6已過期
  int? status;

  /// 预约时间
  String? createdAt;

  /// 预约城市
  String? cityName;

  String? remark;
  String? reason;
  String? contact;
  String? email;
  String? phone;
  String? other;
  int? isRead;

  /// 行程id
  int? tripId;

  bool get isGrey => [4, 5, 6].contains(status);

  GuideReservation({
    this.user,
    this.id,
    this.arrivalTime,
    this.number,
    this.status,
    this.createdAt,
    this.cityName,
    this.remark,
    this.reason,
    this.contact,
    this.email,
    this.phone,
    this.other,
    this.isRead,
    this.tripId,
  });

  factory GuideReservation.fromJson(Map<String, dynamic> json) {
    return GuideReservation(
      user: json.safeObject('user', UserInfo.fromJson),
      id: json.safeInt('id'),
      arrivalTime: json.safeString('arrival_time'),
      number: json.safeString('number'),
      status: json.safeInt('status'),
      createdAt: json.safeString('created_at'),
      cityName: json.safeString('city_name'),
      remark: json.safeString('remark'),
      reason: json.safeString('reason'),
      contact: json.safeString('contact'),
      email: json.safeString('email'),
      phone: json.safeString('phone'),
      other: json.safeString('other'),
      isRead: json.safeInt('is_read'),
      tripId: json.safeInt('trip_id'),
    );
  }
}
