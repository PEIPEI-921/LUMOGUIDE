/* ============================================
   MinePage — User profile center
   Redesigned 2026-07-06: clean card layout, web-friendly
   All icons: SVG line art (replaced emoji)
   ============================================ */

// SVG line-art icons (1em × 1em, currentColor stroke)
const I = {
  user:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M20 22c0-4.4-3.6-8-8-8s-8 3.6-8 8"/></svg>',
  settings: '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v2m0 18v2M4.2 4.2l1.4 1.4m12.8 12.8l1.4 1.4M1 12h2m18 0h2M4.2 19.8l1.4-1.4m12.8-12.8l1.4-1.4"/></svg>',
  crown:    '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 6l4 8h12l4-8-4.5 4.5L12 4 6.5 10.5 2 6z"/><path d="M2 18h20"/></svg>',
  compass:  '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polygon points="16.2 7.8 12 12 7.8 16.2"/><line x1="12" y1="12" x2="7.8" y2="7.8"/></svg>',
  shop:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9h18v11a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9z"/><path d="M1 9l2-5h18l2 5"/><line x1="10" y1="14" x2="14" y2="14"/></svg>',
  gift:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="8" width="18" height="13" rx="1"/><line x1="12" y1="8" x2="12" y2="21"/><line x1="3" y1="8" x2="21" y2="8"/><path d="M8 3c-1.7 0-3 1.3-3 3h5c0-1.7-1.3-3-3-3h1"/><path d="M16 3c1.7 0 3 1.3 3 3h-5c0-1.7 1.3-3 3-3h-1"/></svg>',
  building: '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="2" width="16" height="20" rx="1"/><line x1="9" y1="6" x2="11" y2="6"/><line x1="13" y1="6" x2="15" y2="6"/><line x1="9" y1="10" x2="11" y2="10"/><line x1="13" y1="10" x2="15" y2="10"/><line x1="9" y1="14" x2="11" y2="14"/><line x1="13" y1="14" x2="15" y2="14"/><path d="M9 22v-4h6v4"/></svg>',
  document: '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a1 1 0 0 0-1 1v18a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="16" y2="17"/></svg>',
  clipboard:'<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 2h6a1 1 0 0 1 1 1v1H8V3a1 1 0 0 1 1-1z"/><rect x="4" y="5" width="16" height="17" rx="1"/><line x1="8" y1="11" x2="16" y2="11"/><line x1="8" y1="15" x2="16" y2="15"/></svg>',
  calendar: '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="1"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>',
  coin:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v12m-3-9c0-1 1.5-2 3-2s3 1 3 2-1.5 2-3 2-3 1.5-3 3 1.5 2 3 2 3-1 3-2"/></svg>',
  cart:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.7 13.6a1 1 0 0 0 1 .9h10.6a1 1 0 0 0 1-.9L23 6H6"/></svg>',
  handshake:'<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 13c-1.5 0-3-1-4-3s-1-4 0-5 3-1 5 1l1 1"/><path d="M16 13c1.5 0 3-1 4-3s1-4 0-5-3-1-5 1l-1 1"/><path d="M8 13l2 3 4-3"/><path d="M12 16l-2 3 4 2 4-1"/></svg>',
  pencil:   '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3l4 4-12 12H5v-4L17 3z"/></svg>',
  lock:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/><circle cx="12" cy="16" r="1"/></svg>',
  phone:    '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><line x1="12" y1="18" x2="12" y2="18"/></svg>',
  heart:    '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.8 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></svg>',
  people:   '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="7" r="3"/><path d="M1 20v-1a5 5 0 0 1 5-5h6a5 5 0 0 1 5 5v1"/><circle cx="18" cy="7" r="3"/><path d="M23 20v-1a5 5 0 0 0-2.5-4.3"/></svg>',
  star:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.1 8.3 22 9.3 17 14.1 18.2 21 12 17.8 5.8 21 7 14.1 2 9.3 8.9 8.3"/></svg>',
  ticket:   '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 7a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v3a2 2 0 0 0 0 4v3a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2v-3a2 2 0 0 0 0-4V7z"/><line x1="10" y1="7" x2="10" y2="17"/></svg>',
  refresh:  '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.5 9a9 9 0 0 1 14.2-3.4L23 10M1 14l5.3 4.4A9 9 0 0 0 20.5 15"/></svg>',
  diamond:  '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 19 11 12 22 5 11"/></svg>',
  box:      '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>',
  chat:     '<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10z"/></svg>',
  phoneCall:'<svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2 4.2 2 2 0 0 1 4 2h3a2 2 0 0 1 2 1.7c.2 1.1.5 2.2.9 3.3a2 2 0 0 1-.5 2.1L8.1 10.3a16 16 0 0 0 5.6 5.6l1.2-1.3a2 2 0 0 1 2.1-.5c1.1.4 2.2.7 3.3.9a2 2 0 0 1 1.7 2v.1z"/></svg>',
};

