import 'package:lumotrip/common/index.dart';

class CityInfo {
  int? id;
  String? name;
  String? nameEn;
  int? isCapital;
  List<String> pictures;
  String? currency;
  String? language;
  String? population;
  String? race;
  String? overview;
  String? history;

  CityInfo({
    this.id,
    this.name,
    this.nameEn,
    this.isCapital,
    this.pictures = const [],
    this.currency,
    this.language,
    this.population,
    this.race,
    this.overview,
    this.history,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      nameEn: json.safeString('name_en'),
      isCapital: json.safeInt('is_capital'),
      pictures: json.safeList<String>('pictures') ?? [],
      currency: json.safeString('currency'),
      language: json.safeString('language'),
      population: json.safeString('population'),
      race: json.safeString('race'),
      overview: json.safeString('overview'),
      history: json.safeString('history'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'is_capital': isCapital,
      'pictures': pictures,
      'currency': currency,
      'language': language,
      'population': population,
      'race': race,
      'overview': overview,
      'history': history,
    };
  }
}

class CityClass {
  List<Category> type;
  List<Category> guideType;

  CityClass({
    this.type = const [],
    this.guideType = const [],
  });

  factory CityClass.fromJson(Map<String, dynamic> json) {
    return CityClass(
      type: json.safeObjectList('type', Category.fromJson) ?? [],
      guideType: json.safeObjectList('guide_type', Category.fromJson) ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.map((e) => e.toJson()).toList(),
      'guide_type': guideType.map((e) => e.toJson()).toList(),
    };
  }
}
