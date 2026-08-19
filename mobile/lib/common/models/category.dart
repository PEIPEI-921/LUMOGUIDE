import '../extensions/map.dart';

class Category {
  int? id;
  String? name;
  String? icon;
  int? count;
  List<Category> child;

  Category({
    this.id,
    this.name,
    this.icon,
    this.count,
    this.child = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      icon: json.safeString('icon'),
      count: json.safeInt('count'),
      child: json.safeObjectList('child', Category.fromJson) ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'count': count,
      'child': child.map((e) => e.toJson()).toList(),
    };
  }
}
