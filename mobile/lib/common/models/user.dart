import 'package:intl/intl.dart';

import '../index.dart';

class UserInfo {
  String? id;

  String? number;

  /// 邮箱
  String? email;

  /// 昵称
  String? nickname;

  /// 头像
  String? avatar;

  /// 手机号
  String? phone;

  /// 出生日期
  String? birthday;

  /// 邀请码
  String? inviterCode;

  /// 积分
  int? integral;

  /// 身份 1普通用户 2导游 3企业
  int? identity;

  /// vip 类型  0非会员/1导游/2企业
  int? vipType;

  /// vip id
  int? vipId;

  /// vip 名称
  String? vipName;

  /// vip 过期时间
  int? vipExpirationTime;

  /// 身份类型
  String? identityType;

  String? identityStr;

  /// 关注数
  int? followCount;

  /// 粉丝数
  int? fanCount;

  /// 是否是免费会员
  int? vipFree;

  /// 免费会员天数
  int? vipFreeDay;

  /// 导游认证状态 9未提交,0提交审核,1审核通过,2审核驳回
  int? guideAuditStatus;

  /// 企业认证状态 9未提交,0提交审核,1审核通过,2审核驳回
  int? companyAuditStatus;

  /// 預約我的數量
  int? reserveCount;

  /// 导游城市未读
  int? cityRemindCount;

  /// 城市发布未读
  int? contentRemindCount;

  int? userStatus;

  UserGuideInfo? guideInfo;

  UserCompanyInfo? companyInfo;

  String? inviteImg;
  String? inviteUrl;

  /// 是否是导游
  bool get isGuide => identity == 2;

  /// 是否是企业
  bool get isEnterprise => identity == 3;

  /// 是否是普通用户
  bool get isUser => identity == 1;

  bool get inAudit => userStatus == 1;

  /// 是否是付费会员
  bool get isPaidVip =>
      vipType != null &&
      vipType! > 0 &&
      vipExpirationTime != null &&
      vipExpirationTime! > 0;

  /// 是否是免费会员
  bool get isFreeVip => vipFree == 1 && vipFreeDay != null && vipFreeDay! > 0;

  /// 是否是会员
  bool get isVip => isPaidVip || isFreeVip;

  /// 是否显示导游认证
  bool get showGuideAuth =>
      isUser && guideAuditStatus != 1 && companyAuditStatus == 9;

  /// 是否显示企业认证
  bool get showEnterpriseAuth =>
      isUser && companyAuditStatus != 1 && guideAuditStatus == 9;

  /// 会员过期时间
  String get vipExpirationTimeStr =>
      vipExpirationTime != null && vipExpirationTime! > 0
      ? DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.fromMillisecondsSinceEpoch(vipExpirationTime! * 1000))
      : '';

  /// 是否是会员过期
  bool get isVipExpired =>
      vipExpirationTime != null &&
      vipExpirationTime! < DateTime.now().millisecondsSinceEpoch / 1000;

  UserInfo({
    this.id,
    this.number,
    this.email,
    this.nickname,
    this.avatar,
    this.phone,
    this.birthday,
    this.inviterCode,
    this.integral,
    this.identity,
    this.vipType,
    this.vipId,
    this.vipName,
    this.vipExpirationTime,
    this.followCount,
    this.fanCount,
    this.guideAuditStatus,
    this.companyAuditStatus,
    this.identityType,
    this.identityStr,
    this.vipFree,
    this.vipFreeDay,
    this.guideInfo,
    this.companyInfo,
    this.reserveCount,
    this.cityRemindCount,
    this.contentRemindCount,
    this.userStatus,
    this.inviteImg,
    this.inviteUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'phone': phone,
      'birthday': birthday,
      'inviter_code': inviterCode,
      'integral': integral,
      'identity': identity,
      'vip_type': vipType,
      'vip_id': vipId,
      'vip_name': vipName,
      'vip_expiration_time': vipExpirationTime,
      'follow_count': followCount,
      'fan_count': fanCount,
      'guide_audit_status': guideAuditStatus,
      'company_audit_status': companyAuditStatus,
      'identity_type': identityType,
      'identity_str': identityStr,
      'vip_free': vipFree,
      'vip_free_day': vipFreeDay,
      'guide_info': guideInfo?.toJson(),
      'company_info': companyInfo?.toJson(),
      'reserve_count': reserveCount,
      'city_remind_count': cityRemindCount,
      'content_remind_count': contentRemindCount,
      'user_status': userStatus,
      'invite_img': inviteImg,
      'invite_url': inviteUrl,
    };
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json.safeString('id'),
      number: json.safeString('number'),
      email: json.safeString('email'),
      nickname: json.safeString('nickname'),
      avatar: json.safeString('avatar'),
      phone: json.safeString('phone'),
      birthday: json.safeString('birthday'),
      inviterCode: json.safeString('inviter_code'),
      integral: json.safeInt('integral'),
      identity: json.safeInt('identity'),
      vipType: json.safeInt('vip_type'),
      vipId: json.safeInt('vip_id'),
      vipName: json.safeString('vip_name'),
      vipExpirationTime: json.safeInt('vip_expiration_time'),
      followCount: json.safeInt('follow_count'),
      fanCount: json.safeInt('fan_count'),
      guideAuditStatus: json.safeInt('guide_audit_status'),
      companyAuditStatus: json.safeInt('company_audit_status'),
      identityType: json.safeString('identity_type'),
      identityStr: json.safeString('identity_str'),
      vipFree: json.safeInt('vip_free'),
      vipFreeDay: json.safeInt('vip_free_day'),
      guideInfo: json.safeObject('guide_info', UserGuideInfo.fromJson),
      companyInfo: () {
        final raw = json['company_info'];
        if (raw is Map && raw.isNotEmpty) {
          return UserCompanyInfo.fromJson(Map<String, dynamic>.from(raw));
        }
        return null;
      }(),
      reserveCount: json.safeInt('reserve_count'),
      cityRemindCount: json.safeInt('city_remind_count'),
      contentRemindCount: json.safeInt('content_remind_count'),
      userStatus: json.safeInt('user_status'),
      inviteImg: json.safeString('invite_img'),
      inviteUrl: json.safeString('invite_url'),
    );
  }
}

class UserGuideInfo {
  int? id;
  String? name;
  String? photo;
  String? cityName;
  int? identityType;

  UserGuideInfo({
    this.id,
    this.name,
    this.photo,
    this.cityName,
    this.identityType,
  });

  factory UserGuideInfo.fromJson(Map<String, dynamic> json) {
    return UserGuideInfo(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      photo: json.safeString('photo'),
      cityName: json.safeString('city_name'),
      identityType: json.safeInt('identity_type'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'city_name': cityName,
      'identity_type': identityType,
    };
  }
}

class UserCompanyInfo {
  int? id;

  UserCompanyInfo({this.id});

  factory UserCompanyInfo.fromJson(Map<String, dynamic> json) {
    return UserCompanyInfo(id: json.safeInt('id'));
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
