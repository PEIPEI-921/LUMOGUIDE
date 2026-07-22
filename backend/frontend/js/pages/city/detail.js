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
          <img v-for="(pic, idx) in banners" :key="'banner-' + idx + '-' + pic.substring(pic.lastIndexOf('/'))" :src="pic" :alt="city.name"
            style="width:100%;height:100%;object-fit:cover;object-position:center;position:absolute;inset:0;transition:opacity .4s"
            :style="{ opacity: idx === bannerIndex ? 1 : 0 }">
        </div>
        <div v-else style="width:100%;height:100%;background:linear-gradient(135deg,var(--color-accent-soft),transparent);display:flex;align-items:center;justify-content:center">
          <span style="font-size:48px;opacity:0.3"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="4" y="2" width="16" height="20" rx="1"/><line x1="9" y1="6" x2="11" y2="6"/><line x1="13" y1="6" x2="15" y2="6"/><line x1="9" y1="14" x2="15" y2="14"/><path d="M9 22v-4h6v4"/></svg></span>
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
          <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:10px">
            <div v-if="city.currency" class="card" style="text-align:center;padding:18px 14px">
              <div class="tiny" style="margin-bottom:4px">{{ $t('貨幣') }}</div>
              <div style="font-size:14px;font-weight:600">{{ city.currency }}</div>
            </div>
            <div v-if="city.language" class="card" style="text-align:center;padding:18px 14px">
              <div class="tiny" style="margin-bottom:4px">{{ $t('語言') }}</div>
              <div style="font-size:14px;font-weight:600">{{ city.language }}</div>
            </div>
            <div v-if="city.population" class="card" style="text-align:center;padding:18px 14px">
              <div class="tiny" style="margin-bottom:4px">{{ $t('人口') }}</div>
              <div style="font-size:14px;font-weight:600">{{ city.population }}</div>
            </div>
            <div v-if="city.race" class="card" style="text-align:center;padding:18px 14px">
              <div class="tiny" style="margin-bottom:4px">{{ $t('種族') }}</div>
              <div style="font-size:14px;font-weight:600">{{ city.race }}</div>
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
              :href="'#/detail/' + currentTabKey + '?id=' + item.id + (cityId ? '&city_id=' + cityId : '') + '&type_id=' + getTypeId(currentTabKey)"
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

      <!-- Publish FAB (always visible for guides on specific tabs; VIP check on click, matching Flutter) -->
      <a v-if="showPublishFab" href="#" @click.prevent="onPublishFabClick"
        style="position:fixed;bottom:24px;right:24px;z-index:100;display:flex;flex-direction:column;align-items:center;justify-content:center;width:56px;height:56px;border-radius:100px;background:var(--color-primary);color:#fff;text-decoration:none;box-shadow:0 4px 16px rgba(102,111,255,.4);transition:transform .2s,box-shadow .2s"
        @mouseenter="$event.currentTarget.style.transform='scale(1.05)';$event.currentTarget.style.boxShadow='0 6px 20px rgba(102,111,255,.5)'"
        @mouseleave="$event.currentTarget.style.transform='scale(1)';$event.currentTarget.style.boxShadow='0 4px 16px rgba(102,111,255,.4)'"
        :title="$t('發布') + contentTabs[activeTab].label">
        <span style="font-size:20px;line-height:1;font-weight:300">+</span>
        <span style="font-size:10px;line-height:1;margin-top:1px">{{ $t('發布') }}</span>
      </a>
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
      },
      // Tab → publish route (only 4 types guides can publish)
      publishRouteMap: {
        2: '/publish/attraction',
        7: '/publish/transportation',
        8: '/publish/facility',
        9: '/publish/activity'
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
        return (this.cityClass.guide_type || []);
      }
      if (tab.typeId === 0) return [];
      const group = (this.cityClass.type || []).find(g => g.id === tab.typeId);
      return group ? (group.child || []) : [];
    },

    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    },

    showPublishFab() {
      // Visible for all guides on specific tabs; VIP check on click (matching Flutter)
      return this.isGuide && this.publishRouteMap[this.activeTab] !== undefined;
    }
  },

  methods: {
    getTypeId(key) {
      const tab = this.contentTabs.find(t => t.key === key);
      return tab ? tab.typeId : 0;
    },
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
        ApiProvider.get(ApiUrl.cityInfo, { city_id: this.cityId }).catch(e => ({ success: false, message: e.message, data: null })),
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

    // Publish FAB click — VIP gate (matching Flutter VIPCheckUtils.check())
    onPublishFabClick() {
      if (!UserStore.isVip) {
        this.$router.push('/vip');
        return;
      }
      const route = this.publishRouteMap[this.activeTab];
      if (route) {
        this.$router.push(route + '?city_id=' + this.cityId);
      }
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
