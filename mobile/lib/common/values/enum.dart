import 'dart:ui';

import 'package:get/get.dart';

import '../index.dart';

enum PasswordCodeInputType { register, retrieve }

enum CityDetailTab {
  overview,
  guide,
  scenic,
  restaurant,
  mall,
  hotel,
  traffic,
  facility,
  activity,
  ticket,
  all,
}

extension CityDetailTabExt on CityDetailTab {
  String get title {
    switch (this) {
      case CityDetailTab.overview:
        return '概覽'.tr;
      case CityDetailTab.guide:
        return 'LuMo\nGuide'.tr;
      case CityDetailTab.scenic:
        return '景點'.tr;
      case CityDetailTab.restaurant:
        return '餐廳'.tr;
      case CityDetailTab.mall:
        return '購物'.tr;
      case CityDetailTab.hotel:
        return '住宿'.tr;
      case CityDetailTab.traffic:
        return '交通'.tr;
      case CityDetailTab.facility:
        return '設施'.tr;
      case CityDetailTab.activity:
        return '活動'.tr;
      case CityDetailTab.ticket:
        return '票務'.tr;
      case CityDetailTab.all:
        return '全部'.tr;
    }
  }

  String get icon {
    switch (this) {
      case CityDetailTab.overview:
        return Assets.iconCityOverview;
      case CityDetailTab.guide:
        return Assets.iconCityGuide;
      case CityDetailTab.scenic:
        return Assets.iconCityScenic;
      case CityDetailTab.restaurant:
        return Assets.iconCityRestaurant;
      case CityDetailTab.mall:
        return Assets.iconCityMall;
      case CityDetailTab.hotel:
        return Assets.iconCityHotel;
      case CityDetailTab.traffic:
        return Assets.iconCityTraffic;
      case CityDetailTab.facility:
        return Assets.iconCityFacility;
      case CityDetailTab.activity:
        return Assets.iconCityActivity;
      case CityDetailTab.ticket:
        return Assets.iconCityTicket;
      case CityDetailTab.all:
        return '';
    }
  }

  String get iconActive {
    switch (this) {
      case CityDetailTab.overview:
        return Assets.iconCityOverviewS;
      case CityDetailTab.guide:
        return Assets.iconCityGuideS;
      case CityDetailTab.scenic:
        return Assets.iconCityScenicS;
      case CityDetailTab.restaurant:
        return Assets.iconCityRestaurantS;
      case CityDetailTab.mall:
        return Assets.iconCityMallS;
      case CityDetailTab.hotel:
        return Assets.iconCityHotelS;
      case CityDetailTab.traffic:
        return Assets.iconCityTrafficS;
      case CityDetailTab.facility:
        return Assets.iconCityFacilityS;
      case CityDetailTab.activity:
        return Assets.iconCityActivityS;
      case CityDetailTab.ticket:
        return Assets.iconCityTicketS;
      case CityDetailTab.all:
        return '';
    }
  }

  String get homeTitle {
    switch (this) {
      case CityDetailTab.guide:
        return '導遊'.tr;
      case CityDetailTab.overview:
        return '城市'.tr;
      default:
        return title;
    }
  }

  String get homeIcon {
    switch (this) {
      case CityDetailTab.guide:
        return Assets.iconHomeGuide;
      case CityDetailTab.restaurant:
        return Assets.iconHomeRestaurant;
      case CityDetailTab.mall:
        return Assets.iconHomeMall;
      case CityDetailTab.hotel:
        return Assets.iconHomeHotel;
      case CityDetailTab.ticket:
        return Assets.iconHomeTicket;
      case CityDetailTab.scenic:
        return Assets.iconHomeScenic;
      case CityDetailTab.traffic:
        return Assets.iconHomeTraffic;
      case CityDetailTab.facility:
        return Assets.iconHomeFacility;
      case CityDetailTab.activity:
        return Assets.iconHomeActivity;
      case CityDetailTab.all:
        return Assets.iconHomeAll;
      case CityDetailTab.overview:
        return Assets.iconHomeCity;
    }
  }