const MinePage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:16px;padding-bottom:40px">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" class="card" style="text-align:center;max-width:400px;margin:60px auto 0">
        <div class="empty-state-v2">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="8" r="4"/><path d="M20 22c0-4.4-3.6-8-8-8s-8 3.6-8 8"/></svg>
          <div class="title">{{ $t('請登錄以查看個人中心') }}</div>
          <a href="#/login" class="btn btn-primary" style="font-size:13px;padding:8px 28px">{{ $t('登錄') }}</a>
        </div>
      </div>

      <!-- Loading -->
      <div v-else-if="!profile" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <!-- Logged in -->
      <template v-else>
        <!-- Profile Card v2 -->
        <div class="profile-card-v2">
          <a href="#/profile" class="pc-avatar" style="text-decoration:none;cursor:pointer">
            <img v-if="profile.avatar" :src="profile.avatar" alt="" />
            <span v-else>{{ (profile.nickname || profile.email || '?')[0] }}</span>
          </a>
          <div class="pc-info">
            <div class="pc-name">
              {{ profile.nickname || profile.email || '' }}
              <span v-if="profile.identity === 2" class="badge-guide">{{ $t('认证导游') }}</span>
              <span v-if="profile.identity === 3" class="badge-company">{{ $t('认证企业') }}</span>
              <span v-if="UserStore.isVip" class="badge-vip">VIP</span>
            </div>
            <div class="pc-id">ID: {{ (profile.number || '').slice(0, 10) }}</div>
          </div>
          <a href="#/settings" style="text-decoration:none;flex-shrink:0">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" stroke-width="1.8"><circle cx="12" cy="12" r="3"/><path d="M12 1v2m0 18v2M4.2 4.2l1.4 1.4m12.8 12.8l1.4 1.4M1 12h2m18 0h2M4.2 19.8l1.4-1.4m12.8-12.8l1.4-1.4"/></svg>
          </a>
        </div>

        <!-- Stats Row v2 -->
        <div class="stats-row-v2">
          <a href="#/following" class="stat-card" style="text-decoration:none;color:inherit">
            <div class="num">{{ profile.follow_count || 0 }}</div>
            <div class="label">{{ $t('關注') }}</div>
          </a>
          <a href="#/followers" class="stat-card" style="text-decoration:none;color:inherit">
            <div class="num">{{ profile.fan_count || 0 }}</div>
            <div class="label">{{ $t('粉絲') }}</div>
          </a>
          <a href="#/integral" class="stat-card" style="text-decoration:none;color:inherit">
            <div class="num">{{ profile.integral || 0 }}</div>
            <div class="label">{{ $t('積分') }}</div>
          </a>
        </div>

        <!-- VIP Status -->
        <a v-if="UserStore.isVip" href="#/vip" class="card" style="display:flex;align-items:center;justify-content:space-between;text-decoration:none;color:inherit;margin-bottom:16px;padding:16px 20px;background:linear-gradient(135deg,#FFFDF5,#FFF9E6);border-color:rgba(212,160,23,.15)">
          <div>
            <div style="font-size:14px;font-weight:600;color:#D4A017"><span v-html="I.crown" style="vertical-align:-2px"></span> {{ $t('VIP會員') }}</div>
            <div style="font-size:12px;color:var(--color-secondary-text);margin-top:2px">{{ $t('有效期至') }} {{ profile.vip_expiration_time ? formatDate(new Date(profile.vip_expiration_time * 1000)) : '' }}</div>
          </div>
          <span style="font-size:12px;color:#D4A017;font-weight:500">{{ $t('延長') }} ›</span>
        </a>

        <!-- Auth/Promotion Cards -->
        <div v-if="UserStore.showGuideAuth || UserStore.showEnterpriseAuth" style="display:flex;gap:12px;margin-bottom:16px">
          <a v-if="UserStore.showGuideAuth" href="#/guide/certify" class="card" style="flex:1;text-decoration:none;color:inherit;padding:16px 18px;background:linear-gradient(135deg,#EEF0FF,#E6E8FF);border-color:rgba(102,111,255,.15)">
            <div style="font-size:14px;font-weight:600;color:var(--color-primary)"><span v-html="I.compass" style="vertical-align:-2px"></span> {{ $t('成為導遊') }}</div>
            <div style="font-size:12px;color:var(--color-secondary-text);margin-top:4px">{{ $t('發布城市內容') }}</div>
          </a>
          <a v-if="UserStore.showEnterpriseAuth" href="#/merchant/entry" class="card" style="flex:1;text-decoration:none;color:inherit;padding:16px 18px;background:linear-gradient(135deg,#FFF4ED,#FFECE0);border-color:rgba(249,115,22,.15)">
            <div style="font-size:14px;font-weight:600;color:var(--color-orange)"><span v-html="I.shop" style="vertical-align:-2px"></span> {{ $t('成為商家') }}</div>
            <div style="font-size:12px;color:var(--color-secondary-text);margin-top:4px">{{ $t('管理店鋪預約') }}</div>
          </a>
        </div>

        <!-- Menu Card v2 -->
        <div class="menu-card">
          <a v-for="menu in myMenus" :key="menu.key"
            :href="'#' + menu.route"
            class="menu-item-v2" style="text-decoration:none;color:inherit">
            <span class="mi-icon" v-html="menuSvg(menu.key)"></span>
            <span class="mi-label">{{ $t(menu.label) }}</span>
            <span v-if="menu.badge > 0" class="msg-count" style="margin-right:6px">{{ menu.badge > 99 ? '99+' : menu.badge }}</span>
            <span class="mi-arrow">›</span>
          </a>
        </div>

        <!-- Invite -->
        <a href="#/invite" class="card" style="display:flex;align-items:center;gap:14px;text-decoration:none;color:inherit;margin-top:16px;padding:16px 18px">
          <div style="width:40px;height:40px;border-radius:10px;background:linear-gradient(135deg,#FEF3C7,#FDE68A);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:#D4A017"><span v-html="I.gift"></span></div>
          <div style="flex:1;min-width:0">
            <div style="font-size:14px;font-weight:500">{{ $t('邀請好友') }}</div>
            <div style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ $t('邀請碼') }}: {{ profile.inviter_code || '' }}</div>
          </div>
          <span class="mi-arrow">›</span>
        </a>
      </template>
    </div>
    </div>
  `,

  data() {
    return { I };
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
        menus.push({ key: 'city_pub', label: '城市管理', route: '/guide/publish-city', badge: 0 });
        menus.push({ key: 'publish', label: '我的發佈', route: '/guide/publish', badge: 0 });
        menus.push({ key: 'my_book', label: '我的預約', route: '/my-bookings', badge: 0 });
        menus.push({ key: 'reserve_me', label: '預約我的', route: '/guide/bookings', badge: 0 });
      } else if (isEnterprise) {
        menus.push({ key: 'shop', label: '商家管理', route: '/merchant/manage', badge: 0 });
        menus.push({ key: 'reserve_me', label: '預約我的', route: '/merchant/bookings', badge: 0 });
        menus.push({ key: 'my_book', label: '我的預約', route: '/my-bookings', badge: 0 });
      } else {
        menus.push({ key: 'my_book', label: '我的預約', route: '/my-bookings', badge: 0 });
      }

      menus.push({ key: 'integral', label: '我的積分', route: '/integral', badge: 0 });
      menus.push({ key: 'mall', label: '積分商城', route: '/integral/mall', badge: 0 });
      menus.push({ key: 'invite', label: '我的邀請', route: '/invite', badge: 0 });
      menus.push({ key: 'vip', label: '會員中心', route: '/vip', badge: 0 });

      return menus;
    },
  },

  methods: {
    imageUrl,
    formatDate,
    menuSvg(key) {
      const m = {
        city_pub: I.building, publish: I.document, my_book: I.clipboard,
        reserve_me: I.calendar, shop: I.shop, integral: I.coin,
        mall: I.cart, invite: I.handshake, vip: I.crown,
      };
      return m[key] || '';
    },
  },

  mounted() {
    if (UserStore.isLogin) {
      (UserStore.fetchProfile || UserStore.init || (() => {})).call(UserStore);
    }
  }
};
