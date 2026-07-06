/* ============================================
   Message Sub Pages (system / follow / comments / reserves)
   Refined 2026-07-06: cleaner headings, empty states, detail modal
   ============================================ */

/* ---- System Messages ---- */
const MessageSystemPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:12px;padding-bottom:40px">
      <div style="font-family:var(--font-serif);font-size:22px;font-weight:600;letter-spacing:-.01em;margin-bottom:14px;padding-top:8px">
        {{ $t('系統消息') }}
      </div>

      <div v-if="loading" class="loading-container" style="padding:60px 0"><div class="spinner"></div></div>

      <div v-else-if="error" class="ds-empty" style="padding:60px 0">
        <p style="margin-bottom:12px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary" style="border-radius:100px">{{ $t('重新載入') }}</button>
      </div>

      <div v-else-if="messages.length === 0" style="text-align:center;padding:60px 0">
        <div style="font-size:48px;margin-bottom:12px;opacity:.3">📢</div>
        <p style="color:var(--color-secondary-text);font-size:14px">{{ $t('暫無系統消息') }}</p>
      </div>

      <div v-else class="ds-msg-list">
        <div v-for="msg in messages" :key="msg.id"
          @click="openDetail(msg)"
          class="ds-msg" :class="{ unread: !msg.is_read }">
          <div class="ds-msg-avatar system">📢</div>
          <div class="ds-msg-body">
            <div class="ds-msg-head">
              <span class="ds-msg-name">{{ msg.title }}</span>
              <span class="ds-msg-tag system">{{ $t('系統') }}</span>
            </div>
            <p class="ds-msg-text">{{ msg.desc || msg.content }}</p>
          </div>
          <span class="ds-msg-time">{{ formatTime(msg.time || msg.created_at) }}</span>
        </div>
      </div>

      <!-- Detail Modal -->
      <div v-if="selectedMsg" style="position:fixed;inset:0;background:rgba(0,0,0,.35);z-index:200;display:flex;align-items:flex-end;justify-content:center"
        @click="selectedMsg = null">
        <div style="background:var(--color-bg-white);border-radius:20px 20px 0 0;width:100%;max-width:480px;max-height:70vh;overflow:auto;padding:24px 22px"
          @click.stop>
          <div style="width:36px;height:4px;border-radius:2px;background:var(--color-border);margin:0 auto 18px"></div>
          <h2 style="font-family:var(--font-serif);font-size:18px;font-weight:600;letter-spacing:-.01em;margin-bottom:8px;line-height:1.4">{{ selectedMsg.title }}</h2>
          <p style="font-size:12px;color:var(--color-assistant-text);margin-bottom:18px">{{ formatTime(selectedMsg.time || selectedMsg.created_at) }}</p>
          <p style="font-size:14px;color:var(--color-primary-text);white-space:pre-wrap;line-height:1.8">{{ selectedMsg.content || selectedMsg.desc }}</p>
          <button @click="selectedMsg = null" class="ds-btn ds-btn-primary" style="margin-top:24px;width:100%;border-radius:100px">
            {{ $t('關閉') }}
          </button>
        </div>
      </div>
    </div>
    </div>
  `,
  data() {
    return { messages: [], loading: true, error: null, selectedMsg: null };
  },
  methods: {
    async load() {
      this.loading = true;
      this.error = null;
      const res = await ApiProvider.get(ApiUrl.messageSystem);
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.messages = Array.isArray(list) ? list : [];
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },
    formatTime(t) { return t ? (t + '').slice(0, 10) : ''; },
    openDetail(msg) { this.selectedMsg = msg; }
  },
  mounted() { this.load(); }
};

/* ---- Follow Notifications ---- */
const MessageFollowPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:12px;padding-bottom:40px">
      <div style="font-family:var(--font-serif);font-size:22px;font-weight:600;letter-spacing:-.01em;margin-bottom:14px;padding-top:8px">
        {{ $t('關注信息') }}
      </div>

      <div v-if="loading" class="loading-container" style="padding:60px 0"><div class="spinner"></div></div>

      <div v-else-if="error" class="ds-empty" style="padding:60px 0">
        <p style="margin-bottom:12px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary" style="border-radius:100px">{{ $t('重新載入') }}</button>
      </div>

      <div v-else-if="messages.length === 0" style="text-align:center;padding:60px 0">
        <div style="font-size:48px;margin-bottom:12px;opacity:.3">❤️</div>
        <p style="color:var(--color-secondary-text);font-size:14px">{{ $t('暫無關注通知') }}</p>
      </div>

      <div v-else class="ds-msg-list">
        <a v-for="msg in messages" :key="msg.id"
          :href="msg.user_id ? '#/guide/' + msg.user_id : '#'"
          class="ds-msg" :class="{ unread: !msg.is_read }">
          <div class="ds-msg-avatar follow">❤️</div>
          <div class="ds-msg-body">
            <div class="ds-msg-head">
              <span class="ds-msg-name">{{ msg.user_name || msg.user_nickname || msg.title }}</span>
              <span class="ds-msg-tag follow">{{ $t('關注') }}</span>
            </div>
            <p class="ds-msg-text">{{ msg.text || msg.content || (msg.user_name ? '關注了你' : '') }}</p>
          </div>
          <span class="ds-msg-time">{{ formatTime(msg.time || msg.created_at) }}</span>
        </a>
      </div>
    </div>
    </div>
  `,
  data() { return { messages: [], loading: true, error: null }; },
  methods: {
    async load() {
      this.loading = true;
      this.error = null;
      const res = await ApiProvider.get(ApiUrl.messageFollowMe, { page: 1, limit: 50 });
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.messages = Array.isArray(list) ? list : [];
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },
    formatTime(t) { return t ? (t + '').slice(0, 10) : ''; }
  },
  mounted() { this.load(); }
};

