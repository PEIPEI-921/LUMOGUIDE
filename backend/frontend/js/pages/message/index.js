/* ============================================
   MessagePage — Message center with categories
   Redesigned 2026-07-06: clean card layout, web-friendly
   ============================================ */

const MessagePage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:12px;padding-bottom:40px">
      <!-- Not Logged In -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding:80px 0">
        <div style="font-size:48px;margin-bottom:16px;opacity:.4">🔔</div>
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
        <div style="font-size:48px;margin-bottom:12px;opacity:.4">⚠️</div>
        <p style="color:var(--color-secondary-text);font-size:15px;margin-bottom:20px">{{ error }}</p>
        <button @click="fetchMessages" style="font-size:13px;color:var(--color-primary);background:none;border:none;cursor:pointer;font-weight:500">{{ t('重新載入') }}</button>
      </div>

      <!-- Message Categories -->
      <div v-else>
        <div style="font-family:var(--font-serif);font-size:22px;font-weight:600;letter-spacing:-.01em;margin-bottom:14px;padding-top:8px">
          {{ t('消息中心') }}
        </div>

        <div class="ds-card" style="padding:0;overflow:hidden">
          <a v-for="(item, idx) in messageItems" :key="item.key"
            @click="goItem(item)"
            style="display:flex;align-items:center;gap:14px;padding:16px 18px;text-decoration:none;color:inherit;cursor:pointer;border-bottom:0.5px solid var(--color-border-light)"
            :style="idx === messageItems.length - 1 ? 'border-bottom:none' : ''">

            <!-- Icon -->
            <div :style="{width:'44px',height:'44px',borderRadius:'12px',display:'flex',alignItems:'center',justifyContent:'center',fontSize:'22px',flexShrink:0,background:item.bg}">
              {{ item.icon }}
            </div>

            <!-- Text -->
            <div style="flex:1;min-width:0">
              <div style="font-size:14.5px;font-weight:600;color:var(--color-primary-text)">{{ t(item.title) }}</div>
              <div v-if="item.subtitle" style="font-size:12.5px;color:var(--color-assistant-text);margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.subtitle }}</div>
            </div>

            <!-- Badge + Arrow -->
            <div style="display:flex;align-items:center;gap:8px">
              <span v-if="item.count > 0"
                style="min-width:22px;height:22px;padding:0 7px;border-radius:11px;background:var(--color-red);color:#fff;font-size:11px;font-weight:600;display:inline-flex;align-items:center;justify-content:center">
                {{ item.count > 99 ? '99+' : item.count }}
              </span>
              <span style="color:var(--color-assistant-text);font-size:16px">›</span>
            </div>
          </a>
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
        { key: 'follow', icon: '👥', bg: '#EEEDFF', title: '關注信息', subtitle: d.follow_message?.text || '', count: d.follow_my_count || 0, route: '/message/follow' },
        { key: 'evaluate', icon: '💬', bg: '#E8F5E9', title: '評論信息', subtitle: d.evaluate_message?.text || '', count: d.evaluate_my_count || 0, route: '/message/comments' },
        { key: 'reserve', icon: '📋', bg: '#FFF3E0', title: '預定信息', subtitle: d.reserve_message?.text || '', count: 0, route: '/message/reserves' },
        { key: 'myReserve', icon: '📅', bg: '#E3F2FD', title: '我的預約', subtitle: d.my_reserve_message?.text || '', count: 0, route: '/my-bookings' },
        { key: 'system', icon: '📢', bg: '#F3E5F5', title: '系統消息', subtitle: '', count: d.system_count || 0, route: '/message/system' },
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
          this.error = res.message || this.t('加載失敗');
        }
      } catch (e) {
        this.error = this.t('網絡錯誤');
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
