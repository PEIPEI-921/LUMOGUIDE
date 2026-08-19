import '../extensions/map.dart';

class SystemConfig {

  String? userProtocol;
  String? privacyProtocol;
  String? contactUs;
  String? integralRule;
  String? inviteRule;
  List<String> businessType;
  List<String> languages;
  String? vipUserProtocol;
  String? vipUserSubscribe;
  String? stripeKey;

  String? systemLogo;
  String? systemWelcomeZh;
  String? systemWelcomeEn;

  SystemConfig({
    this.userProtocol,
    this.privacyProtocol,
    this.contactUs,
    this.integralRule,
    this.inviteRule,
    this.businessType = const [],
    this.languages = const [],
    this.vipUserProtocol,
    this.vipUserSubscribe,
    this.systemLogo,
    this.systemWelcomeZh,
    this.systemWelcomeEn,
    this.stripeKey,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      userProtocol: json.safeString('user_protocol'),
      privacyProtocol: json.safeString('privacy_protocol'),
      contactUs: json.safeString('contact_us'),
      integralRule: json.safeString('integral_rule'),
      inviteRule: json.safeString('invite_rule'),
      businessType: json.safeList<String>('business_type') ?? [],
      // 兼容两种后端格式：JSON 数组（新）与逗号分隔字符串（旧）
      languages: _parseLanguages(json['languages']),
      vipUserProtocol: json.safeString('vip_user_protocol'),
      vipUserSubscribe: json.safeString('vip_user_subscribe'),
      systemLogo: json.safeString('system_logo'),
      systemWelcomeZh: json.safeString('system_welcome_zh'),
      systemWelcomeEn: json.safeString('system_welcome_en'),
      stripeKey: json.safeString('stripe_key'),
    );
  }

  /// 语言列表解析：List 直接使用；逗号字符串拆分；其他情况返回空列表
  static List<String> _parseLanguages(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return value
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_protocol': userProtocol,
      'privacy_protocol': privacyProtocol,
      'contact_us': contactUs,
      'integral_rule': integralRule,
      'business_type': businessType,
      'languages': languages,
      'vip_user_protocol': vipUserProtocol,
      'vip_user_subscribe': vipUserSubscribe,
      'system_logo': systemLogo,
      'system_welcome_zh': systemWelcomeZh,
      'system_welcome_en': systemWelcomeEn,
      'stripe_key': stripeKey,
    };
  }
}
