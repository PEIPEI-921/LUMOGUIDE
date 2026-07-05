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
  List<MerchantShop>? shop;

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
    this.shop,
    this.wechat,
    this.whatsApp,
    this.line,
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
      shop: json.safeObjectList<MerchantShop>('shop', MerchantShop.fromJson),
      address: json.safeString('address'),
      wechat: json.safeString('wechat'),
      whatsApp: json.safeString('whats_app'),
      line: json.safeString('line'),
    );
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
      'shop': shop?.map((e) => e.toJson()).toList(),
      'address': address,
      'wechat': wechat,
      'whats_app': whatsApp,
      'line': line,
    };
  }
}
