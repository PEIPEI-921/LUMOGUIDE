/* ============================================
   Guide Publish Page — 我的发布管理
   Reference: PPCC profile/my-publish/page.tsx
   Tab-based: 景点/资讯/交通/设施/活动
   ============================================ */

const TAB_CONFIG = [
  { key: 'attraction', label: '景點', endpoint: ApiUrl.guideAttraction, addPath: '/publish/attraction' },
  { key: 'information', label: '資訊', endpoint: ApiUrl.guideInformation, addPath: '/publish/information' },
  { key: 'transportation', label: '交通', endpoint: ApiUrl.guideTransportation, addPath: '/publish/transportation' },
  { key: 'facility', label: '設施', endpoint: ApiUrl.guideFacility, addPath: '/publish/facility' },
  { key: 'activity', label: '活動', endpoint: ApiUrl.guideActivity, addPath: '/publish/activity' },
];

const DELETE_ENDPOINTS = {
  attraction: ApiUrl.guideAttractionDel,
  information: ApiUrl.guideInformationDel,
  transportation: ApiUrl.guideTransportationDel,
  facility: ApiUrl.guideFacilityDel,
  activity: ApiUrl.guideActivityDel,
};

const AUDIT_MAP = {
  0: { label: '審核中', cls: 'ds-badge-sm ds-badge-warning' },
  1: { label: '已通過', cls: 'ds-badge-sm ds-badge-success' },
  2: { label: '已駁回', cls: 'ds-badge-sm ds-badge-danger' },
};

const GuidePublishPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">📝</div>
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
      <div v-else class="ds-container-760">
        <!-- Header -->
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
          <h2 class="ds-page-head" style="margin:0">{{ $t('發布管理') }}</h2>
          <a v-if="currentTab" :href="'#'+currentTab.addPath" style="font-size:13px;color:var(--color-primary);font-weight:500;text-decoration:none">+ {{ $t('新增') }}{{ currentTab.label }}</a>
        </div>

        <!-- Type tabs -->
        <div class="ds-type-tabs" style="margin-bottom:16px">
          <div class="ds-type-tabs-row">
            <button v-for="(t, i) in TAB_CONFIG" :key="t.key" @click="switchTab(i)"
              :class="['ds-type-tab', { active: activeTab === i }]">{{ t.label }}</button>
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
          <button @click="fetchItems" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- Empty -->
        <div v-else-if="items.length===0" class="ds-empty">
          <div style="font-size:36px;margin-bottom:8px">📝</div>
          <p style="color:var(--color-assistant-text);font-size:13px">{{ $t('暫無') }}{{ currentTab?.['label'] }}{{ $t('發布') }}</p>
        </div>

        <!-- List -->
        <div v-else>
          <div v-for="item in items" :key="item.id" class="ds-card" style="padding:16px;margin-bottom:8px">
            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px">
              <div style="flex:1;min-width:0">
                <div style="font-size:14px;font-weight:600">{{ item.name || item.title || '—' }}</div>
                <div v-if="item.desc" style="font-size:12px;color:var(--color-secondary-text);margin-top:4px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.desc }}</div>
                <div v-if="item.created_at" style="font-size:10px;color:var(--color-assistant-text);margin-top:6px">{{ item.created_at.slice(0,10) }}</div>
              </div>
              <span :class="auditStatus(item.audit_status).cls" style="flex-shrink:0">{{ auditStatus(item.audit_status).label }}</span>
            </div>
            <div style="display:flex;justify-content:flex-end;gap:16px;margin-top:12px;padding-top:12px;border-top:1px solid var(--color-border)">
              <a :href="'#'+currentTab.addPath+'?id='+item.id" style="font-size:12px;color:var(--color-primary);text-decoration:none">{{ $t('編輯') }}</a>
              <button @click="handleDelete(item.id)" style="font-size:12px;color:var(--color-red);background:none;border:none;cursor:pointer">{{ $t('刪除') }}</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      activeTab: 0, items: [], loading: true, error: null, TAB_CONFIG
    };
  },
  computed: {
    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    },
    currentTab() { return TAB_CONFIG[this.activeTab]; }
  },
  mounted() {
    if (!UserStore.isLogin || !this.isGuide) { this.loading = false; return; }
    this.fetchItems();
  },
  methods: {
    async fetchItems() {
      const tab = TAB_CONFIG[this.activeTab];
      if (!tab) return;
      this.loading = true; this.error = null;
      try {
        const result = await ApiProvider.get(tab.endpoint, { page: 1, limit: 50 });
        if (result.success) {
          const list = result.data?.data || result.data?.list || result.data || [];
          this.items = Array.isArray(list) ? list : [];
        } else {
          this.error = result.message || '載入失敗';
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    switchTab(i) {
      this.activeTab = i;
      this.fetchItems();
    },
    auditStatus(s) {
      return AUDIT_MAP[Number(s)] || AUDIT_MAP[0];
    },
    async handleDelete(id) {
      if (!confirm('確定刪除？')) return;
      const ep = DELETE_ENDPOINTS[TAB_CONFIG[this.activeTab]?.key];
      if (!ep) return;
      try {
        const result = await ApiProvider.post(ep, { id });
        if (result.success) this.fetchItems();
      } catch (e) { /* silent */ }
    },
  }
};
