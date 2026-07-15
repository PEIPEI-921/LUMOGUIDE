/* ============================================
   Mine Extra Pages — 设置 / 反馈 / 客服 / 邀请 /
   粉丝 / 关注 / 评价 / 预约 / 修改密码 / 修改手机
   ============================================ */

/* ---- Settings ---- */
const SettingsPage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-menu-group">
        <div class="ds-menu-group-title">{{ $t('語言') }}</div>
        <div class="ds-menu-item" style="cursor:pointer" @click="switchLang('zh-CN')">
          <span>🇨🇳 简体中文</span>
          <span v-if="currentLang === 'zh-CN'" style="color:var(--color-primary);font-size:12px">✓</span>
        </div>
        <div class="ds-menu-item" style="cursor:pointer" @click="switchLang('zh-TW')">
          <span>🇹🇼 繁體中文</span>
          <span v-if="currentLang === 'zh-TW'" style="color:var(--color-primary);font-size:12px">✓</span>
        </div>
        <div class="ds-menu-item" style="cursor:pointer" @click="switchLang('en')">
          <span>🇺🇸 English</span>
          <span v-if="currentLang === 'en'" style="color:var(--color-primary);font-size:12px">✓</span>
        </div>
      </div>

      <div class="ds-menu-group">
        <a href="#/contact" class="ds-menu-item">
          <span><span v-html="I.phoneCall" style="font-size:18px;vertical-align:-4px;margin-right:2px"></span> {{ $t('聯繫客服') }}</span>
          <span class="ds-menu-arrow">›</span>
        </a>
        <a href="#/feedback" class="ds-menu-item">
          <span><span v-html="I.chat" style="font-size:18px;vertical-align:-4px;margin-right:2px"></span> {{ $t('意見反饋') }}</span>
          <span class="ds-menu-arrow">›</span>
        </a>
      </div>

      <div class="ds-menu-group">
        <div class="ds-menu-item" style="cursor:pointer;color:var(--color-red)" @click="clearCache">
          <span><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-4px;margin-right:2px"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg> {{ $t('清除緩存') }}</span>
        </div>
      </div>
    </div>
    </div>
  `,
  data() {
    return { currentLang: I18n.locale || 'zh-TW', I };
  },
  methods: {
    switchLang(locale) {
      I18n.setLocale(locale);
      this.currentLang = locale;
      showToast($t ? $t('語言已切換') : 'Language changed');
    },
    clearCache() {
      if (confirm($t ? $t('確定清除緩存？') : 'Clear cache?')) {
        localStorage.clear();
        location.reload();
      }
    }
  }
};


/* ---- Modify Password ---- */
const ModifyPasswordPage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('修改密碼') }}</h1>
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('當前密碼') }}</label>
        <input v-model="oldPwd" type="password" class="ds-input" :placeholder="$t('請輸入當前密碼')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('新密碼') }}</label>
        <input v-model="newPwd" type="password" class="ds-input" :placeholder="$t('請輸入新密碼')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('確認密碼') }}</label>
        <input v-model="confirmPwd" type="password" class="ds-input" :placeholder="$t('請再次輸入新密碼')">
      </div>
      <button @click="submit" :disabled="submitting" class="ds-btn ds-btn-primary" style="width:100%">
        {{ submitting ? $t('提交中...') : $t('修改密碼') }}
      </button>
      <p v-if="msg" style="text-align:center;margin-top:12px;font-size:13px" :style="{color: msgColor}">{{ msg }}</p>
    </div>
    </div>
  `,
  data() { return { oldPwd: '', newPwd: '', confirmPwd: '', submitting: false, msg: '', msgColor: 'var(--color-green)' }; },
  methods: {
    async submit() {
      if (this.newPwd !== this.confirmPwd) { this.msg = '兩次密碼不一致'; this.msgColor = 'var(--color-red)'; return; }
      this.submitting = true;
      this.msg = '';
      const res = await ApiProvider.post(ApiUrl.resetPassword, {
        old_password: this.oldPwd,
        password: this.newPwd
      });
      this.msg = res.message || (res.success ? '修改成功' : '修改失敗');
      this.msgColor = res.success ? 'var(--color-green)' : 'var(--color-red)';
      this.submitting = false;
    }
  }
};