/* ---- Comment Notifications ---- */
const MessageCommentsPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:12px;padding-bottom:40px">
      <div style="font-family:var(--font-serif);font-size:22px;font-weight:600;letter-spacing:-.01em;margin-bottom:14px;padding-top:8px">
        {{ $t('評論信息') }}
      </div>

      <div v-if="loading" class="loading-container" style="padding:60px 0"><div class="spinner"></div></div>

      <div v-else-if="error" class="ds-empty" style="padding:60px 0">
        <p style="margin-bottom:12px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary" style="border-radius:100px">{{ $t('重新載入') }}</button>
      </div>

      <div v-else-if="messages.length === 0" style="text-align:center;padding:60px 0">
        <div style="font-size:48px;margin-bottom:12px;opacity:.3">⭐</div>
        <p style="color:var(--color-secondary-text);font-size:14px">{{ $t('暫無評論通知') }}</p>
      </div>

      <div v-else class="ds-msg-list">
        <a v-for="msg in messages" :key="msg.id"
          :href="msg.content_id ? '#/news/' + msg.content_id : '#'"
          class="ds-msg" :class="{ unread: !msg.is_read }">
          <div class="ds-msg-avatar evaluate">⭐</div>
          <div class="ds-msg-body">
            <div class="ds-msg-head">
              <span class="ds-msg-name">{{ msg.user_name || msg.user_nickname || msg.title }}</span>
              <span class="ds-msg-tag evaluate">{{ $t('評論') }}</span>
            </div>
            <p class="ds-msg-text">{{ msg.text || msg.content || (msg.user_name ? '評論了你' : '') }}</p>
          </div>
          <span class="ds-msg-time">{{ formatTime(msg.time || msg.created_at) }}</span>
        </a>
      </div>
    </div>
    </div>
  `,
  data() { return { messages: [], loading: true, error: null }; },
  methods: {
    async load() {
      this.loading = true;
      this.error = null;
      const res = await ApiProvider.get(ApiUrl.messageEvaluateMe, { page: 1, limit: 50 });
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.messages = Array.isArray(list) ? list : [];
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },
    formatTime(t) { return t ? (t + '').slice(0, 10) : ''; }
  },
  mounted() { this.load(); }
};

/* ---- Reserve Notifications ---- */
const MessageReservesPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:12px;padding-bottom:40px">
      <div style="font-family:var(--font-serif);font-size:22px;font-weight:600;letter-spacing:-.01em;margin-bottom:14px;padding-top:8px">
        {{ $t('預約信息') }}
      </div>

      <div v-if="loading" class="loading-container" style="padding:60px 0"><div class="spinner"></div></div>

      <div v-else-if="error" class="ds-empty" style="padding:60px 0">
        <p style="margin-bottom:12px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary" style="border-radius:100px">{{ $t('重新載入') }}</button>
      </div>

      <div v-else-if="messages.length === 0" style="text-align:center;padding:60px 0">
        <div style="font-size:48px;margin-bottom:12px;opacity:.3">📋</div>
        <p style="color:var(--color-secondary-text);font-size:14px">{{ $t('暫無預約通知') }}</p>
      </div>

      <div v-else class="ds-msg-list">
        <a v-for="msg in messages" :key="msg.id"
          href="#/my-bookings"
          class="ds-msg" :class="{ unread: !msg.is_read }">
          <div class="ds-msg-avatar reserve">📋</div>
          <div class="ds-msg-body">
            <div class="ds-msg-head">
              <span class="ds-msg-name">{{ msg.user_name || msg.title }}</span>
              <span class="ds-msg-tag reserve">{{ $t('預約') }}</span>
            </div>
            <p class="ds-msg-text">{{ msg.text || msg.content || (msg.user_name ? '向你發起了預約' : '') }}</p>
          </div>
          <span class="ds-msg-time">{{ formatTime(msg.time || msg.created_at) }}</span>
        </a>
      </div>
    </div>
    </div>
  `,
  data() { return { messages: [], loading: true, error: null }; },
  methods: {
    async load() {
      this.loading = true;
      this.error = null;
      const res = await ApiProvider.get(ApiUrl.messageList, { type: 'reserve', page: 1, limit: 50 });
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.messages = Array.isArray(list) ? list : [];
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },
    formatTime(t) { return t ? (t + '').slice(0, 10) : ''; }
  },
  mounted() { this.load(); }
};
