/* ============================================
   City Detail Page — 城市详情
   Reference: PPCC cities/[id]/page.tsx
   ============================================ */

const CityDetailPage = {
  template: `
    <div class="page-content">
      <!-- Banner -->
      <div style="position:relative;height:220px;background:var(--color-bg-card)">
        <img v-if="banner" :src="banner" :alt="city.name"
          style="width:100%;height:100%;object-fit:cover">
        <div v-else style="width:100%;height:100%;background:linear-gradient(135deg,var(--color-accent-soft),transparent);display:flex;align-items:center;justify-content:center">
          <span style="font-size:48px;opacity:0.3">🏙️</span>
        </div>
        <div style="position:absolute;inset:0;background:linear-gradient(to top, rgba(0,0,0,.6), transparent)"></div>
        <div style="position:absolute;bottom:16px;left:16px;color:#fff">
          <h1 style="font-family:var(--font-serif);font-size:28px;font-weight:400;letter-spacing:-.01em">{{ city.name }}</h1>
          <p v-if="city.name_en" style="font-size:13px;opacity:.8">{{ city.name_en }}</p>
        </div>
      </div>

      <!-- Main Tabs (underline style) -->
      <div class="ds-tabs" style="margin:0;padding:0 16px;background:var(--color-bg-white);position:sticky;top:48px;z-index:30;overflow-x:auto">
        <button v-for="(tab, idx) in contentTabs" :key="tab.key"
          @click="switchTab(idx)"
          :class="['ds-tab', { active: activeTab === idx }]">{{ $t(tab.label) }}</button>
      </div>

      <!-- Sub-category Tabs (pill style) -->
      <div v-if="subCategories.length > 0" style="background:var(--color-bg-white);padding:4px 16px 8px;display:flex;gap:6px;overflow-x:auto">
        <button v-for="(cat, idx) in subCategories" :key="cat.id"
          @click="switchSubTab(idx)"
          :class="['ds-type-tab', { active: subTabIndex === idx }]">{{ cat.name }}</button>
      </div>

      <!-- Content Area -->
      <div class="ds-container-960" style="padding-top:16px;padding-bottom:16px">
        <!-- Loading -->
        <div v-if="tabLoading" class="loading-container">
          <div class="spinner"></div>
        </div>

        <!-- Overview Tab -->
        <div v-else-if="activeTab === 0">
          <div class="card" style="padding:16px;margin-bottom:12px">
            <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:12px;font-size:14px">
              <div v-if="city.currency"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('貨幣') }}</span><p style="font-size:14px;font-weight:500;margin-top:2px">{{ city.currency }}</p></div>
              <div v-if="city.language"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('語言') }}</span><p style="font-size:14px;font-weight:500;margin-top:2px">{{ city.language }}</p></div>
              <div v-if="city.population"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('人口') }}</span><p style="font-size:14px;font-weight:500;margin-top:2px">{{ city.population }}</p></div>
              <div v-if="city.race"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('種族') }}</span><p style="font-size:14px;font-weight:500;margin-top:2px">{{ city.race }}</p></div>
            </div>
          </div>
          <div v-if="city.overview" class="card" style="padding:16px;margin-bottom:12px">
            <h3 style="font-weight:600;margin-bottom:8px">{{ $t('城市概覽') }}</h3>
            <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap">{{ city.overview }}</p>
          </div>
          <div v-if="city.history" class="card" style="padding:16px">
            <h3 style="font-weight:600;margin-bottom:8px">{{ $t('歷史') }}</h3>
            <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap">{{ city.history }}</p>
          </div>
        </div>

        <!-- Guide Tab -->
        <div v-else-if="activeTab === 1">
          <div v-if="guides.length > 0" style="text-align:right;margin-bottom:12px">
            <a :href="'#/city/guide-list?city_id=' + cityId" style="font-size:12px;color:var(--color-primary);text-decoration:none">{{ $t('查看全部導遊') }} ›</a>
          </div>
          <div v-if="guides.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(160px, 1fr));gap:12px">
            <a v-for="g in guides" :key="g.id" :href="'#/guide/' + g.id"
              class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block">
              <div style="height:140px;background:var(--color-bg-card);overflow:hidden">
                <img v-if="g.photo" :src="g.photo" :alt="g.name" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:32px">👤</div>
              </div>
              <div style="padding:12px">
                <div style="font-size:14px;font-weight:600">{{ g.name }}</div>
                <div style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ g.city_name }}</div>
              </div>
            </a>
          </div>
          <div v-else class="ds-empty">{{ $t('暫無導遊') }}</div>
        </div>

        <!-- Content Tabs (attraction/restaurant/shopping/accommodation/transportation/facility/activity/ticket) -->
        <div v-else>
          <div v-if="contentItems.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(160px, 1fr));gap:12px">
            <a v-for="item in contentItems" :key="item.id"
              :href="'#/detail/' + currentTabKey + '?id=' + item.id + '&city_id=' + cityId"
              class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block">
              <div style="height:120px;background:var(--color-bg-card);overflow:hidden">
                <img v-if="item.first_picture" :src="item.first_picture" :alt="item.name" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;opacity:.3">📷</div>
              </div>
              <div style="padding:12px">
                <div style="font-size:14px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.name }}</div>
                <div v-if="item.city_name" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ item.city_name }}</div>
              </div>
            </a>
          </div>
          <div v-else class="ds-empty">{{ $t('暫無內容') }}</div>
        </div>
      </div>

      <!-- Error State -->
      <div v-if="error" class="ds-empty" style="padding:80px 0">
        <p style="color:var(--color-secondary-text);margin-bottom:16px">{{ error }}</p>
        <button @click="loadCity" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>

      <!-- Loading State (full page) -->
      <div v-if="loading" class="loading-container" style="padding:80px 0">
        <div class="spinner"></div>
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
      subTabIndex: 0,
      tabLoading: false,
      guides: [],
      contentItems: [],
      contentTabs: [
        { key: 'overview', label: '概覽', typeId: 0 },
        { key: 'guide', label: '導遊', typeId: 0 },
        { key: 'attraction', label: '景點', typeId: 1 },
        { key: 'restaurant', label: '餐廳', typeId: 2 },
        { key: 'shopping', label: '購物', typeId: 3 },
        { key: 'accommodation', label: '住宿', typeId: 4 },
        { key: 'transportation', label: '交通', typeId: 5 },
        { key: 'facility', label: '設施', typeId: 6 },
        { key: 'activity', label: '活動', typeId: 7 },
        { key: 'ticket', label: '票務', typeId: 8 }
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
    banner() {
      const pics = Array.isArray(this.city.pictures) ? this.city.pictures : [];
      return pics.length > 0 ? pics[0] : (this.city.first_picture || '');
    },

    currentTabKey() {
      return this.contentTabs[this.activeTab]?.key || '';
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
      this.loading = false;

      // Load default tab content
      this.loadTabContent(0, 0);
    },

    switchTab(idx) {
      this.activeTab = idx;
      this.subTabIndex = 0;
      this.loadTabContent(idx, 0);
    },

    switchSubTab(idx) {
      this.subTabIndex = idx;
      this.loadTabContent(this.activeTab, idx);
    },

    async loadTabContent(tabIdx, subIdx) {
      const tab = this.contentTabs[tabIdx];
      if (!tab || tab.key === 'overview') return;

      this.tabLoading = true;
      try {
        if (tab.key === 'guide') {
          const subCats = this.subCategories;
          const guideType = subCats.length > 0 ? subCats[subIdx]?.id : undefined;
          const params = { city_id: this.cityId, page: 1, limit: 100 };
          if (guideType) params.guide_type = guideType;
          const res = await ApiProvider.get(ApiUrl.cityGuide, params);
          const list = res.data?.list || res.data || [];
          this.guides = Array.isArray(list) ? list : [];
        } else if (tab.typeId > 0) {
          const epKey = this.contentEndpointMap[tab.typeId];
          if (!epKey || !ApiUrl[epKey]) return;
          const subCats = this.subCategories;
          const typeClassId = subCats.length > 0 ? subCats[subIdx]?.id : undefined;
          const params = { city_id: this.cityId, page: 1, limit: 100 };
          if (typeClassId) params.type_class_id = typeClassId;
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

  // Watch for route query changes (e.g. switching between cities)
  watch: {
    '$route.query.id': function(newId) {
      if (newId) {
        this.cityId = parseInt(newId, 10);
        this.activeTab = 0;
        this.subTabIndex = 0;
        this.loadCity();
      }
    }
  }
};
