import 'index.dart';
import '../extensions/map.dart';

class IntegralOrderList {
  int? id;
  String? createdAt;
  String? goodsPicture;
  String? goodsName;
  int? price;

  IntegralOrderList({
    this.id,
    this.createdAt,
    this.goodsPicture,
    this.goodsName,
    this.price,
  });

  factory IntegralOrderList.fromJson(Map<String, dynamic> json) {
    return IntegralOrderList(
      id: json['id'] as int?,
      createdAt: json['created_at'] as String?,
      goodsPicture: json['goods_picture'] as String?,
      goodsName: json['goods_name'] as String?,
      price: json['price'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'goods_picture': goodsPicture,
      'goods_name': goodsName,
      'price': price,
    };
  }
}

class IntegralOrderInfo {
  ShippingAddress? address;
  String? statusStr;
  IntegralGoods? goodsInfo;
  int? price;
  String? freeShipping;
  String? orderSn;
  String? createdAt;
  String? payTime;
  String? expressDeliveryCompany;
  String? expressDeliveryNumber;

  IntegralOrderInfo({
    this.address,
    this.statusStr,
    this.goodsInfo,
    this.price,
    this.freeShipping,
    this.orderSn,
    this.createdAt,
    this.payTime,
    this.expressDeliveryCompany,
    this.expressDeliveryNumber,
  });

  factory IntegralOrderInfo.fromJson(Map<String, dynamic> json) {
    return IntegralOrderInfo(
      address: json.safeObject('address', ShippingAddress.fromJson),
      statusStr: json.safeString('status_str'),
      goodsInfo: json.safeObject('goods_info', IntegralGoods.fromJson),
      price: json.safeInt('price'),
      freeShipping: json.safeString('free_shipping'),
      orderSn: json.safeString('order_sn'),
      createdAt: json.safeString('created_at'),
      payTime: json.safeString('pay_time'),
      expressDeliveryCompany: json.safeString('express_delivery_company'),
      expressDeliveryNumber: json.safeString('express_delivery_number'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address?.toJson(),
      'status_str': statusStr,
      'goods_info': goodsInfo?.toJson(),
      'price': price,
      'free_shipping': freeShipping,
      'order_sn': orderSn,
      'created_at': createdAt,
      'pay_time': payTime,
      'express_delivery_company': expressDeliveryCompany,
      'express_delivery_number': expressDeliveryNumber,
    };
  }
}
