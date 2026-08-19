import 'package:get/get.dart';

import 'index.dart';
import '../extensions/map.dart';

class UserReservationGuide {
  int? id;

  /// 1待确认/2已确认/3已完成/4已取消/5已拒绝/6已過期
  int? status;
  String? createdAt;
  GuideList? guide;

  /// 预约城市
  String? cityName;

  /// 到达时间
  String? arrivalTime;

  /// 人数
  String? number;

  /// 备注
  String? remark;
  String? contact;
  String? phone;
  String? email;
  String? other;

  String? reason;

  String get infoButtonText {
    if (status == 1) {
      return '確認預約'.tr;
    } else if (status == 2) {
      return '完成預約'.tr;
    }
    return '';
  }

  bool get isGrey => [3, 4, 5, 6].contains(status);

  UserReservationGuide({
    this.id,
    this.status,
    this.createdAt,
    this.guide,
    this.cityName,
    this.arrivalTime,
    this.number,
    this.remark,
    this.contact,
    this.phone,
    this.email,
    this.other,
    this.reason,
  });

  factory UserReservationGuide.fromJson(Map<String, dynamic> json) {
    return UserReservationGuide(
      id: json.safeInt('id'),
      status: json.safeInt('status'),
      createdAt: json.safeString('created_at'),
      guide: json.safeObject('guide', GuideList.fromJson),
      cityName: json.safeString('city_name'),
      arrivalTime: json.safeString('arrival_time'),
      number: json.safeString('number'),
      remark: json.safeString('remark'),
      contact: json.safeString('contact'),
      phone: json.safeString('phone'),
      email: json.safeString('email'),
      other: json.safeString('other'),
      reason: json.safeString('reason'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'created_at': createdAt,
      'guide': guide?.toJson(),
      'city_name': cityName,
      'arrival_time': arrivalTime,
      'number': number,
      'remark': remark,
      'contact': contact,
      'phone': phone,
      'email': email,
      'other': other,
      'reason': reason,
    };
  }
}

class UserReservationMerchant {
  int? id;

  /// 1待确认/2已确认/3已完成/4已取消/5已拒绝/6已過期
  int? status;
  String? createdAt;
  MerchantInfo? content;

  int? userId;
  int? companyId;
  int? cityId;
  int? contentType;
  int? contentId;
  String? ticketsType;
  String? arrivalTime;
  String? leaveTime;
  String? remark;
  String? number;
  String? roomNumber;
  String? file;
  String? contact;
  String? email;
  String? phone;
  String? other;
  String? updatedAt;
  String? reason;

  bool get isGrey => [3, 4, 5, 6].contains(status);

  UserReservationMerchant({
    this.id,
    this.status,
    this.createdAt,
    this.content,
    this.userId,
    this.companyId,
    this.cityId,
    this.contentType,
    this.contentId,
    this.ticketsType,
    this.arrivalTime,
    this.leaveTime,
    this.remark,
    this.number,
    this.roomNumber,
    this.file,
    this.contact,
    this.email,
    this.phone,
    this.other,
    this.updatedAt,
    this.reason,
  });

  factory UserReservationMerchant.fromJson(Map<String, dynamic> json) {
    return UserReservationMerchant(
      id: json.safeInt('id'),
      status: json.safeInt('status'),
      createdAt: json.safeString('created_at'),
      content: json.safeObject('content', MerchantInfo.fromJson),
      userId: json.safeInt('user_id'),
      companyId: json.safeInt('company_id'),
      cityId: json.safeInt('city_id'),
      contentType: json.safeInt('content_type'),
      contentId: json.safeInt('content_id'),
      ticketsType: json.safeString('tickets_type'),
      arrivalTime: json.safeString('arrival_time'),
      leaveTime: json.safeString('leave_time'),
      remark: json.safeString('remark'),
      number: json.safeString('number'),
      roomNumber: json.safeString('room_number'),
      file: json.safeString('file'),
      contact: json.safeString('contact'),
      email: json.safeString('email'),
      phone: json.safeString('phone'),
      other: json.safeString('other'),
      updatedAt: json.safeString('updated_at'),
      reason: json.safeString('reason'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'created_at': createdAt,
      'content': content?.toJson(),
      'user_id': userId,
      'company_id': companyId,
      'city_id': cityId,
      'content_type': contentType,
      'content_id': contentId,
      'tickets_type': ticketsType,
      'arrival_time': arrivalTime,
      'leave_time': leaveTime,
      'remark': remark,
      'number': number,
      'room_number': roomNumber,
      'file': file,
      'contact': contact,
      'email': email,
      'phone': phone,
      'other': other,
      'updated_at': updatedAt,
      'reason': reason,
    };
  }
}
