/* ============================================
   Integral Records — 积分记录列表
   ============================================ */

const IntegralRecordsPage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">📋</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <div v-else class="ds-container-640" style="padding-bottom:32px">
        <h2 class="ds-page-head" style="margin-bottom:16px">{{ $t('積分明細') }}</h2>

        <!-- Balance summary -->
        <div style="padding:16px;border-radius:var(--radius-sm);background:linear-gradient(135deg,var(--color-primary),#1590F3);color:#fff;margin-bottom:16px;display:flex;align-items:center;justify-content:space-between">
          <div>
            <p style="font-size:12px;opacity:.8;margin:0">{{ $t('當前積分') }}</p>
            <p style="font-size:28px;font-weight:800;margin:4px 0 0">{{ currentBalance }}</p>
          </div>
          <a href="#/integral" style="font-size:12px;background:rgba(255,255,255,.2);padding:6px 14px;border-radius:20px;color:#fff;text-decoration:none">{{ $t('去兌換') }} ›</a>
        </div>

        <!-- Loading -->
        <div v-if="loading" style="text-align:center;padding:80px 0">
          <div class="spinner"></div>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="ds-empty">
          <div style="font-size:36px;margin-bottom:8px">⚠️</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <button @click="fetchRecords" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- Empty -->
        <div v-else-if="records.length===0" class="ds-empty">
          <div style="font-size:40px;margin-bottom:12px">📋</div>
          <p style="color:var(--color-secondary-text)">{{ $t('暫無積分記錄') }}</p>
        </div>

        <!-- Records list -->
        <div v-else>
          <div v-for="r in records" :key="r.id" class="ds-card" style="padding:14px;margin-bottom:8px">
            <div style="display:flex;align-items:center;justify-content:space-between">
              <div style="flex:1;min-width:0">
                <p style="font-size:14px;font-weight:600;margin:0">{{ r.desc || r.title || r.remark || '—' }}</p>
                <p style="font-size:11px;color:var(--color-assistant-text);margin-top:4px">{{ formatDate(r.created_at) }}</p>
              </div>
              <div style="text-align:right;flex-shrink:0">
                <span :style="{fontSize:'15px',fontWeight:700,color:Number(r.num||r.integral||0)>=0?'var(--color-green)':'var(--color-red)'}">
                  {{ Number(r.num||r.integral||0)>=0 ? '+' : '' }}{{ r.num || r.integral || 0 }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return { records: [], loading: true, error: null };
  },
  computed: {
    currentBalance() {
      const profile = UserStore.profile || UserStore.userInfo;
      return Number(profile?.integral || 0);
    }
  },
  mounted() { this.fetchRecords(); },
  methods: {
    async fetchRecords() {
      this.loading = true; this.error = null;
      try {
        const result = await ApiProvider.get(ApiUrl.integralUserDetails, { page: 1, limit: 50 });
        if (result.success) {
          this.records = result.data?.list || result.data || [];
        } else {
          this.error = result.message || '載入失敗';
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    formatDate(d) {
      if (!d) return '—';
      return d.slice(0, 16).replace('T', ' ');
    }
  }
};
