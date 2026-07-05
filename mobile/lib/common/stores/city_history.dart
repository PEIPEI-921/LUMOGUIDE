import 'dart:convert';

import 'package:get/get.dart';

import '../index.dart';

class CityHistoryStore extends GetxController {
  static CityHistoryStore get to => Get.find();
  final cityHistories = <CityHistory>[].obs;

  @override
  void onInit() {
    super.onInit();

    try {
      final cache = StorageStone.cityHistory;
      final list = jsonDecode(cache) as List<dynamic>;
      cityHistories.value = list.map((e) => CityHistory.fromJson(e)).toList();
    } catch (e) {
      cityHistories.value = [];
    }
  }

  addCity(int id, String name) {
    final city = CityHistory(id: id, name: name);
    if (cityHistories.any((e) => e.id == id)) {
      cityHistories.removeWhere((e) => e.id == id);
    }
    cityHistories.insert(0, city);
    StorageStone.setCityHistory(
        jsonEncode(cityHistories.map((e) => e.toJson()).toList()));
  }
}

class CityHistory {
  int id = 0;
  String name = '';

  CityHistory({required this.id, required this.name});

  factory CityHistory.fromJson(Map<String, dynamic> json) {
    return CityHistory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
