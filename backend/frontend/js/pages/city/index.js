/* ============================================
   CityPage — City list browser
   Mirrors Flutter CityPage
   ============================================ */

const CityPage = {
  template: `
    <div class="page-content">
      <div class="search-bar" style="margin-top:12px;">
        <span>🔍</span>
        <input v-model="searchKeyword" :placeholder="t('請輸入城市/導遊/內容')"
          @keyup.enter="goSearch" />
      </div>

      <div class="ds-page-wrapper">
      <loading-spinner v-if="!continents.length && loading" />

      <!-- Fallback empty: no continents loaded at all -->
      <div v-if="!continents.length && !loading" style="text-align:center;padding:60px 0">
        <div style="font-size:48px;margin-bottom:12px;opacity:.3">🌍</div>
        <p style="color:var(--color-secondary-text);font-size:14px;margin-bottom:16px">{{ t('暫無城市數據') }}</p>
        <button @click="fetchCities" class="ds-btn ds-btn-outline" style="border-radius:100px">{{ t('重新載入') }}</button>
      </div>

      <template v-if="continents.length">
        <!-- Continent Tabs -->
        <div class="filter-pills" style="margin-top:8px">
          <button v-for="(c, idx) in continents" :key="'ct-'+idx"
            class="filter-pill" :class="{ active: continentIndex === idx }"
            @click="selectContinent(idx)">
            {{ c.name || t('全部') }}
          </button>
        </div>

        <!-- Cities Grid -->
        <div class="card-grid-2" style="margin-top:12px">
          <div v-for="city in currentCities" :key="'city-'+city.id"
            class="city-card" style="cursor:pointer;" @click="goCityDetail(city.id)">
            <img class="city-img" :src="imageUrl(city.first_picture)" />
            <div class="city-overlay">
              <span class="city-name">{{ city.name }}</span>
              <span v-if="city.name_en" class="city-name-en">{{ city.name_en }}</span>
              <span v-if="city.area_name" class="city-badge">{{ city.area_name }}</span>
            </div>
          </div>
        </div>

        <div v-if="!currentCities.length && !loading" style="text-align:center;padding:30px 0;color:var(--color-assistant-text);font-size:13px">
          {{ t('此分類暫無城市') }}
        </div>
      </template>

      <div style="height:20px;"></div>
    </div>
    </div>
  `,

  data() {
    return {
      continents: [],
      continentIndex: 0,
      loading: false,
      searchKeyword: ''
    };
  },

  computed: {
    currentCities() {
      return this.continents[this.continentIndex]?.city || [];
    }
  },

  methods: {
    t(key) { return I18n.t(key); },
    imageUrl,

    async fetchCities() {
      this.loading = true;
      const res = await ApiProvider.get(ApiUrl.cityList, { limit: 1000, page: 1 });
      this.loading = false;
      if (res.success && res.data) {
        const list = res.data.list || res.data || [];
        const cities = Array.isArray(list) ? list : [];

        // Group cities by continent (reuse home page's AREA_TO_CONTINENT mapping)
        const continentMap = {};
        cities.forEach(city => {
          const areaName = city.area_name || '';
          const continent = (typeof AREA_TO_CONTINENT !== 'undefined' && AREA_TO_CONTINENT[areaName])
            || areaName || this.t('其他');
          if (!continentMap[continent]) {
            continentMap[continent] = { name: continent, city: [] };
          }
          continentMap[continent].city.push(city);
        });

        // Sort continents in a consistent order
        const order = ['亚洲', '亞洲', '欧洲', '歐洲', '北美洲', '南美洲', '非洲', '大洋洲'];
        const result = [];
        order.forEach(name => {
          const match = Object.keys(continentMap).find(k => k === name);
          if (match) {
            result.push(continentMap[match]);
            delete continentMap[match];
          }
        });
        // Append any remaining continents not in the order list
        Object.values(continentMap).forEach(g => result.push(g));

        this.continents = result;
      }
    },

    selectContinent(idx) {
      this.continentIndex = idx;
    },

    goCityDetail(id) {
      this.$router.push('/city/detail?id=' + id);
    },

    goSearch() {
      if (this.searchKeyword.trim()) {
        this.$router.push('/search?keyword=' + encodeURIComponent(this.searchKeyword.trim()));
      }
    }
  },

  mounted() {
    this.fetchCities();
  }
};
