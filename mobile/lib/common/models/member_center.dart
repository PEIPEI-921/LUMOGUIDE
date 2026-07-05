import 'package:lumotrip/common/index.dart';

class MemberProduct {
  int? id;

  /// 名称
  String? name;

  /// 时间类型 1月/2年
  int? timeType;

  /// 购买类型 1金额/2积分
  int? buyType;

  /// 价格
  String? price;

  /// 时间类型字符串
  String? timeTypeStr;

  String? icon;

  MemberProduct({
    this.id,
    this.name,
    this.timeType,
    this.buyType,
    this.price,
    this.timeTypeStr,
    this.icon,
  });

  factory MemberProduct.fromJson(Map<String, dynamic> json) {
    return MemberProduct(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      timeType: json.safeInt('time_type'),
      buyType: json.safeInt('buy_type'),
      price: json.safeString('price'),
      timeTypeStr: json.safeString('time_type_str'),
      icon: json.safeString('icon'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time_type': timeType,
      'buy_type': buyType,
      'price': price,
      'time_type_str': timeTypeStr,
      'icon': icon,
    };
  }
}

class MemberAbility {
  List<String> guide;
  List<List<String>> company;

  MemberAbility({
    this.guide = const [],
    this.company = const [],
  });

  factory MemberAbility.fromJson(Map<String, dynamic> json) {
    return MemberAbility(
      guide: json.safeList<String>('guide') ?? [],
      company: json
              .safeList<List<dynamic>>('company')
              ?.map((e) => e.cast<String>())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guide': guide,
      'company': company,
    };
  }
}
