import '../extensions/map.dart';

class News {
  int? id;
  String? title;
  String? desc;
  String? createdAt;
  NewsUser? user;
  int? evaluateCount;
  int? view;

  String? firstPicture;
  List<String> pictures;

  /// 是否可以評論 0 不可以 1 可以
  int? isEvaluate;

  News({
    this.id,
    this.title,
    this.desc,
    this.createdAt,
    this.user,
    this.evaluateCount,
    this.view,
    this.isEvaluate,
    this.firstPicture,
    this.pictures = const [],
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json.safeInt('id'),
      title: json.safeString('title'),
      desc: json.safeString('desc'),
      createdAt: json.safeString('created_at'),
      user: json.safeObject('user', NewsUser.fromJson),
      evaluateCount: json.safeInt('evaluate_count'),
      view: json.safeInt('view'),
      isEvaluate: json.safeInt('is_evaluate'),
      firstPicture: json.safeString('first_picture'),
      pictures: json.safeList<String>('pictures') ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'created_at': createdAt,
      'user': user?.toJson(),
      'evaluate_count': evaluateCount,
      'view': view,
      'is_evaluate': isEvaluate,
      'first_picture': firstPicture,
      'pictures': pictures,
    };
  }
}

class NewsUser {
  String? name;
  String? photo;
  String? identityType;
  String? cityName;
  int? cityId;
  int? guideId;

  NewsUser({
    this.name,
    this.photo,
    this.identityType,
    this.cityName,
    this.cityId,
    this.guideId,
  });

  factory NewsUser.fromJson(Map<String, dynamic> json) {
    return NewsUser(
      name: json.safeString('name'),
      photo: json.safeString('photo'),
      identityType: json.safeString('identity_type'),
      cityName: json.safeString('city_name'),
      cityId: json.safeInt('city_id'),
      guideId: json.safeInt('guide_id'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photo': photo,
      'identity_type': identityType,
      'city_name': cityName,
      'city_id': cityId,
      'guide_id': guideId,
    };
  }
}
