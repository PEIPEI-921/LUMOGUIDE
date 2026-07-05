import 'package:get/get.dart';
import 'package:lumotrip/common/values/index.dart';

enum MineMenu {
  fun,
  mall,
  exchange,
  invite,
  city,
  publishCity,
  myReserve,
  reserveMe,
  publish,
  certificate,
  merchant,
  vip,
}

extension MineMenuExt on MineMenu {
  String get title {
    switch (this) {
      case MineMenu.fun:
        return 'LuMoFun'.tr;
      case MineMenu.mall:
        return 'Fun商城'.tr;
      case MineMenu.exchange:
        return '兌換紀錄'.tr;
      case MineMenu.invite:
        return '邀請'.tr;
      case MineMenu.city:
        return '城市'.tr;
      case MineMenu.publishCity:
        return '發布城市'.tr;
      case MineMenu.myReserve:
        return '我的預約'.tr;
      case MineMenu.reserveMe:
        return '預約我的'.tr;
      case MineMenu.publish:
        return '發布'.tr;
      case MineMenu.certificate:
        return '認證資料'.tr;
      case MineMenu.merchant:
        return '商家管理'.tr;
      case MineMenu.vip:
        return '會員中心'.tr;
    }
  }

  String get icon {
    switch (this) {
      case MineMenu.fun:
        return Assets.iconAccountMenuFun;
      case MineMenu.mall:
        return Assets.iconAccountMenuMall;
      case MineMenu.exchange:
        return Assets.iconAccountMenuExchange;
      case MineMenu.invite:
        return Assets.iconAccountMenuInvite;
      case MineMenu.city:
        return Assets.iconAccountMenuCity;
      case MineMenu.publishCity:
        return Assets.iconAccountMenuCity;
      case MineMenu.myReserve:
        return Assets.iconAccountMenuReserveMe;
      case MineMenu.reserveMe:
        return Assets.iconAccountMenuMyReserve;
      case MineMenu.publish:
        return Assets.iconAccountMenuCircleStar;
      case MineMenu.certificate:
        return Assets.iconAccountMenuCertification;
      case MineMenu.merchant:
        return Assets.iconAccountMenuCircleStar;
      case MineMenu.vip:
        return Assets.iconAccountMenuCircleStar;
    }
  }
}
