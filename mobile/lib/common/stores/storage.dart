import '../services/storage.dart';
import '../values/storage.dart';

class StorageStone {
  /// token
  static String get token => StorageService.to.getString(STORAGE_TOKEN_KEY);
  static setToken(String value) async {
    await StorageService.to.setString(STORAGE_TOKEN_KEY, value);
  }

  static String get userNumber => StorageService.to.getString(STORAGE_USER_NUMBER_KEY);
  static setUserNumber(String value) async {
    await StorageService.to.setString(STORAGE_USER_NUMBER_KEY, value);
  }

  static String get userSig => StorageService.to.getString(STORAGE_USER_SIG_KEY);
  static setUserSig(String value) async {
    await StorageService.to.setString(STORAGE_USER_SIG_KEY, value);
  }

  /// 过期时间
  static String get expireTime =>
      StorageService.to.getString(STORAGE_EXPIRE_TIME_KEY);
  static setExpireTime(String value) async {
    await StorageService.to.setString(STORAGE_EXPIRE_TIME_KEY, value);
  }

  /// 用户信息
  static String get userInfo =>
      StorageService.to.getString(STORAGE_USER_INFO_KEY);
  static setUserInfo(String value) async {
    await StorageService.to.setString(STORAGE_USER_INFO_KEY, value);
  }

  /// 账号
  static String get account => StorageService.to.getString(STORAGE_ACCOUNT_KEY);
  static setAccount(String value) async {
    await StorageService.to.setString(STORAGE_ACCOUNT_KEY, value);
  }

  /// 密码
  static String get password =>
      StorageService.to.getString(STORAGE_PASSWORD_KEY);
  static setPassword(String value) async {
    await StorageService.to.setString(STORAGE_PASSWORD_KEY, value);
  }

  /// 是否记住密码
  static bool get rememberMe =>
      StorageService.to.getBool(STORAGE_REMEMBER_ME_KEY, defaultValue: false);
  static setRememberMe(bool value) async {
    await StorageService.to.setBool(STORAGE_REMEMBER_ME_KEY, value);
  }

  /// 城市历史
  static String get cityHistory =>
      StorageService.to.getString(STORAGE_CITY_HISTORY_KEY);
  static setCityHistory(String value) async {
    await StorageService.to.setString(STORAGE_CITY_HISTORY_KEY, value);
  }

  /// 上次登录上报日期
  static String get lastLoginRecordDate =>
      StorageService.to.getString(STORAGE_LAST_LOGIN_RECORD_DATE_KEY);
  static setLastLoginRecordDate(String value) async {
    await StorageService.to.setString(
      STORAGE_LAST_LOGIN_RECORD_DATE_KEY,
      value,
    );
  }

  /// 退出登录
  static logout() async {
    await setToken('');
    await setUserInfo('');
    await setExpireTime('');
  }

  /// 首页数据
  static String get homeData =>
      StorageService.to.getString(STORAGE_HOME_DATA_KEY);
  static setHomeData(String value) async {
    await StorageService.to.setString(STORAGE_HOME_DATA_KEY, value);
  }

  /// 系统Logo路径
  static String get systemLogoPath =>
      StorageService.to.getString(STORAGE_SYSTEM_LOGO_PATH_KEY);
  static setSystemLogoPath(String value) async {
    await StorageService.to.setString(STORAGE_SYSTEM_LOGO_PATH_KEY, value);
  }

  /// 系统欢迎图（中文）路径
  static String get systemWelcomeZhPath =>
      StorageService.to.getString(STORAGE_SYSTEM_WELCOME_ZH_PATH_KEY);
  static setSystemWelcomeZhPath(String value) async {
    await StorageService.to.setString(
      STORAGE_SYSTEM_WELCOME_ZH_PATH_KEY,
      value,
    );
  }

  /// 系统欢迎图（英文）路径
  static String get systemWelcomeEnPath =>
      StorageService.to.getString(STORAGE_SYSTEM_WELCOME_EN_PATH_KEY);
  static setSystemWelcomeEnPath(String value) async {
    await StorageService.to.setString(
      STORAGE_SYSTEM_WELCOME_EN_PATH_KEY,
      value,
    );
  }

  /// 待處理的深鏈參數（JSON 字串，詳見 DeepLinkService）
  static String get pendingDeepLink =>
      StorageService.to.getString(STORAGE_PENDING_DEEP_LINK_KEY);
  static setPendingDeepLink(String value) async {
    await StorageService.to.setString(STORAGE_PENDING_DEEP_LINK_KEY, value);
  }

  /// 冷啟動延遲深鏈是否已檢查過（每次安裝只檢查一次）
  static bool get deepLinkColdChecked =>
      StorageService.to.getBool(
        STORAGE_DEEP_LINK_COLD_CHECKED_KEY,
        defaultValue: false,
      );
  static setDeepLinkColdChecked(bool value) async {
    await StorageService.to.setBool(STORAGE_DEEP_LINK_COLD_CHECKED_KEY, value);
  }
}
