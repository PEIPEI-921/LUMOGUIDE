/* ============================================
   會籍中心 (Membership Center) — 付费导游/商家会员订阅
   Reference: Flutter member_center/page.dart + widgets/*
   Aligned 2026-07-08 · Stripe Payment Element added 2026-07-25
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

          <!-- Submit area -->
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
                <span v-else-if="selectedProduct" style="margin-right:6px">{{ selectedProduct.icon || '€' }}</span>
                <span style="margin-right:6px">{{ selectedProduct?.price || '0' }}</span>
                <span>{{ $t('立即訂閱') }}</span>
              </template>
            </button>
          </div>
        </template>
      </div>

      <!-- Stripe Payment Modal -->
      <div v-if="showPaymentModal" class="pay-modal-overlay" @click.self="closePaymentModal">
        <div class="pay-modal">
          <div class="pay-modal-title">{{ $t('確認付款') }}</div>
          <div class="pay-modal-sub">{{ payModalData.productName }}</div>
          <div class="pay-modal-amount">€{{ payModalData.amount }}</div>

          <div v-if="paymentError" class="pay-modal-error">{{ paymentError }}</div>

          <div id="payment-element" style="min-height:100px"></div>

          <div class="pay-modal-actions">
            <button class="pay-modal-cancel" @click="closePaymentModal" :disabled="paymentLoading">
              {{ $t('取消') }}
            </button>
            <button class="pay-modal-confirm" @click="confirmStripePayment" :disabled="paymentLoading || !stripeLoaded">
              <template v-if="paymentLoading">
                <span class="spinner" style="width:14px;height:14px;border-width:2px;border-color:rgba(255,255,255,.3);border-top-color:#fff;margin-right:6px"></span>
                {{ $t('處理中...') }}
              </template>
              <template v-else>
                {{ $t('支付') }} €{{ payModalData.amount }}
              </template>
            </button>
          </div>
        </div>
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

      // Stripe payment modal
      showPaymentModal: false,
      paymentLoading: false,
      paymentError: null,
      stripeLoaded: false,
      stripeInstance: null,
      stripeElements: null,
      payModalData: {
        orderSn: '',
        clientSecret: '',
        amount: '0',
        productName: '',
      },
    };
  },
  computed: {
    profile() {
      return UserStore.profile || {};
    },
    isGuide() {
      const info = UserStore.userInfo;
      return !!UserStore.token && info && Number(info.identity) === 2;
    },
    isCompany() {
      const info = UserStore.userInfo;
      return !!UserStore.token && info && Number(info.identity) === 3;
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
        const planApi = this.isGuide ? ApiUrl.vipGuide
                      : this.isCompany ? ApiUrl.vipCompany
                      : null;

        const [abRes, planRes] = await Promise.all([
          ApiProvider.get(ApiUrl.vipAbility).catch(() => ({ success: false })),
          planApi
            ? ApiProvider.get(planApi).catch(() => ({ success: false }))
            : Promise.resolve({ success: false }),
        ]);

        if (abRes.success && abRes.data) {
          this.ability = abRes.data;
        } else {
          this.ability = null;
        }

        if (planRes.success && planRes.data) {
          const d = planRes.data;
          this.products = Array.isArray(d) ? d : (d.list || d.data || []);
        } else {
          this.products = [];
        }

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

    /** Handle subscribe button — routes to Stripe or points payment */
    async handleSubscribe() {
      if (!this.selectedProduct) return;
      if (this.subscribing) return;
      this.subscribing = true;
      try {
        const url = this.isGuide ? ApiUrl.vipSubscribeGuide : ApiUrl.vipSubscribeCompany;
        const res = await ApiProvider.post(url, { id: this.selectedProduct.id });
        this.subscribing = false;

        if (!res.success) {
          alert(res.message || this.$t('訂閱失敗'));
          return;
        }

        // Points/integral purchase — processed immediately, no Stripe needed
        if (!res.data?.client_secret) {
          await UserStore.getProfile();
          alert(this.$t('訂閱成功'));
          return;
        }

        // Stripe payment — show payment modal
        this.openStripePayment(
          res.data.order_sn,
          res.data.client_secret,
          String(this.selectedProduct.price || '0'),
          this.selectedProduct.name || '',
        );
      } catch (e) {
        this.subscribing = false;
        alert(e.message || this.$t('訂閱失敗'));
      }
    },

    /** Open Stripe payment modal and mount Payment Element */
    async openStripePayment(orderSn, clientSecret, amount, productName) {
      this.payModalData = { orderSn, clientSecret, amount, productName };
      this.paymentError = null;
      this.paymentLoading = false;
      this.stripeLoaded = false;
      this.showPaymentModal = true;

      await this.$nextTick();

      const stripeKey = ConfigStore.get('stripe_key', '');
      if (!stripeKey) {
        this.paymentError = '無法載入支付模塊 (missing Stripe key)';
        return;
      }

      try {
        // Stripe.js v3 exposes window.Stripe
        if (typeof Stripe === 'undefined') {
          this.paymentError = '無法載入支付模塊 (Stripe.js not loaded)';
          return;
        }
        this.stripeInstance = Stripe(stripeKey);
        this.stripeElements = this.stripeInstance.elements({
          clientSecret: clientSecret,
          appearance: {
            variables: {
              borderRadius: '8px',
              colorPrimary: '#666FFF',
              colorText: '#1a1a1a',
              colorTextSecondary: '#6B7280',
              colorDanger: '#EF4444',
              fontFamily: '-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC",sans-serif',
              spacingUnit: '4px',
            },
            rules: {
              '.Label': { fontWeight: '500', fontSize: '13px' },
              '.Input': { padding: '12px 14px', fontSize: '15px' },
            },
          },
        });

        const paymentElement = this.stripeElements.create('payment', {
          layout: { type: 'tabs', defaultCollapsed: false },
        });
        paymentElement.mount('#payment-element');
        paymentElement.on('ready', () => { this.stripeLoaded = true; });
      } catch (e) {
        this.paymentError = e.message || '支付模塊初始化失敗';
      }
    },

    /** Confirm Stripe payment via Payment Element */
    async confirmStripePayment() {
      if (!this.stripeInstance || !this.stripeElements) return;
      this.paymentLoading = true;
      this.paymentError = null;

      try {
        const result = await this.stripeInstance.confirmPayment({
          elements: this.stripeElements,
          confirmParams: {
            return_url: window.location.origin + '/#/vip',
          },
          redirect: 'if_required',
        });

        if (result.error) {
          this.paymentError = result.error.message || this.$t('支付失敗');
          this.paymentLoading = false;
          return;
        }

        // Payment succeeded — no redirect needed
        if (result.paymentIntent && result.paymentIntent.status === 'succeeded') {
          this.closePaymentModal();
          await UserStore.getProfile();
          alert(this.$t('訂閱成功'));
          return;
        }

        // Payment requires further action — Stripe will handle it
        this.paymentLoading = false;
      } catch (e) {
        this.paymentError = e.message || this.$t('支付失敗');
        this.paymentLoading = false;
      }
    },

    /** Close payment modal and clean up Stripe elements */
    closePaymentModal() {
      if (this.stripeElements) {
        const paymentElement = this.stripeElements.getElement('payment');
        if (paymentElement) paymentElement.unmount();
        this.stripeElements = null;
      }
      this.stripeInstance = null;
      this.stripeLoaded = false;
      this.showPaymentModal = false;
      this.paymentLoading = false;
    },

    openAgreement(type) {
      const key = type === 'member' ? 'vipUserProtocol' : 'vipUserSubscribe';
      this.$router.push(`/protocol/${key}`);
    },
  },
  beforeUnmount() {
    this.closePaymentModal();
  }
};
