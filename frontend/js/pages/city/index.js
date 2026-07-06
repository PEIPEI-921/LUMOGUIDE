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

      <template v-if="continents.length">
        <!-- Continent Tabs -->
        <div class="filter-pills">
          <button v-for="(c, idx) in continents" :key="'ct-'+idx"
            class="filter-pill" :class="{ active: continentIndex === idx }"
            @click="selectContinent(idx)">
            {{ c.name || t('全部') }}
          </button>
        </div>

        <!-- Cities Grid -->
        <div class="card-grid-2" style="margin-top:8px;">
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

        <empty-state v-if="!currentCities.length && !loading" :text="t('暫無城市')" />
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
      const res = await ApiProvider.get(ApiUrl.cityList);
      this.loading = false;
      if (res.success && res.data) {
        this.continents = Array.isArray(res.data) ? res.data : [];
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
