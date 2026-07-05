import '../extensions/map.dart';

class GuideCertification {
  GuideCertification({
    this.photo,
    this.name,
    this.nameEn,
    this.phone,
    this.email,
    this.billAddress,
    this.otherContact,
    this.language = const [],
    this.year,
    this.industryType = const [],
    this.otherType,
    this.identityType,
    this.introduction,
    this.businessContact,
    this.haveVehicle = 0,
    this.vehicleInfo,
    this.vehicleRent = 0,
    this.certificatePicture,
    this.passportPicture,
    this.driverLicenseFront,
    this.driverLicenseBack,
    this.carPictures = const [],
    this.auditStatus,
    this.auditFeedback,
    this.wechat,
    this.whatsApp,
    this.line,
  });

  /// 照片/LOGO
  String? photo;

  /// 真实姓名
  String? name;

  /// 英文姓名
  String? nameEn;

  /// 联系电话
  String? phone;

  /// 邮箱地址
  String? email;

  /// 账单地址
  String? billAddress;

  /// 微信
  String? wechat;

  /// WhatsApp
  String? whatsApp;

  /// Line
  String? line;

  /// 其他联系方式
  String? otherContact;

  /// 语言
  List<String> language;

  /// 从业年份
  String? year;

  /// 从事旅游行业类型
  List<String> industryType;

  /// 其他从业类型
  String? otherType;

  /// 展示身份类型
  String? identityType;

  /// 简介
  String? introduction;

  /// 从业联系人
  String? businessContact;

  /// 是否有车
  int? haveVehicle;

  /// 车辆信息
  String? vehicleInfo;

  /// 车辆是否出租
  int? vehicleRent;

  /// 资格证书图片
  String? certificatePicture;

  /// 护照证件图片
  String? passportPicture;

  /// 驾照正面
  String? driverLicenseFront;

  /// 驾照背面
  String? driverLicenseBack;

  /// 车辆照片
  List<String> carPictures;

  /// 审核状态 0: 待审核 1: 审核通过 2: 审核不通过
  int? auditStatus;

  /// 审核反馈
  String? auditFeedback;

  factory GuideCertification.fromJson(Map<String, dynamic> json) {
    return GuideCertification(
      photo: json.safeString('photo'),
      name: json.safeString('name'),
      nameEn: json.safeString('name_en'),
      phone: json.safeString('phone'),
      email: json.safeString('email'),
      billAddress: json.safeString('bill_address'),
      wechat: json.safeString('wechat'),
      whatsApp: json.safeString('whats_app'),
      line: json.safeString('line'),
      otherContact: json.safeString('other_contact'),
      language: json.safeList<String>('language') ?? [],
      year: json.safeString('year'),
      industryType: json.safeList<String>('industry_type') ?? [],
      otherType: json.safeString('other_type'),
      identityType: json.safeString('identity_type'),
      introduction: json.safeString('introduction'),
      businessContact: json.safeString('business_contact'),
      haveVehicle: json.safeInt('have_vehicle'),
      vehicleInfo: json.safeString('vehicle_info'),
      vehicleRent: json.safeInt('vehicle_rent'),
      certificatePicture: json.safeString('certificate_picture'),
      passportPicture: json.safeString('passport_picture'),
      driverLicenseFront: json.safeString('driver_license_front'),
      driverLicenseBack: json.safeString('driver_license_back'),
      carPictures: json.safeList<String>('car_pictures') ?? [],
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo': photo,
      'name': name,
      'name_en': nameEn,
      'phone': phone,
      'email': email,
      'bill_address': billAddress,
      'wechat': wechat,
      'whats_app': whatsApp,
      'line': line,
      'other_contact': otherContact,
      'language': language,
      'year': year,
      'industry_type': industryType,
      'other_type': otherType,
      'identity_type': identityType,
      'introduction': introduction,
      'business_contact': businessContact,
      'have_vehicle': haveVehicle,
      'vehicle_info': vehicleInfo,
      'vehicle_rent': vehicleRent,
      'certificate_picture': certificatePicture,
      'passport_picture': passportPicture,
      'driver_license_front': driverLicenseFront,
      'driver_license_back': driverLicenseBack,
      'car_pictures': carPictures,
      'audit_status': auditStatus,
      'audit_feedback': auditFeedback,
    };
  }
}
