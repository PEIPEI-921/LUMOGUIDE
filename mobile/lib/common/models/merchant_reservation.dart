import 'index.dart';
import '../extensions/map.dart';

class MerchantReservation {
  int? id;
  int? contentType;
  String? arrivalTime;
  String? leaveTime;
  String? number;
  String? roomNumber;
  String? remark;
  String? file;
  String? contact;
  String? email;
  String? phone;
  String? other;
  int? status;
  String? createdAt;
  UserInfo? user;
  MerchantList? content;
  int? isRead;
  String? reason;

  bool get isGrey => [3, 4, 5, 6].contains(status);

  MerchantReservation({
    this.id,
    this.contentType,
    this.arrivalTime,
    this.leaveTime,
    this.number,
    this.roomNumber,
    this.remark,
    this.file,
    this.contact,
    this.email,
    this.phone,
    this.other,
    this.status,
    this.createdAt,
    this.user,
    this.content,
    this.isRead,
    this.reason,
  });

  factory MerchantReservation.fromJson(Map<String, dynamic> json) {
    return MerchantReservation(
      id: json.safeInt('id'),
      contentType: json.safeInt('content_type'),
      arrivalTime: json.safeString('arrival_time'),
      leaveTime: json.safeString('leave_time'),
      number: json.safeString('number'),
      roomNumber: json.safeString('room_number'),
      remark: json.safeString('remark'),
      file: json.safeString('file'),
      contact: json.safeString('contact'),
      email: json.safeString('email'),
      phone: json.safeString('phone'),
      other: json.safeString('other'),
      status: json.safeInt('status'),
      createdAt: json.safeString('created_at'),
      user: json.safeObject('user', UserInfo.fromJson),
      content: json.safeObject('content', MerchantList.fromJson),
      isRead: json.safeInt('is_read'),
      reason: json.safeString('reason'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_type': contentType,
      'arrival_time': arrivalTime,
      'leave_time': leaveTime,
      'number': number,
      'room_number': roomNumber,
      'file': file,
      'contact': contact,
      'email': email,
      'phone': phone,
      'other': other,
      'status': status,
      'created_at': createdAt,
      'user': user?.toJson(),
      'content': content?.toJson(),
      'is_read': isRead,
      'reason': reason,
    };
  }
}
