import '../extensions/map.dart';

class IntegralGoods {
  int? id;
  String? picture;
  String? name;
  int? price;

  List<String> pictures;
  String? freeShipping;
  int? sales;
  String? content;

  /// 1实体商品/2虚拟商品
  int? goodsType;

  IntegralGoods({
    this.id,
    this.picture,
    this.name,
    this.price,
    this.pictures = const [],
    this.freeShipping,
    this.sales,
    this.content,
    this.goodsType,
  });

  factory IntegralGoods.fromJson(Map<String, dynamic> json) {
    return IntegralGoods(
      id: json.safeInt('id'),
      picture: json.safeString('picture'),
      name: json.safeString('name'),
      price: json.safeInt('price'),
      pictures: json.safeList<String>('pictures') ?? [],
      freeShipping: json.safeString('free_shipping'),
      sales: json.safeInt('sales'),
      content: json.safeString('content'),
      goodsType: json.safeInt('goods_type'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'picture': picture,
      'name': name,
      'price': price,
      'pictures': pictures,
      'free_shipping': freeShipping,
      'sales': sales,
      'content': content,
      'goods_type': goodsType,
    };
  }
}
