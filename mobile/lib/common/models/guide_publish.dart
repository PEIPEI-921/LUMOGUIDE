import '../extensions/map.dart';

class GuidePublishInformation {
  int? id;
  int? classId;
  String? className;
  String? title;
  String? desc;
  String? content;
  List<String> pictures;
  String? createdAt;
  String? firstPicture;
  int? auditStatus;
  String? auditFeedback;

  /// 是否已读 0未读 1已读
  int? isRead;

  /// 仅谁可看 1仅导游/2所有人
  int? look;

  GuidePublishInformation({
    this.id,
    this.classId,
    this.className,
    this.title,
    this.desc,
    this.content,
    this.pictures = const [],
    this.look = 1,
    this.createdAt,
    this.firstPicture,
    this.auditStatus,
    this.auditFeedback,
    this.isRead,
  });

  factory GuidePublishInformation.fromJson(Map<String, dynamic> json) {
    return GuidePublishInformation(
      id: json.safeInt('id'),
      classId: json.safeInt('class_id'),
      className: json.safeString('class_name'),
      title: json.safeString('title'),
      desc: json.safeString('desc'),
      content: json.safeString('content'),
      pictures: json.safeList<String>('pictures') ?? [],
      look: json.safeInt('look'),
      createdAt: json.safeString('created_at'),
      firstPicture: json.safeString('first_picture'),
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
      isRead: json.safeInt('is_read'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'class_id': classId,
      'title': title,
      'desc': desc,
      'content': content,
      'pictures': pictures,
      'look': look,
      'is_read': isRead,
    };
  }
}

class GuidePublishAttraction {
  int? id;
  int? cityId;
  String? cityName;
  int? typeClassId;
  String? typeClassName;
  String? name;
  String? startTime;

  /// 是否已读 0未读 1已读
  int? isRead;

  /// 0收费 1免费
  int? ticketsFree;
  String? price;
  String? phone;
  String? email;
  String? website;
  String? address;
  String? longitude;
  String? latitude;
  String? howArrive;
  String? introduce;
  List<String> pictures;
  String? createdAt;
  String? firstPicture;
  int? auditStatus;
  String? auditFeedback;

  GuidePublishAttraction({
    this.id,
    this.cityId,
    this.cityName,
    this.typeClassId,
    this.name,
    this.startTime,
    this.isRead,
    this.ticketsFree = 1,
    this.price,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.longitude,
    this.latitude,
    this.howArrive,
    this.introduce,
    this.pictures = const [],
    this.createdAt,
    this.firstPicture,
    this.auditStatus,
    this.auditFeedback,
  });

  factory GuidePublishAttraction.fromJson(Map<String, dynamic> json) {
    return GuidePublishAttraction(
      id: json.safeInt('id'),
      cityId: json.safeInt('city_id'),
      cityName: json.safeString('city_name'),
      typeClassId: json.safeInt('type_class_id'),
      name: json.safeString('name'),
      isRead: json.safeInt('is_read'),
      startTime: json.safeString('start_time'),
      ticketsFree: json.safeInt('tickets_free'),
      price: json.safeString('price'),
      phone: json.safeString('phone'),
      email: json.safeString('email'),
      website: json.safeString('website'),
      address: json.safeString('address'),
      longitude: json.safeString('longitude'),
      latitude: json.safeString('latitude'),
      howArrive: json.safeString('how_arrive'),
      introduce: json.safeString('introduce'),
      pictures: json.safeList<String>('pictures') ?? [],
      createdAt: json.safeString('created_at'),
      firstPicture: json.safeString('first_picture'),
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'city_id': cityId,
      'city_name': cityName,
      'type_class_id': typeClassId,
      'name': name,
      'is_read': isRead,
      'start_time': startTime,
      'tickets_free': ticketsFree,
      'price': price,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'how_arrive': howArrive,
      'introduce': introduce,
      'pictures': pictures,
    };
  }
}

class GuidePublishTransportation {
  int? id;
  int? cityId;
  String? cityName;
  int? typeClassId;
  String? typeClassName;
  String? name;
  String? phone;
  String? address;
  String? longitude;
  String? latitude;
  String? introduce;
  List<String> pictures;
  String? createdAt;
  String? firstPicture;
  int? auditStatus;
  String? auditFeedback;

