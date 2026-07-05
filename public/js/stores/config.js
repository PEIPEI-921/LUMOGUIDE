/* ============================================
   ConfigStore — system config cache
   Mirrors Flutter ConfigService + systemConfig()
   ============================================ */

const ConfigStore = Vue.reactive({
  // System config values
  data: {},

  // Whether config has been loaded
  loaded: false,

  // Loading state
  loading: false,

  /** Fetch system config from API */
  async fetch() {
    if (this.loaded || this.loading) return;
    this.loading = true;
    const res = await ApiProvider.get(ApiUrl.config);
    this.loading = false;
    if (res.success) {
      this.data = res.data || {};
      this.loaded = true;
    }
  },

  /** Get a specific config value by key */
  get(key, defaultVal = '') {
    return this.data[key] !== undefined ? this.data[key] : defaultVal;
  }
});
