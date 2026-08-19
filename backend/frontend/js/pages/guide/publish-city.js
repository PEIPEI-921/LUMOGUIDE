/* ============================================
   Guide Publish City Page — 我的城市
   Reference: Flutter my_publish_city/page.dart + controller.dart + widgets/item.dart
   ============================================ */

// Status config — matching Flutter StatusWidget: 0=pending(primary) / 1=approved(green) / 2=rejected(red)
const CITY_AUDIT_MAP = {
  0: { label: '審核中', color: '#666FFF' },
  1: { label: '審核通過', color: '#00BEAA' },
  2: { label: '審核駁回', color: '#DD0000' },
};

const GuidePublishCityPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🌍</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <!-- Not guide -->
      <div v-else-if="!isGuide" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🔒</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('此功能僅限導遊使用') }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回') }}</button>
      </div>

      <!-- Content -->
      <div v-else class="ds-container-640" style="padding-bottom:80px">

        <!-- Info banner -->
        <div style="display:flex;align-items:flex-start;gap:8px;padding:12px 14px;border-radius:12px;background:#FFF7ED;border:1px solid rgba(249,115,22,.15);margin-bottom:16px">
          <span style="font-size:16px;flex-shrink:0;line-height:1.4">ℹ️</span>
          <span style="color:#C2410C;font-size:13px;line-height:1.5;font-weight:500">{{ $t('選擇長期居住城市或者工作所在地城市，請謹慎選擇。') }}</span>
        </div>

        <!-- City selector panel -->
        <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-radius:12px;background:var(--color-bg-white);border:1px solid var(--color-border);box-shadow:var(--shadow-sm);margin-bottom:20px">
          <div style="display:flex;align-items:center;gap:6px">
            <span style="font-size:13px;color:var(--color-secondary-text)">{{ $t('當前城市') }}:</span>
            <span v-if="currentCityName" style="font-size:15px;font-weight:600;color:var(--color-primary-text)">{{ currentCityName }}</span>
            <span v-else style="font-size:14px;color:var(--color-secondary-text)">{{ $t('未設置') }}</span>
          </div>
          <button @click="goChangeCity"
            style="font-size:13px;color:var(--color-primary);font-weight:600;background:none;border:none;cursor:pointer;padding:4px 0">{{ $t('切換城市') }} →</button>
        </div>

        <!-- Section header -->
        <div style="font-size:17px;font-weight:700;color:var(--color-primary-text);margin-bottom:12px;padding-top:4px">{{ $t('發布城市') }}</div>

        <!-- Loading -->
        <div v-if="loading" style="text-align:center;padding:80px 0">
          <div class="spinner"></div>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="ds-empty">
          <div style="font-size:36px;margin-bottom:8px">⚠️</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <button @click="fetchData" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- Empty -->
        <div v-else-if="myCities.length===0" class="ds-empty">
          <div style="font-size:40px;margin-bottom:12px">🌍</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ $t('暫無發布城市') }}</p>
        </div>

        <!-- City cards -->
        <div v-else>
          <div v-for="city in myCities" :key="city.id"
            style="border-radius:12px;overflow:hidden;box-shadow:var(--shadow-card);margin-bottom:12px;background:var(--color-bg-white);border:1px solid var(--color-border)">

            <!-- Card body -->
            <div style="padding:14px">
              <!-- Row 1: Publish time + unread dot + status badge -->
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px">
                <div style="display:flex;align-items:center;gap:6px">
                  <span v-if="city.is_read === 0" style="width:8px;height:8px;border-radius:50%;background:#EF4444;flex-shrink:0"></span>
                  <span style="font-size:13px;color:var(--color-secondary-text)">{{ $t('發佈時間') }}: {{ formatTime(city.created_at) }}</span>
                </div>
                <span v-if="cityStatus(city.audit_status).label"
                  :style="{ color: cityStatus(city.audit_status).color, borderColor: cityStatus(city.audit_status).color, background: cityStatusBg(city.audit_status) }"
                  style="font-size:11px;padding:4px 10px;border-radius:100px;border:1px solid;white-space:nowrap;flex-shrink:0;font-weight:600">{{ cityStatus(city.audit_status).label }}</span>
              </div>

              <!-- Row 2: Cover image with name overlay -->
              <div style="position:relative;border-radius:8px;overflow:hidden;height:200px;background:var(--color-bg-page)">
                <img v-if="getThumb(city)" :src="imageUrl(getThumb(city))" alt=""
                  style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:48px">🏙️</div>

                <!-- Gradient overlay + name -->
                <div style="position:absolute;left:14px;top:14px;padding:10px 14px;border-radius:8px;background:linear-gradient(90deg, rgba(0,0,0,.65) 0%, rgba(0,0,0,.2) 100%);min-width:140px;max-width:calc(100% - 28px)">
                  <div style="display:flex;align-items:center;gap:8px">
                    <span style="color:#fff;font-size:17px;font-weight:700;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:100px">{{ city.name || city.city_name || '—' }}</span>
                    <span v-if="city.is_capital === 1"
                      style="color:#FFD700;font-size:10px;padding:2px 6px;border:1px solid rgba(255,215,0,.6);border-radius:4px;white-space:nowrap;flex-shrink:0;font-weight:600">{{ $t('首都') }}</span>
                  </div>
                  <div v-if="city.name_en" style="color:rgba(255,255,255,.75);font-size:12px;margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:120px">{{ city.name_en }}</div>
                </div>
              </div>

              <!-- Location info -->
              <div v-if="city.continents_name || city.area_name || city.country_name" style="display:flex;gap:12px;margin-top:10px;font-size:12px;color:var(--color-secondary-text)">
                <span v-if="city.continents_name">🌏 {{ city.continents_name }}</span>
                <span v-if="city.area_name">{{ city.area_name }}</span>
                <span v-if="city.country_name">{{ city.country_name }}</span>
              </div>

              <!-- Rejection reason -->
              <div v-if="city.audit_status === 2 && city.audit_feedback"
                style="color:#DD0000;font-size:13px;margin-top:10px;font-weight:500">
                {{ $t('駁回原因') }}: {{ city.audit_feedback }}
              </div>
            </div>

            <!-- Operate bar -->
            <div style="height:44px;display:flex;align-items:center;border-top:1px solid var(--color-border);background:var(--color-bg-card)">
              <div @click="onEditCity(city)"
                style="flex:1;display:flex;align-items:center;justify-content:center;height:100%;cursor:pointer;font-size:14px;color:var(--color-primary-text);font-weight:600;user-select:none">{{ $t('編輯') }}</div>
              <template v-if="city.audit_status === 2">
                <div style="width:1px;height:20px;background:var(--color-border);flex-shrink:0"></div>
                <div @click="onDeleteCity(city)"
                  style="flex:1;display:flex;align-items:center;justify-content:center;height:100%;cursor:pointer;font-size:14px;color:var(--color-primary-text);font-weight:600;user-select:none">{{ $t('刪除') }}</div>
              </template>
            </div>

          </div>
        </div>

      </div>

      <!-- FAB — matching Flutter FloatingActionButton -->
      <div style="position:fixed;bottom:32px;right:24px;z-index:50">
        <button @click="onAddCity"
          style="display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;width:56px;height:56px;border-radius:50%;background:var(--color-primary);color:#fff;border:none;cursor:pointer;box-shadow:0 4px 16px rgba(102,111,255,.35);transition:transform .15s"
          @mouseenter="$event.currentTarget.style.transform='scale(1.05)'"
          @mouseleave="$event.currentTarget.style.transform=''">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          <span style="font-size:10px;font-weight:600">{{ $t('發佈') }}</span>
        </button>
      </div>
    </div>
  `,
  data() {
    return {
      myCities: [],
      loading: true,
      error: null,
      currentCityName: '',
    };
  },
  computed: {
    isGuide() {
      const info = UserStore.userInfo;
      return !!UserStore.token && info && Number(info.identity) === 2;
    },
  },
  mounted() {
    if (!UserStore.isLogin || !this.isGuide) { this.loading = false; return; }
    this.init();
  },
  methods: {
    imageUrl,

    async init() {
      // Get current city name from UserStore profile
      const info = UserStore.profile || UserStore.userInfo || {};
      this.currentCityName = info.city_name
        || (info.guide_info && info.guide_info.city_name)
        || '';
      if (!this.currentCityName) {
        // Fallback: try guide city info API
        try {
          const infoRes = await ApiProvider.get(ApiUrl.guideCityInfo);
          if (infoRes.success && infoRes.data) {
            this.currentCityName = infoRes.data.city_name || infoRes.data.name || '';
          }
        } catch (e) { /* silently ignore */ }
      }
      await this.fetchData();
    },

    // --- Data fetching (matching Flutter fetchData) ---

    async fetchData() {
      this.loading = true; this.error = null;
      try {
        const res = await ApiProvider.get(ApiUrl.guideCityList, { page: 1, limit: 100 });
        console.log('[PublishCity] guideCityList raw:', JSON.stringify({ success: res.success, code: res.code, message: res.message, data: res.data }).slice(0, 300));
        if (res.success) {
          // guideCityList returns flat array — try ALL possible shapes
          const d = res.data;
          let list = null;
          if (Array.isArray(d?.list)) list = d.list;
          else if (Array.isArray(d?.data)) list = d.data;
          else if (Array.isArray(d)) list = d;
          this.myCities = list || [];
          console.log('[PublishCity] parsed myCities:', this.myCities.length, 'items');
        } else {
          this.error = res.message || '載入失敗';
          console.warn('[PublishCity] API failed:', res.code, res.message);
        }
      } catch (e) {
        console.error('[PublishCity] fetchData error:', e);
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },

    // --- Helpers ---

    cityStatus(s) {
      return CITY_AUDIT_MAP[Number(s)] || {};
    },

    cityStatusBg(s) {
      const bgMap = { 0: 'rgba(102,111,255,.08)', 1: 'rgba(0,190,170,.08)', 2: 'rgba(221,0,0,.06)' };
      return bgMap[Number(s)] || 'transparent';
    },

    getThumb(city) {
      return city.first_picture || city.photo
        || (Array.isArray(city.pictures) && city.pictures.length > 0 ? city.pictures[0] : null)
        || '';
    },

    formatTime(d) {
      if (!d) return '—';
      return d.slice(0, 16).replace('T', ' ');
    },

    goChangeCity() {
      this.$router.push('/guide/change-city');
    },

    // --- Add city (matching Flutter onAddCity) ---

    onAddCity() {
      if (!UserStore.isVip) {
        this.$router.push('/vip');
        return;
      }
      this.$router.push('/guide/publish-city-form');
    },

    // --- Edit city (matching Flutter onEditCity — NO VIP check for editing) ---

    onEditCity(city) {
      this.$router.push('/guide/publish-city-form?id=' + city.id);
    },

    // --- Delete city (matching Flutter onDeleteCity — only called when auditStatus == 2) ---

    async onDeleteCity(city) {
      const name = city.name || city.city_name || '此城市';
      if (!confirm('確定要刪除「' + name + '」嗎？')) return;
      try {
        const result = await ApiProvider.post(ApiUrl.guideDelCity, { id: city.id });
        if (result.success) {
          this.fetchData();
        } else {
          alert(result.message || '刪除失敗');
        }
      } catch (e) {
        console.error('[PublishCity] delete error:', e);
      }
    },

  }
};
