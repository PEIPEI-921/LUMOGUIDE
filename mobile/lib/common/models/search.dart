import 'package:lumotrip/common/index.dart';

class SearchHomeList {
  int? id;
  String? name;
  String? nameEn;
  String? firstPicture;
  String? tag;
  int? typeId;
  int? cityId;

  /// 数据类型 1城市/2导游/3内容
  int? dataType;

  String? cityName;
  String? typeName;
  List<String> language;

  SearchHomeList({
    this.id,
    this.name,
    this.nameEn,
    this.firstPicture,
    this.typeId,
    this.cityId,
    this.tag,
    this.dataType,
    this.cityName,
    this.typeName,
    this.language = const [],
  });

  factory SearchHomeList.fromJson(Map<String, dynamic> json) => SearchHomeList(
    id: json.safeInt('id'),
    name: json.safeString('name'),
    nameEn: json.safeString('name_en'),
    firstPicture: json.safeString('first_picture'),
    tag: json.safeString('tag'),
    typeId: json.safeInt('type_id'),
    cityId: json.safeInt('city_id'),
    dataType: json.safeInt('data_type'),
    cityName: json.safeString('city_name'),
    typeName: json.safeString('type_name'),
    language: json.safeList<String>('language') ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_en': nameEn,
    'first_picture': firstPicture,
    'tag': tag,
    'type_id': typeId,
    'city_id': cityId,
    'data_type': dataType,
    'city_name': cityName,
    'type_name': typeName,
    'language': language,
  };
}

class SearchSectionModel {
  int? id;
  String? name;
  List<SearchSectionItem> data;

  SearchSectionModel({this.id, this.name, this.data = const []});

  factory SearchSectionModel.fromJson(Map<String, dynamic> json) =>
      SearchSectionModel(
        id: json.safeInt('id'),
        name: json.safeString('name'),
        data: json.safeObjectList('data', SearchSectionItem.fromJson) ?? [],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class SearchSectionItem {
  int? id;
  String? name;
  String? nameEn;
  String? firstPicture;
  String? tag;
  List<String>? language;
  String? cityName;

  /// 数据类型 1城市/2导游/3内容
  int? dataType;
  int? cityId;
  int? typeId;
  /// 类型名称
  String? typeName;

  String? phone;

  /// 开放时间
  String? startTime;
  String? endTime;

  /// 门票
  String? ticketsFree;

  /// 评价数量
  int? evaluateCount;

  String? address;

  SearchSectionItem({
    this.id,
    this.name,
    this.nameEn,
    this.firstPicture,
    this.tag,
    this.dataType,
    this.cityId,
    this.typeId,
    this.language,
    this.phone,
    this.cityName,
    this.startTime,
    this.endTime,
    this.ticketsFree,
    this.evaluateCount,
    this.address,
    this.typeName,
  });

  factory SearchSectionItem.fromJson(Map<String, dynamic> json) =>
      SearchSectionItem(
        id: json.safeInt('id'),
        name: json.safeString('name'),
        nameEn: json.safeString('name_en'),
        firstPicture: json.safeString('first_picture'),
        tag: json.safeString('tag'),
        dataType: json.safeInt('data_type'),
        cityId: json.safeInt('city_id'),
        typeId: json.safeInt('type_id'),
        language: json.safeList<String>('language') ?? [],
        phone: json.safeString('phone'),
        cityName: json.safeString('city_name'),
        startTime: json.safeString('start_time'),
        endTime: json.safeString('end_time'),
        ticketsFree: json.safeString('tickets_free'),
        evaluateCount: json.safeInt('evaluate_count'),
        address: json.safeString('address'),
        typeName: json.safeString('type_name'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_en': nameEn,
    'first_picture': firstPicture,
    'tag': tag,
    'data_type': dataType,
    'city_id': cityId,
    'type_id': typeId,
    'language': language,
    'phone': phone,
    'city_name': cityName,
    'start_time': startTime,
    'end_time': endTime,
    'tickets_free': ticketsFree,
    'evaluate_count': evaluateCount,
    'address': address,
    'type_name': typeName,
  };
}
