/* ============================================
   Message Sub Pages (system / follow / comments / reserves)
   Refined 2026-07-06: cleaner headings, empty states, detail modal
   ============================================ */

/* ---- System Messages ---- */
const MessageSystemPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:8px;padding-bottom:40px">
      <div style="font-size:17px;font-weight:700;color:var(--color-primary-text);margin-bottom:16px;padding-top:8px">
        {{ $t('系統消息') }}
      </div>

      <div v-if="loading" style="text-align:center;padding:80px 0"><div class="spinner"></div></div>

      <div v-else-if="error" style="text-align:center;padding:80px 0">
        <p style="margin-bottom:14px;color:var(--color-secondary-text);font-size:14px">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary" style="border-radius:100px;padding:8px 24px;font-size:13px">{{ $t('重新載入') }}</button>
      </div>

      <div v-else-if="messages.length === 0" style="text-align:center;padding:80px 0">
        <p style="color:var(--color-secondary-text);font-size:14px">{{ $t('暫無系統消息') }}</p>
      </div>

      <!-- Message list — white card container for solid background -->
      <div v-else style="background:var(--color-bg-white);border-radius:14px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,.04)">
        <div v-for="msg in messages" :key="msg.id"
          @click="openDetail(msg)"
          :style="{display:'flex',alignItems:'flex-start',gap:'14px',padding:'16px 18px',cursor:'pointer',background: !msg.is_read ? '#FAFAFF' : '#fff',borderBottom:'1px solid',borderColor: 'var(--color-border-light)'}">
          <!-- Content -->
          <div style="flex:1;min-width:0">
            <div :style="{fontSize:'14px',fontWeight: !msg.is_read ? 600 : 400,color:'var(--color-primary-text)',lineHeight:1.4,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}">
              <span v-if="!msg.is_read" style="display:inline-block;width:7px;height:7px;border-radius:50%;background:var(--color-primary);margin-right:8px;vertical-align:2px"></span>
              {{ msg.title }}
            </div>
            <div style="font-size:13px;color:var(--color-secondary-text);line-height:1.5;margin-top:4px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">
              {{ stripBrackets(msg.desc || msg.content) }}
            </div>
          </div>
          <!-- Time -->
          <div style="font-size:12px;color:var(--color-assistant-text);white-space:nowrap;padding-top:2px;flex-shrink:0">
            {{ formatTime(msg.time || msg.created_at) }}
          </div>
        </div>
      </div>

      <!-- Detail Modal -->
      <transition name="fade">
      <div v-if="selectedMsg" style="position:fixed;inset:0;background:rgba(0,0,0,.3);z-index:200;display:flex;align-items:center;justify-content:center;padding:24px"
        @click="selectedMsg = null">
        <div style="background:#fff;border-radius:16px;width:100%;max-width:440px;max-height:70vh;overflow:auto;padding:24px 22px"
          @click.stop>
          <h2 style="font-size:17px;font-weight:700;color:var(--color-primary-text);margin:0 0 8px;line-height:1.4">{{ selectedMsg.title }}</h2>
          <p style="font-size:13px;color:var(--color-secondary-text);margin:0 0 18px">{{ formatTime(selectedMsg.time || selectedMsg.created_at) }}</p>
          <p style="font-size:15px;color:var(--color-primary-text);white-space:pre-wrap;line-height:1.85;margin:0" v-html="renderContent(selectedMsg)"></p>
          <button @click="selectedMsg = null"
            style="margin-top:22px;width:100%;padding:12px 0;border-radius:100px;border:none;background:var(--color-primary-text);color:#fff;font-size:14px;font-weight:600;cursor:pointer">
            {{ $t('關閉') }}
          </button>
        </div>
      </div>
      </transition>
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
    openDetail(msg) { this.selectedMsg = msg; msg.is_read = 1; },
    stripBrackets(text) {
      if (!text) return '';
      return String(text).replace(/[（]/g, '').replace(/[）]/g, '');
    },
    renderContent(msg) {
      const text = msg.content || msg.desc || '';
      if (!text) return '';
      // For city messages with city_id, make bracketed city name clickable
      if (msg.content_type === 'city' && msg.city_id > 0) {
        return String(text).replace(/（([^）]+)）/, function(match, name) {
          return '<a href=\"#/city/detail?id=' + msg.city_id + '\" style=\"color:#8B5CF6;font-weight:600;text-decoration:none\">' + name + '</a>';
        });
      }
      // For city_content messages with IDs, make bracketed names clickable
      if (msg.content_type === 'city_content' && msg.city_id > 0 && msg.content_id > 0) {
        let idx = 0;
        return String(text).replace(/（[^）]+）/g, function(match) {
          idx++;
          const name = match.slice(1, -1); // remove （）
          if (idx === 1) {
            // City name — link to city detail
            return '<a href=\"#/city/detail?id=' + msg.city_id + '\" style=\"color:#8B5CF6;font-weight:600;text-decoration:none\">' + name + '</a>';
          }
          if (idx === 3) {
            // Content name — link to content detail
            return '<a href=\"#/detail/city_content?id=' + msg.content_id + '&type_id=' + (msg.city_content_type || 1) + '&city_id=' + msg.city_id + '\" style=\"color:#8B5CF6;font-weight:600;text-decoration:none\">' + name + '</a>';
          }
          // Type name (idx === 2) — strip brackets, no link
          return name;
        });
      }
      // For other message types, just strip brackets
      return this.stripBrackets(text);
    }
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