/* ---- Modify Phone ---- */
const ModifyPhonePage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('修改手機號') }}</h1>
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('手機號') }}</label>
        <input v-model="phone" class="ds-input" :placeholder="$t('請輸入手機號')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('驗證碼') }}</label>
        <div style="display:flex;gap:8px">
          <input v-model="code" class="ds-input" :placeholder="$t('驗證碼')" style="flex:1">
          <button @click="sendSms" :disabled="countdown > 0" class="ds-btn ds-btn-outline" style="white-space:nowrap;font-size:12px">
            {{ countdown > 0 ? countdown + 's' : $t('獲取驗證碼') }}
          </button>
        </div>
      </div>
      <button @click="submit" :disabled="submitting" class="ds-btn ds-btn-primary" style="width:100%">
        {{ submitting ? $t('提交中...') : $t('確認修改') }}
      </button>
      <p v-if="msg" style="text-align:center;margin-top:12px;font-size:13px" :style="{color: msgColor}">{{ msg }}</p>
    </div>
    </div>
  `,
  data() { return { phone: '', code: '', submitting: false, countdown: 0, msg: '', msgColor: 'var(--color-green)' }; },
  methods: {
    async sendSms() {
      if (!this.phone) return;
      const res = await ApiProvider.post(ApiUrl.sendPhoneCode, { phone: this.phone });
      if (res.success) {
        this.countdown = 60;
        this._timer = setInterval(() => {
          this.countdown--;
          if (this.countdown <= 0) { clearInterval(this._timer); this._timer = null; }
        }, 1000);
      }
    },
    async submit() {
      this.submitting = true;
      this.msg = '';
      const res = await ApiProvider.post(ApiUrl.bindPhone, { phone: this.phone, code: this.code });
      this.msg = res.message || (res.success ? '綁定成功' : '綁定失敗');
      this.msgColor = res.success ? 'var(--color-green)' : 'var(--color-red)';
      this.submitting = false;
    }
  },
  beforeUnmount() {
    if (this._timer) { clearInterval(this._timer); this._timer = null; }
  }
};


/* ---- Feedback ---- */
const FeedbackPage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('意見反饋') }}</h1>
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('反饋內容') }}</label>
        <textarea v-model="content" class="ds-textarea" :placeholder="$t('請描述您的意見或建議…')" rows="5"></textarea>
      </div>
      <button @click="submit" :disabled="submitting || !content" class="ds-btn ds-btn-primary" style="width:100%">
        {{ submitting ? $t('提交中...') : $t('提交反饋') }}
      </button>
      <p v-if="msg" style="text-align:center;margin-top:12px;font-size:13px;color:var(--color-green)">{{ msg }}</p>
    </div>
    </div>
  `,
  data() { return { content: '', submitting: false, msg: '' }; },
  methods: {
    async submit() {
      this.submitting = true;
      const res = await ApiProvider.post(ApiUrl.feedback, { content: this.content });
      this.msg = res.message || (res.success ? '感謝您的反饋！' : '提交失敗');
      if (res.success) setTimeout(() => this.$router.back(), 1500);
      this.submitting = false;
    }
  }
};