  Color get homeColor {
    switch (this) {
      case CityDetailTab.guide:
        return const Color(0xFF666FFF);
      case CityDetailTab.restaurant:
        return const Color(0xFFF4B413);
      case CityDetailTab.mall:
        return const Color(0xFFFF6C00);
      case CityDetailTab.hotel:
        return const Color(0xFFA837FF);
      case CityDetailTab.ticket:
        return const Color(0xFF00B4FF);
      case CityDetailTab.scenic:
        return const Color(0xFF00EBC2);
      case CityDetailTab.traffic:
        return const Color(0xFF6695FF);
      case CityDetailTab.facility:
        return const Color(0xFF00D8D5);
      case CityDetailTab.activity:
        return const Color(0xFFFFA921);
      case CityDetailTab.all:
        return const Color(0xFF000000);
      case CityDetailTab.overview:
        return const Color(0xFFFFC466);
    }
  }

  int get id {
    switch (this) {
      case CityDetailTab.scenic:
        return 1;
      case CityDetailTab.restaurant:
        return 2;
      case CityDetailTab.mall:
        return 3;
      case CityDetailTab.hotel:
        return 4;
      case CityDetailTab.traffic:
        return 5;
      case CityDetailTab.facility:
        return 6;
      case CityDetailTab.activity:
        return 7;
      case CityDetailTab.ticket:
        return 8;
      default:
        return 0;
    }
  }

  static CityDetailTab fromId(int id) {
    return CityDetailTab.values.firstWhere(
      (e) => e.id == id,
      orElse: () => CityDetailTab.scenic,
    );
  }
}

enum CityDetailOverviewType { currency, language, population, race }

extension CityDetailOverviewTypeExt on CityDetailOverviewType {
  String get title {
    switch (this) {
      case CityDetailOverviewType.currency:
        return '貨幣'.tr;
      case CityDetailOverviewType.language:
        return '官方語言'.tr;
      case CityDetailOverviewType.population:
        return '人口數量'.tr;
      case CityDetailOverviewType.race:
        return '種族'.tr;
    }
  }

  String get icon {
    switch (this) {
      case CityDetailOverviewType.currency:
        return Assets.iconCityCurrency;
      case CityDetailOverviewType.language:
        return Assets.iconCityLanguage;
      case CityDetailOverviewType.population:
        return Assets.iconCityPopulation;
      case CityDetailOverviewType.race:
        return Assets.iconCityRace;
    }
  }
}

/// 通用详情类型
enum CommonDetailType {
  scenic,
  restaurant,
  shopping,
  hotel,
  traffic,
  facility,
  activity,
  ticket,
}

extension CommonDetailTypeExt on CommonDetailType {
  String get introTitle {
    switch (this) {
      case CommonDetailType.scenic:
      case CommonDetailType.hotel:
      case CommonDetailType.facility:
      case CommonDetailType.ticket:
        return '詳情介紹'.tr;
      case CommonDetailType.restaurant:
        return '本店特色'.tr;
      case CommonDetailType.shopping:
        return '店舖介紹'.tr;
      case CommonDetailType.traffic:
        return '交通介紹'.tr;
      case CommonDetailType.activity:
        return '歷史及介紹'.tr;
    }
  }

  String get reservationText {
    switch (this) {
      case CommonDetailType.scenic:
        return '預約參觀'.tr;
      case CommonDetailType.restaurant:
      case CommonDetailType.ticket:
        return '預約'.tr;
      case CommonDetailType.shopping:
        return '預約進店'.tr;
      case CommonDetailType.hotel:
        return '預約詢價'.tr;
      default:
        return '';
    }
  }

  String get detailTitle {
    switch (this) {
      case CommonDetailType.scenic:
        return '景點詳情'.tr;
      case CommonDetailType.restaurant:
        return '餐廳詳情'.tr;
      case CommonDetailType.shopping:
        return '購物詳情'.tr;
      case CommonDetailType.hotel:
        return '酒店詳情'.tr;
      case CommonDetailType.ticket:
        return '票務詳情'.tr;
      case CommonDetailType.traffic:
        return '交通詳情'.tr;
      case CommonDetailType.facility:
        return '設施詳情'.tr;
      case CommonDetailType.activity:
        return '活動詳情'.tr;
      default:
        return '';
    }
  }

