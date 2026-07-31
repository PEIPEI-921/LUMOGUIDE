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
    this.residentCityId,
    this.residentCityName,
    this.isNewCity = 0,
    this.newCityName,
    this.newCityNameEn,
    this.newCityContinentsId,
    this.newCityContinentsName,
    this.newCityAreaId,
    this.newCityAreaName,
    this.newCityCountryId,
    this.newCityCountryName,
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

  /// 常駐城市 ID（現有城市）
  int? residentCityId;

  /// 常駐城市名稱
  String? residentCityName;

  /// 是否為新增城市 0否 1是
  int? isNewCity;

  /// 新城市中文名
  String? newCityName;

  /// 新城市英文名
  String? newCityNameEn;

  /// 新城市大洲 ID
  int? newCityContinentsId;

  /// 新城市大洲名
  String? newCityContinentsName;

  /// 新城市區域 ID
  int? newCityAreaId;

  /// 新城市區域名
  String? newCityAreaName;

  /// 新城市國家 ID
  int? newCityCountryId;

  /// 新城市國家名
  String? newCityCountryName;

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
      residentCityId: json.safeInt('resident_city_id'),
      residentCityName: json.safeString('resident_city_name'),
      isNewCity: json.safeInt('is_new_city') ?? 0,
      newCityName: json.safeString('new_city_name'),
      newCityNameEn: json.safeString('new_city_name_en'),
      newCityContinentsId: json.safeInt('new_city_continents_id'),
      newCityContinentsName: json.safeString('new_city_continents_name'),
      newCityAreaId: json.safeInt('new_city_area_id'),
      newCityAreaName: json.safeString('new_city_area_name'),
      newCityCountryId: json.safeInt('new_city_country_id'),
      newCityCountryName: json.safeString('new_city_country_name'),
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
      'resident_city_id': residentCityId,
      'resident_city_name': residentCityName,
      'is_new_city': isNewCity,
      'new_city_name': newCityName,
      'new_city_name_en': newCityNameEn,
      'new_city_continents_id': newCityContinentsId,
      'new_city_continents_name': newCityContinentsName,
      'new_city_area_id': newCityAreaId,
      'new_city_area_name': newCityAreaName,
      'new_city_country_id': newCityCountryId,
      'new_city_country_name': newCityCountryName,
    };
  }
}
