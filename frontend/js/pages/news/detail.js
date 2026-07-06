/* ============================================
   News Detail Page — 资讯详情
   Reference: PPCC news/[id]/page.tsx
   ============================================ */

const NewsDetailPage = {
  template: `
    <div class="page-content">
      <!-- Loading -->
      <div v-if="loading" class="loading-container" style="padding:80px 0">
        <div class="spinner"></div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="ds-empty" style="padding:80px 0">
        <p style="color:var(--color-secondary-text);margin-bottom:16px">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>

      <!-- Content -->
      <div v-else class="ds-container-760" style="padding-top:0;padding-bottom:40px">
        <!-- Title -->
        <div class="ds-page-head">
          <h1>{{ news.title }}</h1>
        </div>

        <!-- Author Row -->
        <div v-if="news.user" style="display:flex;align-items:center;gap:12px;margin-bottom:20px;padding-bottom:20px;border-bottom:1px solid var(--color-border)">
          <a v-if="news.user.guide_id" :href="'#/guide/' + news.user.guide_id"
            style="width:44px;height:44px;border-radius:50%;background:var(--color-accent-soft);overflow:hidden;flex-shrink:0;display:block;text-decoration:none">
            <img v-if="news.user.photo" :src="news.user.photo" style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px">👤</div>
          </a>
          <div v-else style="width:44px;height:44px;border-radius:50%;background:var(--color-accent-soft);overflow:hidden;flex-shrink:0">
            <img v-if="news.user.photo" :src="news.user.photo" style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px">👤</div>
          </div>
          <div style="flex:1;min-width:0">
            <div style="font-size:14px;font-weight:650">
              <a v-if="news.user.guide_id" :href="'#/guide/' + news.user.guide_id"
                style="color:var(--color-primary-text);text-decoration:none">{{ news.user.name }}</a>
              <span v-else>{{ news.user.name }}</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;margin-top:2px">
              <a v-if="news.user.city_name && news.user.city_id" :href="'#/city/detail?id=' + news.user.city_id"
                style="font-size:12px;color:var(--color-primary);text-decoration:none;font-weight:500">{{ news.user.city_name }}</a>
              <span v-else-if="news.user.city_name" style="font-size:12px;color:var(--color-assistant-text)">{{ news.user.city_name }}</span>
              <span v-if="news.created_at" style="font-size:12px;color:var(--color-assistant-text)">{{ formatDate(news.created_at) }}</span>
              <span v-if="news.view" style="font-size:12px;color:var(--color-assistant-text)">👁 {{ news.view }}</span>
            </div>
          </div>
          <a v-if="news.user.guide_id" :href="'#/guide/' + news.user.guide_id"
            class="ds-btn ds-btn-outline" style="padding:6px 14px;font-size:12px;height:auto;border-radius:20px">{{ $t('關注') }}</a>
        </div>

        <!-- Featured Image -->
        <div v-if="news.first_picture" style="border-radius:var(--radius-lg);overflow:hidden;margin-bottom:20px">
          <img :src="news.first_picture" style="width:100%;display:block">
        </div>

        <!-- Body Text -->
        <div v-if="news.content" style="font-size:15px;color:var(--color-primary-text);line-height:1.9;white-space:pre-wrap;margin-bottom:24px">{{ news.content }}</div>
        <div v-if="news.description && !news.content" style="font-size:15px;color:var(--color-primary-text);line-height:1.9;white-space:pre-wrap;margin-bottom:24px">{{ news.description }}</div>

        <!-- Gallery -->
        <div v-if="gallery.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:8px;margin-bottom:24px">
          <img v-for="(pic, i) in gallery" :key="i" :src="pic"
            style="width:100%;aspect-ratio:1;object-fit:cover;border-radius:var(--radius-sm);cursor:pointer"
            @click="previewImage(pic)">
        </div>

        <!-- Divider -->
        <div style="height:1px;background:var(--color-border);margin:24px 0"></div>

        <!-- Evaluation Section -->
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
          <h2 style="font-family:var(--font-serif);font-size:20px;font-weight:400;letter-spacing:-.01em;margin:0">
            {{ $t('評價') }}<span v-if="evaluations.length > 0" style="color:var(--color-assistant-text);font-size:14px;margin-left:8px">{{ evaluations.length }}</span>
          </h2>
          <button v-if="UserStore.isLogin" class="ds-btn ds-btn-sm ds-btn-primary"
            @click="$router.push('/evaluation/submit?type=news&id=' + newsId)">
            ✏️ {{ $t('寫評價') }}
          </button>
        </div>

        <!-- Evaluation List -->
        <div v-if="evalLoading" class="loading-container">
          <div class="spinner"></div>
        </div>
        <div v-else-if="evaluations.length > 0">
          <div v-for="ev in evaluations" :key="ev.id"
            style="padding:16px 0;border-bottom:1px solid var(--color-border-light)">
            <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px">
              <div style="width:36px;height:36px;border-radius:50%;background:var(--color-accent-soft);overflow:hidden;flex-shrink:0">
                <img v-if="ev.user?.avatar" :src="ev.user.avatar" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:16px">👤</div>
              </div>
              <div style="flex:1">
                <div style="font-size:13px;font-weight:650">{{ ev.user?.nickname || '用戶' }}</div>
                <div style="font-size:11px;color:var(--color-assistant-text)">{{ formatDate(ev.created_at) }}</div>
              </div>
              <div style="display:flex;gap:2px">
                <span v-for="s in 5" :key="s" style="color:var(--color-amber);font-size:14px">{{ s <= ev.star ? '★' : '☆' }}</span>
              </div>
            </div>
            <p v-if="ev.content" style="font-size:14px;color:var(--color-primary-text);line-height:1.6">{{ ev.content }}</p>
            <div v-if="ev.pictures && ev.pictures.length > 0" style="display:flex;gap:6px;margin-top:8px;flex-wrap:wrap">
              <img v-for="(pic, i) in ev.pictures" :key="i" :src="pic"
                style="width:80px;height:80px;object-fit:cover;border-radius:var(--radius-sm);cursor:pointer"
                @click="previewImage(pic)">
            </div>
          </div>
        </div>
        <div v-else class="ds-empty">{{ $t('暫無評價') }}</div>
      </div>
    </div>
  `,

  data() {
    return {
      newsId: 0,
      news: {},
      loading: true,
      error: null,
      evaluations: [],
      evalLoading: false
    };
  },

  computed: {
    gallery() {
      const pics = Array.isArray(this.news.pictures) ? this.news.pictures : [];
      if (this.news.first_picture) {
        return pics.filter(p => p !== this.news.first_picture);
      }
      return pics;
    }
  },

  methods: {
    async load() {
      const id = this.$route.params.id;
      if (!id) {
        this.error = '缺少資訊 ID';
        this.loading = false;
        return;
      }
      this.newsId = parseInt(id, 10);
      this.loading = true;
      this.error = null;

      const res = await ApiProvider.get(ApiUrl.informationInfo, { id: this.newsId });

      if (!res.success) {
        this.error = res.message || '載入失敗';
        this.loading = false;
        return;
      }

      this.news = res.data || {};
      this.loading = false;

      // Load evaluations
      this.loadEvaluations();
    },

    async loadEvaluations() {
      this.evalLoading = true;
      const res = await ApiProvider.get(ApiUrl.informationEvaluate, {
        information_id: this.newsId,
        page: 1,
        limit: 50
      });
      const list = res.data?.list || res.data || [];
      this.evaluations = Array.isArray(list) ? list : [];
      this.evalLoading = false;
    },

    formatDate(dateStr) {
      if (!dateStr) return '';
      return (dateStr + '').slice(0, 10);
    },

    previewImage(url) {
      this.$router.push('/photo?url=' + encodeURIComponent(url));
    }
  },

  mounted() {
    this.load();
  },

  watch: {
    '$route.params.id': function() {
      this.load();
    }
  }
};
