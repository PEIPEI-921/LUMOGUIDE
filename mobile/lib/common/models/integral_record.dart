/// {"id":11,"type":2,"title":"后台管理操作","amount":5000,"created_at":"2025-08-13 06:48:07"},{"id":10,"type":2,"title":"后台管理操作","amount":7,"created_at":"2025-08-13 06:47:45"}
library;

import '../extensions/map.dart';

class IntegralRecord {
  int? id;
  int? type;
  String? title;
  int? amount;
  String? createdAt;

  IntegralRecord({
    this.id,
    this.type,
    this.title,
    this.amount,
    this.createdAt,
  });

  factory IntegralRecord.fromJson(Map<String, dynamic> json) {
    return IntegralRecord(
      id: json.safeInt('id'),
      type: json.safeInt('type'),
      title: json.safeString('title'),
      amount: json.safeInt('amount'),
      createdAt: json.safeString('created_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'amount': amount,
      'created_at': createdAt,
    };
  }
}
