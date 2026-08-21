import '../extensions/map.dart';

class EvaluateList {
  int? id;
  int? userId;
  String? content;
  List<String> pictures;
  int? star;
  String? createdAt;
  EvaluateListUser? user;

  EvaluateList({
    this.id,
    this.userId,
    this.content,
    this.pictures = const [],
    this.star,
    this.createdAt,
    this.user,
  });

  factory EvaluateList.fromJson(Map<String, dynamic> json) {
    return EvaluateList(
      id: json.safeInt('id'),
      userId: json.safeInt('user_id'),
      content: json.safeString('content'),
      pictures: json.safeList<String>('pictures') ?? [],
      star: json.safeInt('star'),
      createdAt: json.safeString('created_at'),
      user: json.safeObject('user', EvaluateListUser.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'pictures': pictures,
      'star': star,
      'created_at': createdAt,
      'user': user?.toJson(),
    };
  }
}

class EvaluateListUser {
  int? id;
  String? nickname;
  String? avatar;
  int? identity;
  int? guideId;
  int? companyId;
  String? cityName;
  String? countryName;

  EvaluateListUser({
    this.id,
    this.nickname,
    this.avatar,
    this.identity,
    this.guideId,
    this.companyId,
    this.cityName,
    this.countryName,
  });

  factory EvaluateListUser.fromJson(Map<String, dynamic> json) {
    return EvaluateListUser(
      id: json.safeInt('id'),
      nickname: json.safeString('nickname'),
      avatar: json.safeString('avatar'),
      identity: json.safeInt('identity'),
      guideId: json.safeInt('guide_id'),
      companyId: json.safeInt('company_id'),
      cityName: json.safeString('city_name'),
      countryName: json.safeString('country_name'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'identity': identity,
      'guide_id': guideId,
      'company_id': companyId,
      'city_name': cityName,
      'country_name': countryName,
    };
  }
}
