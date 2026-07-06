/* ============================================
   VIP Page — VIP 会员中心
   Reference: PPCC vip/page.tsx
   ============================================ */

const BENEFITS = [
  { icon: '🔍', text: '優先曝光與推薦' },
  { icon: '📊', text: '數據分析工具' },
  { icon: '💬', text: '專屬客服通道' },
  { icon: '🎯', text: '精準行銷推廣' },
  { icon: '📋', text: '無限發布內容' },
  { icon: '🏷️', text: 'VIP 身分標識' },
];

const VipPage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:56px;margin-bottom:16px">💎</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('登入後查看會員中心') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary">{{ $t('立即登入') }}</button>
      </div>

      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else class="ds-container-600" style="padding-bottom:32px">
        <!-- Status card -->
        <div style="padding:32px;border-radius:var(--radius-lg);background:linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);color:#fff;text-align:center;margin-bottom:20px">
          <div style="font-size:48px;margin-bottom:12px">💎</div>
          <template v-if="isVip">
            <h2 style="font-size:22px;font-weight:700;margin:0">{{ user?.vip_name || 'VIP 會員' }}</h2>
            <p v-if="vipExpired" style="font-size:13px;opacity:.7;margin-top:6px">{{ $t('到期日') }}: {{ vipExpired }}</p>
            <div style="display:inline-block;margin-top:16px;background:rgba(255,255,255,.1);border-radius:20px;padding:8px 20px;font-size:13px;font-weight:500">{{ $t('尊享會員權益') }}</div>
          </template>
          <template v-else>
            <h2 style="font-size:22px;font-weight:700;margin:0">{{ $t('免費會員') }}</h2>
            <p style="font-size:13px;opacity:.7;margin-top:6px">{{ $t('升級 VIP 解鎖更多權益') }}</p>
            <div v-if="ability?.vip_free_day" style="display:inline-block;margin-top:16px;background:var(--color-primary);border-radius:20px;padding:8px 20px;font-size:13px;font-weight:500">
              {{ $t('新用戶免費體驗') }} {{ ability.vip_free_day }} {{ $t('天') }}
            </div>
          </template>
        </div>

        <!-- Benefits -->
        <div class="ds-card" style="padding:20px;margin-bottom:20px">
          <h3 style="font-weight:600;font-size:14px;margin-bottom:14px">{{ $t('VIP 專屬權益') }}</h3>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
            <div v-for="b in BENEFITS" :key="b.text" style="display:flex;align-items:center;gap:8px;padding:10px;border-radius:10px;background:var(--color-bg-page)">
              <span style="font-size:20px">{{ b.icon }}</span>
              <span style="font-size:12px;font-weight:500">{{ b.text }}</span>
            </div>
          </div>
        </div>

        <!-- Error -->
        <div v-if="error" style="text-align:center;padding:40px 0">
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <button @click="loadData" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- Plans (non-VIP only) -->
        <template v-if="!isVip && plans.length>0">
          <h3 style="font-weight:600;font-size:14px;margin-bottom:14px">{{ $t('訂閱方案') }}</h3>
          <div v-for="plan in plans" :key="plan.id" class="ds-card" :style="{padding:'20px',marginBottom:'14px',border:plan.is_default?'2px solid var(--color-primary)':'1px solid transparent',position:'relative'}">
            <span v-if="plan.is_default" style="position:absolute;top:-1px;right:20px;background:var(--color-primary);color:#fff;font-size:10px;font-weight:600;padding:3px 12px;border-radius:0 0 8px 8px">{{ $t('推薦') }}</span>
            <div style="display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:12px">
              <div>
                <h4 style="font-size:16px;font-weight:700;margin:0">{{ plan.name }}</h4>
                <p v-if="plan.desc" style="font-size:12px;color:var(--color-assistant-text);margin-top:3px">{{ plan.desc }}</p>
              </div>
              <div style="text-align:right">
                <p style="font-size:24px;font-weight:800;color:var(--color-primary);margin:0">&#36;{{ plan.price || '—' }}</p>
                <p v-if="plan.original_price && plan.original_price>(plan.price||0)" style="font-size:12px;color:var(--color-assistant-text);text-decoration:line-through;margin:0">&#36;{{ plan.original_price }}</p>
              </div>
            </div>
            <p v-if="plan.duration" style="font-size:12px;color:var(--color-assistant-text);margin-bottom:12px">{{ $t('有效期') }}: {{ plan.duration }} {{ plan.duration_unit || $t('天') }}</p>
            <ul v-if="plan.features || plan.benefits" style="list-style:none;padding:0;margin:0 0 16px">
              <li v-for="(f, i) in (plan.features || plan.benefits || [])" :key="i" style="font-size:12px;color:var(--color-secondary-text);padding:4px 0;display:flex;align-items:flex-start;gap:6px">
                <span style="color:#22c55e;flex-shrink:0;margin-top:1px">✓</span>
                <span>{{ f }}</span>
              </li>
            </ul>
            <button @click="handleSubscribe(plan.id)" :disabled="subscribing===plan.id"
              :class="['ds-btn', plan.is_default?'ds-btn-primary':'ds-btn-outline']"
              style="width:100%;justify-content:center;padding:12px 0;font-size:14px;border-radius:100px">
              {{ subscribing===plan.id ? $t('處理中...') : $t('訂閱') + ' ' + plan.name }}
            </button>
          </div>
        </template>

        <!-- Already VIP message -->
        <div v-if="isVip" class="ds-card" style="padding:16px;text-align:center">
          <p style="font-size:13px;color:var(--color-secondary-text)">{{ $t('如需更改方案或取消訂閱，請聯繫客服') }}</p>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      ability: null, plans: [], loading: true, error: null, subscribing: null,
      user: UserStore.profile || UserStore.userInfo,
      BENEFITS
    };
  },
  computed: {
    isVip() {
      return this.user && Number(this.user.vip_type || 0) > 0;
    },
    vipExpired() {
      if (!this.user?.vip_expiration_time) return null;
      return new Date(Number(this.user.vip_expiration_time) * 1000).toLocaleDateString('zh-TW');
    },
    isGuide() {
      return this.user && Number(this.user.identity) === 2;
    },
    isCompany() {
      return this.user && Number(this.user.identity) === 3;
    },
  },
  mounted() { this.loadData(); },
  methods: {
    async loadData() {
      this.loading = true; this.error = null;
      try {
        const [abRes, planRes] = await Promise.all([
          ApiProvider.get(ApiUrl.vipAbility).catch(() => ({ success: false })),
          this.isGuide
            ? ApiProvider.get(ApiUrl.vipGuide).catch(() => ({ success: false }))
            : this.isCompany
              ? ApiProvider.get(ApiUrl.vipCompany).catch(() => ({ success: false }))
              : Promise.resolve({ success: false }),
        ]);
        if (abRes.success) this.ability = abRes.data || {};
        if (planRes.success) this.plans = planRes.data?.list || [];
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    async handleSubscribe(planId) {
      this.subscribing = planId;
      try {
        const url = this.isGuide ? ApiUrl.vipSubscribeGuide : ApiUrl.vipSubscribeCompany;
        const res = await ApiProvider.post(url, { id: planId });
        if (res.success && res.data?.pay_url) {
          window.open(res.data.pay_url, '_blank');
        }
        // Check status
        const statusRes = await ApiProvider.get(ApiUrl.vipPayStatus, { id: planId });
        if (statusRes.success && Number(statusRes.data?.status) === 1) {
          alert('訂閱成功！');
          await UserStore.fetchProfile();
          this.user = UserStore.profile || UserStore.userInfo;
        }
      } catch (e) {
        alert(e.message || '訂閱失敗');
      }
      this.subscribing = null;
    }
  }
};