  /// 是否已读 0未读 1已读
  int? isRead;

  GuidePublishTransportation({
    this.id,
    this.cityId,
    this.cityName,
    this.typeClassId,
    this.typeClassName,
    this.name,
    this.phone,
    this.address,
    this.longitude,
    this.latitude,
    this.introduce,
    this.pictures = const [],
    this.createdAt,
    this.firstPicture,
    this.auditStatus,
    this.auditFeedback,
    this.isRead,
  });

  factory GuidePublishTransportation.fromJson(Map<String, dynamic> json) {
    return GuidePublishTransportation(
      id: json.safeInt('id'),
      cityId: json.safeInt('city_id'),
      cityName: json.safeString('city_name'),
      typeClassId: json.safeInt('type_class_id'),
      typeClassName: json.safeString('type_class_name'),
      name: json.safeString('name'),
      phone: json.safeString('phone'),
      address: json.safeString('address'),
      longitude: json.safeString('longitude'),
      latitude: json.safeString('latitude'),
      introduce: json.safeString('introduce'),
      pictures: json.safeList<String>('pictures') ?? [],
      createdAt: json.safeString('created_at'),
      firstPicture: json.safeString('first_picture'),
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
      isRead: json.safeInt('is_read'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'city_id': cityId,
      'city_name': cityName,
      'type_class_id': typeClassId,
      'type_class_name': typeClassName,
      'name': name,
      'phone': phone,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'introduce': introduce,
      'pictures': pictures,
      'is_read': isRead,
    };
  }
}

class GuidePublishFacility {
  int? id;
  int? cityId;
  String? cityName;
  int? typeClassId;
  String? typeClassName;
  String? name;
  String? phone;
  String? address;
  String? longitude;
  String? latitude;
  String? introduce;
  List<String> pictures;
  String? createdAt;
  String? firstPicture;
  int? auditStatus;
  String? auditFeedback;

  /// 是否已读 0未读 1已读
  int? isRead;
  GuidePublishFacility({
    this.id,
    this.cityId,
    this.cityName,
    this.typeClassId,
    this.typeClassName,
    this.name,
    this.phone,
    this.address,
    this.longitude,
    this.latitude,
    this.introduce,
    this.pictures = const [],
    this.createdAt,
    this.firstPicture,
    this.auditStatus,
    this.auditFeedback,
    this.isRead,
  });

  factory GuidePublishFacility.fromJson(Map<String, dynamic> json) {
    return GuidePublishFacility(
      id: json.safeInt('id'),
      cityId: json.safeInt('city_id'),
      typeClassId: json.safeInt('type_class_id'),
      typeClassName: json.safeString('type_class_name'),
      cityName: json.safeString('city_name'),
      name: json.safeString('name'),
      phone: json.safeString('phone'),
      address: json.safeString('address'),
      longitude: json.safeString('longitude'),
      latitude: json.safeString('latitude'),
      introduce: json.safeString('introduce'),
      pictures: json.safeList<String>('pictures') ?? [],
      createdAt: json.safeString('created_at'),
      firstPicture: json.safeString('first_picture'),
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
      isRead: json.safeInt('is_read'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'city_id': cityId,
      'city_name': cityName,
      'type_class_id': typeClassId,
      'type_class_name': typeClassName,
      'name': name,
      'phone': phone,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'introduce': introduce,
      'pictures': pictures,
      'is_read': isRead,
    };
  }
}

class GuidePublishActivity {
  int? id;
  int? cityId;
  String? cityName;
  int? typeClassId;
  String? typeClassName;
  String? name;
  String? startTime;
  String? endTime;
  String? website;
  String? address;
  String? longitude;
  String? latitude;
  String? introduce;
  List<String> pictures;
  String? createdAt;
  String? firstPicture;

  /// 审核状态 0审核中/1审核通过/2驳回
  int? auditStatus;
  String? auditFeedback;