/* ---- Contact ---- */
const ContactPage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('聯繫客服') }}</h1>
      </div>
      <div class="card" style="padding:20px;text-align:center" v-html="contactHtml"></div>
      <p v-if="!contactHtml" class="ds-empty">{{ $t('暫無客服信息') }}</p>
    </div>
    </div>
  `,
  data() { return { contactHtml: '' }; },
  async mounted() {
    const res = await ApiProvider.get(ApiUrl.contactUs);
    if (res.success) {
      this.contactHtml = res.data?.content || res.data || '';
    }
  }
};


/* ---- Invite ---- */
const InvitePage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('邀請好友') }}</h1>
      </div>

      <!-- Invite Code Card -->
      <div style="padding:24px;border-radius:var(--radius-lg);background:linear-gradient(135deg,var(--color-primary),#4A52E0);color:#fff;text-align:center;margin-bottom:20px">
        <p style="font-size:13px;opacity:.8;margin-bottom:8px">{{ $t('我的邀請碼') }}</p>
        <p style="font-size:36px;font-weight:800;letter-spacing:4px">{{ inviteCode }}</p>
        <button @click="copyCode" style="margin-top:12px;padding:8px 24px;border-radius:20px;border:none;background:rgba(255,255,255,.2);color:#fff;font-size:13px;font-weight:600;cursor:pointer">
          {{ copied ? $t('已複製') : $t('複製邀請碼') }}
        </button>
      </div>

      <!-- Invite Records -->
      <h3 style="font-weight:600;margin-bottom:12px">{{ $t('邀請記錄') }}</h3>
      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="records.length === 0" class="ds-empty">{{ $t('暫無邀請記錄') }}</div>
      <div v-else>
        <div v-for="r in records" :key="r.id" class="ds-list-item">
          <div class="ds-list-avatar" style="display:flex;align-items:center;justify-content:center;color:var(--color-assistant-text)"><span v-html="I.user" style="font-size:20px"></span></div>
          <div class="ds-list-body">
            <div class="ds-list-title">{{ r.name || r.nickname || '用戶' }}</div>
            <div class="ds-list-sub">{{ formatDate(r.created_at) }}</div>
          </div>
        </div>
      </div>
    </div>
    </div>
  `,
  data() {
    return {
      inviteCode: '', copied: false,
      records: [], loading: false, I
    };
  },
  methods: {
    async load() {
      const user = UserStore.profile || UserStore.userInfo || {};
      this.inviteCode = user.inviter_code || '';
      this.loading = true;
      const res = await ApiProvider.get(ApiUrl.inviteLog);
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.records = Array.isArray(list) ? list : [];
      }
      this.loading = false;
    },
    copyCode() {
      navigator.clipboard?.writeText(this.inviteCode);
      this.copied = true;
      setTimeout(() => { this.copied = false; }, 2000);
    },
    formatDate(d) { return d ? (d + '').slice(0, 10) : ''; }
  },
  mounted() { this.load(); }
};


/* ---- Followers ---- */
const FollowersPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:16px;padding-bottom:16px">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('我的粉絲') }}</h1>
      </div>
      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="list.length === 0" class="ds-empty">{{ $t('暫無粉絲') }}</div>
      <div v-else>
        <div v-for="item in list" :key="item.id" class="ds-list-item">
          <div class="ds-list-avatar">
            <img v-if="item.avatar" :src="item.avatar" style="width:100%;height:100%;object-fit:cover;border-radius:50%">
            <span v-else style="display:flex;align-items:center;justify-content:center;width:100%;height:100%;color:var(--color-assistant-text)"><span v-html="I.user" style="font-size:20px"></span></span>
          </div>
          <div class="ds-list-body">
            <div class="ds-list-title">{{ item.nickname || item.name || '用戶' }}</div>
            <div class="ds-list-sub">{{ item.city_name || '' }}</div>
          </div>
        </div>
      </div>
    </div>
    </div>
  `,
  data() { return { list: [], loading: true, I }; },
  async mounted() {
    const res = await ApiProvider.get(ApiUrl.messageFollowMe, { page: 1, limit: 100 });
    if (res.success) { const data = res.data?.list || res.data || []; this.list = Array.isArray(data) ? data : []; }
    this.loading = false;
  }
};


/* ---- Following ---- */
const FollowingPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:16px;padding-bottom:16px">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('我的關注') }}</h1>
      </div>
      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="list.length === 0" class="ds-empty">{{ $t('暫無關注') }}</div>
      <div v-else>
        <div v-for="item in list" :key="item.id" class="ds-list-item" style="justify-content:space-between">
          <div style="display:flex;align-items:center;gap:14px;flex:1;min-width:0">
            <div class="ds-list-avatar">
              <img v-if="item.avatar" :src="item.avatar" style="width:100%;height:100%;object-fit:cover;border-radius:50%">
              <span v-else style="display:flex;align-items:center;justify-content:center;width:100%;height:100%;color:var(--color-assistant-text)"><span v-html="I.user" style="font-size:20px"></span></span>
            </div>
            <div class="ds-list-body">
              <div class="ds-list-title">{{ item.nickname || item.name || '用戶' }}</div>
              <div class="ds-list-sub">{{ item.city_name || '' }}</div>
            </div>
          </div>
          <button @click="unfollow(item)" class="ds-btn ds-btn-outline" style="padding:6px 14px;font-size:12px;height:auto;border-radius:20px">
            {{ $t('取消關注') }}
          </button>
        </div>
      </div>
    </div>
    </div>
  `,
  data() { return { list: [], loading: true, I }; },
  async mounted() {
    const res = await ApiProvider.get(ApiUrl.messageMyFollow, { page: 1, limit: 100 });
    if (res.success) { const data = res.data?.list || res.data || []; this.list = Array.isArray(data) ? data : []; }
    this.loading = false;
  },
  methods: {
    async unfollow(item) {
      const res = await ApiProvider.post(ApiUrl.messageFollow, { user_id: item.user_id || item.id });
      if (res.success) { this.list = this.list.filter(i => i.id !== item.id); }
    }
  }
};


