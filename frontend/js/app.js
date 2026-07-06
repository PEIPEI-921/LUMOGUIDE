/* ============================================
   App Entry Point — Vue app initialization
   ============================================ */

// Root shell component
// NOTE: AppTopBar is kept inline due to Vue 3 CDN component resolution pitfall.
// The reference component exists at frontend/js/components/app-topbar.js
// but MUST be inlined here — see [[vue3-cdn-component-pitfall]].
const AppShell = {
  template: `
    <div class="app-shell">
      <!-- Top navigation bar (inline — do NOT extract to component) -->
      <header v-if="showTopBar" class="app-topbar safe-top">
        <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="topbar-logo-full" />

        <div class="topbar-nav-group">
          <nav class="topbar-tabs">
            <button
              v-for="tab in tabs"
              :key="tab.key"
              :class="['topbar-tab', { active: activeTab === tab.key, 'topbar-tab-icon': tab.icon }]"
              @click="onTabClick(tab)"
            >
              <span v-if="tab.icon">{{ tab.icon }}</span>
              <span v-else>{{ $t(tab.label) }}</span>
              <span v-if="tab.key === 'message' && unreadCount > 0" class="topbar-tab-badge">
                {{ unreadCount > 99 ? '99+' : unreadCount }}
              </span>
            </button>
          </nav>

          <button class="topbar-search-btn" @click="onSearchClick" :title="$t('搜索')">🔍</button>
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
        { key: 'message', label: '消息', icon: '🔔' },
        { key: 'mine', label: '我的', icon: '👤' }
      ]
    };
  },

  computed: {
    showTopBar() {
      const hideOn = ['/welcome', '/login', '/register'];
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
  methods: { $t(key) { return I18n.t(key); } },
  template: '<app-shell />'
});

app.use(router);

app.config.globalProperties.$t = (key) => I18n.t(key);
app.config.globalProperties.$router = router;

app.mount('#app');

UserStore.init();
I18n.init();
ConfigStore.fetch();
