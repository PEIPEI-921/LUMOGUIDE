import 'package:lumotrip/common/index.dart';


class MemberInfo {
  int? identity;
  int? guideId;
  int? companyId;
  String? nickname;
  String? avatar;
  String? cityCountry;
  String? cityContinent;
  String? cityArea;
  GuideList? guideInfo;
  CompanyInfo? companyInfo;

  MemberInfo({
    this.identity,
    this.guideId,
    this.companyId,
    this.nickname,
    this.avatar,
    this.cityCountry,
    this.cityContinent,
    this.cityArea,
    this.guideInfo,
    this.companyInfo,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      identity: json.safeInt('identity'),
      guideId: json.safeInt('guide_id'),
      companyId: json.safeInt('company_id'),
      nickname: json.safeString('nickname'),
      avatar: json.safeString('avatar'),
      cityCountry: json.safeString('city_country'),
      cityContinent: json.safeString('city_continent'),
      cityArea: json.safeString('city_area'),
      guideInfo: json.safeObject('guide_info', GuideList.fromJson),
      companyInfo: json.safeObject('company_info', CompanyInfo.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'guide_id': guideId,
      'company_id': companyId,
      'nickname': nickname,
      'avatar': avatar,
      'city_country': cityCountry,
      'city_continent': cityContinent,
      'city_area': cityArea,
      'guide_info': guideInfo?.toJson(),
      'company_info': companyInfo?.toJson(),
    };
  }
}
