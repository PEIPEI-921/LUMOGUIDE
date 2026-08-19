import 'package:lumotrip/common/index.dart';


class MemberInfo {
  int? identity;
  int? guideId;
  int? companyId;
  GuideList? guideInfo;
  CompanyInfo? companyInfo;

  MemberInfo({
    this.identity,
    this.guideId,
    this.companyId,
    this.guideInfo,
    this.companyInfo,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      identity: json.safeInt('identity'),
      guideId: json.safeInt('guide_id'),
      companyId: json.safeInt('company_id'),
      guideInfo: json.safeObject('guide_info', GuideList.fromJson),
      companyInfo: json.safeObject('company_info', CompanyInfo.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'guide_id': guideId,
      'company_id': companyId,
      'guide_info': guideInfo?.toJson(),
      'company_info': companyInfo?.toJson(),
    };
  }
}