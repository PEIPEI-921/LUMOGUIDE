/* ============================================
   City Detail Page — 城市详情
   Redesigned 2026-07-06: 4-col grid, smaller images,
   2-level classification (tabs + sub-category pills)
   ============================================ */

const CityDetailPage = {
  template: `
    <div class="page-content">
      <!-- Banner Carousel (full-width) -->
      <div style="position:relative;height:250px;background:var(--color-bg-card);overflow:hidden">
        <!-- Slides -->
        <div v-if="banners.length > 0" style="width:100%;height:100%;position:relative">
          <img v-for="(pic, idx) in banners" :key="idx" :src="pic" :alt="city.name"
            style="width:100%;height:100%;object-fit:cover;object-position:center;position:absolute;inset:0;transition:opacity .4s"
            :style="{ opacity: idx === bannerIndex ? 1 : 0 }">
        </div>
        <div v-else style="width:100%;height:100%;background:linear-gradient(135deg,var(--color-accent-soft),transparent);display:flex;align-items:center;justify-content:center">
          <span style="font-size:48px;opacity:0.3">🏙️</span>
        </div>
        <!-- Overlay -->
        <div style="position:absolute;inset:0;background:linear-gradient(to top, rgba(0,0,0,.6), transparent);pointer-events:none"></div>
        <!-- Dots -->
        <div v-if="banners.length > 1" style="position:absolute;bottom:14px;right:16px;display:flex;gap:6px;z-index:2">
          <button v-for="(pic, idx) in banners" :key="'dot-'+idx"
            @click="goBanner(idx)"
            style="width:6px;height:6px;border-radius:50%;border:none;padding:0;cursor:pointer;transition:all .2s"
            :style="{ background: idx === bannerIndex ? '#fff' : 'rgba(255,255,255,.4)' }"></button>
        </div>
        <!-- City Name -->
        <div class="ds-container-1280" style="position:absolute;bottom:16px;left:0;right:0;color:#fff;z-index:1;padding-top:0;padding-bottom:0">
          <h1 style="font-family:var(--font-serif);font-size:26px;font-weight:400;letter-spacing:-.01em;margin:0">{{ city.name }}</h1>
          <p v-if="city.name_en" style="font-size:12px;opacity:.8;margin:2px 0 0">{{ city.name_en }}</p>
        </div>
      </div>

      <!-- Main Tabs (centered, sticky) -->
      <div class="ds-container-1280 ds-tabs" style="margin-top:0;margin-bottom:0;padding-top:0;padding-bottom:0;border-bottom:none;justify-content:center;position:sticky;top:48px;z-index:30;overflow-x:auto">
        <button v-for="(tab, idx) in contentTabs" :key="tab.key"
          @click="switchTab(idx)"
          :class="['ds-tab', { active: activeTab === idx }]" style="font-size:17.5px">{{ $t(tab.label) }}</button>
      </div>

      <!-- Sub-category Tabs (centered, always rendered, same style as main tabs) -->
      <div class="ds-container-1280" style="min-height:44px;padding-top:0;padding-bottom:0">
        <div v-if="showSubCategories" style="display:flex;gap:0;overflow-x:auto;align-items:center">
          <button @click="switchSubTab(-1)"
            :class="['ds-tab', { active: subTabIndex === -1 }]" style="font-size:15.5px">{{ $t('全部') }}</button>
          <button v-for="(cat, idx) in subCategories" :key="cat.id"
            @click="switchSubTab(idx)"
            :class="['ds-tab', { active: subTabIndex === idx }]" style="font-size:15.5px">{{ cat.name }}</button>
        </div>
      </div>

      <!-- Content Area -->
      <div class="ds-container-1280" style="padding-top:14px;padding-bottom:20px">
        <!-- Loading -->
        <div v-if="tabLoading" class="loading-container" style="padding:60px 0">
          <div class="spinner"></div>
        </div>

        <!-- Overview Tab -->
        <div v-else-if="activeTab === 0">
          <div class="ds-card" style="padding:18px 20px;margin-bottom:10px;background:transparent;box-shadow:none">
            <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:14px;font-size:14px">
              <div v-if="city.currency" style="text-align:center">
                <span style="font-size:11px;color:var(--color-assistant-text)">{{ $t('貨幣') }}</span>
                <p style="font-size:14px;font-weight:600;margin-top:4px">{{ city.currency }}</p>
              </div>
              <div v-if="city.language" style="text-align:center">
                <span style="font-size:11px;color:var(--color-assistant-text)">{{ $t('語言') }}</span>
                <p style="font-size:14px;font-weight:600;margin-top:4px">{{ city.language }}</p>
              </div>
              <div v-if="city.population" style="text-align:center">
                <span style="font-size:11px;color:var(--color-assistant-text)">{{ $t('人口') }}</span>
                <p style="font-size:14px;font-weight:600;margin-top:4px">{{ city.population }}</p>
              </div>
              <div v-if="city.race" style="text-align:center">
                <span style="font-size:11px;color:var(--color-assistant-text)">{{ $t('種族') }}</span>
                <p style="font-size:14px;font-weight:600;margin-top:4px">{{ city.race }}</p>
              </div>
            </div>
          </div>
          <div v-if="city.overview" class="ds-card" style="padding:16px 20px;margin-bottom:10px;background:transparent;box-shadow:none">
            <h3 style="font-weight:600;margin-bottom:8px;font-size:15px">{{ $t('城市概覽') }}</h3>
            <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap;line-height:1.8">{{ city.overview }}</p>
          </div>
          <div v-if="city.history" class="ds-card" style="padding:16px 20px;background:transparent;box-shadow:none">
            <h3 style="font-weight:600;margin-bottom:8px;font-size:15px">{{ $t('歷史') }}</h3>
            <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap;line-height:1.8">{{ city.history }}</p>
          </div>
        </div>

        <!-- Guide Tab -->
        <div v-else-if="activeTab === 1">
          <div v-if="guides.length > 0" style="text-align:right;margin-bottom:10px">
            <a :href="'#/city/guide-list?city_id=' + cityId" style="font-size:12px;color:var(--color-primary);text-decoration:none">{{ $t('查看全部導遊') }} ›</a>
          </div>
          <div v-if="guides.length > 0" class="city-content-grid">
            <a v-for="g in guides" :key="g.id" :href="'#/guide/' + g.id"
              class="ds-card ds-card-hover city-card-item" style="background:transparent;box-shadow:none">
              <div class="city-card-img">
                <img v-if="g.photo" :src="g.photo" :alt="g.name">
                <div v-else class="city-card-img-placeholder">👤</div>
              </div>
              <div class="city-card-body">
                <div class="city-card-title">{{ g.name }}</div>
                <div v-if="g.language && g.language.length" class="city-card-tags">
                  <span v-for="lang in g.language.slice(0,2)" :key="lang">{{ lang }}</span>
                </div>
              </div>
            </a>
          </div>
          <div v-else class="ds-empty" style="padding:60px 0">{{ $t('暫無導遊') }}</div>
        </div>

        <!-- Content Tabs (attraction/restaurant/shopping/ticket/accommodation/transportation/facility/activity) -->
        <div v-else>
          <div v-if="contentItems.length > 0" class="city-content-grid">
            <a v-for="item in contentItems" :key="item.id"
              :href="'#/detail/' + currentTabKey + '?id=' + item.id + '&city_id=' + cityId"
              class="ds-card ds-card-hover city-card-item" style="background:transparent;box-shadow:none">
              <div class="city-card-img">
                <img v-if="item.first_picture" :src="item.first_picture" :alt="item.name">
                <div v-else class="city-card-img-placeholder">📷</div>
              </div>
              <div class="city-card-body">
                <div class="city-card-title">{{ item.name }}</div>
                <div v-if="item.start_time || item.tickets_free" class="city-card-meta">
                  <span v-if="item.start_time">{{ item.start_time }}</span>
                  <span v-if="item.tickets_free" style="color:var(--color-primary);font-weight:500">{{ item.tickets_free }}</span>
                </div>
              </div>
            </a>
          </div>
          <div v-else class="ds-empty" style="padding:60px 0">{{ $t('暫無內容') }}</div>
        </div>
      </div>

      <!-- Error State -->
      <div v-if="error" class="ds-container-1280" style="padding-top:80px;padding-bottom:20px">
        <div style="text-align:center">
          <p style="color:var(--color-secondary-text);margin-bottom:16px">{{ error }}</p>
          <button @click="loadCity" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>
      </div>

      <!-- Loading State (full page) -->
      <div v-if="loading" class="ds-container-1280" style="padding-top:80px;padding-bottom:20px">
        <div class="loading-container">
          <div class="spinner"></div>
        </div>
      </div>
    </div>
  `,

  data() {
    return {
      cityId: 0,
      city: {},
      cityClass: null,
      loading: true,
      error: null,
      activeTab: 0,
      subTabIndex: -1,
      tabLoading: false,
      bannerIndex: 0,
      bannerTimer: null,
      guides: [],
      contentItems: [],
      contentTabs: [
        { key: 'overview', label: '概覽', typeId: 0 },
        { key: 'guide', label: '導遊', typeId: 0 },
        { key: 'attraction', label: '景點', typeId: 1 },
        { key: 'restaurant', label: '餐廳', typeId: 2 },
        { key: 'shopping', label: '購物', typeId: 3 },
        { key: 'ticket', label: '票務', typeId: 8 },
        { key: 'accommodation', label: '住宿', typeId: 4 },
        { key: 'transportation', label: '交通', typeId: 5 },
        { key: 'facility', label: '設施', typeId: 6 },
        { key: 'activity', label: '活動', typeId: 7 }
      ],
      contentEndpointMap: {
        1: 'cityAttraction',
        2: 'cityRestaurant',
        3: 'cityShopping',
        4: 'cityAccommodation',
        5: 'cityTransportation',
        6: 'cityFacility',
        7: 'cityActivity',
        8: 'cityTicket'
      }
    };
  },

  computed: {
    banners() {
      const pics = Array.isArray(this.city.pictures) ? this.city.pictures : [];
      if (pics.length > 0) return pics;
      return this.city.first_picture ? [this.city.first_picture] : [];
    },

    currentTabKey() {
      return this.contentTabs[this.activeTab]?.key || '';
    },

    showSubCategories() {
      if (this.activeTab === 0) return false; // overview has no sub-categories
      return true; // always show "全部" + sub-categories (even if empty, "全部" is useful)
    },

    subCategories() {
      if (!this.cityClass) return [];
      const tab = this.contentTabs[this.activeTab];
      if (!tab) return [];
      if (tab.key === 'guide') {
        return (this.cityClass.guideType || []);
      }
      if (tab.typeId === 0) return [];
      const group = (this.cityClass.type || []).find(g => g.id === tab.typeId);
      return group ? (group.child || []) : [];
    }
  },

  methods: {
    async loadCity() {
      const id = this.$route.query.id;
      if (!id) {
        this.error = '缺少城市 ID';
        this.loading = false;
        return;
      }
      this.cityId = parseInt(id, 10);
      this.loading = true;
      this.error = null;

      const [cityRes, classRes] = await Promise.all([
        ApiProvider.get(ApiUrl.cityInfo, { city_id: this.cityId }),
        ApiProvider.get(ApiUrl.cityClass, { city_id: this.cityId }).catch(() => null)
      ]);

      if (!cityRes.success) {
        this.error = cityRes.message || '載入失敗';
        this.loading = false;
        return;
      }

      this.city = cityRes.data || {};
      this.cityClass = classRes?.data || null;
      this.bannerIndex = 0;
      this.loading = false;
      this.startBannerAuto();

      // Load default tab content (overview doesn't need loading)
      if (this.activeTab !== 0) {
        this.loadTabContent(this.activeTab, this.subTabIndex);
      }
    },

    switchTab(idx) {
      this.activeTab = idx;
      this.subTabIndex = -1;
      this.guides = [];
      this.contentItems = [];
      if (idx !== 0) this.loadTabContent(idx, -1);
    },

    switchSubTab(idx) {
      this.subTabIndex = idx;
      this.loadTabContent(this.activeTab, idx);
    },

    startBannerAuto() {
      if (this.banners.length <= 1) return;
      this.stopBannerAuto();
      this.bannerTimer = setInterval(() => {
        this.bannerIndex = (this.bannerIndex + 1) % this.banners.length;
      }, 4000);
    },
    stopBannerAuto() {
      if (this.bannerTimer) { clearInterval(this.bannerTimer); this.bannerTimer = null; }
    },
    goBanner(idx) {
      this.bannerIndex = idx;
      this.startBannerAuto(); // reset timer on manual interaction
    },

    async loadTabContent(tabIdx, subIdx) {
      const tab = this.contentTabs[tabIdx];
      if (!tab || tab.key === 'overview') return;

      this.tabLoading = true;
      try {
        if (tab.key === 'guide') {
          const subCats = this.subCategories;
          const params = { city_id: this.cityId, page: 1, limit: 100 };
          // subIdx === -1 means "全部" — don't filter by sub-category
          if (subIdx >= 0 && subCats.length > 0) {
            const guideType = subCats[subIdx]?.id;
            if (guideType) params.guide_type = guideType;
          }
          const res = await ApiProvider.get(ApiUrl.cityGuide, params);
          const list = res.data?.list || res.data || [];
          this.guides = Array.isArray(list) ? list : [];
        } else if (tab.typeId > 0) {
          const epKey = this.contentEndpointMap[tab.typeId];
          if (!epKey || !ApiUrl[epKey]) return;
          const subCats = this.subCategories;
          const params = { city_id: this.cityId, page: 1, limit: 100 };
          // subIdx === -1 means "全部" — don't filter by sub-category
          if (subIdx >= 0 && subCats.length > 0) {
            const typeClassId = subCats[subIdx]?.id;
            if (typeClassId) {
              if (tab.key === 'activity') params.category_id = typeClassId;
              else params.type_class_id = typeClassId;
            }
          }
          const res = await ApiProvider.get(ApiUrl[epKey], params);
          const list = res.data?.list || res.data || [];
          this.contentItems = Array.isArray(list) ? list : [];
        }
      } catch (e) {
        this.guides = [];
        this.contentItems = [];
      } finally {
        this.tabLoading = false;
      }
    }
  },

  mounted() {
    this.loadCity();
  },

  beforeUnmount() {
    this.stopBannerAuto();
  },

  watch: {
    '$route.query.id': function(newId) {
      if (newId) {
        this.cityId = parseInt(newId, 10);
        this.activeTab = 0;
        this.subTabIndex = -1;
        this.loadCity();
      }
    }
  }
};
