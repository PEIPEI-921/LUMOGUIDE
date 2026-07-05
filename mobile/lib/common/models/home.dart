import 'city_list.dart';
import 'merchant_list.dart';
import 'guide_list.dart';
import '../extensions/map.dart';

class HomeModel {
  HomeModel({
    this.city = const [],
    this.guide = const [],
    this.shop = const [],
    this.information = const [],
  });

  List<CityList> city;
  List<HomeModelGuide> guide;
  List<HomeModelShop> shop;
  List<HomeModelInformation> information;

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    city:
        (json['city'] as List<dynamic>?)
            ?.map((x) => CityList.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
    guide:
        (json['guide'] as List<dynamic>?)
            ?.map((x) => HomeModelGuide.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
    shop:
        (json['shop'] as List<dynamic>?)
            ?.map((x) => HomeModelShop.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
    information:
        (json['information'] as List<dynamic>?)
            ?.map(
              (x) => HomeModelInformation.fromJson(x as Map<String, dynamic>),
            )
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() {
    return {
      "city": city.map((x) => x.toJson()).toList(),
      "guide": guide.map((x) => x.toJson()).toList(),
      "shop": shop.map((x) => x.toJson()).toList(),
      "information": information.map((x) => x.toJson()).toList(),
    };
  }
}

class HomeModelGuide {
  HomeModelGuide({this.id, this.name, this.list = const []});

  int? id;
  String? name;
  List<GuideList> list;

  factory HomeModelGuide.fromJson(Map<String, dynamic> json) => HomeModelGuide(
    id: json['id'] as int?,
    name: json['name'] as String?,
    list:
        (json['list'] as List<dynamic>?)
            ?.map((x) => GuideList.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'list': list.map((x) => x.toJson()).toList(),
    };
  }
}

class HomeModelShop {
  HomeModelShop({
    this.id,
    this.typeId,
    this.name,
    this.list = const [],
    this.banner = const [],
  });

  int? id;
  int? typeId;
  String? name;
  List<MerchantList> list;
  List<MerchantList> banner;

  factory HomeModelShop.fromJson(Map<String, dynamic> json) => HomeModelShop(
    id: json['id'] as int?,
    typeId: json.safeInt('type_id'),
    name: json.safeString('name'),
    list:
        (json['list'] as List<dynamic>?)
            ?.map((x) => MerchantList.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
    banner:
        (json['banner'] as List<dynamic>?)
            ?.map((x) => MerchantList.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'list': list.map((x) => x.toJson()).toList(),
      'banner': banner.map((x) => x.toJson()).toList(),
    };
  }
}

class HomeModelInformation {
  HomeModelInformation({this.id, this.name, this.list = const []});

  int? id;
  String? name;
  List<HomeModelInformationList> list;

  factory HomeModelInformation.fromJson(Map<String, dynamic> json) =>
      HomeModelInformation(
        id: json['id'] as int?,
        name: json['name'] as String?,
        list:
            (json['list'] as List<dynamic>?)
                ?.map(
                  (x) => HomeModelInformationList.fromJson(
                    x as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'list': list.map((x) => x.toJson()).toList(),
    };
  }
}

class HomeModelInformationList {
  HomeModelInformationList({
    this.id,
    this.title,
    this.desc,
    this.createdAt,
    this.guideType,
    this.userNickname,
    this.userAvatar,
    this.evaluateCount,
    this.firstPicture,
    this.pictures = const [],
  });

  int? id;
  String? title;
  String? desc;
  String? createdAt;
  String? guideType;
  String? userNickname;
  String? userAvatar;
  int? evaluateCount;
  String? firstPicture;
  List<String> pictures;

  factory HomeModelInformationList.fromJson(Map<String, dynamic> json) =>
      HomeModelInformationList(
        id: json['id'] as int?,
        title: json['title'] as String?,
        desc: json['desc'] as String?,
        createdAt: json['created_at'] as String?,
        guideType: json['guide_type'] as String?,
        userNickname: json['user_nickname'] as String?,
        userAvatar: json['user_avatar'] as String?,
        evaluateCount: json['evaluate_count'] as int?,
        firstPicture: json['first_picture'] as String?,
        pictures: json.safeList<String>('pictures') ?? [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "desc": desc,
    "created_at": createdAt,
    "guide_type": guideType,
    "user_nickname": userNickname,
    "user_avatar": userAvatar,
    "evaluate_count": evaluateCount,
    "first_picture": firstPicture,
    "pictures": pictures,
  };
}
