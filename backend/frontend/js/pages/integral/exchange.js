/* ============================================
   Integral Exchange — 积分兑换确认 / 结果 / 订单详情
   Reference: PPCC points exchange flow
   ============================================ */

/*** IntegralExchangePage — 兑换确认 ***/
const IntegralExchangePage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🔄</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else-if="error" class="ds-empty">
        <div style="font-size:36px;margin-bottom:8px">⚠️</div>
        <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary">{{ $t('返回') }}</button>
      </div>

      <div v-else class="ds-container-600" style="padding-bottom:32px">
        <h2 class="ds-page-head" style="margin-bottom:20px">{{ $t('確認兌換') }}</h2>

        <!-- Goods summary -->
        <div class="ds-card" style="padding:16px;margin-bottom:16px">
          <div style="display:flex;gap:12px">
            <div style="width:80px;height:80px;border-radius:8px;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
              <img v-if="goods.picture" :src="goods.picture" alt="" style="width:100%;height:100%;object-fit:cover">
              <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:32px">🎁</div>
            </div>
            <div style="flex:1;min-width:0">
              <p style="font-size:15px;font-weight:600;margin:0">{{ goods.name }}</p>
              <p style="font-size:20px;font-weight:800;color:var(--color-primary);margin:8px 0 0">{{ goods.price }} {{ $t('積分') }}</p>
              <p v-if="goods.sales!=null" style="font-size:11px;color:var(--color-assistant-text);margin:4px 0 0">{{ $t('已兌換') }} {{ goods.sales }} {{ $t('次') }}</p>
            </div>
          </div>
        </div>

        <!-- User balance -->
        <div class="ds-card" style="padding:16px;margin-bottom:16px">
          <div style="display:flex;justify-content:space-between;align-items:center">
            <span style="font-size:14px;color:var(--color-secondary-text)">{{ $t('當前積分') }}</span>
            <span style="font-size:16px;font-weight:700;color:var(--color-primary-text)">{{ currentBalance }} {{ $t('積分') }}</span>
          </div>
          <div style="display:flex;justify-content:space-between;align-items:center;margin-top:10px;padding-top:10px;border-top:1px solid var(--color-border)">
            <span style="font-size:14px;font-weight:600">{{ $t('兌換後剩餘') }}</span>
            <span :style="{fontSize:'16px',fontWeight:700,color:remainingBalance>=0?'var(--color-green)':'var(--color-red)'}">{{ remainingBalance }} {{ $t('積分') }}</span>
          </div>
        </div>

        <!-- Address (for physical goods) -->
        <div v-if="!isVirtual" class="ds-card" style="padding:16px;margin-bottom:20px">
          <h3 style="font-weight:600;font-size:14px;margin-bottom:12px">{{ $t('收貨地址') }}</h3>
          <div v-if="addresses.length===0" style="text-align:center;padding:16px 0">
            <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:12px">{{ $t('暫無地址') }}</p>
            <a href="#/address/edit" style="font-size:13px;color:var(--color-primary);text-decoration:none">+ {{ $t('新增地址') }}</a>
          </div>
          <div v-else>
            <div v-for="addr in addresses" :key="addr.id" @click="selectedAddr=addr.id"
              :style="{padding:'12px',borderRadius:'8px',marginBottom:'8px',border:'1px solid '+(selectedAddr===addr.id?'var(--color-primary)':'var(--color-border)'),background:selectedAddr===addr.id?'var(--color-accent-soft)':'transparent',cursor:'pointer'}">
              <div style="display:flex;justify-content:space-between;align-items:center">
                <span style="font-size:13px;font-weight:600">{{ addr.name }}</span>
                <span style="font-size:12px;color:var(--color-assistant-text)">{{ addr.phone }}</span>
              </div>
              <p style="font-size:12px;color:var(--color-assistant-text);margin:4px 0 0">{{ addr.address }}</p>
            </div>
          </div>
          <div class="ds-form-group" style="margin-top:12px">
            <label class="ds-label">{{ $t('備註') }}</label>
            <textarea v-model="remark" class="ds-textarea" rows="2" style="margin-top:4px" :placeholder="$t('選填')"></textarea>
          </div>
        </div>

        <!-- Error -->
        <div v-if="exchangeError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:12px;border-radius:8px;margin-bottom:16px">{{ exchangeError }}</div>

        <!-- Submit -->
        <button @click="handleExchange" :disabled="submitting||(remainingBalance<0)" class="ds-btn ds-btn-primary"
          style="width:100%;justify-content:center;padding:14px 0;font-size:15px;border-radius:100px">
          {{ submitting ? $t('兌換中...') : remainingBalance<0 ? $t('積分不足') : $t('確認兌換') }}
        </button>
      </div>
    </div>
  `,
  data() {
    return {
      goods: {}, loading: true, error: null,
      addresses: [], selectedAddr: null, remark: '',
      submitting: false, exchangeError: '',
    };
  },
  computed: {
    isVirtual() { return this.goods && Number(this.goods.goods_type) === 2; },
    currentBalance() {
      const profile = UserStore.profile || UserStore.userInfo;
      return Number(profile?.integral || 0);
    },
    remainingBalance() { return this.currentBalance - Number(this.goods.price || 0); }
  },
  async mounted() {
    const id = this.$route.params.id;
    // Fetch goods info
    try {
      const goodsRes = await ApiProvider.get(ApiUrl.integralGoodsInfo, { id: Number(id) });
      if (goodsRes.success && goodsRes.data) {
        this.goods = goodsRes.data;
      } else {
        this.error = goodsRes.message || '商品不存在';
        this.loading = false; return;
      }
    } catch (e) { this.error = e.message || '載入失敗'; this.loading = false; return; }

    // Fetch addresses for physical goods
    if (this.goods && Number(this.goods.goods_type) !== 2) {
      try {
        const addrRes = await ApiProvider.get(ApiUrl.addressLists);
        if (addrRes.success && addrRes.data) {
          this.addresses = Array.isArray(addrRes.data) ? addrRes.data : (addrRes.data.list || []);
        }
      } catch (e) { /* silent */ }
    }
    this.loading = false;
  },
  methods: {
    async handleExchange() {
      if (!this.goods.id) return;
      if (!this.isVirtual && !this.selectedAddr) {
        this.exchangeError = '請選擇收貨地址';
        return;
      }
      this.submitting = true; this.exchangeError = '';
      try {
        const payload = { id: Number(this.goods.id) };
        if (!this.isVirtual) {
          payload.address_id = this.selectedAddr;
          payload.remark = this.remark;
        }
        const result = await ApiProvider.post(ApiUrl.integralExchange, payload);
        if (result.success) {
          // Refresh user balance
          await UserStore.fetchProfile();
          this.$router.push('/integral/exchange/result?order_id=' + (result.data?.id || result.data?.order_id || ''));
        } else {
          this.exchangeError = result.message || '兌換失敗';
        }
      } catch (e) {
        this.exchangeError = e.message || '兌換失敗';
      }
      this.submitting = false;
    }
  }
};

/*** IntegralExchangeResultPage — 兑换结果 ***/
const IntegralExchangeResultPage = {
  template: `
    <div class="page-content" style="text-align:center;padding:80px 16px">
      <div style="font-size:56px;margin-bottom:16px">✅</div>
      <h2 style="font-size:20px;font-weight:700;margin-bottom:8px">{{ $t('兌換成功') }}</h2>
      <p style="color:var(--color-secondary-text);margin-bottom:24px">{{ $t('您的兌換訂單已提交，請等待處理') }}</p>
      <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
        <a :href="'#/integral/exchange/order/' + orderId" class="ds-btn ds-btn-primary" style="padding:10px 24px;text-decoration:none">{{ $t('查看訂單') }}</a>
        <a href="#/integral" class="ds-btn ds-btn-outline" style="padding:10px 24px;text-decoration:none">{{ $t('返回商城') }}</a>
      </div>
    </div>
  `,
  data() {
    return {
      orderId: this.$route?.query?.order_id || ''
    };
  }
};

/*** IntegralExchangeOrderPage — 兑换订单详情 ***/
const IntegralExchangeOrderPage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">📦</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else-if="error" class="ds-empty">
        <div style="font-size:36px;margin-bottom:8px">⚠️</div>
        <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
        <button @click="fetchOrder" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>

      <div v-else class="ds-container-600" style="padding-bottom:32px">
        <h2 class="ds-page-head" style="margin-bottom:20px">{{ $t('訂單詳情') }}</h2>

        <div class="ds-card" style="padding:16px;margin-bottom:12px">
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('訂單編號') }}</span>
            <span style="font-size:13px;font-weight:500">{{ order.number || order.id || '—' }}</span>
          </div>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('商品名稱') }}</span>
            <span style="font-size:13px;font-weight:500">{{ order.goods_name || order.name || '—' }}</span>
          </div>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('消耗積分') }}</span>
            <span style="font-size:13px;font-weight:700;color:var(--color-primary)">{{ order.integral || order.price || '—' }}</span>
          </div>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('兌換時間') }}</span>
            <span style="font-size:13px;font-weight:500">{{ formatDate(order.created_at) }}</span>
          </div>
          <div class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('狀態') }}</span>
            <span :class="['ds-badge-sm', statusCls]">{{ statusLabel }}</span>
          </div>
          <div v-if="order.address" class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('收貨地址') }}</span>
            <span style="font-size:13px">{{ order.address }}</span>
          </div>
          <div v-if="order.remark" class="ds-list-item" style="padding:8px 0">
            <span style="color:var(--color-assistant-text);font-size:13px">{{ $t('備註') }}</span>
            <span style="font-size:13px">{{ order.remark }}</span>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return { order: {}, loading: true, error: null };
  },
  computed: {
    statusLabel() {
      const map = { 0: '待處理', 1: '處理中', 2: '已完成', 3: '已取消' };
      return map[this.order.status] || '待處理';
    },
    statusCls() {
      const map = { 0: 'ds-badge-warning', 1: 'ds-badge-warning', 2: 'ds-badge-success', 3: '' };
      return map[this.order.status] || '';
    }
  },
  mounted() { this.fetchOrder(); },
  methods: {
    async fetchOrder() {
      this.loading = true; this.error = null;
      const id = this.$route.params.id;
      try {
        const result = await ApiProvider.get(ApiUrl.integralExchangeOrderInfo, { id: Number(id) });
        if (result.success && result.data) {
          this.order = result.data;
        } else {
          // Try list as fallback
          const listRes = await ApiProvider.get(ApiUrl.integralExchangeOrders, { page: 1, limit: 50 });
          if (listRes.success && listRes.data?.list) {
            const found = listRes.data.list.find(o => String(o.id) === String(id));
            if (found) this.order = found;
            else this.error = '訂單不存在';
          } else {
            this.error = result.message || '訂單不存在';
          }
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
