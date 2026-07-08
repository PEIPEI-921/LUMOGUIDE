/* ============================================
   Storage Utility — localStorage wrapper
   Matches Flutter StorageStone keys
   ============================================ */

const Storage = {
  // --- Auth ---
  get token() { return localStorage.getItem('token') || ''; },
  set token(v) { localStorage.setItem('token', v); },

  get userNumber() { return localStorage.getItem('user_number') || ''; },
  set userNumber(v) { localStorage.setItem('user_number', v); },

  get userSig() { return localStorage.getItem('user_sig') || ''; },
  set userSig(v) { localStorage.setItem('user_sig', v); },

  get expireTime() { return localStorage.getItem('expire_time') || ''; },
  set expireTime(v) { localStorage.setItem('expire_time', v); },

  get userInfo() { return localStorage.getItem('user_info') || ''; },
  set userInfo(v) { localStorage.setItem('user_info', v); },

  // --- Account Remember ---
  get account() { return localStorage.getItem('account') || ''; },
  set account(v) { localStorage.setItem('account', v); },

  get rememberMe() { return localStorage.getItem('remember_me') === '1'; },
  set rememberMe(v) { localStorage.setItem('remember_me', v ? '1' : '0'); },

  get password() { return localStorage.getItem('saved_password') || ''; },
  set password(v) { localStorage.setItem('saved_password', v); },

  // --- Home Data Cache ---
  get homeData() { return localStorage.getItem('home_data') || ''; },
  set homeData(v) { localStorage.setItem('home_data', v); },

  get cityAreaMap() { return localStorage.getItem('city_area_map') || ''; },
  set cityAreaMap(v) { localStorage.setItem('city_area_map', v); },

  // --- Language ---
  get locale() { return localStorage.getItem('locale') || ''; },
  set locale(v) { localStorage.setItem('locale', v); },

  // --- Daily Record ---
  get lastLoginRecordDate() { return localStorage.getItem('last_login_record_date') || ''; },
  set lastLoginRecordDate(v) { localStorage.setItem('last_login_record_date', v); },

  // --- Clear ---

  /** Clear auth session (token expiry / explicit logout) — preserve remember-me */
  clearAuth() {
    ['token', 'user_info', 'user_number', 'user_sig', 'expire_time',
     'last_login_record_date'].forEach(k => localStorage.removeItem(k));
  },

  /** Full logout — clear auth session, keep remember-me credentials */
  logout() {
    this.clearAuth();
    ['home_data', 'city_area_map'].forEach(k => localStorage.removeItem(k));
  },

  /** Clear everything including remember-me (for "uncheck remember + login" or full reset) */
  clearAll() {
    this.logout();
    ['locale', 'account', 'remember_me', 'saved_password', 'rememberMe', 'cityAreaMap']
      .forEach(k => localStorage.removeItem(k));
  }
};
