/* ============================================
   Guide Publish City Page — 发布/管理我的城市
   Reference: Flutter my_publish_city/controller.dart
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
          <button @click="onAddCity" class="ds-btn ds-btn-primary"
            style="font-size:12px;padding:7px 18px;border-radius:8px">
            + {{ $t('新建城市') }}
          </button>
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
          <button @click="onAddCity" class="ds-btn ds-btn-primary">{{ $t('新增城市') }}</button>
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
              <div style="display:flex;gap:8px;flex-shrink:0">
                <button @click="onEditCity(city)" style="font-size:12px;color:var(--color-primary);background:none;border:none;cursor:pointer;padding:4px 8px">{{ $t('編輯') }}</button>
                <button @click="onDeleteCity(city)" style="font-size:12px;color:var(--color-red);background:none;border:none;cursor:pointer;padding:4px 8px">{{ $t('刪除') }}</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      myCities: [],
      loading: true,
      error: null
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
    this.fetchData();
  },
  methods: {
    // --- Data fetching (matching Flutter fetchData) ---

    async fetchData() {
      this.loading = true; this.error = null;
      try {
        const res = await ApiProvider.get(ApiUrl.guideCityList, { page: 1, limit: 100 });
        // guideCityList returns data as flat array (same as Flutter: res.dataJson['data'] as List)
        this.myCities = Array.isArray(res.data?.list) ? res.data.list
          : (res.success && Array.isArray(res.data) ? res.data : []);
      } catch (e) {
        console.error('[PublishCity] fetchData error:', e);
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },

    // --- Add city (matching Flutter onAddCity) ---

    onAddCity() {
      // VIP gate (matching Flutter VIPCheckUtils.check())
      if (!UserStore.isVip) {
        this.$router.push('/vip');
        return;
      }
      // Navigate to publish city form (matching Flutter Get.toNamed(AppRoutes.PUBLISH_CITY))
      this.$router.push('/guide/publish-city-form');
    },

    // --- Edit city (matching Flutter onEditCity — NO VIP check for editing) ---

    onEditCity(city) {
      // Navigate to form with city id (matching Flutter arguments: {'id': item.id})
      this.$router.push('/guide/publish-city-form?id=' + city.id);
    },

    // --- Delete city (matching Flutter onDeleteCity) ---

    async onDeleteCity(city) {
      const name = city.city_name || city.name || '此城市';
      if (!confirm('確定要刪除「' + name + '」的服務嗎？')) return;
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
