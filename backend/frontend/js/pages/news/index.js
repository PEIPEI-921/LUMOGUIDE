/* ============================================
   NewsPage — Information/articles list
   Redesigned 2026-07-06: clean card layout, web-friendly
   ============================================ */

const NewsPage = {
  template: `
    <div class="page-content"><div class="ds-container-760" style="padding-top:12px;padding-bottom:40px">
      <!-- Category Filter Pills -->
      <div class="filter-pills" style="margin-bottom:16px" v-if="categories.length > 0">
        <button v-for="(cat, idx) in categories" :key="'ncat-'+idx"
          class="filter-pill" :class="{ active: catIndex === idx }"
          @click="selectCategory(idx)">
          {{ cat.name || t('全部') }}
        </button>
      </div>

      <!-- Loading -->
      <loading-spinner v-if="!newsList.length && loading" />

      <!-- Empty State -->
      <div v-else-if="!newsList.length && !loading" class="ds-empty" style="padding:60px 0">
        <div style="font-size:48px;margin-bottom:12px;opacity:.4">📰</div>
        <p style="color:var(--color-secondary-text)">{{ t('暫無資訊') }}</p>
      </div>

      <!-- News List — clean card layout -->
      <div v-else>
        <a v-for="news in newsList" :key="'n-'+news.id"
          :href="'#/news/' + news.id"
          class="ds-card ds-card-hover"
          style="text-decoration:none;color:inherit;display:block;overflow:hidden;margin-bottom:14px">

          <!-- Cover Image -->
          <div v-if="news.first_picture" style="height:200px;overflow:hidden;background:var(--color-bg-card)">
            <img :src="imageUrl(news.first_picture)" :alt="news.title"
              style="width:100%;height:100%;object-fit:cover">
          </div>

          <!-- Content -->
          <div style="padding:18px 20px">
            <!-- Title -->
            <h2 style="font-family:var(--font-serif);font-size:18px;font-weight:600;line-height:1.45;color:var(--color-primary-text);margin:0 0 8px;letter-spacing:-.01em;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">
              {{ news.title }}
            </h2>

            <!-- Description -->
            <p v-if="news.desc" style="font-size:13.5px;color:var(--color-secondary-text);line-height:1.6;margin:0 0 14px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">
              {{ news.desc }}
            </p>

            <!-- Meta Row -->
            <div style="display:flex;align-items:center;justify-content:space-between;font-size:12px;color:var(--color-assistant-text)">
              <div style="display:flex;align-items:center;gap:8px">
                <span v-if="news.user" style="display:flex;align-items:center;gap:4px">
                  <span style="width:20px;height:20px;border-radius:50%;background:var(--color-accent-soft);overflow:hidden;display:inline-flex;align-items:center;justify-content:center;flex-shrink:0">
                    <img v-if="news.user.photo" :src="news.user.photo" style="width:100%;height:100%;object-fit:cover">
                    <span v-else style="font-size:10px">{{ (news.user.name || '?')[0] }}</span>
                  </span>
                  {{ news.user.name }}
                </span>
                <span v-if="news.created_at">{{ formatDate(news.created_at) }}</span>
              </div>
              <div style="display:flex;align-items:center;gap:12px">
                <span v-if="news.view">👁 {{ news.view }}</span>
                <span v-if="news.evaluate_count !== undefined">💬 {{ news.evaluate_count }}</span>
              </div>
            </div>
          </div>
        </a>

        <!-- Load More -->
        <div v-if="hasMore" style="text-align:center;padding:16px 0">
          <button @click="fetchNews()" :disabled="loading"
            class="ds-btn ds-btn-outline" style="border-radius:100px;font-size:13px">
            {{ loading ? t('加載中...') : t('載入更多') }}
          </button>
        </div>

        <div v-else-if="newsList.length > 0" style="text-align:center;padding:20px 0;color:var(--color-assistant-text);font-size:12px">
          {{ t('已加載全部') }}
        </div>
      </div>
    </div>
    </div>
  `,

  data() {
    return {
      categories: [],
      catIndex: 0,
      newsList: [],
      page: 1,
      hasMore: true,
      loading: false
    };
  },

  methods: {
    t(key) { return I18n.t(key); },
    imageUrl,
    formatDate(d) { return d ? (d + '').slice(0, 10) : ''; },

    async fetchCategories() {
      const res = await ApiProvider.get(ApiUrl.getInformationClass);
      if (res.success && res.data) {
        this.categories = Array.isArray(res.data) ? res.data : [];
      }
    },

    async fetchNews(reset = false) {
      if (this.loading) return;
      if (reset) { this.page = 1; this.hasMore = true; this.newsList = []; }
      if (!this.hasMore) return;

      this.loading = true;
      const catId = this.categories[this.catIndex]?.id;
      const res = await ApiProvider.get(ApiUrl.informationLists, {
        page: this.page,
        class_id: catId || ''
      });
      this.loading = false;

      if (res.success && res.data) {
        const list = Array.isArray(res.data) ? res.data : (res.data.data || []);
        if (reset) {
          this.newsList = list;
        } else {
          this.newsList = [...this.newsList, ...list];
        }
        this.hasMore = list.length > 0;
        if (list.length > 0) this.page++;
      }
    },

    selectCategory(idx) {
      this.catIndex = idx;
      this.fetchNews(true);
    }
  },

  mounted() {
    this.fetchCategories();
    this.fetchNews(true);
  }
};
