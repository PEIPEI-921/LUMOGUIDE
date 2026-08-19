import '../extensions/map.dart';

class ShippingAddress {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? postCode;
  int isDefault;

  ShippingAddress({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.postCode,
    this.isDefault = 0,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json.safeInt('id'),
      name: json.safeString('name'),
      phone: json.safeString('phone'),
      address: json.safeString('address'),
      postCode: json.safeString('post_code'),
      isDefault: json.safeInt('default') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'post_code': postCode,
      'default': isDefault,
    };
  }
}
