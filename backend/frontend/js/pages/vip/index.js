/* ============================================
   會籍中心 (Membership Center) — 付费导游/商家会员订阅
   Reference: Flutter member_center/page.dart + widgets/*
   Aligned 2026-07-08
   ============================================ */

const VipPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('登入後查看會員中心') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary">{{ $t('立即登入') }}</button>
      </div>

      <!-- Loading -->
      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <!-- Content -->
      <div v-else class="ds-container-600" style="padding-bottom:32px">
        <!-- Top: User info card -->
        <div class="member-top-card" :class="isGuide ? 'member-top--guide' : 'member-top--company'">
          <div class="member-top-row">
            <div class="member-avatar" :style="avatarStyle">
              <span v-if="!avatarUrl" class="member-avatar-fallback">{{ avatarFallback }}</span>
            </div>
            <div class="member-top-info">
              <div class="member-nickname">{{ profile.nickname || profile.email || '' }}</div>
              <div class="member-badges">
                <span :class="['member-badge', isGuide ? 'member-badge--guide' : 'member-badge--company']">
                  {{ isGuide ? $t('導遊') : isCompany ? $t('企業') : $t('普通用戶') }}
                </span>
                <span v-if="vipName" class="member-badge member-badge--vip">{{ vipName }}</span>
              </div>
            </div>
          </div>
          <div class="member-expiry">
            <template v-if="isPaidVip && isVipExpired">
              <span style="color:#EF4444">{{ $t('會員已過期') }}</span>
            </template>
            <template v-else-if="isPaidVip">
              {{ $t('會員有效期') }}: {{ vipExpiredDate }}
            </template>
            <template v-else-if="isFreeVip">
              {{ $t('免費試用') }} {{ profile.vip_free_day || 0 }} {{ $t('天') }}
            </template>
            <template v-else>
              {{ $t('非會員') }}
            </template>
          </div>
        </div>

        <!-- Error -->
        <div v-if="error" style="text-align:center;padding:40px 0">
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <button @click="loadData" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- Products + Abilities section -->
        <template v-if="!error">
          <div class="ds-card" style="padding:20px;margin-bottom:20px">
            <!-- Section title -->
            <h3 style="font-weight:700;font-size:16px;margin:0 0 12px;text-align:center">{{ $t('會籍中心') }}</h3>

            <!-- Product grid -->
            <div v-if="products.length > 0" :class="isGuide ? 'member-product-grid member-product-grid--guide' : 'member-product-grid member-product-grid--company'">
              <div v-for="p in products" :key="p.id"
                :class="['member-product-card', { 'member-product-card--selected': selectedProductId === p.id }]"
                :style="selectedProductId === p.id ? { borderColor: accentColor, borderWidth: '3px' } : {}"
                @click="selectProduct(p.id)">
                <!-- Tag: 月/年 -->
                <span class="member-product-tag" :style="selectedProductId === p.id ? { background: accentColor, color: '#fff' } : {}">
                  {{ p.time_type === 1 ? $t('月') : $t('年') }}
                </span>
                <!-- Name -->
                <div class="member-product-name" :style="selectedProductId === p.id ? { color: accentColor } : {}">
                  {{ p.name || '' }}
                </div>
                <!-- Price -->
                <div class="member-product-price-row">
                  <template v-if="p.buy_type === 2">
                    <img src="images/icon-integral.png" class="member-product-currency-icon" :style="selectedProductId === p.id ? {} : { opacity: 0.6 }" />
                    <span class="member-product-price" :style="selectedProductId === p.id ? { color: accentColor } : {}">{{ p.price || '0' }}</span>
                  </template>
                  <template v-else>
                    <span class="member-product-currency" :style="selectedProductId === p.id ? { color: accentColor } : {}">{{ p.icon || '$' }}</span>
                    <span class="member-product-price" :style="selectedProductId === p.id ? { color: accentColor } : {}">{{ p.price || '0' }}</span>
                  </template>
                  <span class="member-product-unit">/{{ p.time_type_str || '' }}</span>
                </div>
                <!-- Points balance for points-based products -->
                <div v-if="p.buy_type === 2" style="font-size:11px;color:var(--color-assistant-text);margin-top:6px">
                  {{ $t('我的積分') }}: {{ profile.integral || 0 }}
                </div>
              </div>
            </div>

            <!-- Abilities -->
            <div v-if="abilities.length > 0" style="margin-top:20px">
              <div style="display:flex;align-items:center;margin-bottom:10px">
                <span style="font-size:14px;font-weight:600;white-space:nowrap">{{ $t('會員權益') }}</span>
                <span style="flex:1;height:1px;background:rgba(0,0,0,.1);margin-left:10px"></span>
              </div>
              <template v-if="isGuide">
                <div v-for="(a, i) in abilities" :key="i" style="display:flex;align-items:flex-start;padding:4px 0;font-size:12px;color:var(--color-primary-text)">
                  <span style="color:var(--color-primary);margin-right:6px;flex-shrink:0">▸</span>
                  <span>{{ a }}</span>
                </div>
              </template>
              <template v-else>
                <div :style="companyAbilityGridStyle">
                  <div v-for="(col, ci) in abilities" :key="ci">
                    <div v-for="(a, ai) in col" :key="ai" style="display:flex;align-items:flex-start;padding:4px 0;font-size:12px;color:var(--color-primary-text)">
                      <span style="color:var(--color-primary);margin-right:6px;flex-shrink:0">▸</span>
                      <span>{{ a }}</span>
                    </div>
                  </div>
                </div>
              </template>
            </div>
          </div>

          <!-- Submit area (always show if products exist) -->
          <div v-if="products.length > 0" style="text-align:center;margin-bottom:20px">
            <p style="font-size:12px;color:var(--color-secondary-text);margin-bottom:10px;line-height:1.6">
              {{ $t('點擊按鈕即同意') }}<a href="javascript:void(0)" @click="openAgreement('subscribe')" style="color:var(--color-primary)">{{ $t('VIP會員訂閲服務協議') }}</a>{{ $t('、') }}<a href="javascript:void(0)" @click="openAgreement('member')" style="color:var(--color-primary)">{{ $t('VIP會員服務協議') }}</a>
            </p>
            <button @click="handleSubscribe"
              :disabled="subscribing"
              class="ds-btn"
              style="width:100%;justify-content:center;padding:12px 0;font-size:14px;border-radius:100px;background:var(--color-primary-text);color:#fff;font-weight:600">
              <template v-if="subscribing">
                <span class="spinner" style="width:16px;height:16px;border-width:2px;border-color:rgba(255,255,255,.3);border-top-color:#fff;margin-right:8px"></span>
                {{ $t('處理中...') }}
              </template>
              <template v-else>
                <img v-if="selectedProduct && selectedProduct.buy_type === 2" src="images/icon-integral.png" style="width:14px;height:14px;margin-right:6px;filter:brightness(0) invert(1)" />
                <span v-else-if="selectedProduct" style="margin-right:6px">{{ selectedProduct.icon || '$' }}</span>
                <span style="margin-right:6px">{{ selectedProduct?.price || '0' }}</span>
                <span>{{ $t('立即訂閱') }}</span>
              </template>
            </button>
          </div>
        </template>
      </div>
    </div>
  `,
  data() {
    return {
      ability: null,
      products: [],
      selectedProductId: 0,
      loading: true,
      error: null,
      subscribing: false,
    };
  },
  computed: {
    profile() {
      return UserStore.profile || {};
    },
    isGuide() {
      return Number(this.profile.identity) === 2;
    },
    isCompany() {
      return Number(this.profile.identity) === 3;
    },
    isPaidVip() {
      return Number(this.profile.vip_type || 0) > 0 && Number(this.profile.vip_expiration_time || 0) > 0;
    },
    isFreeVip() {
      return Number(this.profile.vip_free || 0) === 1 && Number(this.profile.vip_free_day || 0) > 0;
    },
    vipName() {
      return this.profile.vip_name || '';
    },
    vipExpiredDate() {
      const ts = Number(this.profile.vip_expiration_time || 0);
      if (!ts) return null;
      return new Date(ts * 1000).toLocaleDateString('zh-TW');
    },
    isVipExpired() {
      const ts = Number(this.profile.vip_expiration_time || 0);
      if (!ts) return false;
      return ts < Math.floor(Date.now() / 1000);
    },
    avatarUrl() {
      return this.profile.avatar || '';
    },
    avatarFallback() {
      const name = this.profile.nickname || this.profile.email || '';
      return name.charAt(0).toUpperCase();
    },
    avatarStyle() {
      if (this.avatarUrl) {
        return { backgroundImage: `url(${this.avatarUrl})`, backgroundSize: 'cover', backgroundPosition: 'center' };
      }
      return { background: 'var(--color-primary)' };
    },
    accentColor() {
      return this.isGuide ? 'var(--color-primary)' : '#FF9000';
    },
    selectedProduct() {
      return this.products.find(p => p.id === this.selectedProductId) || this.products[0] || null;
    },
    abilities() {
      if (!this.ability) return [];
      if (this.isGuide) {
        return Array.isArray(this.ability.guide) ? this.ability.guide : [];
      }
      return Array.isArray(this.ability.company) ? this.ability.company : [];
    },
    companyAbilityGridStyle() {
      const cols = this.abilities.length || 1;
      return { display: 'grid', gridTemplateColumns: `repeat(${cols}, 1fr)`, gap: '8px' };
    },
  },
  mounted() { this.loadData(); },
  methods: {
    async loadData() {
      this.loading = true; this.error = null;
      try {
        // Decide which product API to call based on identity
        const planApi = this.isGuide ? ApiUrl.vipGuide
                      : this.isCompany ? ApiUrl.vipCompany
                      : null;

        const [abRes, planRes] = await Promise.all([
          ApiProvider.get(ApiUrl.vipAbility).catch(() => ({ success: false })),
          planApi
            ? ApiProvider.get(planApi).catch(() => ({ success: false }))
            : Promise.resolve({ success: false }),
        ]);

        // Parse ability — API returns { guide: [...], company: [[...], ...] }
        if (abRes.success && abRes.data) {
          this.ability = abRes.data;
        } else {
          this.ability = null;
        }

        // Parse products — API returns flat array [{id, name, ...}, ...]
        // Defensive: also handle {list: [...], total: N} wrapped format
        if (planRes.success && planRes.data) {
          const d = planRes.data;
          this.products = Array.isArray(d) ? d : (d.list || d.data || []);
        } else {
          this.products = [];
        }

        // Auto-select first product
        if (this.products.length > 0) {
          this.selectedProductId = this.products[0].id || 0;
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    selectProduct(id) {
      this.selectedProductId = id;
    },
    async handleSubscribe() {
      if (!this.selectedProduct) return;
      if (this.subscribing) return;
      this.subscribing = true;
      try {
        const url = this.isGuide ? ApiUrl.vipSubscribeGuide : ApiUrl.vipSubscribeCompany;
        const res = await ApiProvider.post(url, { id: this.selectedProduct.id });
        if (res.success && res.data?.pay_url) {
          window.open(res.data.pay_url, '_blank');
          let attempts = 0;
          this._pollTimer = setInterval(async () => {
            attempts++;
            const statusRes = await ApiProvider.get(ApiUrl.vipPayStatus, { id: this.selectedProduct.id });
            if (statusRes.success && Number(statusRes.data?.status) === 1) {
              clearInterval(this._pollTimer);
              this._pollTimer = null;
              await UserStore.getProfile();
              this.subscribing = false;
              alert(this.$t('訂閱成功'));
            }
            if (attempts >= 60) {
              clearInterval(this._pollTimer);
              this._pollTimer = null;
              this.subscribing = false;
            }
          }, 5000);
        } else if (res.success) {
          await UserStore.getProfile();
          this.subscribing = false;
          alert(this.$t('訂閱成功'));
        } else {
          this.subscribing = false;
          alert(res.message || this.$t('訂閱失敗'));
        }
      } catch (e) {
        this.subscribing = false;
        alert(e.message || this.$t('訂閱失敗'));
      }
    },
    openAgreement(type) {
      const key = type === 'member' ? 'vipUserProtocol' : 'vipUserSubscribe';
      this.$router.push(`/protocol/${key}`);
    },
  },
  beforeUnmount() {
    if (this._pollTimer) { clearInterval(this._pollTimer); this._pollTimer = null; }
  }
};
