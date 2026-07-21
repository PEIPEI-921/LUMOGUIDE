/* ============================================
   HomePage — Main home tab with all sections
   Mirrors Flutter HomePage + HomeController
   ============================================ */

// Sub-region → top-level continent mapping (API returns area_name as sub-region)
const AREA_TO_CONTINENT = {
  // Europe
  '西欧': '欧洲', '西歐': '欧洲',
  '东欧': '欧洲', '東歐': '欧洲',
  '南欧': '欧洲', '南歐': '欧洲',
  '北欧': '欧洲', '北歐': '欧洲',
  '中欧': '欧洲', '中歐': '欧洲',
  // Asia
  '东亚': '亚洲', '東亞': '亚洲',
  '东南亚': '亚洲', '東南亞': '亚洲',
  '南亚': '亚洲', '南亞': '亚洲',
  '中亚': '亚洲', '中亞': '亚洲',
  '西亚': '亚洲', '西亞': '亚洲',
  // Americas
  '北美': '北美洲',
  '南美': '南美洲',
  '中美': '北美洲',
  '加勒比': '北美洲',
  // Africa
  '北非': '非洲',
  '东非': '非洲', '東非': '非洲',
  '西非': '非洲',
  '南非': '非洲',
  '中非': '非洲',
  // Oceania
  '澳新': '大洋洲',
  '澳洲': '大洋洲',
  '澳大利亚': '大洋洲', '澳大利亞': '大洋洲',
};

// Top-level continent names (identity mapping)
const TOP_CONTINENTS = new Set([
  '欧洲', '歐洲',
  '亚洲', '亞洲',
  '北美洲', '南美洲',
  '非洲',
  '大洋洲',
  '南极洲', '南極洲',
]);