/* ---- Evaluations (My) ---- */
const MyEvaluationsPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:16px;padding-bottom:16px">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('我的評價') }}</h1>
      </div>
      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="list.length === 0" class="ds-empty">{{ $t('暫無評價') }}</div>
      <div v-else>
        <div v-for="ev in list" :key="ev.id"
          style="padding:14px 0;border-bottom:1px solid var(--color-border-light)">
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px">
            <span style="font-size:13px;font-weight:650">{{ ev.user?.nickname || '用戶' }}</span>
            <span v-for="s in 5" :key="s" style="font-size:12px" :style="{color: s <= (ev.star||0) ? 'var(--color-amber)' : '#E2E5EA'}">{{ s <= (ev.star||0) ? '★' : '☆' }}</span>
            <span style="margin-left:auto;font-size:11px;color:var(--color-assistant-text)">{{ fmt(ev.created_at) }}</span>
          </div>
          <p v-if="ev.content" style="font-size:13px;color:var(--color-secondary-text);line-height:1.5">{{ ev.content }}</p>
        </div>
      </div>
    </div>
    </div>
  `,
  data() { return { list: [], loading: true }; },
  methods: { fmt(d) { return d ? (d + '').slice(0, 10) : ''; } },
  async mounted() {
    const res = await ApiProvider.get(ApiUrl.messageMyEvaluate, { page: 1, limit: 50 });
    if (res.success) { const data = res.data?.list || res.data || []; this.list = Array.isArray(data) ? data : []; }
    this.loading = false;
  }
};


/* ---- My Bookings ---- */
const MyBookingsPage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-760">
      <div class="ds-page-head" style="padding-top:0;display:flex;align-items:baseline;justify-content:space-between">
        <h1>{{ $t('我的預約') }}</h1>
      </div>

      <!-- Tab: Guide / Company -->
      <div style="display:flex;background:rgba(0,0,0,.03);border-radius:var(--radius-sm);padding:3px;margin-bottom:14px">
        <button v-for="t in ['guide', 'company']" :key="t" @click="switchTab(t)"
          style="flex:1;padding:8px 0;border-radius:var(--radius-sm);border:none;font-size:13px;font-weight:500;cursor:pointer;transition:all .15s"
          :style="{background: tab === t ? 'var(--color-bg-white)' : 'transparent', color: tab === t ? 'var(--color-primary-text)' : 'var(--color-assistant-text)', boxShadow: tab === t ? '0 1px 3px rgba(0,0,0,.06)' : 'none'}">
          {{ t === 'guide' ? $t('導遊預約') : $t('商家預約') }}
        </button>
      </div>

      <!-- Status Filter -->
      <div class="ds-type-tabs">
        <div class="ds-type-tabs-row">
          <button v-for="opt in statusOptions" :key="opt.value"
            @click="statusFilter = opt.value; load()"
            :class="['ds-type-tab', { active: statusFilter === opt.value }]">{{ opt.label }}</button>
        </div>
      </div>

      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="bookings.length === 0" class="ds-empty">
        <div style="font-size:40px;margin-bottom:12px;color:var(--color-assistant-text)"><span v-html="I.clipboard"></span></div>
        <p>{{ $t('暫無預約記錄') }}</p>
      </div>
      <div v-else>
        <div v-for="b in bookings" :key="b.id" class="ds-card ds-card-hover" style="padding:16px;margin-bottom:10px">
          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px">
            <div style="flex:1;min-width:0">
              <div style="font-size:14px;font-weight:600">{{ b.guide?.name || b.content?.name || '—' }}</div>
              <div v-if="b.city_name" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ b.city_name }}</div>
              <div v-if="b.arrival_time" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-3px;margin-right:2px"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg> {{ fmtTime(b.arrival_time) }}</div>
              <div v-if="b.number" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ b.number }} 人</div>
            </div>
            <span :class="statusCls(b.status)">{{ statusLabel(b.status) }}</span>
          </div>
          <div style="display:flex;justify-content:flex-end;gap:16px;margin-top:12px;padding-top:12px;border-top:1px solid var(--color-border)">
            <a :href="'#/booking-detail/' + tab + '/' + b.id" style="font-size:12px;color:var(--color-primary);font-weight:500;text-decoration:none">{{ $t('查看詳情') }} ›</a>
            <button v-if="b.status === 1" @click="cancel(b.id)" :disabled="cancelling === b.id"
              style="font-size:12px;color:var(--color-red);font-weight:500;background:none;border:none;cursor:pointer">
              {{ cancelling === b.id ? $t('取消中...') : $t('取消預約') }}
            </button>
          </div>
        </div>
      </div>
    </div>
    </div>
  `,
  data() {
    return {
      tab: 'guide', statusFilter: 0, bookings: [],
      loading: true, cancelling: null, I,
      statusOptions: [
        { value: 0, label: '全部' },
        { value: 1, label: '待確認' },
        { value: 2, label: '已確認' },
        { value: 3, label: '已完成' },
        { value: 4, label: '已取消' },
        { value: 5, label: '已拒絕' },
        { value: 6, label: '已過期' }
      ],
      statusMap: { 1: { l: '待確認', c: 'ds-badge-sm ds-badge-warning' }, 2: { l: '已確認', c: 'ds-badge-sm ds-badge-primary' }, 3: { l: '已完成', c: 'ds-badge-sm ds-badge-success' }, 4: { l: '已取消', c: 'ds-badge-sm' }, 5: { l: '已拒絕', c: 'ds-badge-sm ds-badge-danger' }, 6: { l: '已過期', c: 'ds-badge-sm' } }
    };
  },
  methods: {
    switchTab(t) { this.tab = t; this.statusFilter = 0; this.load(); },
    statusLabel(s) { return this.statusMap[s]?.l || '未知'; },
    statusCls(s) { return this.statusMap[s]?.c || ''; },
    fmtTime(t) { return t ? (t + '').slice(0, 16).replace('T', ' ') : ''; },
    async load() {
      this.loading = true;
      const ep = this.tab === 'guide' ? ApiUrl.userReserveGuide : ApiUrl.userReserveCompany;
      const params = { page: 1, limit: 100 };
      if (this.statusFilter > 0) params.status = this.statusFilter;
      const res = await ApiProvider.get(ep, params);
      if (res.success) { const data = res.data?.list || res.data || []; this.bookings = Array.isArray(data) ? data : []; }
      this.loading = false;
    },
    async cancel(id) {
      if (!confirm('確定取消此預約嗎？')) return;
      this.cancelling = id;
      const ep = this.tab === 'guide' ? ApiUrl.userReserveGuideCancel : ApiUrl.userReserveCompanyCancel;
      await ApiProvider.post(ep, { id });
      this.cancelling = null;
      this.load();
    }
  },
  mounted() { this.load(); }
};


