import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'index.dart';

class MineController extends GetxController with UserStoreMixin {
  List<MineMenu> get menus {
    if (userInfo.isGuide) {
      return [
        MineMenu.city,
        // MineMenu.publishCity,
        MineMenu.myReserve,
        MineMenu.reserveMe,
        MineMenu.publish,
        // MineMenu.fun,
        MineMenu.mall,
        // MineMenu.exchange,
        MineMenu.invite,
        MineMenu.certificate,
        if (!userInfo.inAudit || kDebugMode) MineMenu.vip,
      ];
    }
    if (userInfo.isEnterprise) {
      return [
        MineMenu.reserveMe,
        MineMenu.merchant,
        // MineMenu.fun,
        MineMenu.mall,
        // MineMenu.exchange,
        MineMenu.invite,
        MineMenu.certificate,
        if (!userInfo.inAudit) MineMenu.vip,
      ];
    }
    return [
      // MineMenu.fun,
      MineMenu.mall,
      // MineMenu.exchange,
      MineMenu.invite,
    ];
  }

  String get guideAuthStatusText {
    if (userInfo.guideAuditStatus == 9) {
      return '瞭解更多'.tr;
    } else if (userInfo.guideAuditStatus == 0) {
      return '審核中'.tr;
    } else if (userInfo.guideAuditStatus == 2) {
      return '審核未通過'.tr;
    }
    return '';
  }

  Color get guideAuthStatusColor {
    if (userInfo.guideAuditStatus == 0) {
      return AppColors.yellow;
    } else if (userInfo.guideAuditStatus == 2) {
      return AppColors.red;
    }
    return Colors.white;
  }

  String get enterpriseAuthStatusText {
    if (userInfo.companyAuditStatus == 9) {
      return '去加入'.tr;
    } else if (userInfo.companyAuditStatus == 0) {
      return '審核中'.tr;
    } else if (userInfo.companyAuditStatus == 2) {
      return '審核未通過'.tr;
    }
    return '';
  }

  Color get enterpriseAuthStatusColor {
    if (userInfo.companyAuditStatus == 0) {
      return AppColors.yellow;
    } else if (userInfo.companyAuditStatus == 2) {
      return AppColors.red;
    }
    return Colors.white;
  }

  int unReadCount(MineMenu menu) {
    switch (menu) {
      case MineMenu.reserveMe:
        return userInfo.reserveCount ?? 0;
      case MineMenu.publish:
      case MineMenu.merchant:
        return userInfo.contentRemindCount ?? 0;
      case MineMenu.city:
        return userInfo.cityRemindCount ?? 0;
      default:
        return 0;
    }
  }

  onRefresh() async {
    await reloadUserInfo();
  }

  /// 设置
  onSetting() {
    Get.toNamed(AppRoutes.SETTING);
  }

  /// 编辑用户信息
  onEditUserInfo() async {
    await Get.toNamed(AppRoutes.PROFILE);
    reloadUserInfo();
  }

  /// 延長會籍
  onExtendVip() async {
    Get.toNamed(AppRoutes.MEMBER_CENTER);
  }

  /// 成为Guide
  onToBeGuide() {
    Get.toNamed(AppRoutes.GUIDE_CERTIFICATION);
  }

  /// 成为Merchant
  onToBeMerchant() {
    Get.toNamed(AppRoutes.MERCHANT_ENTRY);
  }

  onMyFollow() {
    Get.toNamed(AppRoutes.FOLLOW, arguments: {'isMyFollow': true});
  }

  onFollowMe() {
    Get.toNamed(AppRoutes.FOLLOW, arguments: {'isMyFollow': false});
  }

  onMenuTap(MineMenu menu) async {
    switch (menu) {
      case MineMenu.fun:
        await Get.toNamed(AppRoutes.MY_INTEGRAL);
        break;
      case MineMenu.mall:
        await Get.toNamed(AppRoutes.INTEGRAL_MALL);
        break;
      case MineMenu.certificate:
        if (userInfo.isGuide) {
          await Get.toNamed(AppRoutes.GUIDE_CERTIFICATION);
        } else {
          await Get.toNamed(AppRoutes.MERCHANT_ENTRY);
        }
        break;
      case MineMenu.invite:
        await Get.toNamed(AppRoutes.INVITE);
        break;
      case MineMenu.exchange:
        await Get.toNamed(AppRoutes.INTEGRAL_EXCHANGE_RECORD);
        break;
      case MineMenu.publish:
        await Get.toNamed(AppRoutes.MY_PUBLISH);
        break;
      case MineMenu.merchant:
        await Get.toNamed(AppRoutes.MERCHANT_MANAGEMENT);
        break;
      case MineMenu.myReserve:
        await Get.toNamed(AppRoutes.USER_BOOKING_MANAGER);
        break;
      case MineMenu.reserveMe:
        if (userInfo.isGuide) {
          await Get.toNamed(AppRoutes.GUIDE_BOOKING_MANAGER);
        } else {
          await Get.toNamed(AppRoutes.MERCHANT_BOOKING_MANAGER);
        }
        break;
      case MineMenu.publishCity:
      // await Get.toNamed(AppRoutes.MY_PUBLISH_CITY);
      // break;
      case MineMenu.city:
        await Get.toNamed(AppRoutes.MY_PUBLISH_CITY);
        break;
      case MineMenu.vip:
        await Get.toNamed(AppRoutes.MEMBER_CENTER);
        break;
      default:
        break;
    }
    onRefresh();
  }
}
