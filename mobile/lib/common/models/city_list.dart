import '../extensions/map.dart';

class CityList {
  CityList({
    this.id,
    this.name,
    this.nameEn,
    this.firstPicture,
    this.areaName,
    this.country,
  });

  int? id;
  String? name;
  String? nameEn;
  String? firstPicture;
  String? areaName;
  String? country;

  factory CityList.fromJson(Map<String, dynamic> json) => CityList(
        id: json.safeInt('id'),
        name: json.safeString('name'),
        nameEn: json.safeString('name_en'),
        firstPicture: json.safeString('first_picture'),
        areaName: json.safeString('area_name'),
        country: json.safeString('country_name') ?? json.safeString('country'),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'first_picture': firstPicture,
      'area_name': areaName,
      'country': country,
    };
  }
}