/* ---- Booking Detail ---- */
const BookingDetailPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:16px;padding-bottom:16px">
      <div v-if="loading" class="loading-container" style="padding:80px 0"><div class="spinner"></div></div>
      <div v-else-if="!booking.id" class="ds-empty">{{ $t('預約不存在') }}</div>
      <div v-else>
        <div class="card" style="padding:20px">
          <div style="text-align:center;margin-bottom:16px">
            <span :class="statusCls(booking.status)" style="font-size:14px;padding:4px 16px">{{ statusLabel(booking.status) }}</span>
          </div>
          <div style="display:flex;flex-direction:column;gap:12px;font-size:14px">
            <div v-if="booking.guide?.name"><span style="color:var(--color-assistant-text)">{{ $t('導遊') }}：</span>{{ booking.guide.name }}</div>
            <div v-if="booking.content?.name"><span style="color:var(--color-assistant-text)">{{ $t('內容') }}：</span>{{ booking.content.name }}</div>
            <div v-if="booking.city_name"><span style="color:var(--color-assistant-text)">{{ $t('城市') }}：</span>{{ booking.city_name }}</div>
            <div v-if="booking.arrival_time"><span style="color:var(--color-assistant-text)">{{ $t('到達時間') }}：</span>{{ fmtTime(booking.arrival_time) }}</div>
            <div v-if="booking.leave_time"><span style="color:var(--color-assistant-text)">{{ $t('離開時間') }}：</span>{{ fmtTime(booking.leave_time) }}</div>
            <div v-if="booking.number"><span style="color:var(--color-assistant-text)">{{ $t('人數') }}：</span>{{ booking.number }}</div>
            <div v-if="booking.contact"><span style="color:var(--color-assistant-text)">{{ $t('聯繫人') }}：</span>{{ booking.contact }}</div>
            <div v-if="booking.phone"><span style="color:var(--color-assistant-text)">{{ $t('電話') }}：</span>{{ booking.phone }}</div>
            <div v-if="booking.email"><span style="color:var(--color-assistant-text)">{{ $t('郵箱') }}：</span>{{ booking.email }}</div>
            <div v-if="booking.remark"><span style="color:var(--color-assistant-text)">{{ $t('備註') }}：</span>{{ booking.remark }}</div>
            <div v-if="booking.reason"><span style="color:var(--color-assistant-text)">{{ $t('原因') }}：</span>{{ booking.reason }}</div>
            <div><span style="color:var(--color-assistant-text)">{{ $t('創建時間') }}：</span>{{ fmtTime(booking.created_at) }}</div>
          </div>
          <button v-if="booking.status === 1" @click="cancel" :disabled="cancelling"
            class="ds-btn ds-btn-danger" style="width:100%;margin-top:20px">
            {{ cancelling ? $t('取消中...') : $t('取消預約') }}
          </button>
        </div>
      </div>
    </div>
    </div>
  `,
  data() {
    return { booking: {}, loading: true, cancelling: false,
      statusMap: { 1: { l: '待確認', c: 'ds-badge-sm ds-badge-warning' }, 2: { l: '已確認', c: 'ds-badge-sm ds-badge-primary' }, 3: { l: '已完成', c: 'ds-badge-sm ds-badge-success' }, 4: { l: '已取消', c: 'ds-badge-sm' }, 5: { l: '已拒絕', c: 'ds-badge-sm ds-badge-danger' }, 6: { l: '已過期', c: 'ds-badge-sm' } } };
  },
  methods: {
    statusLabel(s) { return this.statusMap[s]?.l || '未知'; },
    statusCls(s) { return this.statusMap[s]?.c || ''; },
    fmtTime(t) { return t ? (t + '').slice(0, 16).replace('T', ' ') : ''; },
    async load() {
      const type = this.$route.params.type || 'guide';
      const id = this.$route.params.id;
      if (!id) { this.loading = false; return; }
      const ep = type === 'guide' ? ApiUrl.userReserveGuideInfo : ApiUrl.userReserveCompanyInfo;
      const res = await ApiProvider.get(ep, { id: parseInt(id) });
      if (res.success) this.booking = res.data || {};
      this.loading = false;
    },
    async cancel() {
      if (!confirm('確定取消嗎？')) return;
      this.cancelling = true;
      const type = this.$route.params.type || 'guide';
      const ep = type === 'guide' ? ApiUrl.userReserveGuideCancel : ApiUrl.userReserveCompanyCancel;
      await ApiProvider.post(ep, { id: this.booking.id });
      this.cancelling = false;
      this.load();
    }
  },
  mounted() { this.load(); }
};
