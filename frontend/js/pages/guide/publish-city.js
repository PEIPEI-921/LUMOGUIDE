/* ============================================
   Guide Publish City Page — 发布/管理我的城市
   Reference: PPCC guide-panel/cities/page.tsx
   ============================================ */

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
      <div v-else class="ds-container-640">
        <!-- Header -->
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
          <h2 class="ds-page-head" style="margin:0">{{ $t('我的城市') }}</h2>
          <button @click="showAdd=!showAdd" style="font-size:13px;color:var(--color-primary);font-weight:500;background:none;border:none;cursor:pointer">
            {{ showAdd ? $t('取消') : '+ ' + $t('新增城市') }}
          </button>
        </div>

        <!-- Add city panel -->
        <div v-if="showAdd" class="ds-card" style="padding:16px;margin-bottom:16px">
          <h3 style="font-weight:600;font-size:14px;margin-bottom:12px">{{ $t('選擇要申請服務的城市') }}</h3>
          <div v-if="addError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:10px 12px;border-radius:8px;margin-bottom:12px">{{ addError }}</div>
          <div v-if="availableCities.length===0" style="font-size:13px;color:var(--color-assistant-text)">
            {{ $t('你已申請所有可用城市') }}
          </div>
          <div v-else style="max-height:300px;overflow-y:auto">
            <div v-for="city in availableCities" :key="city.id" style="display:flex;align-items:center;gap:10px;padding:10px 8px;border-radius:8px"
              @mouseenter="$event.currentTarget.style.background='var(--color-bg-page)'" @mouseleave="$event.currentTarget.style.background='transparent'">
              <div style="width:40px;height:40px;border-radius:8px;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
                <img v-if="city.first_picture" :src="city.first_picture" alt="" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:18px">🏙️</div>
              </div>
              <span style="font-size:13px;flex:1">{{ city.name }}</span>
              <button @click="handleAddCity(city.id)" :disabled="addingId===city.id"
                class="ds-btn ds-btn-outline" style="font-size:11px;padding:4px 14px;border-radius:20px;opacity:addingId===city.id?.5:1">
                {{ addingId===city.id ? $t('申請中...') : $t('申請') }}
              </button>
            </div>
          </div>
        </div>

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
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ $t('你還沒有服務的城市') }}</p>
          <button @click="showAdd=true" class="ds-btn ds-btn-primary">{{ $t('新增城市') }}</button>
        </div>

        <!-- My cities list -->
        <div v-else>
          <div v-for="city in myCities" :key="city.id" class="ds-card" style="padding:14px;margin-bottom:10px">
            <div style="display:flex;align-items:center;gap:12px">
              <div style="width:52px;height:52px;border-radius:8px;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
                <img v-if="city.first_picture" :src="city.first_picture" alt="" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:22px">🏙️</div>
              </div>
              <div style="flex:1;min-width:0">
                <p style="font-size:14px;font-weight:600;margin:0">{{ city.city_name || city.name || '—' }}</p>
                <p v-if="city.created_at" style="font-size:11px;color:var(--color-assistant-text);margin-top:2px">{{ $t('申請時間') }}: {{ city.created_at.slice(0,10) }}</p>
                <span v-if="city.status!==undefined" :class="['ds-badge-sm', city.status===1?'ds-badge-success':'ds-badge-warning']" style="margin-top:4px;display:inline-block">
                  {{ city.status===1 ? $t('已通過') : $t('審核中') }}
                </span>
              </div>
              <button @click="handleDeleteCity(city.id, city.city_name||city.name)" style="font-size:12px;color:var(--color-red);background:none;border:none;cursor:pointer;flex-shrink:0">{{ $t('刪除') }}</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      myCities: [], allCities: [], loading: true, error: null,
      showAdd: false, addingId: null, addError: ''
    };
  },
  computed: {
    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    },
    myCityIds() { return new Set(this.myCities.map(c => c.city_id)); },
    availableCities() { return this.allCities.filter(c => !this.myCityIds.has(c.id)); },
  },
  mounted() {
    if (!UserStore.isLogin || !this.isGuide) { this.loading = false; return; }
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.loading = true; this.error = null;
      try {
        const [myRes, allRes] = await Promise.all([
          ApiProvider.get(ApiUrl.guideCityList, { page: 1, limit: 100 }),
          ApiProvider.get(ApiUrl.cityList, { limit: 1000, page: 1 }),
        ]);
        this.myCities = (myRes.success && myRes.data?.list) ? myRes.data.list : [];
        this.allCities = (allRes.success && allRes.data?.list) ? allRes.data.list : [];
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    async handleAddCity(cityId) {
      this.addingId = cityId; this.addError = '';
      try {
        const result = await ApiProvider.post(ApiUrl.guidePublishCity, { city_id: cityId });
        if (result.success) {
          this.showAdd = false;
          this.fetchData();
        } else {
          this.addError = result.message || '申請失敗';
        }
      } catch (e) {
        this.addError = e.message || '申請失敗';
      }
      this.addingId = null;
    },
    async handleDeleteCity(id, cityName) {
      if (!confirm('確定要刪除「' + (cityName || '此城市') + '」的服務嗎？')) return;
      try {
        const result = await ApiProvider.post(ApiUrl.guideDelCity, { id });
        if (result.success) this.fetchData();
      } catch (e) { /* silent */ }
    },
  }
};
