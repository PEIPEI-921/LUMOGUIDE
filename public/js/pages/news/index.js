/* ============================================
   NewsPage — Information/articles list
   Mirrors Flutter NewsPage
   ============================================ */

const NewsPage = {
  template: `
    <div class="page-content">
      <!-- Category Filter -->
      <div class="filter-pills" style="margin-top:8px;" v-if="categories.length > 0">
        <button v-for="(cat, idx) in categories" :key="'ncat-'+idx"
          class="filter-pill" :class="{ active: catIndex === idx }"
          @click="selectCategory(idx)">
          {{ cat.name || t('全部') }}
        </button>
      </div>

      <loading-spinner v-if="!newsList.length && loading" />

      <!-- News List -->
      <div v-if="newsList.length">
        <div v-for="news in newsList" :key="'n-'+news.id"
          class="news-card" style="cursor:pointer;" @click="goDetail(news.id)">
          <div class="news-content">
            <div class="news-title">{{ news.title }}</div>
            <div class="news-desc">{{ news.desc || '' }}</div>
            <div class="news-meta">
              <span v-if="news.user">{{ news.user.name || '' }}</span>
              <span v-if="news.evaluate_count">💬 {{ news.evaluate_count }}</span>
              <span v-if="news.view">👁 {{ news.view }}</span>
              <span>{{ news.created_at || '' }}</span>
            </div>
          </div>
          <img v-if="news.first_picture" class="news-img" :src="imageUrl(news.first_picture)" />
        </div>

        <div v-if="!hasMore" style="text-align:center;padding:20px;color:var(--color-assistant-text);font-size:12px;">
          {{ t('已加載全部') }}
        </div>
      </div>

      <empty-state v-if="!newsList.length && !loading" :text="t('暫無記錄')" />
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

    async fetchCategories() {
      const res = await ApiProvider.get(ApiUrl.getInformationClass);
      if (res.success && res.data) {
        this.categories = Array.isArray(res.data) ? res.data : [];
      }
    },

    async fetchNews(reset = false) {
      if (this.loading) return;
      if (reset) { this.page = 1; this.hasMore = true; }
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
    },

    goDetail(id) {
      this.$router.push('/news/' + id);
    }
  },

  mounted() {
    this.fetchCategories();
    this.fetchNews(true);
  }
};
