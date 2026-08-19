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

  EvaluateListUser({
    this.id,
    this.nickname,
    this.avatar,
  });

  factory EvaluateListUser.fromJson(Map<String, dynamic> json) {
    return EvaluateListUser(
      id: json.safeInt('id'),
      nickname: json.safeString('nickname'),
      avatar: json.safeString('avatar'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
    };
  }
}
