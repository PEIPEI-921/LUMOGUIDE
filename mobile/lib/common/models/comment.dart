import 'package:lumotrip/common/index.dart';

class Comment {
  int? id;
  String? userAvatar;
  String? userNickname;
  String? myAvatar;
  String? myNickname;
  String? title;
  String? content;
  int? contentId;

  /// 1 店铺 2 资讯
  int? contentType;
  String? contentPicture;
  String? time;
  String? contentUser;
  CommentShopInfo? contentInfo;

  String? get formatDate {
    if (time == null) return null;
    final date = DateTime.tryParse(time ?? '');
    if (date == null) return null;
    return date.formatTimeAgo();
  }

  Comment({
    this.id,
    this.userAvatar,
    this.userNickname,
    this.myAvatar,
    this.myNickname,
    this.title,
    this.content,
    this.contentId,
    this.contentType,
    this.contentPicture,
    this.time,
    this.contentUser,
    this.contentInfo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json.safeInt('id'),
      userAvatar: json.safeString('user_avatar'),
      userNickname: json.safeString('user_nickname'),
      myAvatar: json.safeString('my_avatar'),
      myNickname: json.safeString('my_nickname'),
      title: json.safeString('title'),
      content: json.safeString('content'),
      contentId: json.safeInt('content_id'),
      contentType: json.safeInt('content_type'),
      contentPicture: json.safeString('content_picture'),
      time: json.safeString('time'),
      contentUser: json.safeString('content_user'),
      contentInfo: json.safeObject('content_info', CommentShopInfo.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_avatar': userAvatar,
      'user_nickname': userNickname,
      'my_avatar': myAvatar,
      'my_nickname': myNickname,
      'title': title,
      'content': content,
      'content_id': contentId,
      'content_type': contentType,
      'content_picture': contentPicture,
      'time': time,
      'content_info': contentInfo,
      'content_user': contentUser,
    };
  }
}

class CommentShopInfo {
  int? id;
  int? cityId;
  int? typeId;

  CommentShopInfo({
    this.id,
    this.cityId,
    this.typeId,
  });

  factory CommentShopInfo.fromJson(Map<String, dynamic> json) {
    return CommentShopInfo(
      id: json.safeInt('id'),
      cityId: json.safeInt('city_id'),
      typeId: json.safeInt('type_id'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'type_id': typeId,
    };
  }
}
