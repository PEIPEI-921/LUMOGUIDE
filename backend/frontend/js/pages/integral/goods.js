/* ============================================
   Integral Goods Detail — 商品详情 (Amazon style)
   ============================================ */

const IntegralGoodsPage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🎁</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else-if="error||!goods" class="ds-empty">
        <div style="font-size:36px;margin-bottom:8px">⚠️</div>
        <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error || '商品不存在' }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary">{{ $t('返回') }}</button>
      </div>

      <div v-else class="amz-page">
        <!-- Image -->
        <div v-if="pics.length>0" class="amz-gallery">
          <div class="amz-gallery-main" @touchstart="onTouchStart" @touchend="onTouchEnd">
            <img :src="pics[currentPic]" :alt="goods.name">
          </div>
          <div v-if="pics.length>1" class="amz-thumbs">
            <div v-for="(pic, i) in pics" :key="i"
              :class="['amz-thumb', { 'amz-thumb--active': i === currentPic }]"
              @click="currentPic=i">
              <img :src="pic" alt="">
            </div>
          </div>
        </div>

        <!-- Info -->
        <div class="amz-info">
          <span :class="['amz-type-tag', isVirtual ? 'amz-type-tag--virtual' : 'amz-type-tag--physical']">
            {{ isVirtual ? $t('虛擬商品') : $t('實體商品') }}
          </span>
          <h1 class="amz-title">{{ goods.name }}</h1>

          <div class="amz-price-row">
            <span class="amz-price-symbol">{{ $t('積分') }}</span>
            <span class="amz-price-value">{{ goods.price }}</span>
          </div>

          <div v-if="goods.sales!=null || goods.free_shipping" class="amz-meta">
            <span v-if="goods.sales!=null">{{ $t('已兌換') }} <strong>{{ goods.sales }}</strong> {{ $t('次') }}</span>
            <span v-if="goods.free_shipping" class="amz-meta-shipping">{{ goods.free_shipping }}</span>
          </div>

          <button @click="$router.push('/integral/exchange/'+goods.id)" class="amz-btn">
            {{ $t('立即兌換') }}
          </button>
        </div>

        <!-- Divider -->
        <div class="amz-divider"></div>

        <!-- Description -->
        <div v-if="goods.content" class="amz-desc-wrap">
          <h2 class="amz-section-title">{{ $t('商品介紹') }}</h2>
          <div class="amz-desc" v-html="goods.content"></div>
        </div>
      </div>
    </div>
  `,
  data() {
    return { goods: null, pics: [], currentPic: 0, loading: true, error: null, touchStartX: 0 };
  },
  computed: {
    isVirtual() { return this.goods && Number(this.goods.goods_type) === 2; }
  },
  mounted() { this.fetchDetail(); },
  methods: {
    async fetchDetail() {
      this.loading = true; this.error = null;
      const id = this.$route.params.id;
      try {
        const result = await ApiProvider.get(ApiUrl.integralGoodsInfo, { id: Number(id) });
        if (result.success && result.data) {
          this.goods = result.data;
          this.pics = result.data.pictures?.length ? result.data.pictures : result.data.picture ? [result.data.picture] : [];
        } else {
          this.error = result.message || '商品不存在';
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    onTouchStart(e) { this.touchStartX = e.changedTouches[0].clientX; },
    onTouchEnd(e) {
      if (!this.pics.length>1) return;
      const dx = e.changedTouches[0].clientX - this.touchStartX;
      if (dx < -40) { this.currentPic = (this.currentPic+1) % this.pics.length; }
      if (dx > 40) { this.currentPic = (this.currentPic-1+this.pics.length) % this.pics.length; }
    }
  }
};
