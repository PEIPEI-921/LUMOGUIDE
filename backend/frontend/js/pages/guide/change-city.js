/* ============================================
   Guide Change City Page — 切换城市
   ============================================ */

const GuideChangeCityPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🔄</div>
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
        <h2 class="ds-page-head" style="margin-bottom:8px">{{ $t('切換城市') }}</h2>
        <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:20px">{{ $t('選擇一個城市作為當前服務城市') }}</p>

        <!-- Current city -->
        <div v-if="currentCity" class="ds-card" style="padding:16px;margin-bottom:16px;background:var(--color-accent-soft);border:1px solid rgba(102,111,255,.15)">
          <span style="font-size:11px;color:var(--color-primary);font-weight:600;text-transform:uppercase">{{ $t('當前城市') }}</span>
          <div style="display:flex;align-items:center;gap:12px;margin-top:8px">
            <div style="width:48px;height:48px;border-radius:12px;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
              <img v-if="currentCity.first_picture" :src="currentCity.first_picture" alt="" style="width:100%;height:100%;object-fit:cover">
              <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:22px">🏙️</div>
            </div>
            <div>
              <p style="font-size:16px;font-weight:700;margin:0;color:var(--color-primary-text)">{{ currentCity.city_name || currentCity.name }}</p>
            </div>
          </div>
        </div>

        <!-- Loading -->
        <div v-if="loading" style="text-align:center;padding:60px 0">
          <div class="spinner"></div>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="ds-empty">
          <div style="font-size:36px;margin-bottom:8px">⚠️</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <button @click="fetchCities" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- City list -->
        <div v-else-if="cities.length===0" class="ds-empty">
          <div style="font-size:40px;margin-bottom:12px">🌍</div>
          <p style="color:var(--color-secondary-text)">{{ $t('暫無可用城市') }}</p>
        </div>

        <div v-else>
          <div v-for="city in cities" :key="city.id" @click="handleChange(city)"
            class="ds-card ds-card-hover" style="padding:14px;margin-bottom:10px;cursor:pointer"
            :style="{border:currentCity&&city.id===currentCity.city_id?'2px solid var(--color-primary)':''}">
            <div style="display:flex;align-items:center;gap:12px">
              <div style="width:48px;height:48px;border-radius:10px;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
                <img v-if="city.first_picture" :src="city.first_picture" alt="" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:22px">🏙️</div>
              </div>
              <div style="flex:1;min-width:0">
                <p style="font-size:14px;font-weight:600;margin:0">{{ city.city_name || city.name }}</p>
                <p v-if="city.country_name" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ city.country_name }}</p>
              </div>
              <span v-if="currentCity&&city.id===currentCity.city_id" style="font-size:12px;color:var(--color-green);font-weight:500">✓ {{ $t('當前') }}</span>
              <span v-else style="color:var(--color-assistant-text);font-size:20px">›</span>
            </div>
          </div>
        </div>

        <!-- Submit message -->
        <div v-if="message" style="margin-top:20px;margin-bottom:32px">
          <div :style="{textAlign:'center',padding:'16px',borderRadius:'12px',background:messageType==='success'?'#ECFDF5':'#FEF2F2',color:messageType==='success'?'var(--color-green)':'var(--color-red)',fontSize:'13px'}">{{ message }}</div>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      cities: [], currentCity: null, loading: true, error: null, message: '', messageType: 'success', switching: false
    };
  },
  computed: {
    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    },
  },
  mounted() {
    if (!UserStore.isLogin || !this.isGuide) { this.loading = false; return; }
    this.fetchCities();
  },
  methods: {
    async fetchCities() {
      this.loading = true; this.error = null;
      try {
        const [citiesRes, infoRes] = await Promise.all([
          ApiProvider.get(ApiUrl.guideCityList, { page: 1, limit: 100 }),
          ApiProvider.get(ApiUrl.guideCityInfo).catch(() => ({ success: false })),
        ]);
        this.cities = Array.isArray(citiesRes.data?.list) ? citiesRes.data.list
          : (citiesRes.success && Array.isArray(citiesRes.data) ? citiesRes.data : []);
        if (infoRes.success && infoRes.data) {
          this.currentCity = infoRes.data;
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    async handleChange(city) {
      if (this.switching) return;
      if (this.currentCity && city.id === this.currentCity.city_id) return;
      this.switching = true; this.message = '';
      try {
        const result = await ApiProvider.post(ApiUrl.guideChangeCity, { city_id: city.id });
        if (result.success) {
          this.currentCity = city;
          this.message = '城市切換成功';
          this.messageType = 'success';
          setTimeout(() => { this.message = ''; }, 2000);
        } else {
          this.message = result.message || '切換失敗';
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = e.message || '切換失敗';
        this.messageType = 'error';
      }
      this.switching = false;
    },
  }
};
