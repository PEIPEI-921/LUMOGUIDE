import '../extensions/map.dart';

class MerchantEntry {
  MerchantEntry({
    this.name,
    this.nameEn,
    this.cityId,
    this.address,
    this.taxId,
    this.businessType,
    this.typeId,
    this.typeClassId,
    this.typeClassName,
    this.introduction,
    this.email,
    this.phone,
    this.website,
    this.otherContact,
    this.documentsPicture,
    this.picture = const [],
    this.auditStatus,
    this.auditFeedback,
    this.wechat,
    this.whatsApp,
    this.line,
  });

  /// 公司名称
  String? name;

  /// 所在城市
  String? nameEn;

  /// 所在城市
  int? cityId;

  /// 公司地址
  String? address;

  /// 公司税号
  String? taxId;

  /// 经营类型（字串，保留相容舊資料）
  String? businessType;

  /// 經營類型 ID（對應 MerchantShopType 枚舉值）
  int? typeId;

  /// 經營類型子分類 ID（對應 typeClass API 返回的 Category.id）
  int? typeClassId;

  /// 經營類型子分類名稱
  String? typeClassName;

  /// 简介
  String? introduction;

  /// Email
  String? email;

  /// 联系电话
  String? phone;

  /// 公司网址
  String? website;

  /// 其他联系方式
  String? otherContact;

  /// 微信
  String? wechat;

  /// WhatsApp
  String? whatsApp;

  /// Line
  String? line;

  /// 证件图片
  String? documentsPicture;

  /// 商家图片
  List<String> picture;

  /// 审核状态
  int? auditStatus;

  /// 审核反馈
  String? auditFeedback;

  factory MerchantEntry.fromJson(Map<String, dynamic> json) {
    return MerchantEntry(
      name: json.safeString('name'),
      nameEn: json.safeString('name_en'),
      cityId: json.safeInt('city_id'),
      address: json.safeString('address'),
      taxId: json.safeString('tax_id'),
      businessType: json.safeString('business_type'),
      typeId: json.safeInt('type_id'),
      typeClassId: json.safeInt('type_class_id'),
      typeClassName: json.safeString('type_class_name'),
      introduction: json.safeString('introduction'),
      email: json.safeString('email'),
      phone: json.safeString('phone'),
      website: json.safeString('website'),
      otherContact: json.safeString('other_contact'),
      wechat: json.safeString('wechat'),
      whatsApp: json.safeString('whats_app'),
      line: json.safeString('line'),
      documentsPicture: json.safeString('documents_picture'),
      picture: json.safeList<String>('picture') ?? [],
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_en': nameEn,
      'city_id': cityId,
      'address': address,
      'tax_id': taxId,
      'business_type': businessType,
      'type_id': typeId,
      'type_class_id': typeClassId,
      'type_class_name': typeClassName,
      'introduction': introduction,
      'email': email,
      'phone': phone,
      'website': website,
      'other_contact': otherContact,
      'wechat': wechat,
      'whats_app': whatsApp,
      'line': line,
      'documents_picture': documentsPicture,
      'picture': picture,
      'audit_status': auditStatus,
      'audit_feedback': auditFeedback,
    };
  }
}
