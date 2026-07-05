import 'dart:ui';

import 'package:get/get.dart';

import '../../common/index.dart';

enum HomeSection {
  city,
  guide,
  merchant,
  information,
}

extension HomeSectionExt on HomeSection {
  String get title {
    switch (this) {
      case HomeSection.city:
        return '熱門城市'.tr;
      case HomeSection.guide:
        return '推薦導遊'.tr;
      case HomeSection.merchant:
        return '推薦商家'.tr;
      case HomeSection.information:
        return '資訊'.tr;
      default:
        return '';
    }
  }

  String get subTitle {
    switch (this) {
      case HomeSection.city:
        return '在路上輕鬆掌握每個城市'.tr;
      case HomeSection.guide:
        return '輕鬆找到專業導遊'.tr;
      case HomeSection.merchant:
        return '輕鬆找到合作商家'.tr;
      case HomeSection.information:
        return '及時瞭解當地咨詢'.tr;
      default:
        return '';
    }
  }
}

enum HomeCityGuideType {
  guide,
  restaurant,
  shopping,
  hotel,
  ticket,
}

extension HomeCityGuideTypeExt on HomeCityGuideType {
  String get title {
    switch (this) {
      case HomeCityGuideType.guide:
        return '導遊'.tr;
      case HomeCityGuideType.restaurant:
        return '餐廳'.tr;
      case HomeCityGuideType.shopping:
        return '購物'.tr;
      case HomeCityGuideType.hotel:
        return '住宿'.tr;
      case HomeCityGuideType.ticket:
        return '門票'.tr;
    }
  }

  String get image {
    switch (this) {
      case HomeCityGuideType.guide:
        return Assets.iconHomeGuide;
      case HomeCityGuideType.restaurant:
        return Assets.iconHomeRestaurant;
      case HomeCityGuideType.hotel:
        return Assets.iconHomeHotel;
      case HomeCityGuideType.ticket:
        return Assets.iconHomeTicket;
      case HomeCityGuideType.shopping:
        return Assets.iconHomeMall;
    }
  }

  Color get bgColor {
    switch (this) {
      case HomeCityGuideType.guide:
        return const Color(0xFF666FFF).withOpacity(0.05);
      case HomeCityGuideType.restaurant:
        return const Color(0xFFF4B413).withOpacity(0.05);
      case HomeCityGuideType.hotel:
        return const Color(0xFFA837FF).withOpacity(0.05);
      case HomeCityGuideType.ticket:
        return const Color(0xFF00B4FF).withOpacity(0.05);
      case HomeCityGuideType.shopping:
        return const Color(0xFFFF6C00).withOpacity(0.05);
    }
  }
}
