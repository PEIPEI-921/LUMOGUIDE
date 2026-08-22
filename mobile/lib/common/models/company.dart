import 'dart:convert';

import '../index.dart';

class CompanyInfo {
  int? id;
  String? name;
  String? nameEn;
  String? cityName;
  String? businessType;
  String? introduction;
  String? email;
  String? phone;
  String? website;
  String? otherContact;
  String? wechat;
  String? whatsApp;
  String? line;
  String? address;
  String? picture;
  List<MerchantShop>? shop;

  /// 企业所属用户编号（聊天入口）
  String? userNumber;

  String get fullName {
    if ((nameEn?.isNotEmpty ?? false) && name != nameEn) {
      return '$name\n($nameEn)';
    }
    return name ?? '';
  }

  CompanyInfo({
    this.id,
    this.name,
    this.nameEn,
    this.cityName,
    this.businessType,
    this.introduction,
    this.email,
    this.phone,
    this.website,
    this.otherContact,
    this.address,
    this.picture,
    this.shop,
    this.wechat,
    this.whatsApp,
    this.line,
    this.userNumber,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      nameEn: json.safeString('name_en'),
      cityName: json.safeString('city_name'),
      businessType: json.safeString('business_type'),
      introduction: json.safeString('introduction'),
      email: json.safeString('email'),
      phone: json.safeString('phone'),
      website: json.safeString('website'),
      otherContact: json.safeString('other_contact'),
      picture: _firstPicture(json['picture']),
      shop: json.safeObjectList<MerchantShop>('shop', MerchantShop.fromJson),
      address: json.safeString('address'),
      wechat: json.safeString('wechat'),
      whatsApp: json.safeString('whats_app'),
      line: json.safeString('line'),
      userNumber: json.safeString('user_number'),
    );
  }

  /// 公司形象照可能是字符串或 JSON 数组，统一取第一张 URL
  static String? _firstPicture(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final v = value.trim();
      if (v.startsWith('[')) {
        try {
          final list = jsonDecode(v);
          if (list is List && list.isNotEmpty) return list.first.toString();
        } catch (_) {}
        return null;
      }
      return v.isEmpty ? null : v;
    }
    if (value is List) {
      for (final item in value) {
        if (item is String && item.isNotEmpty) return item;
      }
      return null;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'city_name': cityName,
      'business_type': businessType,
      'introduction': introduction,
      'email': email,
      'phone': phone,
      'website': website,
      'other_contact': otherContact,
      'picture': picture,
      'shop': shop?.map((e) => e.toJson()).toList(),
      'address': address,
      'wechat': wechat,
      'whats_app': whatsApp,
      'line': line,
    };
  }
}
