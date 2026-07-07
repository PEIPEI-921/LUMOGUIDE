/* ============================================
   Search Page — 搜索
   Reference: PPCC search/page.tsx
   ============================================ */

const SearchPage = {
  template: `
    <div class="page-content"><div class="ds-container-960" style="padding-top:16px;padding-bottom:16px">
      <!-- Search Input -->
      <div class="ds-hero-search" style="margin-bottom:16px">
        <input type="text" v-model="query" :placeholder="$t('搜尋城市、導遊或景點…')"
          @input="onSearchInput" @keyup.enter="doSearch">
        <button @click="doSearch">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          {{ $t('搜尋') }}
        </button>
      </div>

      <!-- Result Tabs -->
      <div v-if="hasSearched" class="ds-tabs" style="margin:0 0 16px">
        <button v-for="tab in resultTabs" :key="tab.key"
          @click="activeResultTab = tab.key"
          :class="['ds-tab', { active: activeResultTab === tab.key }]">
          {{ tab.label }}
          <span v-if="tab.count > 0" style="font-size:10px;opacity:.5;margin-left:4px">{{ tab.count }}</span>
        </button>
      </div>

      <!-- Loading -->
      <div v-if="searching" class="loading-container">
        <div class="spinner"></div>
      </div>

      <!-- Results -->
      <div v-else-if="hasSearched">
        <!-- Cities -->
        <div v-if="activeResultTab === 'city'">
          <div v-if="results.city.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(180px, 1fr));gap:12px">
            <a v-for="c in results.city" :key="c.id" :href="'#/city/detail?id=' + c.id"
              class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block;overflow:hidden">
              <div style="aspect-ratio:4/3;overflow:hidden;background:var(--color-bg-card)">
                <img v-if="c.first_picture" :src="c.first_picture" :alt="c.name" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:32px;opacity:.3">🏙️</div>
              </div>
              <div style="padding:14px 16px">
                <div style="font-size:14.5px;font-weight:600">{{ c.name }}</div>
                <div v-if="c.name_en" style="font-size:11.5px;color:var(--color-assistant-text);margin-top:2px">{{ c.name_en }}</div>
                <div v-if="c.area_name" style="margin-top:6px">
                  <span style="font-size:10px;padding:2px 8px;border-radius:20px;background:rgba(0,0,0,.38);color:#fff;backdrop-filter:blur(6px)">{{ c.area_name }}</span>
                </div>
              </div>
            </a>
          </div>
          <div v-else class="ds-empty">{{ $t('暫無結果') }}</div>
        </div>

        <!-- Guides -->
        <div v-if="activeResultTab === 'guide'">
          <div v-if="results.guide.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(160px, 1fr));gap:12px">
            <a v-for="g in results.guide" :key="g.id" :href="'#/guide/' + g.id"
              class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block;overflow:hidden">
              <div style="aspect-ratio:3/4;overflow:hidden;background:var(--color-bg-card)">
                <img v-if="g.photo" :src="g.photo" :alt="g.name" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:28px">👤</div>
              </div>
              <div style="padding:10px">
                <div style="font-size:12.5px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ g.name }}</div>
                <div style="font-size:10px;color:var(--color-assistant-text);margin-top:2px">{{ g.city_name || '' }}</div>
              </div>
            </a>
          </div>
          <div v-else class="ds-empty">{{ $t('暫無結果') }}</div>
        </div>

        <!-- Content -->
        <div v-if="activeResultTab === 'content'">
          <div v-if="results.content.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(160px, 1fr));gap:12px">
            <a v-for="item in results.content" :key="item.id"
              :href="item.data_type === 'info' ? '#/news/' + item.id :
                (item.city_id ? '#/city/detail?id=' + item.city_id : '#')"
              class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block;overflow:hidden">
              <div style="aspect-ratio:4/3;overflow:hidden;background:var(--color-bg-card)">
                <img v-if="item.first_picture" :src="item.first_picture" :alt="item.name" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:24px;opacity:.3">📷</div>
              </div>
              <div style="padding:10px">
                <div style="font-size:12.5px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.name }}</div>
                <div style="display:flex;align-items:center;gap:6px;margin-top:4px">
                  <span v-if="item.type_name" class="ds-badge-sm ds-badge-primary">{{ item.type_name }}</span>
                  <span v-if="item.city_name" style="font-size:10px;color:var(--color-assistant-text)">{{ item.city_name }}</span>
                </div>
              </div>
            </a>
          </div>
          <div v-else class="ds-empty">{{ $t('暫無結果') }}</div>
        </div>
      </div>

      <!-- Empty (no search yet) -->
      <div v-else class="ds-empty">
        <div style="font-size:48px;margin-bottom:12px">🔍</div>
        <p>{{ $t('輸入關鍵字開始搜索') }}</p>
      </div>
    </div>
    </div>
  `,

  data() {
    return {
      query: '',
      results: { city: [], guide: [], content: [] },
      searching: false,
      hasSearched: false,
      activeResultTab: 'city',
      searchTimer: null,
      resultTabs: [
        { key: 'city', label: '城市', count: 0 },
        { key: 'guide', label: '導遊', count: 0 },
        { key: 'content', label: '內容', count: 0 }
      ]
    };
  },

  methods: {
    onSearchInput() {
      if (this.searchTimer) clearTimeout(this.searchTimer);
      if (!this.query.trim()) return;
      this.searchTimer = setTimeout(() => {
        this.doSearch();
      }, 500);
    },

    async doSearch() {
      const text = this.query.trim();
      if (!text) return;

      this.searching = true;
      this.hasSearched = true;

      const res = await ApiProvider.get(ApiUrl.homeSearch, { name: text });

      // API returns flat array with data_type: 1=city, 2=guide, 3=content
      if (res.success && res.data) {
        const list = Array.isArray(res.data) ? res.data : (res.data.list || []);
        this.results.city = list.filter(item => Number(item.data_type) === 1);
        this.results.guide = list.filter(item => Number(item.data_type) === 2);
        this.results.content = list.filter(item => Number(item.data_type) === 3);

        // Update counts
        this.resultTabs[0].count = this.results.city.length;
        this.resultTabs[1].count = this.results.guide.length;
        this.resultTabs[2].count = this.results.content.length;

        // Auto-select first non-empty tab
        if (this.results.city.length > 0) this.activeResultTab = 'city';
        else if (this.results.guide.length > 0) this.activeResultTab = 'guide';
        else this.activeResultTab = 'content';
      } else {
        this.results = { city: [], guide: [], content: [] };
        this.resultTabs.forEach(t => t.count = 0);
      }

      this.searching = false;
    }
  },

  mounted() {
    // If query param is present, pre-fill search
    const q = this.$route.query.keyword;
    if (q) {
      this.query = q;
      this.doSearch();
    }
  },

  beforeUnmount() {
    if (this.searchTimer) { clearTimeout(this.searchTimer); this.searchTimer = null; }
  }
};
