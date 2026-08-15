import 'package:lumotrip/common/index.dart';

class FollowUser {
  /*
   * {
                "id": 1,
                "user_id": 35,
                "user_nickname": "LuMo-ID-2025-08-000035",
                "user_avatar": "https://lumo.api.arilks.cn/storage/uploads/jGuxFfgPiRZ0MU8N3DoU.jpg",
                "user_identity": 2,
                "user_identity_id": 5,
                "user_identity_tag": "Local guide",
                "is_follow": 1
            }
   */

  int? id;
  int? userId;
  String? userNickname;
  String? userAvatar;
  int? userIdentity;
  int? userIdentityId;
  String? userIdentityTag;
  String? userCityName;
  int? isFollow;
  FollowShopInfo? shopInfo;
  List<String> shopsName;
  String? userNumber;

  FollowUser({
    this.id,
    this.userId,
    this.userNickname,
    this.userAvatar,
    this.userIdentity,
    this.userIdentityId,
    this.userIdentityTag,
    this.userCityName,
    this.isFollow,
    this.shopInfo,
    this.shopsName = const [],
    this.userNumber,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json.safeInt('id'),
      userId: json.safeInt('user_id'),
      userNickname:
          json.safeString('user_nickname') ?? json.safeString('user_name'),
      userAvatar: json.safeString('user_avatar'),
      userIdentity: json.safeInt('user_identity'),
      userIdentityId: json.safeInt('user_identity_id'),
      userIdentityTag: json.safeString('user_identity_tag'),
      userCityName: json.safeString('user_city_name'),
      isFollow: json.safeInt('is_follow'),
      shopInfo: json.safeObject('shop_info', FollowShopInfo.fromJson),
      shopsName: json.safeList<String>('shops_name') ?? [],
      userNumber: json.safeString('user_number'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_nickname': userNickname,
      'user_avatar': userAvatar,
      'user_identity': userIdentity,
      'user_identity_id': userIdentityId,
      'user_identity_tag': userIdentityTag,
      'user_city_name': userCityName,
      'is_follow': isFollow,
      'shops_name': shopsName,
      'user_number': userNumber,
    };
  }
}

class FollowShopInfo {
  int? id;
  String? name;
  String? firstPicture;

  int? cityId;
  int? typeId;

  FollowShopInfo({
    this.id,
    this.name,
    this.firstPicture,
    this.cityId,
    this.typeId,
  });

  factory FollowShopInfo.fromJson(Map<String, dynamic> json) {
    return FollowShopInfo(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      firstPicture: json.safeString('first_picture'),
      cityId: json.safeInt('city_id'),
      typeId: json.safeInt('type_id'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_picture': firstPicture,
      'city_id': cityId,
      'type_id': typeId,
    };
  }
}
