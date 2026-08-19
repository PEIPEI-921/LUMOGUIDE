import 'dart:io';

import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:url_launcher/url_launcher.dart';

import 'index.dart';

class SettingController extends GetxController {
  final List<SettingList> items = [
    SettingList.language,
    SettingList.terms,
    SettingList.policy,
    SettingList.password,
    SettingList.contact,
    SettingList.feedback,
    SettingList.clearCache,
    SettingList.version,
  ];

  valueOfItem(SettingList item) {
    switch (item) {
      case SettingList.language:
        return LocalizationService.to.language.text;
      case SettingList.version:
        return 'V${ConfigService.to.version}';
      default:
        return '';
    }
  }

  onItemTap(SettingList item) {
    switch (item) {
      case SettingList.language:
        switchLanguage();
        break;
      case SettingList.policy:
        Get.toNamed(
          AppRoutes.WEB,
          arguments: {
            'url': ConfigService.to.systemConfig.privacyProtocol,
            'title': '隱私政策'.tr,
          },
        );
        break;
      case SettingList.terms:
        Get.toNamed(
          AppRoutes.WEB,
          arguments: {
            'url': ConfigService.to.systemConfig.userProtocol,
            'title': '用戶協議'.tr,
          },
        );
        break;
      case SettingList.password:
        Get.toNamed(AppRoutes.MODIFY_PASSWORD);
        break;
      case SettingList.contact:
        Get.toNamed(AppRoutes.CONTACT_US);
        break;
      case SettingList.feedback:
        Get.toNamed(AppRoutes.FEEDBACK);
        break;
      case SettingList.clearCache:
        clearCache();
        break;
      case SettingList.version:
        checkUpdate();
        break;
    }
  }

  switchLanguage() async {
    final languages = LanguageType.values.toList();
    final res = await ValuePicker.show(
      title: '請選擇語言'.tr,
      datas: languages.map((e) => e.text).toList(),
      selectedDatas: [LocalizationService.to.language.text],
    );
    if (res != null && res.isNotEmpty) {
      LanguageType language = languages.firstWhere((e) => e.text == res.first);
      LocalizationService.to.updateLocate(language.locale);
    }
  }

  clearCache() async {
    await ImageCacheService.to.clearCache();
    Loading.success('清除緩存成功'.tr);
  }

  checkUpdate() async {
    var url = '';
    if (Platform.isAndroid) {
      final appId = ConfigService.to.packName;
      url = 'market://details?id=$appId';
    } else if (Platform.isIOS) {
      url = 'itms-apps://itunes.apple.com/app/id6740724999';
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  logout() async {
    final flag = await AlertUtils.show(
      title: '退出登錄'.tr,
      content: '確定退出登錄嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (flag) {
      await UserStore.to.logout();
    }
  }

  deleteAccount() async {
    final flag = await AlertUtils.show(
      title: '註銷賬號'.tr,
      content: '註銷賬號會將您的數據刪除並且無法找回，確定要註銷賬號嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
      confirmTextColor: AppColors.red,
    );
    if (flag) {
      Loading.show();
      await UserStore.to.deleteAccount();
      Loading.dismiss();
    }
  }
}
