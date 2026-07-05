/* ============================================
   Vue Router — Hash-based SPA routing
   Matches Flutter AppRoutes (56 routes)
   ============================================ */

// Placeholder component for pages not yet implemented
const ComingSoon = {
  template: `
    <div class="page-content">
      <app-header title="Coming Soon" :show-back="true"></app-header>
      <empty-state text="此頁面正在開發中" />
    </div>
  `
};

const routes = [
  // === Root Shell (5 tabs) ===
  { path: '/', redirect: '/welcome' },
  { path: '/home', component: HomePage, meta: { tab: 'home' } },
  { path: '/city', component: CityPage, meta: { tab: 'city' } },
  { path: '/news', component: NewsPage, meta: { tab: 'news' } },
  { path: '/message', component: MessagePage, meta: { tab: 'message', requiresAuth: true } },
  { path: '/mine', component: MinePage, meta: { tab: 'mine', requiresAuth: true } },

  // === Auth ===
  { path: '/welcome', component: WelcomePage },
  { path: '/login', component: LoginPage },
  { path: '/register', component: RegisterPage },
  { path: '/forget-password', component: ComingSoon },
  { path: '/verify-code', component: ComingSoon },
  { path: '/password-input', component: ComingSoon },

  // === City ===
  { path: '/city/detail', component: ComingSoon },
  { path: '/city/strategy', component: ComingSoon },
  { path: '/city/guide-list', component: ComingSoon },

  // === Guide ===
  { path: '/guide/:id', component: ComingSoon },
  { path: '/guide/certify', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/guide/publish', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/guide/publish-city', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/guide/bookings', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/guide/change-city', component: ComingSoon, meta: { requiresAuth: true } },

  // === Common Detail ===
  { path: '/detail/:type', component: ComingSoon },
  { path: '/company/:id', component: ComingSoon },

  // === News ===
  { path: '/news/:id', component: ComingSoon },

  // === Search ===
  { path: '/search', component: ComingSoon },

  // === Message sub-pages ===
  { path: '/message/system', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/message/follow', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/message/comments', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/message/reserves', component: ComingSoon, meta: { requiresAuth: true } },

  // === Mine sub-pages ===
  { path: '/profile', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/settings', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/nickname', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/modify-phone', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/modify-password', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/feedback', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/contact', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/invite', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/my-bookings', component: ComingSoon, meta: { requiresAuth: true } },

  // === Booking ===
  { path: '/booking-guide/:id', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/booking-merchant/:id', component: ComingSoon, meta: { requiresAuth: true } },

  // === Publish ===
  { path: '/publish/attraction', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/publish/transportation', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/publish/facility', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/publish/activity', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/publish/information', component: ComingSoon, meta: { requiresAuth: true } },

  // === Merchant ===
  { path: '/merchant/manage', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/merchant/entry', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/merchant/bookings', component: ComingSoon, meta: { requiresAuth: true } },

  // === Integral ===
  { path: '/integral', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/integral/mall', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/integral/goods/:id', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/integral/exchange/:id', component: ComingSoon, meta: { requiresAuth: true } },

  // === VIP ===
  { path: '/vip', component: ComingSoon, meta: { requiresAuth: true } },

  // === Address ===
  { path: '/address', component: ComingSoon, meta: { requiresAuth: true } },
  { path: '/address/edit', component: ComingSoon, meta: { requiresAuth: true } },

  // === Evaluation ===
  { path: '/evaluation/:id', component: ComingSoon },
  { path: '/evaluate-list/:id', component: ComingSoon },

  // === Misc ===
  { path: '/photo', component: ComingSoon },
  { path: '/web', component: ComingSoon },

  // === Catch-all ===
  { path: '/:pathMatch(.*)*', redirect: '/home' }
];

// Create router
const router = VueRouter.createRouter({
  history: VueRouter.createWebHashHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 };
  }
});

// Auth guard
router.beforeEach((to, from, next) => {
  // Check auth requirement
  if (to.meta.requiresAuth && !UserStore.isLogin) {
    next({ path: '/login', query: { redirect: to.fullPath } });
    return;
  }
  next();
});

// Track active tab
router.afterEach((to) => {
  const tab = to.meta.tab;
  if (tab) {
    const app = document.querySelector('#app').__vue_app__;
    if (app) {
      const root = app._instance?.proxy;
      if (root) root.activeTab = tab;
    }
  }
});
