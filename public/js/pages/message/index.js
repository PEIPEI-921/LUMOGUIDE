/* ============================================
   MessagePage — Message center with categories
   Mirrors Flutter MessagePage
   ============================================ */

const MessagePage = {
  template: `
    <div class="page-content">
      <loading-spinner v-if="!messageData && loading" />

      <template v-if="messageData">
        <!-- Message Categories -->
        <div class="card" style="margin:12px;display:flex;flex-direction:column;gap:0;">
          <div v-for="item in messageItems" :key="item.key"
            class="flex items-center justify-between" style="padding:14px 0;border-bottom:0.5px solid var(--color-border);cursor:pointer;"
            @click="goItem(item)">
            <div class="flex items-center gap-sm">
              <span style="font-size:24px;">{{ item.icon }}</span>
              <div>
                <div style="font-size:14px;font-weight:500;">{{ t(item.title) }}</div>
                <div style="font-size:12px;color:var(--color-assistant-text);">{{ item.subtitle || '' }}</div>
              </div>
            </div>
            <div class="flex items-center gap-sm">
              <span v-if="item.count > 0" class="tag tag-red" style="min-width:20px;justify-content:center;">{{ item.count }}</span>
              <span style="color:var(--color-assistant-text);">›</span>
            </div>
          </div>
        </div>
      </template>

      <empty-state v-if="!messageData && !loading" :text="t('請登錄查看消息')" />
    </div>
  `,

  data() {
    return {
      messageData: null,
      loading: false
    };
  },

  computed: {
    messageItems() {
      const d = this.messageData || {};
      return [
        { key: 'follow', icon: '👥', title: '關注信息', subtitle: d.follow_message?.text || '', count: d.follow_my_count || 0, route: '/message/follow' },
        { key: 'evaluate', icon: '💬', title: '評論信息', subtitle: d.evaluate_message?.text || '', count: d.evaluate_my_count || 0, route: '/message/comments' },
        { key: 'reserve', icon: '📋', title: '預定信息', subtitle: d.reserve_message?.text || '', count: 0, route: '/message/reserves' },
        { key: 'myReserve', icon: '📅', title: '預定信息', subtitle: d.my_reserve_message?.text || '', count: 0, route: '/my-bookings' },
        { key: 'system', icon: '📢', title: '系統消息', subtitle: '', count: d.system_count || 0, route: '/message/system' },
      ];
    }
  },

  methods: {
    t(key) { return I18n.t(key); },

    async fetchMessages() {
      if (!UserStore.isLogin) return;
      this.loading = true;
      const res = await ApiProvider.get(ApiUrl.messageList);
      this.loading = false;
      if (res.success) {
        this.messageData = res.data || {};
      }
    },

    goItem(item) {
      if (!UserStore.isLogin) {
        this.$router.push('/login');
        return;
      }
      this.$router.push(item.route);
    }
  },

  mounted() {
    if (UserStore.isLogin) {
      this.fetchMessages();
    }
  }
};
