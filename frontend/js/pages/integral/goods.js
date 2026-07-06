/* ============================================
   Integral Goods Detail — 商品详情
   Reference: PPCC points/[id]/page.tsx
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

      <div v-else class="ds-container-600" style="padding-bottom:32px">
        <!-- Image gallery -->
        <div v-if="pics.length>0" style="margin-bottom:16px">
          <div style="aspect-ratio:1;border-radius:var(--radius-sm);overflow:hidden;background:var(--color-bg-page)">
            <img :src="pics[currentPic]" :alt="goods.name" style="width:100%;height:100%;object-fit:cover">
          </div>
          <div v-if="pics.length>1" style="display:flex;gap:6px;margin-top:8px;justify-content:center">
            <button v-for="(pic, i) in pics" :key="i" @click="currentPic=i"
              :style="{width:'52px',height:'52px',borderRadius:'8px',overflow:'hidden',border:'2px solid '+(i===currentPic?'var(--color-primary)':'transparent'),opacity:i===currentPic?'1':'.5',cursor:'pointer',padding:0}">
              <img :src="pic" alt="" style="width:100%;height:100%;object-fit:cover">
            </button>
          </div>
        </div>

        <!-- Info card -->
        <div class="ds-card" style="padding:16px;margin-bottom:16px">
          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px">
            <h2 style="font-size:18px;font-weight:700;flex:1;margin:0">{{ goods.name }}</h2>
            <span style="font-size:10px;background:var(--color-bg-page);color:var(--color-assistant-text);padding:3px 10px;border-radius:20px;flex-shrink:0">{{ isVirtual ? $t('虛擬商品') : $t('實體商品') }}</span>
          </div>
          <div style="display:flex;align-items:baseline;gap:6px;margin-top:12px;padding-top:12px;border-top:1px solid var(--color-border)">
            <span style="font-size:28px;font-weight:800;color:var(--color-primary)">{{ goods.price }}</span>
            <span style="font-size:14px;color:var(--color-secondary-text)">{{ $t('積分') }}</span>
          </div>
          <div style="display:flex;gap:16px;margin-top:8px;font-size:12px;color:var(--color-assistant-text)">
            <span v-if="goods.sales!=null">{{ $t('已兌換') }} {{ goods.sales }} {{ $t('次') }}</span>
            <span v-if="goods.free_shipping">{{ goods.free_shipping }}</span>
          </div>
        </div>

        <!-- Description -->
        <div v-if="goods.content" class="ds-card" style="padding:16px;margin-bottom:20px">
          <h3 style="font-weight:600;font-size:14px;margin-bottom:10px">{{ $t('商品介紹') }}</h3>
          <div style="font-size:13px;color:var(--color-secondary-text);line-height:1.7;white-space:pre-wrap">{{ goods.content }}</div>
        </div>

        <!-- Exchange button -->
        <button @click="$router.push('/integral/exchange/'+goods.id)" class="ds-btn ds-btn-primary"
          style="width:100%;justify-content:center;padding:14px 0;font-size:15px;border-radius:100px">
          {{ $t('立即兌換') }}
        </button>
      </div>
    </div>
  `,
  data() {
    return { goods: null, pics: [], currentPic: 0, loading: true, error: null };
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
    }
  }
};
