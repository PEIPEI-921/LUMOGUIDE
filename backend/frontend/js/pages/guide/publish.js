/* ============================================
   Guide Publish Page — 我的发布管理
   Reference: Flutter my_publish/controller.dart + widgets/*_list.dart
   Tab-based: 景点/资讯/交通/设施/活动
   ============================================ */

const TAB_CONFIG = [
  { key: 'attraction', label: '景點', endpoint: ApiUrl.guideAttraction, addPath: '/publish/attraction' },
  { key: 'information', label: '資訊', endpoint: ApiUrl.guideInformation, addPath: '/publish/information' },
  { key: 'transportation', label: '交通', endpoint: ApiUrl.guideTransportation, addPath: '/publish/transportation' },
  { key: 'facility', label: '設施', endpoint: ApiUrl.guideFacility, addPath: '/publish/facility' },
  { key: 'activity', label: '活動', endpoint: ApiUrl.guideActivity, addPath: '/publish/activity' },
];

// Match Flutter StatusWidget: 0=审核中(primary) / 1=审核通过(green) / 2=驳回(red)
const AUDIT_MAP = {
  0: { label: '審核中', color: '#666FFF' },
  1: { label: '審核通過', color: '#00BEAA' },
  2: { label: '審核駁回', color: '#DD0000' },
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
          <button v-if="currentTab" @click="onAddItem" style="font-size:13px;color:var(--color-primary);font-weight:500;background:none;border:none;cursor:pointer">+ {{ $t('新增') }}{{ currentTab.label }}</button>
        </div>

        <!-- Type tabs — pill style matching Flutter _CustomTabBar -->
        <div style="display:flex;gap:6px;margin-bottom:16px;padding:3px;border-radius:100px;background:var(--color-bg-card)">
          <button v-for="(t, i) in TAB_CONFIG" :key="t.key" @click="switchTab(i)"
            :style="activeTab === i
              ? 'background:#666FFF;color:#fff;font-weight:500;box-shadow:0 2px 8px rgba(102,111,255,.25)'
              : 'background:transparent;color:#162539;font-weight:400'"
            style="flex:1;border:none;border-radius:100px;padding:7px 0;font-size:13px;cursor:pointer;transition:all .2s">{{ t.label }}</button>
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
          <p style="color:var(--color-assistant-text);font-size:13px">{{ $t('暫無') }}{{ currentTab?.label }}{{ $t('發布') }}</p>
        </div>

        <!-- List — matching Flutter _Item widget layout -->
        <div v-else>
          <div v-for="item in items" :key="item.id"
            style="border-radius:8px;overflow:hidden;box-shadow:0 2px 4px rgba(0,0,0,.05);margin-bottom:10px">

            <!-- Card body -->
            <div style="padding:10px;background:#fff">
              <!-- Row 1: Publish time + status (matching Flutter) -->
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px">
                <div style="display:flex;align-items:center;gap:6px">
                  <!-- Unread dot (matching Flutter: if item.isRead == 0) -->
                  <span v-if="item.is_read === 0" style="width:8px;height:8px;border-radius:50%;background:#EF4444;flex-shrink:0"></span>
                  <span style="font-size:12px;color:#6B7280">{{ $t('發佈時間') }}: {{ formatTime(item.created_at) }}</span>
                </div>
                <!-- Status badge — matching Flutter StatusWidget: bordered style -->
                <span v-if="auditStatus(item.audit_status).label"
                  :style="{ color: auditStatus(item.audit_status).color, borderColor: auditStatus(item.audit_status).color }"
                  style="font-size:10px;padding:3px 8px;border-radius:4px;border:1px solid;white-space:nowrap;flex-shrink:0">{{ auditStatus(item.audit_status).label }}</span>
              </div>

              <!-- Row 2: Thumbnail + Content (matching Flutter layout) -->
              <div style="display:flex;gap:12px;align-items:flex-start">
                <!-- Thumbnail — matching Flutter: 90w×67h, rounded 6 -->
                <div style="width:90px;height:67px;min-width:90px;border-radius:6px;overflow:hidden;background:var(--color-bg-page);display:flex;align-items:center;justify-content:center">
                  <img v-if="getThumb(item)" :src="imageUrl(getThumb(item))" alt=""
                    style="width:100%;height:100%;object-fit:cover">
                  <span v-else style="font-size:20px;color:var(--color-assistant-text)">📷</span>
                </div>

                <!-- Content — type-specific fields (matching Flutter per-type display) -->
                <div style="flex:1;min-width:0">
                  <!-- Name/Title -->
                  <div style="font-size:14px;font-weight:500;color:#162539;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;margin-bottom:8px">{{ item.name || item.title || '—' }}</div>

                  <!-- Type-specific info fields (matching Flutter IconContent widgets) -->
                  <!-- Attraction: 開放時間 + 地址 -->
                  <template v-if="currentTab.key === 'attraction'">
                    <div v-if="item.start_time" style="display:flex;gap:4px;margin-bottom:4px">
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">🕐</span>
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">{{ $t('開放時間') }}:</span>
                      <span style="font-size:12px;color:#9CA3AF;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.start_time }}</span>
                    </div>
                    <div v-if="item.address" style="display:flex;gap:4px">
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">📍</span>
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">{{ $t('地址') }}:</span>
                      <span style="font-size:12px;color:#9CA3AF;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.address }}</span>
                    </div>
                  </template>

                  <!-- Transportation / Facility: 電話 + 地址 -->
                  <template v-if="currentTab.key === 'transportation' || currentTab.key === 'facility'">
                    <div v-if="item.phone" style="display:flex;gap:4px;margin-bottom:4px">
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">📞</span>
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">{{ $t('電話') }}:</span>
                      <span style="font-size:12px;color:#9CA3AF;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.phone }}</span>
                    </div>
                    <div v-if="item.address" style="display:flex;gap:4px">
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">📍</span>
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">{{ $t('地址') }}:</span>
                      <span style="font-size:12px;color:#9CA3AF;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.address }}</span>
                    </div>
                  </template>

                  <!-- Activity: 開始時間 + 結束時間 -->
                  <template v-if="currentTab.key === 'activity'">
                    <div v-if="item.start_time" style="display:flex;gap:4px;margin-bottom:4px">
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">▶️</span>
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">{{ $t('開始時間') }}:</span>
                      <span style="font-size:12px;color:#9CA3AF;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.start_time }}</span>
                    </div>
                    <div v-if="item.end_time" style="display:flex;gap:4px">
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">⏹</span>
                      <span style="font-size:12px;color:#9CA3AF;flex-shrink:0">{{ $t('結束時間') }}:</span>
                      <span style="font-size:12px;color:#9CA3AF;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.end_time }}</span>
                    </div>
                  </template>

                  <!-- Information: description -->
                  <template v-if="currentTab.key === 'information'">
                    <div v-if="item.desc" style="font-size:12px;color:#6B7280;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">{{ item.desc }}</div>
                  </template>
                </div>
              </div>

              <!-- Rejection reason — matching Flutter: red text when audit_status == 2 -->
              <div v-if="item.audit_status === 2 && item.audit_feedback"
                style="color:#DD0000;font-size:12px;margin-top:10px;padding-top:0">
                {{ $t('駁回原因') }}: {{ item.audit_feedback }}
              </div>
            </div>

            <!-- Operate bar — matching Flutter OperateWidget: edit only (canDelete: false) -->
            <div style="height:40px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,.6);border-top:1px solid rgba(0,0,0,.04);cursor:pointer"
              @click="onEditItem(item)">
              <span style="font-size:14px;color:#162539;font-weight:500">{{ $t('編輯') }}</span>
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
      return AUDIT_MAP[Number(s)] || {};
    },
    getThumb(item) {
      return item.first_picture || item.photo
        || (Array.isArray(item.pictures) && item.pictures.length > 0 ? item.pictures[0] : null)
        || '';
    },
    formatTime(d) {
      if (!d) return '—';
      return d.slice(0, 16).replace('T', ' ');
    },
    imageUrl,
    // Edit item — matching Flutter onEditItem: navigate to publish form with id
    onEditItem(item) {
      const tab = TAB_CONFIG[this.activeTab];
      if (!tab) return;
      this.$router.push(tab.addPath + '?id=' + item.id);
    },
    // VIP gate (matching Flutter onPublishTap → VIPCheckUtils.check())
    onAddItem() {
      if (!UserStore.isVip) {
        this.$router.push('/vip');
        return;
      }
      const tab = TAB_CONFIG[this.activeTab];
      if (tab) this.$router.push(tab.addPath);
    },

  }
};
