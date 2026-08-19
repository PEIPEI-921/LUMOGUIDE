/* ============================================
   AppNav — Bottom Tab Navigation (5 tabs)
   Mirrors Flutter RootPage bottom bar
   ============================================ */

const AppNav = {
  template: `
    <nav class="tab-nav">
      <div
        v-for="tab in tabs"
        :key="tab.key"
        class="tab-item"
        :class="{ active: currentTab === tab.key }"
        @click="onTabClick(tab)"
      >
        <span class="tab-icon">{{ currentTab === tab.key ? tab.iconActive : tab.icon }}</span>
        <span>{{ $t(tab.label) }}</span>
        <span v-if="tab.key === 'message' && unreadCount > 0" class="tab-badge">
          {{ unreadCount > 99 ? '99+' : unreadCount }}
        </span>
      </div>
    </nav>
  `,

  props: {
    currentTab: { type: String, default: 'home' },
    unreadCount: { type: Number, default: 0 }
  },

  setup(props, { emit }) {
    const tabs = [
      {
        key: 'home',
        label: '首頁',
        icon: '🏠',
        iconActive: '🏠',
        route: '/home'
      },
      {
        key: 'city',
        label: '城市',
        icon: '🏙️',
        iconActive: '🏙️',
        route: '/city'
      },
      {
        key: 'news',
        label: '資訊',
        icon: '📰',
        iconActive: '📰',
        route: '/news'
      },
      {
        key: 'message',
        label: '消息',
        icon: '💬',
        iconActive: '💬',
        route: '/message'
      },
      {
        key: 'mine',
        label: '我的',
        icon: '👤',
        iconActive: '👤',
        route: '/mine'
      }
    ];

    function onTabClick(tab) {
      // Check auth for message and mine tabs
      if ((tab.key === 'message' || tab.key === 'mine') && !UserStore.isLogin) {
        emit('require-login');
        return;
      }
      emit('tab-change', tab.key);
    }

    return { tabs, onTabClick };
  }
};
