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
    city: json.safeObjectList<CityList>('city', CityList.fromJson) ?? [],
    guide: json.safeObjectList<HomeModelGuide>('guide', HomeModelGuide.fromJson) ?? [],
    shop: json.safeObjectList<HomeModelShop>('shop', HomeModelShop.fromJson) ?? [],
    information:
        json.safeObjectList<HomeModelInformation>(
          'information',
          HomeModelInformation.fromJson,
        ) ??
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
    id: json.safeInt('id'),
    name: json.safeString('name'),
    list: json.safeObjectList<GuideList>('list', GuideList.fromJson) ?? [],
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
    id: json.safeInt('id'),
    typeId: json.safeInt('type_id'),
    name: json.safeString('name'),
    list: json.safeObjectList<MerchantList>('list', MerchantList.fromJson) ?? [],
    banner: json.safeObjectList<MerchantList>('banner', MerchantList.fromJson) ?? [],
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
        id: json.safeInt('id'),
        name: json.safeString('name'),
        list:
            json.safeObjectList<HomeModelInformationList>(
              'list',
              HomeModelInformationList.fromJson,
            ) ??
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
        id: json.safeInt('id'),
        title: json.safeString('title'),
        desc: json.safeString('desc'),
        createdAt: json.safeString('created_at'),
        guideType: json.safeString('guide_type'),
        userNickname: json.safeString('user_nickname'),
        userAvatar: json.safeString('user_avatar'),
        evaluateCount: json.safeInt('evaluate_count'),
        firstPicture: json.safeString('first_picture'),
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
