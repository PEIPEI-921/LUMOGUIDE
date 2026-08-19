import '../extensions/map.dart';

class GuideList {
  int? id;
  String? userNumber;
  String? name;
  String? nameEn;
  String? cityId;
  String? cityName;
  String? photo;
  List<String>? language;
  String? phone;
  String? email;
  String? otherContact;
  String? identityType;
  String? identityTypeName;
  String? industryType;
  String? haveVehicle;
  String? vehicleRent;
  List<String> carPictures;
  String? introduction;
  String? wechat;
  String? whatsApp;
  String? line;
  int isFollow = 0;
  int isReserve = 0; // 是否可预约 0否/1是
  int canFollow = 0; // 是否可关注 0否/1是

  String get fullName {
    if (nameEn?.isNotEmpty ?? false) {
      return '$name($nameEn)';
    }
    return name ?? '';
  }

  GuideList({
    this.id,
    this.userNumber,
    this.name,
    this.nameEn,
    this.cityId,
    this.cityName,
    this.photo,
    this.language,
    this.phone,
    this.email,
    this.otherContact,
    this.identityType,
    this.identityTypeName,

    /// 从事工作类型
    this.industryType,

    /// 是否有车
    this.haveVehicle,

    /// 是否出租
    this.vehicleRent,
    this.carPictures = const [],
    this.introduction,
    this.isFollow = 0,
    this.wechat,
    this.whatsApp,
    this.line,
    this.isReserve = 0,
    this.canFollow = 0,
  });

  factory GuideList.fromJson(Map<String, dynamic> json) => GuideList(
    id: json.safeInt('id'),
    userNumber: json.safeString('user_number'),
    name: json.safeString('name'),
    nameEn: json.safeString('name_en'),
    cityId: json.safeString('city_id'),
    cityName: json.safeString('city_name'),
    photo: json.safeString('photo'),
    language: json.safeList<String>('language'),
    phone: json.safeString('phone'),
    email: json.safeString('email'),
    otherContact: json.safeString('other_contact'),
    identityType: json.safeString('identity_type'),
    identityTypeName: json.safeString('identity_type_name'),
    industryType: json.safeString('industry_type'),
    haveVehicle: json.safeString('have_vehicle'),
    vehicleRent: json.safeString('vehicle_rent'),
    carPictures: json.safeList<String>('car_pictures') ?? [],
    introduction: json.safeString('introduction'),
    isFollow: json.safeInt('is_follow') ?? 0,
    wechat: json.safeString('wechat'),
    whatsApp: json.safeString('whats_app'),
    line: json.safeString('line'),
    isReserve: json.safeInt('is_reserve') ?? 0,
    canFollow: json.safeInt('can_follow') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_number": userNumber,
    "name": name,
    "name_en": nameEn,
    "city_id": cityId,
    "city_name": cityName,
    "photo": photo,
    "language": language == null
        ? null
        : List<dynamic>.from(language!.map((x) => x)),
    "phone": phone,
    "email": email,
    "other_contact": otherContact,
    "identity_type": identityType,
    "identity_type_name": identityTypeName,
    "industry_type": industryType,
    "have_vehicle": haveVehicle,
    "vehicle_rent": vehicleRent,
    "car_pictures": carPictures,
    "introduction": introduction,
    "is_follow": isFollow,
    "wechat": wechat,
    "whats_app": whatsApp,
    "line": line,
    "is_reserve": isReserve,
    "can_follow": canFollow,
  };
}
