/* ============================================
   Guide Bookings — 导游预约管理 + 预约详情
   Reference: PPCC guide-panel/bookings/page.tsx
   ============================================ */

const STATUS_MAP = {
  1: { label: '新預約', cls: 'ds-badge-sm ds-badge-warning' },
  2: { label: '已確認', cls: 'ds-badge-sm ds-badge-success' },
  3: { label: '已完成', cls: 'ds-badge-sm' },
  4: { label: '已取消', cls: 'ds-badge-sm' },
  5: { label: '已拒絕', cls: 'ds-badge-sm ds-badge-danger' },
  6: { label: '已過期', cls: 'ds-badge-sm' },
};

/*** GuideBookingsPage ***/
const GuideBookingsPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">📋</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <!-- Not guide -->
      <div v-else-if="!isGuide" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🔒</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('此功能僅限導遊使用') }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回') }}</button>
      </div>

      <!-- Content -->
      <div v-else class="ds-container-640">
        <h2 class="ds-page-head" style="margin-bottom:16px">{{ $t('預約我的') }}</h2>

        <!-- Date filter -->
        <div style="display:flex;gap:8px;margin-bottom:16px">
          <button v-for="f in dateFilters" :key="f.key" @click="dateFilter=f.key;fetchBookings()"
            :class="['ds-btn', dateFilter===f.key?'ds-btn-primary':'ds-btn-outline']"
            style="padding:6px 18px;font-size:13px;border-radius:100px">{{ f.label }}</button>
        </div>

        <!-- Loading -->
        <div v-if="loading" style="text-align:center;padding:80px 0">
          <div class="spinner"></div>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="ds-empty">
          <div style="font-size:36px;margin-bottom:8px">⚠️</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <button @click="fetchBookings" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- Empty -->
        <div v-else-if="bookings.length===0" class="ds-empty">
          <div style="font-size:40px;margin-bottom:12px">📋</div>
          <p style="color:var(--color-secondary-text)">{{ $t('暫無預約') }}</p>
        </div>

        <!-- List -->
        <div v-else>
          <div v-for="b in bookings" :key="b.id" @click="$router.push('/guide/booking-detail/'+b.id)"
            class="ds-card ds-card-hover" style="padding:16px;margin-bottom:10px;cursor:pointer">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
              <div style="display:flex;align-items:center;gap:6px">
                <span v-if="b.is_read===0" style="width:7px;height:7px;border-radius:50%;background:var(--color-red)"></span>
                <span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('預約時間') }}: {{ formatDate(b.created_at) }}</span>
              </div>
              <span :class="statusInfo(b.status).cls">{{ statusInfo(b.status).label }}</span>
            </div>
            <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:10px">
              <div>
                <span style="font-size:11px;color:var(--color-assistant-text)">{{ $t('預約城市') }}</span>
                <p style="font-size:13px;font-weight:600;margin:0">{{ b.city_name || '—' }}</p>
              </div>
              <div>
                <span style="font-size:11px;color:var(--color-assistant-text)">{{ $t('預計到達') }}</span>
                <p style="font-size:13px;font-weight:600;margin:0">{{ formatDate(b.arrival_time) }}</p>
              </div>
              <div>
                <span style="font-size:11px;color:var(--color-assistant-text)">{{ $t('人數') }}</span>
                <p style="font-size:13px;font-weight:600;margin:0">{{ b.number || '—' }}</p>
              </div>
            </div>
            <div style="display:flex;align-items:center;gap:10px;padding-top:10px;border-top:1px solid var(--color-border)">
              <div style="width:32px;height:32px;border-radius:50%;overflow:hidden;background:var(--color-bg-page)">
                <img v-if="b.user?.avatar" :src="b.user.avatar" alt="" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:14px">👤</div>
              </div>
              <span style="font-size:13px;font-weight:500">{{ b.user?.nickname || b.contact || '—' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      bookings: [], loading: true, error: null,
      dateFilter: 'today',
      dateFilters: [{ key: 'today', label: '今天' }, { key: 'all', label: '全部' }],
    };
  },
  computed: {
    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    },
  },
  mounted() {
    if (!UserStore.isLogin || !this.isGuide) { this.loading = false; return; }
    this.fetchBookings();
  },
  methods: {
    async fetchBookings() {
      this.loading = true; this.error = null;
      try {
        const params = { page: 1, limit: 50 };
        if (this.dateFilter === 'today') {
          const today = new Date().toISOString().slice(0, 10);
          params.start_time = today;
          params.end_time = today;
        }
        const result = await ApiProvider.get(ApiUrl.guideReserve, params);
        if (result.success) {
          this.bookings = result.data?.list || result.data || [];
        } else {
          this.error = result.message || '載入失敗';
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    statusInfo(s) { return STATUS_MAP[Number(s)] || STATUS_MAP[1]; },
    formatDate(d) {
      if (!d) return '—';
      return d.slice(0, 16).replace('T', ' ');
    },
  }
};

/*** GuideBookingDetailPage ***/
const GuideBookingDetailPage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">📋</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else-if="error" class="ds-empty">
        <div style="font-size:36px;margin-bottom:8px">⚠️</div>
        <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
        <button @click="fetchDetail" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>

      <div v-else class="ds-container-600">
        <!-- Status -->
        <div style="margin-bottom:16px">
          <span :class="statusInfo(detail.status).cls" style="font-size:14px;padding:6px 14px">{{ statusInfo(detail.status).label }}</span>
        </div>

        <!-- Booking info card -->
        <div class="ds-card" style="padding:16px;margin-bottom:12px">
          <h3 style="font-size:15px;font-weight:600;margin-bottom:12px">{{ $t('預約資訊') }}</h3>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('預約編號') }}</span>
            <span style="font-size:13px;font-weight:500">{{ detail.number || detail.id }}</span>
          </div>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('預約時間') }}</span>
            <span style="font-size:13px;font-weight:500">{{ formatDate(detail.created_at) }}</span>
          </div>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('預計到達') }}</span>
            <span style="font-size:13px;font-weight:500">{{ formatDate(detail.arrival_time) }}</span>
          </div>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('人數') }}</span>
            <span style="font-size:13px;font-weight:500">{{ detail.number || '—' }}</span>
          </div>
          <div v-if="detail.remark" class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('備註') }}</span>
            <span style="font-size:13px">{{ detail.remark }}</span>
          </div>
        </div>

        <!-- User info card -->
        <div class="ds-card" style="padding:16px;margin-bottom:12px">
          <h3 style="font-size:15px;font-weight:600;margin-bottom:12px">{{ $t('預約人資訊') }}</h3>
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px">
            <div style="width:48px;height:48px;border-radius:50%;overflow:hidden;background:var(--color-bg-page)">
              <img v-if="detail.user?.avatar" :src="detail.user.avatar" alt="" style="width:100%;height:100%;object-fit:cover">
              <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px">👤</div>
            </div>
            <div>
              <p style="font-size:15px;font-weight:600;margin:0">{{ detail.user?.nickname || detail.contact || '—' }}</p>
            </div>
          </div>
          <div v-if="detail.contact" class="ds-list-item" style="padding:6px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('聯繫人') }}</span>
            <span style="font-size:13px">{{ detail.contact }}</span>
          </div>
          <div v-if="detail.phone" class="ds-list-item" style="padding:6px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('電話') }}</span>
            <span style="font-size:13px">{{ detail.phone }}</span>
          </div>
          <div v-if="detail.email" class="ds-list-item" style="padding:6px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('郵箱') }}</span>
            <span style="font-size:13px">{{ detail.email }}</span>
          </div>
        </div>

        <!-- Actions -->
        <div v-if="detail.status===1" style="display:flex;gap:12px;margin-bottom:32px">
          <button @click="handleConfirm" :disabled="submitting" class="ds-btn ds-btn-primary" style="flex:1;justify-content:center;padding:12px 0">{{ $t('確認預約') }}</button>
          <button @click="handleReject" :disabled="submitting" class="ds-btn ds-btn-outline" style="flex:1;justify-content:center;padding:12px 0;border-color:var(--color-red);color:var(--color-red)">{{ $t('拒絕') }}</button>
        </div>
        <div v-else-if="detail.status===2" style="margin-bottom:32px">
          <button @click="handleComplete" :disabled="submitting" class="ds-btn ds-btn-primary" style="width:100%;justify-content:center;padding:12px 0">{{ $t('標記為已完成') }}</button>
        </div>
      </div>
    </div>
  `,
  data() {
    return { detail: {}, loading: true, error: null, submitting: false };
  },
  mounted() { this.fetchDetail(); },
  methods: {
    async fetchDetail() {
      this.loading = true; this.error = null;
      const id = this.$route.params.id;
      try {
        const result = await ApiProvider.get(ApiUrl.guideReserveInfo, { id });
        if (result.success) {
          this.detail = result.data || {};
        } else {
          this.error = result.message || '載入失敗';
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    statusInfo(s) { return STATUS_MAP[Number(s)] || STATUS_MAP[1]; },
    formatDate(d) {
      if (!d) return '—';
      return d.slice(0, 16).replace('T', ' ');
    },
    async handleConfirm() {
      if (!confirm('確定確認此預約？')) return;
      this.submitting = true;
      try {
        const result = await ApiProvider.post(ApiUrl.guideConfirmReserve, { id: this.detail.id });
        if (result.success) this.fetchDetail();
      } catch (e) { /* silent */ }
      this.submitting = false;
    },
    async handleReject() {
      const reason = prompt('請輸入拒絕原因（可選）：');
      if (reason === null) return;
      this.submitting = true;
      try {
        const result = await ApiProvider.post(ApiUrl.guideRejectReserve, { id: this.detail.id, reason });
        if (result.success) this.fetchDetail();
      } catch (e) { /* silent */ }
      this.submitting = false;
    },
    async handleComplete() {
      if (!confirm('確定標記為已完成？')) return;
      this.submitting = true;
      try {
        const result = await ApiProvider.post(ApiUrl.guideConfirmReserve, { id: this.detail.id, status: 3 });
        if (result.success) this.fetchDetail();
      } catch (e) { /* silent */ }
      this.submitting = false;
    },
  }
};
