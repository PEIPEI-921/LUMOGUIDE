/* ============================================
   AppTopBar — 顶部导航栏（浅色，匹配城市攻略背景）[REFERENCE]

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
            :class="['topbar-tab', { active: currentTab === tab.key, 'topbar-tab-icon': tab.iconOnly }]"
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
            <span v-else>{{ $t(tab.label) }}</span>
            <span v-if="tab.key === 'message' && unreadCount > 0" class="topbar-tab-badge">
              {{ unreadCount > 99 ? '99+' : unreadCount }}
            </span>
          </button>
        </nav>

        <button class="topbar-search-btn" @click="$emit('search-click')">
          <svg class="topbar-svg" width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/>
            <path d="m21 21-4.35-4.35"/>
          </svg>
        </button>
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
        { key: 'message', label: '消息', iconOnly: true },
        { key: 'mine',    label: '我的', iconOnly: true }
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
