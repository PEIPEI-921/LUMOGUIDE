import 'package:get/get.dart';

enum SettingList {
  language,
  terms,
  policy,
  password,
  contact,
  feedback,
  clearCache,
  version,
}

extension SettingListExtension on SettingList {
  String get title => switch (this) {
        SettingList.language => '語言切換'.tr,
        SettingList.terms => '用戶協議'.tr,
        SettingList.policy => '隱私政策'.tr,
        SettingList.password => '修改密碼'.tr,
        SettingList.contact => '聯繫我們'.tr,
        SettingList.feedback => '意見反饋'.tr,
        SettingList.clearCache => '清除緩存'.tr,
        SettingList.version => '檢查更新'.tr,
      };

}