const HomePage = {
  template: `
    <div class="page-content">
      <!-- Search Bar -->
      <div class="search-bar">
        <svg width="18" height="18" viewBox="0 0 24 24" style="flex-shrink:0;opacity:.35"><circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><line x1="16.5" y1="16.5" x2="21" y2="21" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
        <input
          v-model="searchQuery"
          :placeholder="t('請輸入城市/導遊/內容')"
          @input="onSearchInput"
          @keyup.enter="onSearchEnter" />
      </div>

      <!-- Search Results Overlay -->
      <div v-if="searchResults.length > 0" class="card" style="margin:0 12px; max-height:360px; overflow-y:auto; position:absolute; z-index:200; left:0; right:0; box-shadow:var(--shadow-popup);">
        <div v-for="item in searchResults" :key="'s-'+item.id" class="flex items-center gap-sm" style="padding:8px 0;border-bottom:0.5px solid var(--color-border);cursor:pointer;" @click="onSearchResultTap(item)">
          <img :src="imageUrl(item.first_picture)" style="width:48px;height:48px;border-radius:4px;object-fit:cover;" />
          <div>
            <div style="font-size:14px;font-weight:600;">{{ item.name }}</div>
            <div style="font-size:11px;color:var(--color-assistant-text);">{{ item.city_name || item.type_name || '' }}</div>
          </div>
        </div>
        <div style="text-align:center;padding:8px;color:var(--color-primary);font-size:12px;cursor:pointer;" @click="onSearchEnter">
          {{ t('查看全部') }}
        </div>
      </div>
      <div v-else-if="searchDone && searchQuery.trim()" class="card" style="margin:0 12px; padding:24px; text-align:center; position:absolute; z-index:200; left:0; right:0; box-shadow:var(--shadow-popup); color:var(--color-assistant-text); font-size:13px">
        {{ $t('暫無搜索結果') }}
      </div>

      <!-- Loading -->
      <loading-spinner v-if="!homeData && loading" :text="t('加載中...')" />

      <!-- Content Sections -->
      <div class="ds-page-wrapper">
      <template v-if="homeData">
        <!-- City Strategy -->
        <div v-if="homeData.city && homeData.city.length">
          <div class="sec-head">
            <div class="sec-head-title">{{ t('城市攻略') }}</div>
          </div>
          <div class="strategy-grid">
            <div v-for="cat in strategyCategories" :key="cat.key"
              class="strategy-card" :style="{background:cat.bg}"
              @click="onStrategyTap(cat)">
              <div class="strategy-icon" v-html="cat.svg"></div>
              <span class="strategy-label" :style="{color:cat.color}">{{ t(cat.label) }}</span>
            </div>
          </div>
        </div>

        <!-- Hot Cities by Continent -->
        <div v-if="continentGroups.length > 0">
          <div class="sec-head">
            <div class="sec-head-title">{{ t('熱門城市') }}</div>
            <a href="#/city" class="sec-head-more">{{ t('查看全部') }} ›</a>
          </div>

          <!-- Continent Tabs — same style as guide/merchant filter pills -->
          <div v-if="continentGroups.length > 1" class="filter-pills">
            <button v-for="(group, idx) in continentGroups" :key="'ct-'+idx"
              class="filter-pill" :class="{ active: currentContinentIndex === idx }"
              @click="switchContinent(idx)">
              {{ group.name }}
            </button>
          </div>

          <!-- City Grid (4 per row, max 12 per continent) — placeholder slots prevent height jump -->
          <div class="card-grid-4 continent-city-grid" :key="'cg-'+currentContinentIndex">
            <div v-for="city in paddedContinentCities" :key="'c-'+city.id"
              :class="['city-card', { 'grid-placeholder': city._placeholder }]"
              :style="city._placeholder ? '' : 'cursor:pointer'"
              @click="city._placeholder ? null : goCityDetail(city.id)">
              <template v-if="!city._placeholder">
                <img class="city-img" :src="imageUrl(city.first_picture)" />
                <div class="city-overlay">
                  <span class="city-name">{{ city.name }}</span>
                  <span v-if="city.name_en" class="city-name-en">{{ city.name_en }}</span>
                </div>
              </template>
            </div>
          </div>
        </div>

        <!-- Recommended Guides -->
        <div v-if="homeData.guide && homeData.guide.length">
          <div class="sec-head" style="margin-top:48px">
            <div class="sec-head-title">{{ t('推薦導遊') }}</div>
            <a href="#/search?type=guide" class="sec-head-more">{{ t('查看全部') }} ›</a>
          </div>
          <div class="filter-pills" v-if="guideCategories.length > 1">
            <button v-for="(cat, idx) in guideCategories" :key="'gc-'+idx"
              class="filter-pill" :class="{ active: guideCatIndex === idx }"
              @click="onGuideCatTap(idx)">{{ cat.name || t('全部') }}</button>
          </div>
          <div class="h-scroll" :key="'gg-'+guideCatIndex">
            <div v-for="guide in currentGuides" :key="'g-'+guide.id" class="guide-card-v2" @click="goGuideDetail(guide.id)">
              <img :src="imageUrl(guide.photo)" />
              <div class="gc-info">
                <div class="gc-name">{{ guide.name }}</div>
                <div v-if="guide.language && guide.language.length" class="gc-lang">{{ guide.language[0] }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recommended Businesses -->
        <div v-if="shopCategories.length > 0">
          <div class="sec-head" style="margin-top:48px">
            <div class="sec-head-title">{{ t('推薦商家') }}</div>
            <span class="sec-head-more" style="cursor:pointer;" @click="goSearch('shop')">{{ t('查看全部') }} ›</span>
          </div>
          <div class="filter-pills" v-if="shopCategories.length > 1">
            <button v-for="(cat, idx) in shopCategories" :key="'sc-'+idx"
              class="filter-pill" :class="{ active: shopCatIndex === idx }"
              @click="onShopCatTap(idx)">{{ cat.name || t('全部') }}</button>
          </div>

          <!-- Shop Banner Carousel (v-show + placeholder: no layout jump) -->
          <div v-if="maxShopBannerCount > 0">
            <div v-show="currentShopBanner.length > 0" class="shop-banner">
              <div class="shop-banner-viewport">
                <div class="shop-banner-track" :style="{ transform: 'translateX(-' + shopBannerIndex * 100 + '%)' }">
                  <div v-for="banner in currentShopBanner" :key="'sb-'+banner.id"
                    class="shop-banner-slide" @click="goCommonDetail(banner.id, banner.city_id, banner.type_id)">
                    <img :src="imageUrl(banner.first_picture)" class="shop-banner-img" />
                    <div class="shop-banner-info">
                      <div class="shop-banner-name">{{ banner.name }}</div>
                      <div class="shop-banner-meta">
                        <span v-if="banner.phone">📞 {{ banner.phone }}</span>
                        <span v-if="banner.city_name">📍 {{ banner.city_name }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div v-if="currentShopBanner.length > 1" class="shop-banner-dots">
                <span v-for="(dot, idx) in currentShopBanner" :key="'bd-'+idx"
                  class="shop-banner-dot" :class="{ active: shopBannerIndex === idx }"
                  @click="goBannerSlide(idx)"></span>
              </div>
            </div>
            <!-- Invisible placeholder: keeps banner height when current category has none -->
            <div v-show="currentShopBanner.length === 0" class="shop-banner shop-banner-ph" aria-hidden="true">
              <div class="shop-banner-slide">
                <div class="shop-banner-img"></div>
                <div class="shop-banner-info">
                  <div class="shop-banner-name">&nbsp;</div>
                  <div class="shop-banner-meta"><span>&nbsp;</span></div>
                </div>
              </div>
            </div>
          </div>

          <div class="card-grid-4">
            <div v-for="shop in paddedCurrentShops" :key="'sh-'+shop.id"
              :class="['merchant-card', { 'shop-grid-ph': shop._placeholder }]"
              :style="shop._placeholder ? '' : 'cursor:pointer'"
              @click="shop._placeholder ? null : goCommonDetail(shop.id, shop.city_id, shop.type_id)">
              <img class="merchant-img" :src="shop._placeholder ? '' : imageUrl(shop.first_picture)" />
              <div class="merchant-info">
                <div class="merchant-name">{{ shop._placeholder ? ' ' : shop.name }}</div>
                <div class="merchant-phone" v-if="!shop._placeholder && shop.phone">📞 {{ shop.phone }}</div>
                <div class="merchant-meta" v-if="!shop._placeholder && shop.city_name">
                  <span>📍</span>{{ shop.city_name }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Information / News -->
        <div v-if="homeData.information && homeData.information.length">
          <div class="sec-head" style="margin-top:48px">
            <div class="sec-head-title">{{ t('熱門資訊') }}</div>
            <a href="#/news" class="sec-head-more">{{ t('查看全部') }} ›</a>
          </div>
          <div class="filter-pills" v-if="infoCategories.length > 1">
            <button v-for="(cat, idx) in infoCategories" :key="'ic-'+idx"
              class="filter-pill" :class="{ active: infoCatIndex === idx }"
              @click="infoCatIndex = idx">{{ cat.name || t('全部') }}</button>
          </div>
          <div v-for="info in currentInfoList" :key="'i-'+info.id"
            class="news-card-v2" @click="goNewsDetail(info.id)">
            <div class="nc-header">
              <div class="nc-avatar">
                <img v-if="info.user_avatar" class="nc-avatar-img" :src="imageUrl(info.user_avatar)" />
                <span v-else>{{ (info.user_nickname || 'L')[0] }}</span>
              </div>
              <div>
                <div class="nc-name">{{ info.user_nickname || t('LUMO 官方') }}</div>
                <div class="nc-time">{{ timeAgo(info.created_at) }}</div>
              </div>
            </div>
            <div class="nc-title">{{ info.title }}</div>
            <div class="nc-desc">{{ info.desc || '' }}</div>
          </div>
        </div>

        <div style="height:30px;"></div>
      </template>

      <!-- Error State -->
      <empty-state v-if="!homeData && !loading" :text="t('加載失敗')" :retry="true" @retry="initData" />
    </div>
    </div>
  `,

  data() {
    return {
      homeData: null,
      loading: false,
      searchQuery: '',
      searchResults: [], searchDone: false,
      guideCatIndex: 0,
      shopCatIndex: 0,
      infoCatIndex: 0,
      searchDebounce: null,
      cityAreaMap: {},
      currentContinentIndex: 0,
      continentTimer: null,
      guideAutoTimer: null,
      shopBannerIndex: 0,
      shopBannerTimer: null,

      strategyCategories: [
        { key: 'guide', label: '導遊', bg: 'rgba(102,111,255,0.06)', color: '#666FFF',
          svg: '<svg width="32" height="32" viewBox="0 0 32 32" fill="none"><circle cx="16" cy="11" r="6" stroke="#666FFF" stroke-width="1.6"/><path d="M6 27c0-5.5 4.5-10 10-10s10 4.5 10 10" stroke="#666FFF" stroke-width="1.6" stroke-linecap="round"/></svg>' },
        { key: 'restaurant', label: '餐廳', bg: 'rgba(244,180,19,0.08)', color: '#C89200',
          svg: '<svg width="32" height="32" viewBox="0 0 32 32" fill="none"><path d="M6 7h20l-2 12H8L6 7z" stroke="#F4B413" stroke-width="1.6"/><path d="M8 7c0-2 1.5-3 3-3h10c1.5 0 3 1 3 3" stroke="#F4B413" stroke-width="1.6"/></svg>' },
        { key: 'shopping', label: '購物', bg: 'rgba(255,108,0,0.08)', color: '#D45A00',
          svg: '<svg width="32" height="32" viewBox="0 0 32 32" fill="none"><rect x="5" y="8" width="22" height="18" rx="2" stroke="#FF6C00" stroke-width="1.6"/><line x1="5" y1="14" x2="27" y2="14" stroke="#FF6C00" stroke-width="1.6"/></svg>' },
        { key: 'accommodation', label: '住宿', bg: 'rgba(168,55,255,0.06)', color: '#8C2BE0',
          svg: '<svg width="32" height="32" viewBox="0 0 32 32" fill="none"><rect x="4" y="10" width="24" height="16" rx="2" stroke="#A837FF" stroke-width="1.6"/><path d="M12 10V6a4 4 0 0 1 8 0v4" stroke="#A837FF" stroke-width="1.6"/></svg>' },
        { key: 'attraction', label: '景點', bg: 'rgba(0,235,194,0.08)', color: '#00B898',
          svg: '<svg width="32" height="32" viewBox="0 0 32 32" fill="none"><path d="M8 26V6l8-4 8 4v20" stroke="#00EBC2" stroke-width="1.6"/><line x1="12" y1="14" x2="20" y2="14" stroke="#00EBC2" stroke-width="1.6"/></svg>' },
        { key: 'ticket', label: '票務', bg: 'rgba(102,149,255,0.08)', color: '#4C7BD4',
          svg: '<svg width="32" height="32" viewBox="0 0 32 32" fill="none"><circle cx="16" cy="16" r="11" stroke="#6695FF" stroke-width="1.6"/><polygon points="16,8 20,14 16,20 12,14" stroke="#6695FF" stroke-width="1.6"/></svg>' },
      ]
    };
  },

  computed: {
    continentGroups() {
      // Only use homeData.city — backend-recommended cities
      const source = this.homeData?.city || [];
      if (!source.length) return [];

      // Map sub-region area_name → top-level continent
      const mapToContinent = (areaName) => {
        if (!areaName) return '其他';
        if (TOP_CONTINENTS.has(areaName)) return areaName;
        return AREA_TO_CONTINENT[areaName] || areaName;
      };

      // Group by continent — use cityAreaMap for accurate area_name
      const groups = {};
      source.forEach(city => {
        const areaName = this.cityAreaMap[city.id] || city.area_name;
        const continent = mapToContinent(areaName);
        if (!groups[continent]) groups[continent] = [];
        groups[continent].push(city);
      });

      // Build result: 4 per row, max 12 (multiples of 4)
      // Only keep groups that map to a recognized top-level continent
      const VALID_CONTINENTS = new Set([
        '欧洲', '亞洲', '亚洲',
        '北美洲', '南美洲',
        '非洲',
        '大洋洲',
        '南极洲', '南極洲',
      ]);
      let result = Object.entries(groups)
        .filter(([name]) => VALID_CONTINENTS.has(name))
        .filter(([, cities]) => cities.length > 0)
        .map(([name, cities]) => ({
          name,
          cities: cities.slice(0, Math.min(12, Math.floor(cities.length / 4) * 4 || 4))
        }))
        .filter(g => g.cities.length > 0);

      // Order: 欧洲 first, 亚洲 second, rest by city count descending
      const ORDER = ['欧洲', '亞洲', '亚洲'];
      result.sort((a, b) => {
        const ai = ORDER.findIndex(n => a.name === n);
        const bi = ORDER.findIndex(n => b.name === n);
        if (ai >= 0 && bi >= 0) return ai - bi;
        if (ai >= 0) return -1;
        if (bi >= 0) return 1;
        return b.cities.length - a.cities.length;
      });

      return result;
    },
    currentContinentCities() {
      const group = this.continentGroups[this.currentContinentIndex];
      return group ? group.cities : [];
    },
    // Pad to max rows to prevent layout jumping on auto-switch
    maxContinentSlots() {
      let max = 0;
      this.continentGroups.forEach(g => { if (g.cities.length > max) max = g.cities.length; });
      return Math.ceil(max / 4) * 4; // round up to nearest row of 4
    },
    paddedContinentCities() {
      const list = this.currentContinentCities.slice();
      while (list.length < this.maxContinentSlots) {
        list.push({ id: '__ph_' + list.length, _placeholder: true });
      }
      return list;
    },
    guideCategories() {
      return this.homeData?.guide || [];
    },
    currentGuides() {
      const cat = this.homeData?.guide?.[this.guideCatIndex];
      return (cat?.list || []).slice(0, 10);
    },
    shopCategories() {
      // Only show categories that have content (banner or list)
      return (this.homeData?.shop || []).filter(cat =>
        (cat.list && cat.list.length > 0) || (cat.banner && cat.banner.length > 0)
      );
    },
    currentShopCat() {
      return this.shopCategories[this.shopCatIndex] || {};
    },
    currentShops() {
      return this.currentShopCat.list || [];
    },
    currentShopBanner() {
      return this.currentShopCat.banner || [];
    },
    // Prevent layout jump: max counts across all categories
    maxShopBannerCount() {
      let max = 0;
      this.shopCategories.forEach(c => { if (c.banner && c.banner.length > max) max = c.banner.length; });
      return max;
    },
    maxShopListCount() {
      let max = 0;
      this.shopCategories.forEach(c => { if (c.list && c.list.length > max) max = c.list.length; });
      return Math.ceil(max / 4) * 4; // round to nearest row of 4
    },
    paddedCurrentShops() {
      const list = this.currentShops.slice();
      while (list.length < this.maxShopListCount) {
        list.push({ id: '__sh_ph_' + list.length, _placeholder: true });
      }
      return list;
    },
    infoCategories() {
      return this.homeData?.information || [];
    },
    currentInfoList() {
      const cat = this.homeData?.information?.[this.infoCatIndex];
      return cat?.list || [];
    }
  },

  methods: {
    t(key) { return I18n.t(key); },
    imageUrl: imageUrl,
    timeAgo: timeAgo,

    async initData() {
      // Load cache for immediate display (both homeData and cityAreaMap)
      const cache = Storage.homeData;
      const areaCache = Storage.cityAreaMap;
      if (cache) {
        try { this.homeData = JSON.parse(cache); } catch (e) {}
        if (areaCache) {
          try { this.cityAreaMap = JSON.parse(areaCache); } catch (e) {}
        }
        this.$nextTick(() => {
          this.startGuideAutoSwitch();
          this.startContinentAutoSwitch();
          this.startShopAutoSwitch();
          this.startShopBannerAutoSwitch();
        });
      }

      this.loading = !this.homeData;

      // Fire both APIs in PARALLEL
      const [homeRes, cityRes] = await Promise.all([
        ApiProvider.get(ApiUrl.homeData),
        ApiProvider.get(ApiUrl.cityList, { limit: 1000, page: 1 })
      ]);
      this.loading = false;

      // Process city area mapping FIRST so it's ready when homeData triggers reactivity
      if (cityRes.success && cityRes.data) {
        const raw = Array.isArray(cityRes.data) ? cityRes.data
          : (cityRes.data.list || cityRes.data.lists || cityRes.data.data || []);
        const map = {};
        raw.forEach(city => {
          if (city.id && city.area_name) map[city.id] = city.area_name;
        });
        this.cityAreaMap = map;
        Storage.cityAreaMap = JSON.stringify(map);
      }

      // Process home data — continentGroups will now use populated cityAreaMap
      if (homeRes.success && homeRes.data) {
        this.homeData = homeRes.data;
        Storage.homeData = JSON.stringify(homeRes.data);
      }
      if (!this.homeData) return;

      // Start auto-switch now that both data sources are ready
      this.$nextTick(() => {
        this.startGuideAutoSwitch();
        this.startContinentAutoSwitch();
        this.startShopAutoSwitch();
        this.startShopBannerAutoSwitch();
      });
    },

    onSearchInput() {
      if (this.searchDebounce) clearTimeout(this.searchDebounce);
      const q = this.searchQuery.trim();
      if (!q) {
        this.searchResults = [];
        this.searchDone = false;
        return;
      }
      this.searchDebounce = setTimeout(() => this.doSearch(q), 500);
    },

    async doSearch(keyword) {
      const res = await ApiProvider.get(ApiUrl.homeSearch, { name: keyword });
      if (res.success) {
        this.searchResults = Array.isArray(res.data) ? res.data : [];
      }
      this.searchDone = true;
    },

    onSearchEnter() {
      if (this.searchQuery.trim()) {
        this.$router.push('/search?keyword=' + encodeURIComponent(this.searchQuery.trim()));
        this.searchResults = [];
        this.searchDone = false;
      }
    },

    onSearchResultTap(item) {
      const dataType = item.data_type || item.dataType;
      if (dataType === 1) {
        this.$router.push('/city/detail?id=' + item.id);
      } else if (dataType === 2) {
        this.$router.push('/guide/' + item.id);
      } else if (dataType === 3) {
        this.$router.push('/detail/content?id=' + item.id + '&city_id=' + (item.city_id || item.cityId) + '&type_id=' + (item.type_id || item.typeId));
      }
      this.searchResults = [];
      this.searchQuery = '';
    },

    onStrategyTap(cat) {
      this.$router.push('/city/strategy?type=' + cat.key);
    },

    goCityDetail(id) { this.$router.push('/city/detail?id=' + id); },
    goGuideDetail(id) { this.$router.push('/guide/' + id); },
    goNewsDetail(id) { this.$router.push('/news/' + id); },
    goCommonDetail(id, cityId, typeId) {
      this.$router.push('/detail/content?id=' + id + '&city_id=' + cityId + '&type_id=' + typeId);
    },
    goSearch(type) {
      this.$router.push('/search?type=' + type);
    },

    startContinentAutoSwitch() {
      if (this.continentTimer) clearInterval(this.continentTimer);
      if (this.continentGroups.length <= 1) return;
      this.continentTimer = setInterval(() => {
        this.currentContinentIndex = (this.currentContinentIndex + 1) % this.continentGroups.length;
      }, 5000);
    },
    switchContinent(idx) {
      this.currentContinentIndex = idx;
      this.startContinentAutoSwitch();
    },

    // Guide category auto-switch (5s, same as Flutter _guideAutoScrollTimer)
    startGuideAutoSwitch() {
      this.stopGuideAutoSwitch();
      if (this.guideCategories.length <= 1) return;
      this.guideAutoTimer = setInterval(() => {
        this.guideCatIndex = (this.guideCatIndex + 1) % this.guideCategories.length;
      }, 5000);
    },
    stopGuideAutoSwitch() {
      if (this.guideAutoTimer) clearInterval(this.guideAutoTimer);
      this.guideAutoTimer = null;
    },
    onGuideCatTap(idx) {
      this.guideCatIndex = idx;
      this.startGuideAutoSwitch(); // Reset timer on manual tap
    },

    // --- Shop category auto-switch (driven by banner completion) ---
    startShopAutoSwitch() {
      this.stopShopAutoSwitch();
      if (this.shopCategories.length <= 1) return;
      this.startShopBannerAutoSwitch();
    },
    stopShopAutoSwitch() {
      this.stopShopBannerAutoSwitch();
    },
    advanceShopCategory() {
      this.stopShopBannerAutoSwitch();
      if (this.shopCategories.length <= 1) return;
      this.shopCatIndex = (this.shopCatIndex + 1) % this.shopCategories.length;
      this.shopBannerIndex = 0;
      this.$nextTick(() => this.startShopBannerAutoSwitch());
    },
    onShopCatTap(idx) {
      this.shopCatIndex = idx;
      this.shopBannerIndex = 0;
      this.startShopAutoSwitch(); // Reset: restart banner-driven cycle
    },

    // Shop banner auto-rotate: show all slides, then advance category
    startShopBannerAutoSwitch() {
      this.stopShopBannerAutoSwitch();
      const bannerCount = this.currentShopBanner.length;
      if (bannerCount <= 0) {
        // No banner — show list for 8s before switching
        this.shopBannerTimer = setTimeout(() => this.advanceShopCategory(), 8000);
        return;
      }
      if (bannerCount === 1) {
        // Single banner — show for 5s then switch
        this.shopBannerTimer = setTimeout(() => this.advanceShopCategory(), 5000);
        return;
      }
      // Multiple banners — show each for 4s, then advance
      this.shopBannerTimer = setInterval(() => {
        if (this.shopBannerIndex < bannerCount - 1) {
          this.shopBannerIndex++;
        } else {
          this.advanceShopCategory();
        }
      }, 4000);
    },
    stopShopBannerAutoSwitch() {
      if (this.shopBannerTimer) {
        clearInterval(this.shopBannerTimer);
        this.shopBannerTimer = null;
      }
    },
    goBannerSlide(idx) {
      this.shopBannerIndex = idx;
      this.startShopBannerAutoSwitch(); // Reset timer
    }
  },

  mounted() {
    this.initData();
  },

  beforeUnmount() {
    if (this.searchDebounce) clearTimeout(this.searchDebounce);
    if (this.continentTimer) clearInterval(this.continentTimer);
    if (this.guideAutoTimer) clearInterval(this.guideAutoTimer);
    if (this.shopBannerTimer) clearInterval(this.shopBannerTimer);
  }
};
