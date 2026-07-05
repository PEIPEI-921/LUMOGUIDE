import '../extensions/map.dart';

class MerchantShop {
  int? id;
  int? cityId;
  int? typeId;
  int? typeClassId;
  String? name;
  String? phone;
  String? otherPhone;
  String? address;
  String? firstPicture;
  int? auditStatus;
  String? auditFeedback;
  String? createdAt;
  String? type;
  String? startTime;
  int? ticketsFree;
  String? capacity;
  int? orderFood;
  String? price;
  String? email;
  String? website;
  String? longitude;
  String? latitude;
  String? howArrive;
  String? introduce;
  List<String> pictures;
  String? cityName;
  String? typeClassName;
  int? isRead;

  MerchantShop({
    this.id,
    this.cityId,
    this.typeId = 2,
    this.typeClassId,
    this.name,
    this.phone,
    this.otherPhone,
    this.address,
    this.firstPicture,
    this.auditStatus,
    this.auditFeedback,
    this.createdAt,
    this.type,
    this.startTime,
    this.ticketsFree = 1,
    this.capacity,
    this.orderFood,
    this.price,
    this.email,
    this.website,
    this.longitude,
    this.latitude,
    this.howArrive,
    this.introduce,
    this.pictures = const [],
    this.cityName,
    this.typeClassName,
    this.isRead,
  });

  factory MerchantShop.fromJson(Map<String, dynamic> json) => MerchantShop(
    id: json.safeInt('id'),
    cityId: json.safeInt('city_id'),
    typeId: json.safeInt('type_id'),
    typeClassId: json.safeInt('type_class_id'),
    name: json.safeString('name'),
    phone: json.safeString('phone'),
    otherPhone: json.safeString('other_phone'),
    address: json.safeString('address'),
    firstPicture: json.safeString('first_picture'),
    auditStatus: json.safeInt('audit_status'),
    auditFeedback: json.safeString('audit_feedback'),
    createdAt: json.safeString('created_at'),
    type: json.safeString('type'),
    startTime: json.safeString('start_time'),
    ticketsFree: json.safeInt('tickets_free'),
    capacity: json.safeString('capacity'),
    orderFood: json.safeInt('order_food'),
    price: json.safeString('price'),
    email: json.safeString('email'),
    website: json.safeString('website'),
    longitude: json.safeString('longitude'),
    latitude: json.safeString('latitude'),
    howArrive: json.safeString('how_arrive'),
    introduce: json.safeString('introduce'),
    pictures: json.safeList<String>('pictures') ?? [],
    cityName: json.safeString('city_name'),
    typeClassName: json.safeString('type_class_name'),
    isRead: json.safeInt('is_read'),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'city_id': cityId,
    'type_id': typeId,
    'type_class_id': typeClassId,
    'name': name,
    'phone': phone,
    'other_phone': otherPhone,
    'address': address,
    'first_picture': firstPicture,
    // 'audit_status': auditStatus,
    // 'audit_feedback': auditFeedback,
    // 'created_at': createdAt,
    'type': type,
    'start_time': startTime,
    'tickets_free': ticketsFree,
    'capacity': capacity,
    'order_food': orderFood,
    'price': price,
    'email': email,
    'website': website,
    'longitude': longitude,
    'latitude': latitude,
    'how_arrive': howArrive,
    'introduce': introduce,
    'pictures': pictures,
    // 'city_name': cityName,
    // 'type_class_name': typeClassName,
    'is_read': isRead,
  };
}
