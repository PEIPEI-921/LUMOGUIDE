/* ============================================
   City Strategy Page — 城市攻略
   Shows city content filtered by type
   ============================================ */

const CityStrategyPage = {
  template: `
    <div class="page-content"><div class="ds-container-960" style="padding-top:16px;padding-bottom:16px">
      <!-- Page Head -->
      <div class="ds-page-head" style="padding-top:16px">
        <h1>{{ $t('城市攻略') }}<span v-if="typeName"> · {{ typeName }}</span></h1>
      </div>

      <!-- Type Filter -->
      <div class="ds-type-tabs" style="margin-bottom:16px">
        <div class="ds-type-tabs-row">
          <button v-for="t in strategyTypes" :key="t.key"
            @click="switchType(t)"
            :class="['ds-type-tab', { active: activeType === t.key }]">{{ $t(t.label) }}</button>
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
          :href="'#/detail/' + activeType + '?id=' + item.id + '&city_id=' + item.city_id"
          class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:block;overflow:hidden">
          <div style="height:140px;overflow:hidden;background:var(--color-bg-card)">
            <img v-if="item.first_picture" :src="item.first_picture" :alt="item.name"
              style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;opacity:.3">📷</div>
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
      strategyTypes: [
        { key: 'attraction', label: '景點', endpoint: 'cityAttraction' },
        { key: 'restaurant', label: '餐廳', endpoint: 'cityRestaurant' },
        { key: 'shopping', label: '購物', endpoint: 'cityShopping' },
        { key: 'accommodation', label: '住宿', endpoint: 'cityAccommodation' },
        { key: 'transportation', label: '交通', endpoint: 'cityTransportation' },
        { key: 'facility', label: '設施', endpoint: 'cityFacility' },
        { key: 'activity', label: '活動', endpoint: 'cityActivity' },
        { key: 'ticket', label: '票務', endpoint: 'cityTicket' }
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

      const res = await ApiProvider.get(ApiUrl[epKey], { page: 1, limit: 100 });
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.items = Array.isArray(list) ? list : [];
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    }
  },

  mounted() {
    // Default type from query, or first type
    const qType = this.$route.query.type;
    this.activeType = qType || this.strategyTypes[0].key;
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
