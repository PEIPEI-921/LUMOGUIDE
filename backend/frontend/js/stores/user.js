/* ============================================
   UserStore — mirrors Flutter UserStore
   Auth state management, token, profile
   ============================================ */

const UserStore = Vue.reactive({
  // --- State ---
  token: Storage.token,
  userNumber: Storage.userNumber,
  userSig: Storage.userSig,
  userInfo: null,      // parsed from localStorage on init

  // --- Computed-style getters ---
  get isLogin() {
    return !!this.token;
  },

  get profile() {
    return this.userInfo || {};
  },

  get isGuide() {
    return Number(this.userInfo?.identity) === 2;
  },

  get isEnterprise() {
    return Number(this.userInfo?.identity) === 3;
  },

  get isUser() {
    return Number(this.userInfo?.identity) === 1;
  },

  get isVip() {
    const info = this.userInfo;
    if (!info) return false;
    const paidVip = info.vip_type > 0 && info.vip_expiration_time > 0;
    const freeVip = info.vip_free === 1 && info.vip_free_day > 0;
    return paidVip || freeVip;
  },

  get isPaidVip() {
    const info = this.userInfo;
    return info && info.vip_type > 0 && info.vip_expiration_time > 0;
  },

  get isFreeVip() {
    const info = this.userInfo;
    return info && info.vip_free === 1 && info.vip_free_day > 0;
  },

  get showGuideAuth() {
    const info = this.userInfo;
    if (!info) return false;
    return info.identity === 1 && info.guide_audit_status !== 1 && info.company_audit_status === 9;
  },

  get showEnterpriseAuth() {
    const info = this.userInfo;
    if (!info) return false;
    return info.identity === 1 && info.company_audit_status !== 1 && info.guide_audit_status === 9;
  },

  // --- Actions ---

  /** Initialize from localStorage on app start */
  init() {
    const infoStr = Storage.userInfo;
    if (infoStr) {
      try {
        this.userInfo = JSON.parse(infoStr);
      } catch (e) {
        this.userInfo = null;
      }
    }
    return this.isLogin;
  },

  /** Fetch user profile from API */
  async getProfile() {
    if (!this.isLogin) return false;
    const res = await ApiProvider.get(ApiUrl.userIndex);
    if (!res.success) return false;
    this.userInfo = res.data;
    Storage.userInfo = JSON.stringify(res.data);
    return true;
  },

  /** Login — store credentials and fetch profile */
  async login(responseData) {
    this.token = responseData.token || '';
    this.userNumber = responseData.user_number || '';
    this.userSig = responseData.user_sig || '';

    Storage.token = this.token;
    Storage.userNumber = this.userNumber;
    Storage.userSig = this.userSig;

    await this.getProfile();

    // Upload daily login record
    this._uploadLoginRecord();

    return true;
  },

  /** Modify profile fields */
  async modifyProfile(data) {
    const res = await ApiProvider.post(ApiUrl.editUserInfo, data);
    if (!res.success) return false;
    await this.getProfile();
    return true;
  },

  /** Logout — clear all state */
  async logout() {
    Storage.logout();
    this.token = '';
    this.userNumber = '';
    this.userSig = '';
    this.userInfo = null;
  },

  /** Delete account */
  async deleteAccount() {
    const res = await ApiProvider.post(ApiUrl.deleteUser, {});
    if (!res.success) return false;
    await this.logout();
    return true;
  },

  /** Daily login record upload (once per day) */
  async _uploadLoginRecord() {
    const today = new Date().toISOString().slice(0, 10);
    if (Storage.lastLoginRecordDate === today) return;
    try {
      const res = await ApiProvider.get(ApiUrl.userRecord);
      if (res.success) {
        Storage.lastLoginRecordDate = today;
      }
    } catch (e) {
      // Silently ignore
    }
  },

  /** Remember login credentials (email only — never store password) */
  saveCredentials(email, remember) {
    if (remember) {
      Storage.account = email;
      Storage.rememberMe = true;
    } else {
      Storage.account = '';
      Storage.rememberMe = false;
    }
  },

  /** Load saved credentials */
  getCredentials() {
    if (Storage.rememberMe) {
      return {
        email: Storage.account,
        password: '',
        remember: true
      };
    }
    return { email: '', password: '', remember: false };
  }
});