  int get id {
    switch (this) {
      case CommonDetailType.scenic:
        return 1;
      case CommonDetailType.restaurant:
        return 2;
      case CommonDetailType.shopping:
        return 3;
      case CommonDetailType.hotel:
        return 4;
      case CommonDetailType.traffic:
        return 5;
      case CommonDetailType.facility:
        return 6;
      case CommonDetailType.activity:
        return 7;
      case CommonDetailType.ticket:
        return 8;
    }
  }

  static CommonDetailType fromId(int id) {
    return CommonDetailType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => CommonDetailType.scenic,
    );
  }

  // static List<CommonDetailType> get merchantTabs {
  //   return [
  //     CommonDetailType.restaurant,
  //     CommonDetailType.shopping,
  //     CommonDetailType.hotel,
  //     CommonDetailType.traffic,
  //     CommonDetailType.facility,
  //     CommonDetailType.activity,
  //     CommonDetailType.ticket,
  //   ];
  // }
}

/// 导游发布信息类型
enum GuidePublishType {
  attraction, // 景点
  information, // 资讯
  transportation, // 交通
  facility, // 设施
  activity, // 活动
}

extension GuidePublishTypeExt on GuidePublishType {
  String get title {
    switch (this) {
      case GuidePublishType.attraction:
        return '景點'.tr;
      case GuidePublishType.information:
        return '資訊'.tr;
      case GuidePublishType.transportation:
        return '交通'.tr;
      case GuidePublishType.facility:
        return '設施'.tr;
      case GuidePublishType.activity:
        return '活動'.tr;
      default:
        return '';
    }
  }
}

enum GuidePublishEditor { add, edit }

/// 商家店铺类型
enum MerchantShopType { restaurant, shopping, hotel, ticket, scenic }

extension MerchantShopTypeExt on MerchantShopType {
  String get title {
    switch (this) {
      case MerchantShopType.restaurant:
        return '餐廳'.tr;
      case MerchantShopType.shopping:
        return '購物'.tr;
      case MerchantShopType.hotel:
        return '住宿'.tr;
      case MerchantShopType.ticket:
        return '票務'.tr;
      case MerchantShopType.scenic:
        return '景點'.tr;
      default:
        return '';
    }
  }

  int get id {
    switch (this) {
      case MerchantShopType.scenic:
        return 1;
      case MerchantShopType.restaurant:
        return 2;
      case MerchantShopType.shopping:
        return 3;
      case MerchantShopType.hotel:
        return 4;
      case MerchantShopType.ticket:
        return 8;
    }
  }

  String get reservationTitle {
    switch (this) {
      case MerchantShopType.scenic:
        return '景點預約'.tr;
      case MerchantShopType.restaurant:
        return '餐廳預約'.tr;
      case MerchantShopType.shopping:
        return '購物預約'.tr;
      case MerchantShopType.hotel:
        return '酒店預約'.tr;
      case MerchantShopType.ticket:
        return '票務預約'.tr;
      default:
        return '';
    }
  }

  String get reservationTip {
    switch (this) {
      case MerchantShopType.scenic:
        return '預約景點信息'.tr;
      case MerchantShopType.restaurant:
        return '預約餐廳信息'.tr;
      case MerchantShopType.shopping:
        return '預約商家信息'.tr;
      case MerchantShopType.hotel:
        return '預約酒店信息'.tr;
      case MerchantShopType.ticket:
        return '預約票務信息'.tr;
      default:
        return '';
    }
  }

  static MerchantShopType fromId(int id) {
    return MerchantShopType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => MerchantShopType.restaurant,
    );
  }
}

enum UserBookingType { guide, merchant }

extension UserBookingTypeExt on UserBookingType {
  String get title {
    switch (this) {
      case UserBookingType.guide:
        return '導遊'.tr;
      case UserBookingType.merchant:
        return '商家'.tr;
    }
  }
}

enum CalendarMode { day, month, all }

extension CalendarModeExt on CalendarMode {
  String get title {
    switch (this) {
      case CalendarMode.day:
        return '日'.tr;
      case CalendarMode.month:
        return '月'.tr;
      case CalendarMode.all:
        return '全部'.tr;
    }
  }
}
