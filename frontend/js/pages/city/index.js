/* ============================================
   CityPage — City list browser
   Premium minimal design, server-driven
   ============================================ */

const CityPage = {
  template: `
    <div class="page-content" style="padding:0">
      <!-- Minimal Search Bar -->
      <div style="max-width:480px;margin:0 auto;padding:20px 32px 0">
        <div style="display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid rgba(0,0,0,.08);transition:border-color .25s"
          :style="{ borderBottomColor: searchFocused ? 'rgba(0,0,0,.2)' : '' }">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input v-model="searchKeyword" :placeholder="$t('搜索城市...')"
            @keyup.enter="goSearch" @focus="searchFocused=true" @blur="searchFocused=false"
            style="flex:1;background:none;font-size:15px;color:#162539;outline:none;border:none;font-family:inherit" />
        </div>
      </div>

      <div class="ds-page-wrapper" style="padding-top:16px">
      <!-- Guide Toolbar -->
      <div v-if="isGuide" style="display:flex;justify-content:flex-end;padding:0 var(--spacing-lg);margin-bottom:6px">
        <a href="#" @click.prevent="onPublishCity"
          style="display:inline-flex;align-items:center;gap:5px;font-size:13px;color:#fff;font-weight:500;text-decoration:none;background:#666FFF;padding:8px 20px;border-radius:8px;transition:background .2s,transform .15s;letter-spacing:.01em"
          @mouseenter="$event.currentTarget.style.background='#5A5FE8';$event.currentTarget.style.transform='translateY(-1px)'"
          @mouseleave="$event.currentTarget.style.background='#666FFF';$event.currentTarget.style.transform=''">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          發布城市
        </a>
      </div>

      <!-- Loading -->
      <div v-if="!continents.length && loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <!-- Error / Empty -->
      <div v-if="!continents.length && !loading" style="text-align:center;padding:80px 0">
        <p v-if="pageError" style="color:#EF4444;font-size:14px;margin-bottom:20px">{{ pageError }}</p>
        <p v-else style="color:#9CA3AF;font-size:14px;margin-bottom:20px">{{ $t('暫無城市數據') }}</p>
        <button @click="fetchContinents" style="font-size:13px;color:#666FFF;background:none;border:none;cursor:pointer;font-weight:500">{{ $t('重新載入') }}</button>
      </div>

      <template v-if="continents.length">
        <!-- Continent Tabs — minimal underline style -->
        <div style="display:flex;gap:28px;padding:4px var(--spacing-lg) 12px;overflow-x:auto">
          <button v-for="(c, idx) in continents" :key="'ct-'+c.id"
            @click="selectContinent(idx)"
            style="font-size:14px;font-weight:400;white-space:nowrap;padding:0 0 6px;background:none;border:none;cursor:pointer;transition:all .2s;position:relative;letter-spacing:.01em"
            :style="{ color: continentIndex === idx ? '#162539' : '#9CA3AF' }">
            {{ c.name }}
            <span v-if="continentIndex === idx" style="position:absolute;bottom:0;left:0;right:0;height:2px;background:#162539;border-radius:1px"></span>
          </button>
        </div>

        <!-- Area pills — subtle chips -->
        <div v-if="currentAreas.length > 1" style="display:flex;gap:6px;padding:0 var(--spacing-lg) 16px;overflow-x:auto">
          <button v-for="(area, idx) in currentAreas" :key="'ar-'+area.id"
            @click="selectArea(idx)"
            style="font-size:11px;font-weight:400;white-space:nowrap;padding:4px 12px;border-radius:100px;cursor:pointer;transition:all .2s;letter-spacing:.02em"
            :style="{ background: areaIndex === idx ? '#162539' : 'transparent', color: areaIndex === idx ? '#fff' : '#6B7280', border: areaIndex === idx ? '1px solid #162539' : '1px solid rgba(0,0,0,.08)' }">
            {{ area.name }}
          </button>
        </div>

        <!-- Cities Grid — 4 columns, clean cards -->
        <div class="card-grid-4" style="margin-top:0;gap:20px">
          <div v-for="city in currentCities" :key="'city-'+city.id"
            @click="goCityDetail(city.id)"
            style="position:relative;border-radius:8px;overflow:hidden;aspect-ratio:1/1;cursor:pointer;background:#E5E7EB;transition:transform .25s"
            @mouseenter="$event.currentTarget.style.transform='translateY(-2px)'"
            @mouseleave="$event.currentTarget.style.transform=''">
            <img :src="imageUrl(city.first_picture)" alt="" loading="lazy"
              style="width:100%;height:100%;object-fit:cover;transition:transform .5s"
              @mouseenter="$event.currentTarget.style.transform='scale(1.04)'"
              @mouseleave="$event.currentTarget.style.transform=''" />
            <!-- Bottom gradient + text -->
            <div style="position:absolute;bottom:0;left:0;right:0;padding:32px 12px 10px;background:linear-gradient(to top, rgba(0,0,0,.5) 0%, transparent 100%)">
              <div style="display:flex;align-items:center;gap:5px;margin-bottom:2px">
                <span style="color:#fff;font-size:13px;font-weight:500;letter-spacing:.01em;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;flex:1">{{ city.name }}</span>
                <span v-if="city.area_name" style="color:rgba(255,255,255,.75);font-size:9px;font-weight:400;padding:1px 6px;border:1px solid rgba(255,255,255,.3);border-radius:100px;white-space:nowrap;flex-shrink:0">{{ city.area_name }}</span>
              </div>
              <span v-if="city.name_en" style="color:rgba(255,255,255,.5);font-size:10px;font-weight:400">{{ city.name_en }}</span>
            </div>
          </div>
        </div>

        <div v-if="!currentCities.length && !tabLoading" style="text-align:center;padding:60px 0;color:#9CA3AF;font-size:13px">
          {{ $t('此分類暫無城市') }}
        </div>
        <div v-if="tabLoading" style="text-align:center;padding:40px 0">
          <div class="spinner"></div>
        </div>
      </template>

      <div style="height:60px;"></div>
    </div>
    </div>
  `,

  data() {
    return {
      continents: [],       // [{id, name, areas: [{id, name}]}]
      continentIndex: 0,
      areaIndex: 0,         // index within current continent's areas
      cities: [],           // currently displayed cities
      loading: false,
      tabLoading: false,
      pageError: '',
      searchKeyword: '',
      searchFocused: false
    };
  },

  computed: {
    currentAreas() {
      const c = this.continents[this.continentIndex];
      return c ? (c.areas || []) : [];
    },
    currentCities() {
      return this.cities;
    },
    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    }
  },

  methods: {
    imageUrl,

    async fetchContinents() {
      this.loading = true;
      this.pageError = '';
      try {
        // Step 1: Fetch continent list only (1 API call — fast)
        const res = await ApiProvider.get(ApiUrl.getContinentsList, { parent_id: 0 });
        if (!res.success) {
          this.loading = false;
          this.pageError = (res.message || '載入失敗');
          return;
        }
        const continentList = res.data?.list || res.data || [];

        // Show tabs immediately — areas empty, will lazy-load
        this.continents = continentList.map(c => ({ id: c.id, name: c.name, areas: [] }));
        this.continentIndex = 0;
        this.areaIndex = 0;

        if (this.continents.length > 0) {
          // Step 2: Fetch areas ONLY for first continent (1 API call — not all)
          await this.loadAreasForContinent(0);
          // Step 3: Fetch cities for first continent's first area (1 API call)
          await this.fetchCities();
        }
      } catch (e) {
        console.error('[CityPage] fetchContinents error:', e);
        this.pageError = e.message || '網絡錯誤';
      }
      this.loading = false;
    },

    /** Lazy-load areas for a continent (only when needed) */
    async loadAreasForContinent(idx) {
      const c = this.continents[idx];
      if (!c || c.areas.length > 0) return; // Already loaded
      try {
        const areaRes = await ApiProvider.get(ApiUrl.getContinentsList, { parent_id: c.id });
        c.areas = areaRes.success ? (areaRes.data?.list || areaRes.data || []) : [];
      } catch (e) {
        console.error('[CityPage] loadAreasForContinent error:', e);
        c.areas = [];
      }
    },

    async selectContinent(idx) {
      this.continentIndex = idx;
      this.areaIndex = 0;
      this.cities = [];
      // Lazy-load areas for this continent if not yet fetched
      await this.loadAreasForContinent(idx);
      this.fetchCities();
    },

    selectArea(idx) {
      this.areaIndex = idx;
      this.cities = [];
      this.fetchCities();
    },

    async fetchCities() {
      const c = this.continents[this.continentIndex];
      if (!c) return;
      const area = c.areas[this.areaIndex];

      this.tabLoading = true;
      try {
        const params = { page: 1, limit: 100 };
        if (c.id) params.continents_id = c.id;
        if (area && area.id) params.area_id = area.id;

        const res = await ApiProvider.get(ApiUrl.cityList, params);
        if (res.success) {
          const list = res.data?.list || res.data || [];
          this.cities = Array.isArray(list) ? list : [];
        } else {
          this.cities = [];
        }
      } catch (e) {
        console.error('[CityPage] fetchCities error:', e);
        this.cities = [];
      }
      this.tabLoading = false;
    },

    goCityDetail(id) {
      this.$router.push('/city/detail?id=' + id);
    },

    goSearch() {
      if (this.searchKeyword.trim()) {
        this.$router.push('/search?keyword=' + encodeURIComponent(this.searchKeyword.trim()));
      }
    },

    // Publish city — VIP gate on click (matching Flutter VIPCheckUtils.check())
    onPublishCity() {
      if (!UserStore.isVip) {
        this.$router.push('/vip');
        return;
      }
      this.$router.push('/guide/publish-city-form');
    }
  },

  mounted() {
    this.fetchContinents();
  }
};
