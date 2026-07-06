/* ============================================
   MinePage — User profile center
   Redesigned 2026-07-06: clean card layout, web-friendly
   ============================================ */

const MinePage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:12px;padding-bottom:40px">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding:80px 0">
        <div style="width:80px;height:80px;border-radius:50%;background:var(--color-accent-soft);display:inline-flex;align-items:center;justify-content:center;font-size:36px;margin-bottom:20px">👤</div>
        <p style="font-size:15px;color:var(--color-secondary-text);margin-bottom:20px;">{{ t('請登錄以查看個人中心') }}</p>
        <a href="#/login" class="ds-btn ds-btn-primary" style="display:inline-flex;border-radius:100px;padding:10px 36px">
          {{ t('登錄') }}
        </a>
      </div>

      <!-- Logged in -->
      <template v-if="UserStore.isLogin && profile">
        <!-- Profile Header Card -->
        <div class="ds-profile-card" style="margin-top:8px">
          <div class="ds-profile-top">
            <a href="#/profile" style="text-decoration:none;color:inherit;display:flex;align-items:center;gap:16px;flex:1;min-width:0">
              <div class="ds-avatar" style="width:60px;height:60px;border-radius:50%;overflow:hidden;flex-shrink:0">
                <img v-if="profile.avatar" :src="profile.avatar" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;background:linear-gradient(135deg,var(--color-primary),#9B9FFF);display:flex;align-items:center;justify-content:center;color:#fff;font-size:24px;font-weight:600">
                  {{ (profile.nickname || profile.email || '?')[0] }}
                </div>
              </div>
              <div style="min-width:0">
                <div style="display:flex;align-items:center;gap:8px">
                  <span style="font-size:17px;font-weight:600;color:var(--color-primary-text)">{{ profile.nickname || profile.email || '' }}</span>
                  <span v-if="profile.identity === 2" style="font-size:10.5px;padding:2px 8px;border-radius:20px;background:#EEF2FF;color:var(--color-primary);font-weight:600">{{ t('认证导游') }}</span>
                  <span v-if="profile.identity === 3" style="font-size:10.5px;padding:2px 8px;border-radius:20px;background:#FFF7ED;color:var(--color-amber);font-weight:600">{{ t('认证企业') }}</span>
                  <span v-if="profile.vip_name" style="font-size:10.5px;padding:2px 8px;border-radius:20px;background:linear-gradient(135deg,#FFFBF0,#FFF7E0);color:#D4A017;font-weight:600;border:1px solid rgba(212,160,23,.3)">{{ profile.vip_name }}</span>
                </div>
                <div style="font-size:12px;color:var(--color-assistant-text);margin-top:4px">
                  ID: {{ (profile.number || '').slice(0, 10) }}
                </div>
              </div>
            </a>
            <a href="#/settings" style="font-size:20px;text-decoration:none;padding:8px;color:var(--color-assistant-text)">⚙️</a>
          </div>

          <!-- Stats Row -->
          <div class="ds-stats" style="margin-top:20px">
            <a href="#/message/follow" class="ds-stat" style="text-decoration:none">
              <div class="ds-stat-value">{{ profile.follow_count || 0 }}</div>
              <div class="ds-stat-label">{{ $t('關注') }}</div>
            </a>
            <a href="#/message/follow" class="ds-stat" style="text-decoration:none">
              <div class="ds-stat-value">{{ profile.fan_count || 0 }}</div>
              <div class="ds-stat-label">{{ $t('粉絲') }}</div>
            </a>
            <a href="#/integral" class="ds-stat" style="text-decoration:none">
              <div class="ds-stat-value">{{ profile.integral || 0 }}</div>
              <div class="ds-stat-label">{{ $t('積分') }}</div>
            </a>
          </div>
        </div>

        <!-- VIP Status -->
        <a v-if="UserStore.isVip" href="#/vip" class="ds-card"
          style="display:block;text-decoration:none;color:inherit;margin-top:14px;padding:16px 18px;background:linear-gradient(135deg,#FFFDF5,#FFF9E6);border:1px solid rgba(245,184,66,.2)">
          <div style="display:flex;align-items:center;justify-content:space-between">
            <div>
              <div style="font-size:14px;font-weight:600;color:#D4A017">👑 {{ $t('VIP會員') }}</div>
              <div style="font-size:12px;color:var(--color-secondary-text);margin-top:2px">
                {{ $t('有效期至') }} {{ profile.vip_expiration_time ? formatDate(new Date(profile.vip_expiration_time * 1000)) : '' }}
              </div>
            </div>
            <span style="font-size:12px;color:#D4A017;font-weight:500">{{ $t('延長') }} ›</span>
          </div>
        </a>

        <!-- Auth/Promotion Cards -->
        <div v-if="UserStore.showGuideAuth || UserStore.showEnterpriseAuth" style="display:flex;gap:10px;margin-top:14px">
          <a v-if="UserStore.showGuideAuth" href="#/guide/certify"
            class="ds-card ds-card-hover" style="flex:1;text-decoration:none;color:inherit;padding:16px 18px;background:linear-gradient(135deg,#EEF0FF,#E6E8FF);border:1px solid rgba(102,111,255,.15)">
            <div style="font-size:14px;font-weight:600;color:var(--color-primary)">🧭 {{ $t('成為導遊') }}</div>
            <div style="font-size:12px;color:var(--color-secondary-text);margin-top:4px">{{ $t('發布城市內容') }}</div>
          </a>
          <a v-if="UserStore.showEnterpriseAuth" href="#/merchant/entry"
            class="ds-card ds-card-hover" style="flex:1;text-decoration:none;color:inherit;padding:16px 18px;background:linear-gradient(135deg,#FFF4ED,#FFECE0);border:1px solid rgba(249,115,22,.15)">
            <div style="font-size:14px;font-weight:600;color:var(--color-orange)">🏪 {{ $t('成為商家') }}</div>
            <div style="font-size:12px;color:var(--color-secondary-text);margin-top:4px">{{ $t('管理店鋪預約') }}</div>
          </a>
        </div>

        <!-- My Services Menu -->
        <div class="ds-menu-group" style="margin-top:14px">
          <div class="ds-menu-group-title">{{ $t('我的服務') }}</div>
          <a v-for="menu in myMenus" :key="menu.key"
            :href="'#' + menu.route"
            class="ds-menu-item" style="position:relative">
            <span>{{ menu.icon }} {{ $t(menu.label) }}</span>
            <span v-if="menu.badge > 0" style="position:absolute;right:30px;min-width:20px;height:20px;border-radius:10px;background:var(--color-red);color:#fff;font-size:10px;font-weight:600;display:inline-flex;align-items:center;justify-content:center;padding:0 6px">{{ menu.badge > 99 ? '99+' : menu.badge }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
        </div>

        <!-- Invite -->
        <a href="#/invite" class="ds-card ds-card-hover" style="display:block;text-decoration:none;color:inherit;margin-top:14px;padding:16px 18px">
          <div style="display:flex;align-items:center;gap:14px">
            <div style="width:44px;height:44px;border-radius:12px;background:linear-gradient(135deg,#FEF3C7,#FDE68A);display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0">🎁</div>
            <div style="flex:1;min-width:0">
              <div style="font-size:14px;font-weight:550">{{ $t('邀請好友') }}</div>
              <div style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ $t('邀請碼') }}: {{ profile.inviter_code || '' }}</div>
            </div>
            <span style="color:var(--color-assistant-text)">›</span>
          </div>
        </a>
      </template>
    </div>
    </div>
  `,

  data() {
    return {};
  },

  computed: {
    profile() {
      return UserStore.userInfo;
    },

    myMenus() {
      const menus = [];
      const info = this.profile || {};
      const isGuide = info.identity === 2;
      const isEnterprise = info.identity === 3;

      if (isGuide) {
        menus.push({ key: 'city_pub', icon: '🏙️', label: '城市管理', route: '/guide/publish-city', badge: 0 });
        menus.push({ key: 'publish', icon: '📝', label: '我的發佈', route: '/guide/publish', badge: 0 });
        menus.push({ key: 'my_book', icon: '📋', label: '我的預約', route: '/my-bookings', badge: 0 });
        menus.push({ key: 'reserve_me', icon: '📅', label: '預約我的', route: '/guide/bookings', badge: 0 });
      } else if (isEnterprise) {
        menus.push({ key: 'shop', icon: '🏪', label: '商家管理', route: '/merchant/manage', badge: 0 });
        menus.push({ key: 'reserve_me', icon: '📅', label: '預約我的', route: '/merchant/bookings', badge: 0 });
        menus.push({ key: 'my_book', icon: '📋', label: '我的預約', route: '/my-bookings', badge: 0 });
      } else {
        menus.push({ key: 'my_book', icon: '📋', label: '我的預約', route: '/my-bookings', badge: 0 });
      }

      menus.push({ key: 'integral', icon: '💰', label: '我的積分', route: '/integral', badge: 0 });
      menus.push({ key: 'mall', icon: '🛒', label: '積分商城', route: '/integral/mall', badge: 0 });
      menus.push({ key: 'invite', icon: '🤝', label: '我的邀請', route: '/invite', badge: 0 });
      menus.push({ key: 'vip', icon: '👑', label: '會員中心', route: '/vip', badge: 0 });

      return menus;
    },
  },

  methods: {
    t(key) { return I18n.t(key); },
    imageUrl,
    formatDate,
  },

  mounted() {
    if (UserStore.isLogin) {
      UserStore.getProfile();
    }
  }
};
