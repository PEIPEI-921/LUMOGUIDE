/* ============================================
   NewsPage — Information/articles list
   Weibo-style feed: white cards, large images,
   avatar-left layout, clean action bar
   ============================================ */

const NewsPage = {
  template: `
    <div class="page-content">
      <!-- Category Pills — glassmorphism purple, rounded rectangle -->
      <div v-if="allCategories.length > 1" style="display:flex;gap:8px;padding:16px 16px 8px;overflow-x:auto;scrollbar-width:none;max-width:760px;margin:0 auto">
        <button v-for="(cat, idx) in allCategories" :key="'ncat-'+idx"
          @click="selectCategory(idx)"
          style="font-size:12px;font-weight:500;white-space:nowrap;padding:7px 16px;border-radius:8px;cursor:pointer;transition:all .2s;letter-spacing:.01em;border:1px solid;backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)"
          :style="catIndex === idx
            ? { background: '#5B4FCF', color: '#fff', borderColor: '#5B4FCF' }
            : { background: 'rgba(255,255,255,.5)', color: '#6B7280', borderColor: 'rgba(0,0,0,.06)' }">
          {{ cat.name }}
        </button>
      </div>

      <!-- Feed Area -->
      <div class="ds-container-760" style="padding-top:8px">
        <!-- Loading -->
        <div v-if="!newsList.length && loading" style="display:flex;justify-content:center;padding:80px 0">
          <div class="spinner"></div>
        </div>

        <!-- Empty -->
        <div v-else-if="!newsList.length && !loading" style="text-align:center;padding:80px 0">
          <div style="font-size:40px;margin-bottom:12px;opacity:.25"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 22h16a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 0-2 2Z"/><path d="M4 6h16"/><path d="M4 10h16"/><path d="M4 14h10"/></svg></div>
          <p style="color:var(--color-secondary-text);font-size:14px;margin-bottom:20px">{{ t('暫無資訊') }}</p>
          <button @click="fetchNews(true)" style="font-size:13px;color:var(--color-primary);background:none;border:none;cursor:pointer;font-weight:500">{{ t('重新載入') }}</button>
        </div>

        <!-- Feed Cards -->
        <div v-else>
          <div v-for="news in newsList" :key="'n-'+news.id"
            style="background:var(--color-bg-white);border-radius:12px;padding:16px;margin-bottom:10px;box-shadow:0 1px 3px rgba(0,0,0,.04);cursor:pointer;transition:box-shadow .2s"
            @click="$router.push('/news/' + news.id)"
            @mouseenter="$event.currentTarget.style.boxShadow='0 2px 12px rgba(0,0,0,.08)'"
            @mouseleave="$event.currentTarget.style.boxShadow='0 1px 3px rgba(0,0,0,.04)'">

            <!-- Header: Avatar + Info -->
            <div v-if="news.user" style="display:flex;align-items:flex-start;gap:10px;margin-bottom:10px">
              <!-- Avatar -->
              <span style="width:40px;height:40px;border-radius:50%;background:var(--color-accent-soft);overflow:hidden;flex-shrink:0;display:inline-flex;align-items:center;justify-content:center">
                <img v-if="news.user.photo" :src="news.user.photo" style="width:100%;height:100%;object-fit:cover" alt="">
                <span v-else style="font-size:16px;color:var(--color-primary);font-weight:600">{{ (news.user.name || '?')[0] }}</span>
              </span>

              <!-- Name + Meta -->
              <div style="flex:1;min-width:0">
                <div style="display:flex;align-items:center;gap:8px;margin-bottom:2px">
                  <span style="font-size:14px;font-weight:600;color:#1a1a1a;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ news.user.name }}</span>
                  <span v-if="news.user.identity_type" style="font-size:10px;color:var(--color-primary);padding:1px 7px;border-radius:100px;background:var(--color-accent-soft);white-space:nowrap;flex-shrink:0">{{ news.user.identity_type }}</span>
                </div>
                <div style="font-size:12px;color:var(--color-assistant-text);display:flex;align-items:center;gap:6px">
                  <span v-if="news.created_at">{{ formatDate(news.created_at) }}</span>
                  <span v-if="news.view" style="display:flex;align-items:center;gap:2px"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg> {{ news.view }}</span>
                </div>
              </div>
            </div>

            <!-- Body: text + thumbnail -->
            <div style="display:flex;gap:12px">
              <div style="flex:1;min-width:0">
                <!-- Title -->
                <h2 style="font-size:16px;font-weight:600;line-height:1.5;color:#1a1a1a;margin:0 0 6px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;letter-spacing:-.01em">
                  {{ news.title }}
                </h2>
                <!-- Description -->
                <p v-if="news.desc" style="font-size:14px;color:var(--color-secondary-text);line-height:1.7;margin:0;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">
                  {{ news.desc }}
                </p>
              </div>
              <!-- Thumbnail -->
              <div v-if="news.first_picture" style="width:72px;height:72px;border-radius:8px;overflow:hidden;flex-shrink:0;background:var(--color-bg-card);align-self:flex-start">
                <img :src="imageUrl(news.first_picture)" :alt="news.title"
                  style="width:100%;height:100%;object-fit:cover;display:block">
              </div>
            </div>

            <!-- Action Bar -->
            <div style="display:flex;align-items:center;justify-content:space-between;padding-top:10px;border-top:1px solid rgba(0,0,0,.04)">
              <div style="display:flex;align-items:center;gap:16px;font-size:11px;color:var(--color-assistant-text)">
                <span v-if="news.evaluate_count !== undefined" style="display:flex;align-items:center;gap:3px">💬 {{ news.evaluate_count }}</span>
                <span v-if="news.view" style="display:flex;align-items:center;gap:3px"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg> {{ news.view }}</span>
              </div>
            </div>
          </div>

          <!-- Load More -->
          <div v-if="hasMore" style="text-align:center;padding:20px 0">
            <button @click="fetchNews()" :disabled="loading"
              style="font-size:13px;color:var(--color-primary);background:transparent;border:none;cursor:pointer;font-weight:500;padding:8px 24px;border-radius:100px;transition:background .15s"
              @mouseenter="$event.currentTarget.style.background='var(--color-accent-soft)'"
              @mouseleave="$event.currentTarget.style.background='transparent'">
              {{ loading ? t('加載中...') : t('載入更多') }}
            </button>
          </div>

          <div v-else-if="newsList.length > 0" style="text-align:center;padding:20px 0;color:var(--color-assistant-text);font-size:12px">
            — {{ t('已加載全部') }} —
          </div>

          <div style="height:80px"></div>
        </div>
      </div>

      <!-- Publish FAB -->
      <a v-if="isGuide"
        href="#" @click.prevent="onPublishNews"
        style="position:fixed;bottom:28px;right:28px;z-index:200;display:flex;flex-direction:column;align-items:center;gap:2px;width:52px;height:52px;border-radius:50%;background:#666FFF;color:#fff;text-decoration:none;box-shadow:0 4px 16px rgba(102,111,255,.35);transition:transform .2s,box-shadow .2s;justify-content:center"
        @mouseenter="$event.currentTarget.style.transform='scale(1.06)';$event.currentTarget.style.boxShadow='0 6px 20px rgba(102,111,255,.45)'"
        @mouseleave="$event.currentTarget.style.transform='';$event.currentTarget.style.boxShadow='0 4px 16px rgba(102,111,255,.35)'">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        <span style="font-size:9px;font-weight:600;line-height:1">{{ t('發佈') }}</span>
      </a>
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

  computed: {
    allCategories() {
      const list = [{ id: null, name: I18n.t('全部') }];
      return list.concat(this.categories.filter(c => c.count > 0));
    },
    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    }
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
      const cat = this.allCategories[this.catIndex];
      const catId = cat && cat.id ? cat.id : '';
      const res = await ApiProvider.get(ApiUrl.informationLists, {
        page: this.page,
        class_id: catId
      });
      this.loading = false;

      if (res.success && res.data) {
        const list = Array.isArray(res.data) ? res.data : (res.data.list || []);
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

    onPublishNews() {
      if (!UserStore.isVip) {
        this.$router.push('/vip');
        return;
      }
      this.$router.push('/publish/information');
    }
  },

  mounted() {
    this.fetchCategories();
    this.fetchNews(true);
  }
};
