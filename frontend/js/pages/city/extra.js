/* ============================================
   City Strategy Page — 城市攻略（GPS定位就近城市）
   ============================================ */

const CityStrategyPage = {
  template: `
    <div class="page-content"><div class="ds-container-960" style="padding-top:16px;padding-bottom:16px">
      <!-- City Info Bar -->
      <div style="display:flex;align-items:center;justify-content:flex-end;margin-bottom:16px;gap:8px">
        <span v-if="locating" style="color:rgba(255,255,255,0.7);font-size:13px">📍 {{ $t('定位中...') }}</span>
        <template v-else-if="currentCity">
          <span style="color:#fff;font-weight:500;font-size:13px">📍 {{ currentCity.name }}</span>
          <button @click="showCityPicker = !showCityPicker"
            style="font-size:12px;color:#fff;background:rgba(255,255,255,0.12);border:1px solid rgba(255,255,255,0.4);border-radius:20px;padding:3px 14px;cursor:pointer">{{ $t('切換城市') }}</button>
        </template>
        <span v-else style="color:rgba(255,255,255,0.7);font-size:13px">{{ $t('未定位，顯示全部') }}</span>
      </div>

      <!-- City Picker -->
      <div v-if="showCityPicker && cities.length" style="margin-bottom:12px;padding:12px;background:var(--color-bg-card);border-radius:12px;max-height:200px;overflow-y:auto">
        <div style="display:flex;flex-wrap:wrap;gap:8px">
          <button v-for="c in cities" :key="c.id"
            @click="selectCity(c)"
            :style="{padding:'6px 14px',borderRadius:'20px',border:'1px solid ' + (currentCity && currentCity.id === c.id ? 'var(--color-primary)' : 'var(--color-border)'),background: currentCity && currentCity.id === c.id ? 'var(--color-primary)' : '#fff',color: currentCity && currentCity.id === c.id ? '#fff' : 'var(--color-primary-text)',fontSize:'13px',cursor:'pointer'}">{{ c.name }}</button>
        </div>
      </div>

      <!-- Type Pills — rectangular, icon left of text -->
      <div class="strategy-pills">
        <div v-for="cat in strategyTypes" :key="cat.key"
          class="strategy-pill"
          :style="{background: activeType === cat.key ? cat.bgActive : cat.bg, borderColor: activeType === cat.key ? '#7C5CFF' : 'transparent'}"
          @click="switchType(cat)">
          <span v-html="activeType === cat.key ? cat.svgActive : cat.svg"></span>
          <span class="strategy-pill-label">{{ $t(cat.label) }}</span>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>

      <!-- Error -->
      <div v-else-if="error" class="ds-empty">
        <p style="margin-bottom:12px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="loadContent" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>

      <!-- Empty -->
      <div v-else-if="items.length === 0" class="ds-empty">{{ $t('暫無攻略') }}</div>

      <!-- Content Grid -->
      <div v-else style="display:grid;grid-template-columns:repeat(auto-fill, minmax(180px, 1fr));gap:12px">
        <a v-for="item in items" :key="item.id"
          :href="activeType === 'guide' ? '#/guide/' + item.id : '#/detail/' + activeType + '?id=' + item.id + '&city_id=' + item.city_id"
          class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block;overflow:hidden">
          <div style="height:140px;overflow:hidden;background:var(--color-bg-card)">
            <img v-if="item.photo || item.first_picture" :src="item.photo || item.first_picture" :alt="item.name"
              style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;opacity:.3">{{ activeType === 'guide' ? '👤' : '📷' }}</div>
          </div>
          <div style="padding:12px">
            <div style="font-size:14px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.name }}</div>
            <div v-if="item.city_name" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ item.city_name }}</div>
            <div v-if="item.price" style="font-size:12px;color:var(--color-primary);font-weight:600;margin-top:2px">{{ item.price }}</div>
          </div>
        </a>
      </div>
    </div>
    </div>
  `,

  data() {
    return {
      activeType: '',
      items: [],
      loading: false,
      error: null,
      locating: true,
      currentCity: null,
      cities: [],
      showCityPicker: false,
      strategyTypes: [
        { key: 'guide', label: '導遊', endpoint: 'cityGuide',
          bg: '#EDEAF6', bgActive: '#DFDAF0',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><circle cx="8.5" cy="4.5" r="3.5" stroke="#162539" stroke-width="1.6"/><path d="M4.5 21v-6a4 4 0 0 1 4-3.5" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><line x1="16.5" y1="2" x2="16.5" y2="13" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><path d="M16.5 2l4.5 2.5-4.5 2.5z" fill="#7C5CFF" stroke="none"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><circle cx="8.5" cy="4.5" r="3.5" stroke="#7C5CFF" stroke-width="1.8"/><path d="M4.5 21v-6a4 4 0 0 1 4-3.5" stroke="#7C5CFF" stroke-width="1.8" stroke-linecap="round"/><line x1="16.5" y1="2" x2="16.5" y2="13" stroke="#7C5CFF" stroke-width="1.8" stroke-linecap="round"/><path d="M16.5 2l4.5 2.5-4.5 2.5z" fill="#7C5CFF" stroke="none"/></svg>' },
        { key: 'attraction', label: '景點', endpoint: 'cityAttraction',
          bg: '#E2F0E8', bgActive: '#D2E8DC',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><path d="M3 22l5-10 3 4 2-3 4-5.5 3.5 7.5" stroke="#162539" stroke-width="1.6" stroke-linejoin="round"/><path d="M6 11c-1.5 0-3 .8-3 2s1.5 2 3 2h8c1.2 0 2.2-.8 2.2-1.8 0-1-.8-2-2-1.8-.3-1.8-2-2.5-3.5-1.8" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><circle cx="16" cy="8.5" r="1.5" fill="#06D6A0" stroke="none"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><path d="M3 22l5-10 3 4 2-3 4-5.5 3.5 7.5" stroke="#06D6A0" stroke-width="1.8" stroke-linejoin="round"/><path d="M6 11c-1.5 0-3 .8-3 2s1.5 2 3 2h8c1.2 0 2.2-.8 2.2-1.8 0-1-.8-2-2-1.8-.3-1.8-2-2.5-3.5-1.8" stroke="#06D6A0" stroke-width="1.8" stroke-linecap="round"/><circle cx="16" cy="8.5" r="1.5" fill="#06D6A0" stroke="none"/></svg>' },
        { key: 'restaurant', label: '餐廳', endpoint: 'cityRestaurant',
          bg: '#FBF3E0', bgActive: '#F6E8CC',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><path d="M4 7.5c0-2 3.5-3 8-3s8 1 8 3" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><rect x="4.5" y="8.5" width="15" height="2.8" rx="0.5" fill="#FF8C42" stroke="none"/><path d="M4 13c0 2 3.5 3 8 3s8-1 8-3" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><rect x="9" y="17" width="6" height="5" rx="1.3" stroke="#162539" stroke-width="1.6"/><line x1="12" y1="14.5" x2="12" y2="17" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><path d="M4 7.5c0-2 3.5-3 8-3s8 1 8 3" stroke="#FF8C42" stroke-width="1.8" stroke-linecap="round"/><rect x="4.5" y="8.5" width="15" height="2.8" rx="0.5" fill="#FF8C42" stroke="none"/><path d="M4 13c0 2 3.5 3 8 3s8-1 8-3" stroke="#FF8C42" stroke-width="1.8" stroke-linecap="round"/><rect x="9" y="17" width="6" height="5" rx="1.3" stroke="#FF8C42" stroke-width="1.8"/><line x1="12" y1="14.5" x2="12" y2="17" stroke="#FF8C42" stroke-width="1.8" stroke-linecap="round"/></svg>' },
        { key: 'shopping', label: '購物', endpoint: 'cityShopping',
          bg: '#FDE8E2', bgActive: '#FAD8D0',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><path d="M7 3L3.5 7v13a2 2 0 0 0 2 2h13a2 2 0 0 0 2-2V7l-3.5-4z" stroke="#162539" stroke-width="1.6" stroke-linejoin="round"/><path d="M3.5 7h17" stroke="#162539" stroke-width="1.6"/><path d="M7 3a5 5 0 0 1 10 0" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><path d="M9 7.5V6" stroke="#EF476F" stroke-width="2.2" stroke-linecap="round"/><path d="M15 7.5V6" stroke="#EF476F" stroke-width="2.2" stroke-linecap="round"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><path d="M7 3L3.5 7v13a2 2 0 0 0 2 2h13a2 2 0 0 0 2-2V7l-3.5-4z" stroke="#EF476F" stroke-width="1.8" stroke-linejoin="round"/><path d="M3.5 7h17" stroke="#EF476F" stroke-width="1.8"/><path d="M7 3a5 5 0 0 1 10 0" stroke="#EF476F" stroke-width="1.8" stroke-linecap="round"/><path d="M9 7.5V6" stroke="#EF476F" stroke-width="2.2" stroke-linecap="round"/><path d="M15 7.5V6" stroke="#EF476F" stroke-width="2.2" stroke-linecap="round"/></svg>' },
        { key: 'accommodation', label: '住宿', endpoint: 'cityAccommodation',
          bg: '#F2E8F5', bgActive: '#E8D8EE',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="2" y="7" width="20" height="15" rx="1" stroke="#162539" stroke-width="1.6"/><rect x="7" y="10" width="3.5" height="12" stroke="#162539" stroke-width="1.6"/><rect x="13.5" y="10" width="3.5" height="12" stroke="#162539" stroke-width="1.6"/><rect x="14.5" y="12" width="2" height="3.5" rx="0.3" fill="#A837FF" stroke="none"/><line x1="5" y1="3" x2="5" y2="7" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><line x1="12" y1="3" x2="12" y2="7" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><line x1="19" y1="3" x2="19" y2="7" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="2" y="7" width="20" height="15" rx="1" stroke="#A837FF" stroke-width="1.8"/><rect x="7" y="10" width="3.5" height="12" stroke="#A837FF" stroke-width="1.8"/><rect x="13.5" y="10" width="3.5" height="12" stroke="#A837FF" stroke-width="1.8"/><rect x="14.5" y="12" width="2" height="3.5" rx="0.3" fill="#A837FF" stroke="none"/><line x1="5" y1="3" x2="5" y2="7" stroke="#A837FF" stroke-width="1.8" stroke-linecap="round"/><line x1="12" y1="3" x2="12" y2="7" stroke="#A837FF" stroke-width="1.8" stroke-linecap="round"/><line x1="19" y1="3" x2="19" y2="7" stroke="#A837FF" stroke-width="1.8" stroke-linecap="round"/></svg>' },
        { key: 'transportation', label: '交通', endpoint: 'cityTransportation',
          bg: '#E8F0FA', bgActive: '#D6E4F6',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="2" y="5" width="20" height="12" rx="2" stroke="#162539" stroke-width="1.6"/><circle cx="7" cy="19" r="2" stroke="#162539" stroke-width="1.6"/><circle cx="17" cy="19" r="2" stroke="#162539" stroke-width="1.6"/><rect x="10" y="6.5" width="8" height="4" rx="0.5" fill="#6695FF" stroke="none"/><line x1="12" y1="5" x2="12" y2="17" stroke="#162539" stroke-width="1" stroke-dasharray="1.5 1.5"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="2" y="5" width="20" height="12" rx="2" stroke="#6695FF" stroke-width="1.8"/><circle cx="7" cy="19" r="2" stroke="#6695FF" stroke-width="1.8"/><circle cx="17" cy="19" r="2" stroke="#6695FF" stroke-width="1.8"/><rect x="10" y="6.5" width="8" height="4" rx="0.5" fill="#6695FF" stroke="none"/><line x1="12" y1="5" x2="12" y2="17" stroke="#6695FF" stroke-width="1.2" stroke-dasharray="1.5 1.5"/></svg>' },
        { key: 'facility', label: '設施', endpoint: 'cityFacility',
          bg: '#E6F7F7', bgActive: '#D2EFEF',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="4" y="5" width="16" height="17" rx="1" stroke="#162539" stroke-width="1.6"/><rect x="8" y="9" width="3" height="3" rx="0.3" fill="#00D8D5" stroke="none"/><rect x="13" y="9" width="3" height="3" rx="0.3" fill="#00D8D5" stroke="none"/><rect x="8" y="15" width="3" height="3" rx="0.3" stroke="#162539" stroke-width="1.2"/><rect x="13" y="15" width="3" height="3" rx="0.3" stroke="#162539" stroke-width="1.2"/><line x1="12" y1="2" x2="12" y2="5" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="4" y="5" width="16" height="17" rx="1" stroke="#00D8D5" stroke-width="1.8"/><rect x="8" y="9" width="3" height="3" rx="0.3" fill="#00D8D5" stroke="none"/><rect x="13" y="9" width="3" height="3" rx="0.3" fill="#00D8D5" stroke="none"/><rect x="8" y="15" width="3" height="3" rx="0.3" stroke="#00D8D5" stroke-width="1.4"/><rect x="13" y="15" width="3" height="3" rx="0.3" stroke="#00D8D5" stroke-width="1.4"/><line x1="12" y1="2" x2="12" y2="5" stroke="#00D8D5" stroke-width="1.8" stroke-linecap="round"/></svg>' },
        { key: 'activity', label: '活動', endpoint: 'cityActivity',
          bg: '#FFF4E4', bgActive: '#FCE8CC',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="18" rx="2" stroke="#162539" stroke-width="1.6"/><line x1="3" y1="9" x2="21" y2="9" stroke="#162539" stroke-width="1.6"/><line x1="8" y1="2" x2="8" y2="6" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><line x1="16" y1="2" x2="16" y2="6" stroke="#162539" stroke-width="1.6" stroke-linecap="round"/><polygon points="12,11 13.5,14.5 17,14.5 14.5,17 15.5,20.5 12,18.5 8.5,20.5 9.5,17 7,14.5 10.5,14.5" fill="#FFA921" stroke="none"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="18" rx="2" stroke="#FFA921" stroke-width="1.8"/><line x1="3" y1="9" x2="21" y2="9" stroke="#FFA921" stroke-width="1.8"/><line x1="8" y1="2" x2="8" y2="6" stroke="#FFA921" stroke-width="1.8" stroke-linecap="round"/><line x1="16" y1="2" x2="16" y2="6" stroke="#FFA921" stroke-width="1.8" stroke-linecap="round"/><polygon points="12,11 13.5,14.5 17,14.5 14.5,17 15.5,20.5 12,18.5 8.5,20.5 9.5,17 7,14.5 10.5,14.5" fill="#FFA921" stroke="none"/></svg>' },
        { key: 'ticket', label: '票務', endpoint: 'cityTicket',
          bg: '#E3F0F8', bgActive: '#D0E4F2',
          svg: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="16" rx="2" stroke="#162539" stroke-width="1.6"/><line x1="14" y1="4" x2="14" y2="20" stroke="#162539" stroke-width="1.6"/><circle cx="17" cy="8" r="1.2" fill="#4ECDC4" stroke="none"/><circle cx="17" cy="12" r="1.2" fill="#4ECDC4" stroke="none"/><circle cx="17" cy="16" r="1.2" fill="#4ECDC4" stroke="none"/></svg>',
          svgActive: '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="16" rx="2" stroke="#4ECDC4" stroke-width="1.8"/><line x1="14" y1="4" x2="14" y2="20" stroke="#4ECDC4" stroke-width="1.8"/><circle cx="17" cy="8" r="1.2" fill="#4ECDC4" stroke="none"/><circle cx="17" cy="12" r="1.2" fill="#4ECDC4" stroke="none"/><circle cx="17" cy="16" r="1.2" fill="#4ECDC4" stroke="none"/></svg>' },
      ]
    };
  },

  computed: {
    typeName() {
      const t = this.strategyTypes.find(s => s.key === this.activeType);
      return t ? t.label : '';
    }
  },

  methods: {
    switchType(t) {
      this.activeType = t.key;
      this.loadContent();
    },

    selectCity(city) {
      this.currentCity = city;
      this.showCityPicker = false;
      this.loadContent();
    },

    async loadContent() {
      if (!this.activeType) return;
      this.loading = true;
      this.error = null;

      const epKey = this.strategyTypes.find(s => s.key === this.activeType)?.endpoint;
      if (!epKey || !ApiUrl[epKey]) {
        this.error = '未知類型';
        this.loading = false;
        return;
      }

      const params = { page: 1, limit: 100 };
      if (this.currentCity && this.currentCity.id) {
        params.city_id = this.currentCity.id;
      }

      const res = await ApiProvider.get(ApiUrl[epKey], params);
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.items = Array.isArray(list) ? list : [];
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },

    async fetchLocation() {
      this.locating = true;

      // Try browser GPS
      let lat = null, lng = null;
      if (navigator.geolocation) {
        try {
          const pos = await new Promise((resolve, reject) => {
            navigator.geolocation.getCurrentPosition(resolve, reject, {
              timeout: 8000, maximumAge: 600000
            });
          });
          lat = pos.coords.latitude;
          lng = pos.coords.longitude;
        } catch (e) {
          // GPS denied or unavailable — fallback to all cities
        }
      }

      // Fetch city list for picker
      const cityRes = await ApiProvider.get(ApiUrl.cityList, { limit: 1000, page: 1 });
      if (cityRes.success) {
        const list = cityRes.data?.list || cityRes.data || [];
        this.cities = Array.isArray(list) ? list : [];
      }

      // Try to resolve GPS to nearest city
      if (lat !== null && lng !== null) {
        const locRes = await ApiProvider.get(ApiUrl.getLocation, {
          latitude: lat, longitude: lng
        });
        if (locRes.success && locRes.data && locRes.data.id) {
          this.currentCity = locRes.data;
        } else if (this.cities.length > 0) {
          // Fallback: use first city from list
          this.currentCity = this.cities[0];
        }
      } else if (this.cities.length > 0) {
        // No GPS — use first city from list as default
        this.currentCity = this.cities[0];
      }

      this.locating = false;
    }
  },

  async mounted() {
    const qType = this.$route.query.type;
    this.activeType = qType || this.strategyTypes[0].key;

    await this.fetchLocation();
    this.loadContent();
  }
};


/* ============================================
   City Guide List Page — 城市導遊列表
   ============================================ */

const CityGuideListPage = {
  template: `
    <div class="page-content"><div class="ds-container-960" style="padding-top:16px;padding-bottom:16px">
      <div class="ds-page-head" style="padding-top:16px">
        <h1>{{ $t('導遊列表') }}<span v-if="cityName"> · {{ cityName }}</span></h1>
      </div>

      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="error" class="ds-empty">
        <p style="margin-bottom:12px">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>
      <div v-else-if="guides.length === 0" class="ds-empty">{{ $t('暫無導遊') }}</div>
      <div v-else style="display:grid;grid-template-columns:repeat(auto-fill, minmax(180px, 1fr));gap:12px">
        <a v-for="g in guides" :key="g.id" :href="'#/guide/' + g.id"
          class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block;overflow:hidden">
          <div style="height:140px;overflow:hidden;background:var(--color-bg-card)">
            <img v-if="g.photo" :src="g.photo" :alt="g.name" style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:32px">👤</div>
          </div>
          <div style="padding:12px">
            <div style="font-size:14px;font-weight:600">{{ g.name }}</div>
            <div style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ g.city_name }}</div>
            <div v-if="g.language && g.language.length" style="display:flex;gap:3px;margin-top:6px;flex-wrap:wrap">
              <span v-for="lang in g.language.slice(0, 3)" :key="lang"
                style="font-size:9px;padding:1px 6px;border-radius:20px;background:var(--color-accent-soft);color:var(--color-primary)">{{ lang }}</span>
            </div>
          </div>
        </a>
      </div>
    </div>
    </div>
  `,

  data() {
    return { guides: [], loading: true, error: null, cityName: '' };
  },

  methods: {
    async load() {
      const cityId = this.$route.query.city_id;
      if (!cityId) {
        this.error = '缺少城市 ID';
        this.loading = false;
        return;
      }
      this.loading = true;
      this.error = null;
      const res = await ApiProvider.get(ApiUrl.cityGuide, { city_id: cityId, page: 1, limit: 100 });
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.guides = Array.isArray(list) ? list : [];
        if (this.guides.length > 0) this.cityName = this.guides[0].city_name || '';
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    }
  },

  mounted() { this.load(); }
};
