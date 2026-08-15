// ignore_for_file: constant_identifier_names

const String STORAGE_IS_FIRST_OPEN_KEY = 'is_first_open';

const String STORAGE_LANGUAGE_CODE_KEY = 'language_code';

const String STORAGE_TOKEN_KEY = 'token';
const String STORAGE_USER_NUMBER_KEY = 'user_number';
const String STORAGE_USER_SIG_KEY = 'user_sig';
const String STORAGE_EXPIRE_TIME_KEY = 'expire_time';
const String STORAGE_USER_INFO_KEY = 'user_info';

const String STORAGE_ACCOUNT_KEY = 'account';
const String STORAGE_PASSWORD_KEY = 'password';
const String STORAGE_REMEMBER_ME_KEY = 'remember_me';

const String STORAGE_CITY_HISTORY_KEY = 'city_history';
const String STORAGE_LAST_LOGIN_RECORD_DATE_KEY = 'last_login_record_date';
const String STORAGE_HOME_DATA_KEY = 'home_data';
const String STORAGE_SYSTEM_LOGO_PATH_KEY = 'system_logo_path';
const String STORAGE_SYSTEM_WELCOME_ZH_PATH_KEY = 'system_welcome_zh_path';
const String STORAGE_SYSTEM_WELCOME_EN_PATH_KEY = 'system_welcome_en_path';

const String STORAGE_JOURNEY_TEMPLATES_KEY = 'journey_templates';
const String STORAGE_JOURNEY_DRAFT_KEY = 'journey_draft';

/// 待處理的深鏈參數（JSON: {code, type, id, ts}），用於未登錄時登錄後恢復跳轉 + 綁定邀請
const String STORAGE_PENDING_DEEP_LINK_KEY = 'pending_deep_link';

/// 冷啟動延遲深鏈是否已檢查過（每次安裝只檢查一次，deferred token 服務端一次性消費）
const String STORAGE_DEEP_LINK_COLD_CHECKED_KEY = 'deep_link_cold_checked';
