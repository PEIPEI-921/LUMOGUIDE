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
    </div>
  `,

  data() {
    return {
      activeTab: 'home',
      unreadCount: 0,
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
    }
  },

  mounted() {
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
