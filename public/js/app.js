/* ============================================
   App Entry Point — Vue app initialization
   ============================================ */

// Root shell component
const AppShell = {
  template: `
    <div class="app-shell">
      <!-- Page content -->
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>

      <!-- Bottom Tab Navigation (shown on tab routes) -->
      <app-nav
        v-if="showTabBar"
        :current-tab="activeTab"
        :unread-count="unreadCount"
        @tab-change="onTabChange"
        @require-login="goLogin"
      />
    </div>
  `,

  data() {
    return {
      activeTab: 'home',
      unreadCount: 0
    };
  },

  computed: {
    showTabBar() {
      const tabRoutes = ['home', 'city', 'news', 'message', 'mine'];
      const currentRoute = this.$route.name || '';
      // Simple check: show tab bar for main tab routes
      const path = this.$route.path;
      return tabRoutes.some(t => path === '/' + t || path.startsWith('/' + t) && path.split('/').length === 2);
    }
  },

  methods: {
    onTabChange(tab) {
      this.activeTab = tab;
      const routeMap = {
        home: '/home',
        city: '/city',
        news: '/news',
        message: '/message',
        mine: '/mine'
      };
      this.$router.push(routeMap[tab] || '/home');
    },

    goLogin() {
      this.$router.push('/login');
    }
  },

  mounted() {
    // Set initial active tab from route
    const meta = this.$route.meta;
    if (meta && meta.tab) {
      this.activeTab = meta.tab;
    }
  }
};

// Create and mount Vue app
const app = Vue.createApp({
  components: {
    AppShell,
    AppNav,
    AppHeader,
    LoadingSpinner,
    EmptyState
  },

  // Global i18n helper
  methods: {
    $t(key) {
      return I18n.t(key);
    }
  },

  template: '<app-shell />'
});

// Install router
app.use(router);

// Global properties
app.config.globalProperties.$t = (key) => I18n.t(key);
app.config.globalProperties.$router = router;

// Mount
app.mount('#app');

// Init stores
UserStore.init();
I18n.init();
ConfigStore.fetch();
