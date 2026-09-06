import '../extensions/map.dart';

class News {
  int? id;
  String? title;
  String? desc;
  String? content;
  String? createdAt;
  NewsUser? user;
  int? evaluateCount;
  int? view;

  String? firstPicture;
  List<String> pictures;

  /// 是否可以評論 0 不可以 1 可以
  int? isEvaluate;

  /// 文章正文：優先返回完整 `content`（詳情/分享使用），
  /// 舊數據無 content 時回退到摘要 `desc`（與 Web 端行為一致）。
  String? get fullContent {
    final c = content?.trim() ?? '';
    return c.isNotEmpty ? content : desc;
  }

  News({
    this.id,
    this.title,
    this.desc,
    this.content,
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
      content: json.safeString('content'),
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
      'content': content,
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
