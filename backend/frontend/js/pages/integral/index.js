/* ============================================
   Integral Page — 积分商城首页
   Reference: PPCC points/page.tsx
   Gradient balance card + category tabs + goods grid
   ============================================ */

const IntegralPage = {
  template: `
    <div class="page-content">
      <div class="ds-container-960" style="padding-bottom:32px">

        <!-- Balance Card -->
        <div v-if="UserStore.isLogin && user" style="margin:0 0 16px 0">
          <div style="padding:20px;border-radius:var(--radius-lg);background:linear-gradient(135deg, var(--color-primary), #1590F3);color:#fff;display:flex;align-items:center;justify-content:space-between">
            <div>
              <p style="font-size:12px;opacity:.8;margin:0">{{ $t('我的積分') }}</p>
              <p style="font-size:32px;font-weight:800;margin:4px 0 0">{{ user.integral || 0 }}</p>
            </div>
            <a href="#/integral/records" style="font-size:13px;background:rgba(255,255,255,.2);padding:7px 18px;border-radius:20px;color:#fff;text-decoration:none;font-weight:500">
              {{ $t('積分明細') }} ›
            </a>
          </div>
        </div>

        <!-- Login prompt -->
        <div v-if="!UserStore.isLogin" style="text-align:center;padding:60px 16px">
          <div style="font-size:56px;margin-bottom:16px">🎁</div>
          <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('登入後查看積分商城') }}</p>
          <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('立即登入') }}</button>
        </div>

        <!-- Content -->
        <div v-else>
          <h2 class="ds-page-head" style="padding-bottom:8px">{{ $t('積分') }}<span>{{ $t('商城') }}</span></h2>

          <!-- Category tabs -->
          <div style="margin-bottom:16px">
            <div style="display:flex;gap:8px;overflow-x:auto;padding-bottom:4px">
              <button v-for="cat in categories" :key="cat.id" @click="activeCategory=cat.id"
                :class="['ds-btn', activeCategory===cat.id?'ds-btn-primary':'ds-btn-outline']"
                style="padding:6px 18px;font-size:12px;border-radius:100px;white-space:nowrap;flex-shrink:0">{{ cat.name }}</button>
            </div>
          </div>

          <!-- Loading -->
          <div v-if="loading" style="text-align:center;padding:80px 0">
            <div class="spinner"></div>
          </div>

          <!-- Error -->
          <div v-else-if="error" class="ds-empty">
            <div style="font-size:36px;margin-bottom:8px">⚠️</div>
            <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
            <button @click="fetchGoods" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
          </div>

          <!-- Empty -->
          <div v-else-if="goods.length===0" class="ds-empty">
            <div style="font-size:40px;margin-bottom:12px">🎁</div>
            <p style="color:var(--color-secondary-text)">{{ $t('暫無商品') }}</p>
          </div>

          <!-- Goods grid -->
          <div v-else style="display:grid;grid-template-columns:repeat(auto-fill, minmax(160px, 1fr));gap:12px">
            <a v-for="item in goods" :key="item.id" :href="'#/integral/goods/'+item.id"
              class="ds-card" style="text-decoration:none;color:inherit;overflow:hidden">
              <div style="aspect-ratio:1;background:var(--color-bg-page);overflow:hidden">
                <img v-if="item.picture" :src="item.picture" :alt="item.name" style="width:100%;height:100%;object-fit:cover;transition:transform .3s">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:36px">🎁</div>
              </div>
              <div style="padding:12px">
                <p style="font-size:13px;font-weight:600;margin:0;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">{{ item.name }}</p>
                <div style="display:flex;align-items:center;justify-content:space-between;margin-top:8px">
                  <span style="font-size:14px;font-weight:700;color:var(--color-primary)">{{ item.price }} {{ $t('積分') }}</span>
                  <span v-if="item.sales!=null" style="font-size:10px;color:var(--color-assistant-text)">{{ $t('已兌') }} {{ item.sales }}</span>
                </div>
              </div>
            </a>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      categories: [], goods: [], activeCategory: 0,
      loading: true, error: null,
      user: UserStore.profile || UserStore.userInfo
    };
  },
  mounted() {
    if (!UserStore.isLogin) { this.loading = false; return; }
    this.fetchCategories();
  },
  methods: {
    async fetchCategories() {
      this.loading = true;
      try {
        const result = await ApiProvider.get(ApiUrl.integralGoodsClass);
        if (result.success && Array.isArray(result.data)) {
          this.categories = result.data;
          if (this.categories.length > 0) {
            this.activeCategory = this.categories[0].id;
          }
        }
      } catch (e) { /* silent */ }
      if (!this.activeCategory) this.loading = false;
      // fetchGoods() triggered by watch on activeCategory
    },
    async fetchGoods() {
      if (!this.activeCategory) return;
      this.loading = true; this.error = null;
      try {
        const result = await ApiProvider.get(ApiUrl.integralGoods, { class_id: this.activeCategory, page: 1, limit: 50 });
        if (result.success) {
          this.goods = result.data?.list || result.data || [];
        } else {
          this.error = result.message || '載入失敗';
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
  },
  watch: {
    activeCategory() { this.fetchGoods(); }
  }
};
