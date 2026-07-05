/* ============================================
   HomePage — Main home tab with all sections
   Mirrors Flutter HomePage + HomeController
   ============================================ */

const HomePage = {
  template: `
    <div class="page-content">
      <!-- Search Bar -->
      <div class="search-bar" style="margin-top:12px;">
        <span>🔍</span>
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

      <!-- Loading -->
      <loading-spinner v-if="!homeData && loading" :text="t('加載中...')" />

      <!-- Content Sections -->
      <template v-if="homeData">
        <!-- City Strategy -->
        <div v-if="homeData.city && homeData.city.length" style="margin:12px;padding:16px;background:linear-gradient(135deg, #EEF0FF, #F0F0FF);border-radius:12px;">
          <div class="section-header" style="padding:0 0 8px 0;">
            <div class="section-header-left">
              <span class="section-title" style="font-size:16px;">{{ t('城市攻略') }}</span>
            </div>
          </div>
          <div style="display:flex;flex-wrap:wrap;gap:12px;justify-content:space-around;">
            <div v-for="cat in strategyCategories" :key="cat.key" style="display:flex;flex-direction:column;align-items:center;gap:6px;cursor:pointer;" @click="onStrategyTap(cat)">
              <div :style="{width:'48px',height:'48px',borderRadius:'50%',background:cat.color+'20',display:'flex',alignItems:'center',justifyContent:'center',fontSize:'22px'}">{{ cat.icon }}</div>
              <span style="font-size:11px;color:var(--color-primary-text);">{{ t(cat.label) }}</span>
            </div>
          </div>
        </div>

        <!-- Hot Cities -->
        <div v-if="homeData.city && homeData.city.length">
          <div class="section-header">
            <div class="section-header-left">
              <span class="section-title">{{ t('熱門城市') }}</span>
              <span class="section-subtitle">{{ t('在路上輕鬆掌握每個城市') }}</span>
            </div>
            <a href="#/city" class="section-more">{{ t('查看全部') }} ›</a>
          </div>
          <div class="h-scroll">
            <div v-for="city in homeData.city" :key="'c-'+city.id" class="city-card" style="width:140px;flex-shrink:0;cursor:pointer;" @click="goCityDetail(city.id)">
              <img class="city-img" :src="imageUrl(city.first_picture)" />
              <div class="city-overlay">
                <span class="city-name">{{ city.name }}</span>
                <span v-if="city.name_en" class="city-name-en">{{ city.name_en }}</span>
                <span v-if="city.area_name" class="city-badge">{{ city.area_name }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Recommended Guides -->
        <div v-if="homeData.guide && homeData.guide.length">
          <div class="section-header">
            <div class="section-header-left">
              <span class="section-title">{{ t('推薦導遊') }}</span>
            </div>
            <a href="#/search?type=guide" class="section-more">{{ t('查看全部') }} ›</a>
          </div>
          <div class="filter-pills" v-if="guideCategories.length > 1">
            <button v-for="(cat, idx) in guideCategories" :key="'gc-'+idx"
              class="filter-pill" :class="{ active: guideCatIndex === idx }"
              @click="guideCatIndex = idx">{{ cat.name || t('全部') }}</button>
          </div>
          <div class="h-scroll">
            <div v-for="guide in currentGuides" :key="'g-'+guide.id" class="guide-card" style="cursor:pointer;" @click="goGuideDetail(guide.id)">
              <img class="guide-img" :src="imageUrl(guide.photo)" />
              <div class="guide-info">
                <div class="guide-name">{{ guide.name }}</div>
                <div v-if="guide.language && guide.language.length" class="guide-tag">{{ guide.language[0] }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recommended Businesses -->
        <div v-if="homeData.shop && homeData.shop.length">
          <div class="section-header">
            <div class="section-header-left">
              <span class="section-title">{{ t('推薦商家') }}</span>
            </div>
            <span class="section-more" style="cursor:pointer;" @click="goSearch('shop')">{{ t('查看全部') }} ›</span>
          </div>
          <div class="filter-pills" v-if="shopCategories.length > 1">
            <button v-for="(cat, idx) in shopCategories" :key="'sc-'+idx"
              class="filter-pill" :class="{ active: shopCatIndex === idx }"
              @click="shopCatIndex = idx">{{ cat.name || t('全部') }}</button>
          </div>
          <div class="card-grid-2">
            <div v-for="shop in currentShops" :key="'sh-'+shop.id" class="merchant-card" style="cursor:pointer;" @click="goCommonDetail(shop.id, shop.city_id, shop.type_id)">
              <img class="merchant-img" :src="imageUrl(shop.first_picture)" />
              <div class="merchant-info">
                <div class="merchant-name">{{ shop.name }}</div>
                <div class="merchant-meta" v-if="shop.city_name">
                  <span>📍</span>{{ shop.city_name }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Information / News -->
        <div v-if="homeData.information && homeData.information.length">
          <div class="section-header">
            <div class="section-header-left">
              <span class="section-title">{{ t('熱門資訊') }}</span>
            </div>
            <a href="#/news" class="section-more">{{ t('查看全部') }} ›</a>
          </div>
          <div class="filter-pills" v-if="infoCategories.length > 1">
            <button v-for="(cat, idx) in infoCategories" :key="'ic-'+idx"
              class="filter-pill" :class="{ active: infoCatIndex === idx }"
              @click="infoCatIndex = idx">{{ cat.name || t('全部') }}</button>
          </div>
          <div v-for="info in currentInfoList" :key="'i-'+info.id" class="news-card" style="cursor:pointer;" @click="goNewsDetail(info.id)">
            <div class="news-content">
              <div class="news-title">{{ info.title }}</div>
              <div class="news-desc">{{ info.desc || '' }}</div>
              <div class="news-meta">
                <span>{{ info.user_nickname || '' }}</span>
                <span v-if="info.evaluate_count">💬 {{ info.evaluate_count }}</span>
              </div>
            </div>
            <img v-if="info.first_picture" class="news-img" :src="imageUrl(info.first_picture)" />
          </div>
        </div>

        <div style="height:30px;"></div>
      </template>

      <!-- Error State -->
      <empty-state v-if="!homeData && !loading" :text="t('加載失敗')" :retry="true" @retry="fetchHomeData" />
    </div>
  `,

  data() {
    return {
      homeData: null,
      loading: false,
      searchQuery: '',
      searchResults: [],
      guideCatIndex: 0,
      shopCatIndex: 0,
      infoCatIndex: 0,
      searchDebounce: null,

      strategyCategories: [
        { key: 'guide', label: '導遊', color: '#666FFF', icon: '🧑‍💼' },
        { key: 'attraction', label: '景點', color: '#00EBC2', icon: '🏛️' },
        { key: 'restaurant', label: '餐廳', color: '#F4B413', icon: '🍽️' },
        { key: 'shopping', label: '購物', color: '#FF6C00', icon: '🛍️' },
        { key: 'accommodation', label: '住宿', color: '#A837FF', icon: '🏨' },
        { key: 'ticket', label: '票務', color: '#00B4FF', icon: '🎫' },
      ]
    };
  },

  computed: {
    guideCategories() {
      return this.homeData?.guide || [];
    },
    currentGuides() {
      const cat = this.homeData?.guide?.[this.guideCatIndex];
      return cat?.list || [];
    },
    shopCategories() {
      return this.homeData?.shop || [];
    },
    currentShops() {
      const cat = this.homeData?.shop?.[this.shopCatIndex];
      return cat?.list || [];
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

    async fetchHomeData() {
      const cache = Storage.homeData;
      if (cache) {
        try { this.homeData = JSON.parse(cache); } catch (e) {}
      }

      this.loading = true;
      const res = await ApiProvider.get(ApiUrl.homeData);
      this.loading = false;

      if (res.success && res.data) {
        this.homeData = res.data;
        Storage.homeData = JSON.stringify(res.data);
      } else if (!this.homeData) {
        // stay on error state
      }
    },

    onSearchInput() {
      if (this.searchDebounce) clearTimeout(this.searchDebounce);
      const q = this.searchQuery.trim();
      if (!q) {
        this.searchResults = [];
        return;
      }
      this.searchDebounce = setTimeout(() => this.doSearch(q), 500);
    },

    async doSearch(keyword) {
      const res = await ApiProvider.get(ApiUrl.homeSearch, { name: keyword });
      if (res.success) {
        this.searchResults = Array.isArray(res.data) ? res.data : [];
      }
    },

    onSearchEnter() {
      if (this.searchQuery.trim()) {
        this.$router.push('/search?keyword=' + encodeURIComponent(this.searchQuery.trim()));
        this.searchResults = [];
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
    }
  },

  mounted() {
    this.fetchHomeData();
  },

  beforeUnmount() {
    if (this.searchDebounce) clearTimeout(this.searchDebounce);
  }
};
