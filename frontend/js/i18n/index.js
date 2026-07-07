/* ============================================
   i18n Translation Service — mirrors Flutter TranslationService
   ============================================ */

const I18n = Vue.reactive({
  // Supported locales
  locales: ['zh-CN', 'zh-TW', 'en'],

  // Translation maps (loaded from locale files via script tags)
  messages: {
    'zh-CN': typeof zhCN !== 'undefined' ? zhCN : {},
    'zh-TW': typeof zhTW !== 'undefined' ? zhTW : {},
    'en': typeof en !== 'undefined' ? en : {},
  },

  // Current locale (reactive)
  _locale: 'zh-CN',

  get locale() {
    return this._locale;
  },

  set locale(val) {
    if (this.locales.includes(val)) {
      this._locale = val;
      Storage.locale = val;
    }
  },

  /**
   * Get translation for a key
   * Falls back to key itself if not found
   */
  t(key) {
    const map = this.messages[this._locale];
    if (map && map[key] !== undefined) {
      return map[key];
    }
    // Fallback to zh-TW (Traditional Chinese) which has identity mapping
    if (this._locale !== 'zh-TW' && this.messages['zh-TW'] && this.messages['zh-TW'][key] !== undefined) {
      return this.messages['zh-TW'][key];
    }
    return key;
  },

  /**
   * Initialize from saved preference or browser language
   */
  init() {
    const saved = Storage.locale;
    if (saved && this.locales.includes(saved)) {
      this._locale = saved;
    } else {
      // Detect browser language
      const navLang = (navigator.language || navigator.userLanguage || '').toLowerCase();
      if (navLang.startsWith('zh-tw') || navLang.startsWith('zh-hk')) {
        this._locale = 'zh-TW';
      } else if (navLang.startsWith('zh')) {
        this._locale = 'zh-CN';
      } else if (navLang.startsWith('en')) {
        this._locale = 'en';
      } else {
        this._locale = 'zh-CN'; // default
      }
      Storage.locale = this._locale;
    }
    return this._locale;
  },

  /**
   * Set locale and persist
   */
  setLocale(locale) {
    if (this.locales.includes(locale)) {
      this._locale = locale;
      Storage.locale = locale;
    }
  }
});