  /// 是否已读 0未读 1已读
  int? isRead;
  GuidePublishActivity({
    this.id,
    this.cityId,
    this.cityName,
    this.typeClassId,
    this.typeClassName,
    this.name,
    this.startTime,
    this.endTime,
    this.website,
    this.address,
    this.longitude,
    this.latitude,
    this.introduce,
    this.pictures = const [],
    this.createdAt,
    this.firstPicture,
    this.auditStatus,
    this.auditFeedback,
    this.isRead,
  });

  factory GuidePublishActivity.fromJson(Map<String, dynamic> json) {
    return GuidePublishActivity(
      id: json.safeInt('id'),
      cityId: json.safeInt('city_id'),
      cityName: json.safeString('city_name'),
      typeClassId: json.safeInt('type_class_id'),
      typeClassName: json.safeString('type_class_name'),
      name: json.safeString('name'),
      startTime: json.safeString('start_time'),
      endTime: json.safeString('end_time'),
      website: json.safeString('website'),
      address: json.safeString('address'),
      longitude: json.safeString('longitude'),
      latitude: json.safeString('latitude'),
      introduce: json.safeString('introduce'),
      pictures: json.safeList<String>('pictures') ?? [],
      createdAt: json.safeString('created_at'),
      firstPicture: json.safeString('first_picture'),
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
      isRead: json.safeInt('is_read'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'city_id': cityId,
      'city_name': cityName,
      'type_class_id': typeClassId,
      'type_class_name': typeClassName,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'website': website,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'introduce': introduce,
      'pictures': pictures,
      'is_read': isRead,
    };
  }
}

class GuidePublishCity {
  int? id;
  String? name;
  String? nameEn;

  /// 大洲id
  int? continentsId;
  String? continentsName;

  /// 区域id
  int? areaId;
  String? areaName;
  String? longitude;
  String? latitude;

  int? countryId;
  String? countryName;

  /// 是否是首都
  int? isCapital;
  String? currency;
  String? language;
  String? population;
  String? race;

  /// 概览
  String? overview;

  /// 历史
  String? history;
  List<String> pictures = const [];
  String? firstPicture;
  int? auditStatus;
  String? auditFeedback;

  /// 是否已读 0未读 1已读
  int? isRead;
  String? createdAt;

  GuidePublishCity({
    this.id,
    this.name,
    this.nameEn,
    this.continentsId,
    this.continentsName,
    this.areaId,
    this.areaName,
    this.countryId,
    this.countryName,
    this.longitude,
    this.latitude,
    this.isCapital = 0,
    this.currency,
    this.language,
    this.population,
    this.race,
    this.overview,
    this.history,
    this.pictures = const [],
    this.firstPicture,
    this.auditStatus,
    this.auditFeedback,
    this.createdAt,
    this.isRead,
  });

  factory GuidePublishCity.fromJson(Map<String, dynamic> json) {
    return GuidePublishCity(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      nameEn: json.safeString('name_en'),
      continentsId: json.safeInt('continents_id'),
      continentsName: json.safeString('continents_name'),
      areaId: json.safeInt('area_id'),
      areaName: json.safeString('area_name'),
      countryId: json.safeInt('country_id'),
      countryName: json.safeString('country_name'),
      longitude: json.safeString('longitude'),
      latitude: json.safeString('latitude'),
      isCapital: json.safeInt('is_capital'),
      currency: json.safeString('currency'),
      language: json.safeString('language'),
      population: json.safeString('population'),
      race: json.safeString('race'),
      overview: json.safeString('overview'),
      history: json.safeString('history'),
      pictures: json.safeList<String>('pictures') ?? [],
      firstPicture: json.safeString('first_picture'),
      auditStatus: json.safeInt('audit_status'),
      auditFeedback: json.safeString('audit_feedback'),
      createdAt: json.safeString('created_at'),
      isRead: json.safeInt('is_read'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_en': nameEn,
      'continents_id': continentsId,
      'continents_name': continentsName,
      'area_id': areaId,
      'area_name': areaName,
      'country_id': countryId,
      'country_name': countryName,
      'longitude': longitude,
      'latitude': latitude,
      'is_capital': isCapital,
      'currency': currency,
      'language': language,
      'population': population,
      'race': race,
      'overview': overview,
      'history': history,
      'first_picture': firstPicture,
      'audit_status': auditStatus,
      'audit_feedback': auditFeedback,
      'pictures': pictures,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }
}
