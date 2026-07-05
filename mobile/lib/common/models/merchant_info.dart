import '../extensions/map.dart';

class MerchantInfo {
  int? id;
  String? userNumber;
  String? name;
  String? className;
  String? startTime;
  String? endTime;
  String? ticketsFree;
  String? price;
  String? capacity;
  String? orderFood;
  String? phone;
  String? otherPhone;
  String? email;
  String? website;
  String? address;
  String? longitude;
  String? latitude;
  String? howArrive;
  String? introduce;
  List<String> pictures;
  String? cityName;

  MerchantCompany? companyInfo;

  int? isFollow;

  /// 是否评价
  int? isEvaluate;

  /// 是否预约
  int? isReserve;

  int? isShop;
  int? canFollow;

  String? firstPicture;

  MerchantInfo({
    this.id,
    this.userNumber,
    this.name,
    this.className,
    this.startTime,
    this.endTime,
    this.ticketsFree,
    this.price,
    this.capacity,
    this.orderFood,
    this.phone,
    this.otherPhone,
    this.email,
    this.website,
    this.address,
    this.longitude,
    this.latitude,
    this.howArrive,
    this.introduce,
    this.pictures = const [],
    this.cityName,
    this.isEvaluate,
    this.isReserve,
    this.firstPicture,
    this.companyInfo,
    this.isFollow,
    this.isShop,
    this.canFollow,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_number': userNumber,
      'name': name,
      'class_name': className,
      'start_time': startTime,
      'end_time': endTime,
      'tickets_free': ticketsFree,
      'price': price,
      'capacity': capacity,
      'order_food': orderFood,
      'phone': phone,
      'other_phone': otherPhone,
      'email': email,
      'website': website,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'how_arrive': howArrive,
      'introduce': introduce,
      'pictures': pictures,
      'is_evaluate': isEvaluate,
      'is_reserve': isReserve,
      'first_picture': firstPicture,
      'company_info': companyInfo?.toJson(),
      'is_follow': isFollow,
      'is_shop': isShop,
      'can_follow': canFollow,
      'city_name': cityName,
    };
  }

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      id: json.safeInt('id'),
      userNumber: json.safeString('user_number'),
      name: json.safeString('name'),
      className: json.safeString('class_name'),
      startTime: json.safeString('start_time'),
      endTime: json.safeString('end_time'),
      ticketsFree: json.safeString('tickets_free'),
      price: json.safeString('price'),
      capacity: json.safeString('capacity'),
      orderFood: json.safeString('order_food'),
      phone: json.safeString('phone'),
      otherPhone: json.safeString('other_phone'),
      email: json.safeString('email'),
      website: json.safeString('website'),
      address: json.safeString('address'),
      longitude: json.safeString('longitude'),
      latitude: json.safeString('latitude'),
      howArrive: json.safeString('how_arrive'),
      introduce: json.safeString('introduce'),
      pictures: json.safeList<String>('pictures') ?? [],
      isEvaluate: json.safeInt('is_evaluate'),
      isReserve: json.safeInt('is_reserve'),
      firstPicture: json.safeString('first_picture'),
      companyInfo: json.safeObject<MerchantCompany>(
          'company_info', MerchantCompany.fromJson),
      isFollow: json.safeInt('is_follow'),
      isShop: json.safeInt('is_shop'),
      canFollow: json.safeInt('can_follow'),
      cityName: json.safeString('city_name'),
    );
  }
}

class MerchantCompany {
  int? id;
  String? name;
  int? isFollow;

  MerchantCompany({
    this.id,
    this.name,
    this.isFollow,
  });

  factory MerchantCompany.fromJson(Map<String, dynamic> json) {
    return MerchantCompany(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      isFollow: json.safeInt('is_follow'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_follow': isFollow,
    };
  }
}
