/* ============================================
   MinePage — User profile center
   Mirrors Flutter MinePage
   ============================================ */

const MinePage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="display:flex;flex-direction:column;align-items:center;justify-content:center;padding:80px 20px;gap:16px;">
        <div style="font-size:64px;">👤</div>
        <p style="font-size:16px;color:var(--color-secondary-text);">{{ t('請登錄以查看個人中心') }}</p>
        <button class="btn-primary" style="width:200px;" @click="$router.push('/login')">{{ t('登錄') }}</button>
      </div>

      <!-- Logged in -->
      <template v-if="UserStore.isLogin && profile">
        <!-- Profile Header -->
        <div class="profile-header">
          <div class="profile-actions">
            <button @click="$router.push('/profile')" style="font-size:20px;">✏️</button>
            <button @click="$router.push('/settings')" style="font-size:20px;">⚙️</button>
          </div>
          <div class="profile-info">
            <img :src="imageUrl(profile.avatar)" class="avatar avatar-xl" />
            <div>
              <div class="flex items-center gap-sm">
                <span style="font-size:16px;font-weight:600;">{{ profile.nickname || profile.email || '' }}</span>
                <span v-if="profile.identity === 2" class="tag tag-primary">{{ t('導遊') }}</span>
                <span v-if="profile.identity === 3" class="tag tag-orange">{{ t('企業') }}</span>
                <span v-if="profile.vip_name" class="tag tag-orange">{{ profile.vip_name }}</span>
              </div>
              <div style="font-size:12px;color:var(--color-assistant-text);margin-top:4px;">
                {{ t('ID') }}: {{ profile.number || profile.id || '' }}
              </div>
            </div>
          </div>

          <!-- Stats -->
          <div class="stats-row" style="margin-top:12px;">
            <div class="stat-item" style="cursor:pointer;" @click="$router.push('/message/follow')">
              <span class="stat-value">{{ profile.follow_count || 0 }}</span>
              <span class="stat-label">{{ t('關注') }}</span>
            </div>
            <div class="stat-item" style="cursor:pointer;" @click="$router.push('/message/follow')">
              <span class="stat-value">{{ profile.fan_count || 0 }}</span>
              <span class="stat-label">{{ t('粉絲') }}</span>
            </div>
            <div class="stat-item" style="cursor:pointer;" @click="$router.push('/integral')">
              <span class="stat-value">{{ profile.integral || 0 }}</span>
              <span class="stat-label">{{ t('積分') }}</span>
            </div>
          </div>
        </div>

        <!-- VIP Status -->
        <div v-if="UserStore.isVip" class="card" style="margin:12px;background:linear-gradient(135deg,#FFF8E1,#FFF3CD);border:1px solid var(--color-orange);">
          <div class="flex items-center justify-between">
            <div>
              <div style="font-size:14px;font-weight:600;color:var(--color-orange);">{{ t('會員') }}</div>
              <div style="font-size:12px;color:var(--color-secondary-text);">
                {{ t('會員有效期') }}: {{ UserStore.profile.vip_expiration_time ? formatDate(new Date(UserStore.profile.vip_expiration_time * 1000)) : '' }}
              </div>
            </div>
            <a href="#/vip" class="tag tag-orange" style="padding:6px 12px;">{{ t('延長會籍') }}</a>
          </div>
        </div>

        <!-- Auth/Promotion Cards (for regular users) -->
        <div v-if="UserStore.showGuideAuth || UserStore.showEnterpriseAuth" style="display:flex;gap:8px;padding:0 12px;margin-bottom:12px;">
          <div v-if="UserStore.showGuideAuth" class="card" style="flex:1;background:linear-gradient(135deg,#EEF0FF,#E8EAFF);cursor:pointer;" @click="$router.push('/guide/certify')">
            <div style="font-size:13px;font-weight:600;color:var(--color-primary);">{{ t('成為LuMo導遊') }}</div>
            <div style="font-size:11px;color:var(--color-secondary-text);margin-top:4px;">{{ t('了解更多') }} ›</div>
          </div>
          <div v-if="UserStore.showEnterpriseAuth" class="card" style="flex:1;background:linear-gradient(135deg,#FFF0E8,#FFE8D6);cursor:pointer;" @click="$router.push('/merchant/entry')">
            <div style="font-size:13px;font-weight:600;color:var(--color-orange);">{{ t('成為合作商家') }}</div>
            <div style="font-size:11px;color:var(--color-secondary-text);margin-top:4px;">{{ t('了解更多') }} ›</div>
          </div>
        </div>

        <!-- My Services Menu -->
        <div class="card" style="margin:12px;">
          <div style="font-size:14px;font-weight:600;margin-bottom:12px;">{{ t('我的服務') }}</div>
          <div class="menu-grid" style="padding:0;gap:16px;">
            <div v-for="menu in myMenus" :key="menu.key"
              class="menu-item" style="cursor:pointer;" @click="$router.push(menu.route)">
              <div class="menu-icon">{{ menu.icon }}</div>
              <span class="menu-label">{{ t(menu.label) }}</span>
              <span v-if="menu.badge > 0" class="menu-badge">{{ menu.badge > 99 ? '99+' : menu.badge }}</span>
            </div>
          </div>
        </div>

        <!-- Invite -->
        <div class="card" style="margin:12px;cursor:pointer;" @click="$router.push('/invite')">
          <div class="flex items-center gap-md">
            <span style="font-size:28px;">🎁</span>
            <div>
              <div style="font-size:14px;font-weight:500;">{{ t('邀請好友') }}</div>
              <div style="font-size:12px;color:var(--color-assistant-text);">{{ t('邀請碼') }}: {{ profile.inviter_code || '' }}</div>
            </div>
          </div>
        </div>
      </template>

      <div style="height:20px;"></div>
    </div>
  `,

  data() {
    return {
      // UserStore is global, accessed directly
    };
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
        menus.push({ key: 'city_pub', icon: '🏙️', label: '城市', route: '/guide/publish-city', badge: 0 });
        menus.push({ key: 'my_book', icon: '📋', label: '我的預約', route: '/my-bookings', badge: 0 });
        menus.push({ key: 'reserve_me', icon: '📅', label: '預約我的', route: '/guide/bookings', badge: 0 });
        menus.push({ key: 'publish', icon: '📝', label: '我的發佈', route: '/guide/publish', badge: 0 });
      } else if (isEnterprise) {
        menus.push({ key: 'reserve_me', icon: '📅', label: '預約我的', route: '/merchant/bookings', badge: 0 });
        menus.push({ key: 'shop', icon: '🏪', label: '商家管理', route: '/merchant/manage', badge: 0 });
      } else {
        menus.push({ key: 'my_book', icon: '📋', label: '我的預約', route: '/my-bookings', badge: 0 });
      }

      // Common menus
      menus.push({ key: 'integral', icon: '💰', label: '我的積分', route: '/integral', badge: 0 });
      menus.push({ key: 'mall', icon: '🛒', label: '積分商城', route: '/integral/mall', badge: 0 });
      menus.push({ key: 'invite', icon: '🎁', label: '我的邀請', route: '/invite', badge: 0 });
      menus.push({ key: 'vip', icon: '👑', label: '會員中心', route: '/vip', badge: 0 });

      if (isGuide || isEnterprise) {
        menus.push({ key: 'funshop', icon: '🎪', label: '趣店', route: '/integral/mall', badge: 0 });
      }

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
