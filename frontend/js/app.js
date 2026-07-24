/* ============================================
   App Entry Point — Vue app initialization
   ============================================ */

// Root shell component
// NOTE: AppTopBar is kept inline due to Vue 3 CDN component resolution pitfall.
// The reference component exists at frontend/js/components/app-topbar.js
// but MUST be inlined here — see [[vue3-cdn-component-pitfall]].
const AppShell = {
  template: `
    <div :class="['app-shell', { 'app-shell--home': showTopBar }]">
      <!-- Top navigation bar (inline — do NOT extract to component) -->
      <header v-if="showTopBar" class="app-topbar safe-top">
        <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="topbar-logo-full" />

        <div class="topbar-nav-group">
          <nav class="topbar-tabs">
            <!-- Left tabs: 首頁 / 城市 / 資訊 -->
            <button
              v-for="tab in leftTabs"
              :key="tab.key"
              :class="['topbar-tab', { active: activeTab === tab.key }]"
              @click="onTabClick(tab)"
            >
              <span>{{ $t(tab.label) }}</span>
            </button>

            <!-- Language Switcher — single button cycles 简/繁/EN -->
            <button class="topbar-lang-btn" @click="nextLang" :title="nextLangLabel">
              {{ currentLangLabel }}
            </button>

            <!-- Right tabs: 消息 / 我的 (icon only) -->
            <button
              v-for="tab in rightTabs"
              :key="tab.key"
              :class="['topbar-tab', 'topbar-tab-icon', { active: activeTab === tab.key }]"
              @click="onTabClick(tab)"
            >
              <!-- Bell icon -->
              <svg v-if="tab.key === 'message'" class="topbar-svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
              </svg>
              <!-- User icon -->
              <svg v-else-if="tab.key === 'mine'" class="topbar-svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
              <span v-if="tab.key === 'message' && unreadCount > 0" class="topbar-tab-badge">
                {{ unreadCount > 99 ? '99+' : unreadCount }}
              </span>
            </button>
          </nav>

          <button class="topbar-search-btn" @click="onSearchClick" :title="$t('搜索')">
            <svg class="topbar-svg" width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"/>
              <path d="m21 21-4.35-4.35"/>
            </svg>
          </button>

          <!-- Auth toggle: login / logout -->
          <button v-if="!UserStore.isLogin" class="topbar-auth-btn" @click="onAuthClick" :title="$t('登錄')">
            <svg class="topbar-svg" width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/>
              <polyline points="10 17 15 12 10 7"/>
              <line x1="15" y1="12" x2="3" y2="12"/>
            </svg>
          </button>
          <button v-else class="topbar-auth-btn topbar-auth-btn--logout" @click="onAuthClick" :title="$t('退出')">
            <svg class="topbar-svg" width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
              <polyline points="16 17 21 12 16 7"/>
              <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
          </button>

          <slot name="topbar-right"></slot>
        </div>
      </header>

      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>

      <!-- Site Footer: compact single row -->
      <footer v-if="showTopBar" class="app-footer">
        <div class="footer-inner">
          <div class="footer-left">
            <span class="footer-copyright">北京路蓦科技有限公司 版权所有 © 2025 <a class="footer-icp" href="https://beian.miit.gov.cn/" target="_blank" rel="noopener noreferrer">ICP备案号:京B2-20261793</a></span>
          </div>
          <div class="footer-right">
            <span class="footer-download-label">{{ $t('下載App') }}</span>
            <a class="footer-badge" href="#/download" title="App Store">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.02.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
            </a>
            <a class="footer-badge" href="#/download" title="Google Play">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M3.609 1.814L13.792 12 3.609 22.186c-.213.213-.35.357-.456.357-.106 0-.153-.05-.153-.153V1.603c0-.1.05-.153.153-.153.106 0 .243.144.456.364zm.971-.814L17.03 10.31c.346.232.52.501.52.807 0 .306-.174.575-.52.807L4.58 22.993c-.42.284-.763.333-1.03.147-.266-.187-.398-.494-.398-.922V1.807c0-.426.132-.727.398-.913.267-.186.61-.137 1.03.106zM19.974 12L14.28 8.67v6.66L19.974 12zm2.127-.752c.42.286.63.633.63 1.043 0 .41-.21.757-.63 1.043l-2.133 1.448-2.14-1.47 2.14-1.47 2.133 1.449v-.043z"/></svg>
            </a>
          </div>
        </div>
      </footer>

      <!-- Cookie Consent Banner -->
      <div v-if="showCookieBanner" class="cookie-banner">
        <div class="cookie-banner-inner">
          <span class="cookie-banner-text">{{ $t('本網站使用Cookie改善體驗，繼續使用即表示您同意') }}
            <a href="/protocol/privacy_protocol" target="_blank" class="cookie-banner-link">{{ $t('隱私政策') }}</a>
          </span>
          <button class="cookie-banner-btn" @click="acceptCookies">{{ $t('同意') }}</button>
        </div>
      </div>
    </div>
  `,

  data() {
    return {
      activeTab: 'home',
      unreadCount: 0,
      showCookieBanner: false,
      tabs: [
        { key: 'home', label: '首頁' },
        { key: 'city', label: '城市' },
        { key: 'news', label: '資訊' },
        { key: 'message', label: '消息', iconOnly: true },
        { key: 'mine', label: '我的', iconOnly: true }
      ],
      langMap: { 'zh-CN': '简', 'zh-TW': '繁', 'en': 'EN' },
      langOrder: ['zh-CN', 'zh-TW', 'en']
    };
  },

  computed: {
    leftTabs() { return this.tabs.slice(0, 3); },
    rightTabs() { return this.tabs.slice(3); },
    currentLangLabel() { return this.langMap[I18n.locale] || '简'; },
    nextLangLabel() {
      const idx = this.langOrder.indexOf(I18n.locale);
      const next = this.langOrder[(idx + 1) % 3];
      return this.langMap[next];
    },

    showTopBar() {
      const hideOn = ['/welcome', '/login', '/register', '/forget-password', '/verify-code', '/password-input'];
      return !hideOn.includes(this.$route.path);
    },

    topBarMode() {
      return 'tabs';
    },

    topBarTitle() {
      return this.$route.meta?.title || '';
    }
  },

  methods: {
    onTabClick(tab) {
      if ((tab.key === 'message' || tab.key === 'mine') && !UserStore.isLogin) {
        this.$router.push('/login');
        return;
      }
      this.activeTab = tab.key;
      const routeMap = {
        home: '/home', city: '/city', news: '/news',
        message: '/message', mine: '/mine'
      };
      this.$router.push(routeMap[tab.key] || '/home');
    },

    onSearchClick() {
      this.$router.push('/search');
    },

    async onAuthClick() {
      if (UserStore.isLogin) {
        await UserStore.logout();
        this.$router.push('/login');
      } else {
        this.$router.push('/login');
      }
    },

    nextLang() {
      const idx = this.langOrder.indexOf(I18n.locale);
      I18n.setLocale(this.langOrder[(idx + 1) % 3]);
    },

    acceptCookies() {
      localStorage.setItem('_cookie_consent', '1');
      this.showCookieBanner = false;
    }
  },

  mounted() {
    this.showCookieBanner = !localStorage.getItem('_cookie_consent');
    const meta = this.$route.meta;
    if (meta && meta.tab) this.activeTab = meta.tab;
  },

  watch: {
    '$route'(to) {
      if (to.meta && to.meta.tab) this.activeTab = to.meta.tab;
    }
  }
};

// Create and mount Vue app
const app = Vue.createApp({
  components: { AppShell, AppHeader, LoadingSpinner, EmptyState },
  template: '<app-shell />'
});

app.use(router);

app.config.globalProperties.t = (key) => I18n.t(key);
app.config.globalProperties.$t = (key) => I18n.t(key); // keep $t for backward compat
app.config.globalProperties.$router = router;
app.config.globalProperties.UserStore = UserStore;
app.config.globalProperties.I18n = I18n;

// Global component registration — required for Vue 3 CDN child route templates
app.component('loading-spinner', LoadingSpinner);
app.component('empty-state', EmptyState);

I18n.init();
UserStore.init();
app.mount('#app');

ConfigStore.fetch();
