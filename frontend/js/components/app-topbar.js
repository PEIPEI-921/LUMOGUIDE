/* ============================================
   AppTopBar — 顶部导航栏（主色 indigo）[REFERENCE]

   ⚠️ NOT USED at runtime. Due to Vue 3 CDN component
   resolution pitfall, the template is inlined directly
   in app.js AppShell. This file is kept as a reference
   for the component's props/events/slots contract.

   See [[vue3-cdn-component-pitfall]] in memory.
   ============================================ */

const AppTopBar = {
  template: `
    <header class="app-topbar safe-top">
      <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="topbar-logo-full" />

      <div class="topbar-nav-group">
        <nav class="topbar-tabs">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            :class="['topbar-tab', { active: currentTab === tab.key, 'topbar-tab-icon': tab.icon }]"
            @click="onTabClick(tab)"
          >
            <span v-if="tab.icon">{{ tab.icon }}</span>
            <span v-else>{{ $t(tab.label) }}</span>
            <span v-if="tab.key === 'message' && unreadCount > 0" class="topbar-tab-badge">
              {{ unreadCount > 99 ? '99+' : unreadCount }}
            </span>
          </button>
        </nav>

        <button class="topbar-search-btn" @click="$emit('search-click')">🔍</button>
        <slot name="right"></slot>
      </div>
    </header>
  `,

  props: {
    currentTab: { type: String, default: 'home' },
    unreadCount:{ type: Number, default: 0 }
  },

  emits: ['tab-change', 'search-click'],

  data() {
    return {
      tabs: [
        { key: 'home',    label: '首頁' },
        { key: 'city',    label: '城市' },
        { key: 'news',    label: '資訊' },
        { key: 'message', label: '消息', icon: '🔔' },
        { key: 'mine',    label: '我的', icon: '👤' }
      ]
    };
  },

  methods: {
    onTabClick(tab) {
      if ((tab.key === 'message' || tab.key === 'mine') && !UserStore.isLogin) {
        this.$router.push('/login');
        return;
      }
      this.$emit('tab-change', tab.key);
    }
  }
};
