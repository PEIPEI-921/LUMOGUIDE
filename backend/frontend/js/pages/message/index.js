/* ============================================
   MessagePage — Message center with categories
   Redesigned 2026-07-06: clean card layout, web-friendly
   ============================================ */

const MessagePage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:12px;padding-bottom:40px">
      <!-- Not Logged In -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding:80px 0">
        <div style="font-size:48px;margin-bottom:16px;opacity:.4"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px;font-size:15px">{{ t('請登錄以查看消息') }}</p>
        <a href="#/login" class="ds-btn ds-btn-primary" style="display:inline-flex;border-radius:100px;padding:10px 32px">
          {{ t('登錄') }}
        </a>
      </div>

      <!-- Loading -->
      <div v-else-if="loading" style="display:flex;justify-content:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <!-- Error -->
      <div v-else-if="error" style="text-align:center;padding:80px 0">
        <div style="font-size:48px;margin-bottom:12px;opacity:.4"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>
        <p style="color:var(--color-secondary-text);font-size:15px;margin-bottom:20px">{{ error }}</p>
        <button @click="fetchMessages" style="font-size:13px;color:var(--color-primary);background:none;border:none;cursor:pointer;font-weight:500">{{ t('重新載入') }}</button>
      </div>

      <!-- Message Categories -->
      <div v-else>
        <div class="h2" style="margin-bottom:20px">{{ t('消息中心') }}</div>

        <div class="card" style="overflow:hidden">
          <div v-for="(item, idx) in messageItems" :key="item.key"
            @click="goItem(item)"
            class="msg-item">

            <!-- Icon -->
            <div class="msg-icon" v-html="item.icon" :style="{ background: item.bg }"></div>

            <!-- Text -->
            <div class="msg-body">
              <div class="title">{{ t(item.title) }}</div>
              <div v-if="item.subtitle" class="preview">{{ item.subtitle }}</div>
            </div>

            <!-- Badge + Arrow -->
            <span v-if="item.count > 0" class="msg-count">
              {{ item.count > 99 ? '99+' : item.count }}
            </span>
            <span class="msg-arrow">›</span>
          </div>
        </div>
      </div>
    </div>
    </div>
  `,

  data() {
    return {
      messageData: null,
      loading: true,
      error: null
    };
  },

  computed: {
    messageItems() {
      const d = this.messageData || {};
      return [
        { key: 'follow', icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="9" cy="7" r="3"/><path d="M1 20v-1a5 5 0 0 1 5-5h6a5 5 0 0 1 5 5v1"/><circle cx="18" cy="7" r="3"/><path d="M23 20v-1a5 5 0 0 0-2.5-4.3"/></svg>', bg: '#EEEDFF', title: '關注信息', subtitle: d.follow_message?.text || '', count: d.follow_my_count || 0, route: '/message/follow' },
        { key: 'evaluate', icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10z"/></svg>', bg: '#E8F5E9', title: '評論信息', subtitle: d.evaluate_message?.text || '', count: d.evaluate_my_count || 0, route: '/message/comments' },
        { key: 'reserve', icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 2H6a1 1 0 0 0-1 1v18a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V8z"/><polyline points="14 2 14 8 20 8"/></svg>', bg: '#FFF3E0', title: '預定信息', subtitle: d.reserve_message?.text || '', count: 0, route: '/message/reserves' },
        { key: 'myReserve', icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M9 2h6a1 1 0 0 1 1 1v1H8V3a1 1 0 0 1 1-1z"/><rect x="4" y="5" width="16" height="17" rx="1"/></svg>', bg: '#E3F2FD', title: '我的預約', subtitle: d.my_reserve_message?.text || '', count: 0, route: '/my-bookings' },
        { key: 'system', icon: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>', bg: '#F3E5F5', title: '系統消息', subtitle: '', count: d.system_count || 0, route: '/message/system' },
      ];
    }
  },

  methods: {
    t(key) { return I18n.t(key); },

    async fetchMessages() {
      if (!UserStore.isLogin) return;
      this.loading = true;
      this.error = null;
      try {
        const res = await ApiProvider.get(ApiUrl.messageList);
        if (res.success) {
          this.messageData = res.data || {};
        } else {
          this.error = res.message || I18n.t('加載失敗');
        }
      } catch (e) {
        this.error = I18n.t('網絡錯誤');
      }
      this.loading = false;
    },

    goItem(item) {
      if (!UserStore.isLogin) { this.$router.push('/login'); return; }
      this.$router.push(item.route);
    }
  },

  mounted() {
    if (UserStore.isLogin) {
      this.fetchMessages();
    } else {
      this.loading = false;
    }
  }
};
