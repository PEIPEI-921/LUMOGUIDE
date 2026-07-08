/* ============================================
   Vue Router — Hash-based SPA routing
   Matches Flutter AppRoutes (56 routes)
   ============================================ */

// Placeholder component for pages not yet implemented
const ComingSoon = {
  template: `
    <div class="page-content">
      <empty-state text="此頁面正在開發中" />
    </div>
  `
};

const routes = [
  // === Root Shell (5 tabs) ===
  { path: '/', redirect: '/welcome' },
  { path: '/home', component: HomePage, meta: { tab: 'home', title: '首頁' } },
  { path: '/city', component: CityPage, meta: { tab: 'city', title: '城市' } },
  { path: '/news', component: NewsPage, meta: { tab: 'news', title: '資訊' } },
  { path: '/message', component: MessagePage, meta: { tab: 'message', title: '消息', requiresAuth: true } },
  { path: '/mine', component: MinePage, meta: { tab: 'mine', title: '我的', requiresAuth: true } },

  // === Auth ===
  { path: '/welcome', component: WelcomePage, meta: { title: '歡迎' } },
  { path: '/login', component: LoginPage, meta: { title: '登錄' } },
  { path: '/register', component: RegisterPage, meta: { title: '註冊' } },
  { path: '/forget-password', component: ForgetPasswordPage, meta: { title: '忘記密碼' } },
  { path: '/verify-code', component: VerifyCodePage, meta: { title: '驗證碼' } },
  { path: '/password-input', component: PasswordInputPage, meta: { title: '設置密碼' } },

  // === City ===
  { path: '/city/detail', component: CityDetailPage, meta: { title: '城市詳情' } },
  { path: '/city/strategy', component: CityStrategyPage, meta: { title: '城市攻略' } },
  { path: '/city/guide-list', component: CityGuideListPage, meta: { title: '導遊列表' } },

  // === Guide ===
  { path: '/guide/:id', component: GuideDetailPage, meta: { title: '導遊詳情' } },
  { path: '/guide/certify', component: GuideCertifyPage, meta: { title: '導遊認證', requiresAuth: true } },
  { path: '/guide/publish', component: GuidePublishPage, meta: { title: '我的發布', requiresAuth: true } },
  { path: '/guide/publish-city', component: GuidePublishCityPage, meta: { title: '發布城市', requiresAuth: true } },
  { path: '/guide/publish-city-form', component: GuidePublishCityFormPage, meta: { title: '新建城市', requiresAuth: true } },
  { path: '/guide/bookings', component: GuideBookingsPage, meta: { title: '預約管理', requiresAuth: true } },
  { path: '/guide/booking-detail/:id', component: GuideBookingDetailPage, meta: { title: '預約詳情', requiresAuth: true } },
  { path: '/guide/change-city', component: GuideChangeCityPage, meta: { title: '切換城市', requiresAuth: true } },

  // === Common Detail ===
  { path: '/detail/:type', component: CommonDetailPage, meta: { title: '內容詳情' } },
  { path: '/company/:id', component: CompanyDetailPage, meta: { title: '商家詳情' } },

  // === News ===
  { path: '/news/:id', component: NewsDetailPage, meta: { title: '資訊詳情' } },

  // === Search ===
  { path: '/search', component: SearchPage, meta: { title: '搜索' } },

  // === Message sub-pages ===
  { path: '/message/system', component: MessageSystemPage, meta: { title: '系統消息', requiresAuth: true } },
  { path: '/message/follow', component: MessageFollowPage, meta: { title: '關注通知', requiresAuth: true } },
  { path: '/message/comments', component: MessageCommentsPage, meta: { title: '評論通知', requiresAuth: true } },
  { path: '/message/reserves', component: MessageReservesPage, meta: { title: '預約通知', requiresAuth: true } },

  // === Mine sub-pages ===
  { path: '/profile', component: ProfilePage, meta: { title: '個人資料', requiresAuth: true } },
  { path: '/profile/edit', component: ProfileEditPage, meta: { title: '編輯資料', requiresAuth: true } },
  { path: '/settings', component: SettingsPage, meta: { title: '設置', requiresAuth: true } },
  { path: '/modify-phone', component: ModifyPhonePage, meta: { title: '修改手機', requiresAuth: true } },
  { path: '/modify-password', component: ModifyPasswordPage, meta: { title: '修改密碼', requiresAuth: true } },
  { path: '/feedback', component: FeedbackPage, meta: { title: '意見反饋', requiresAuth: true } },
  { path: '/contact', component: ContactPage, meta: { title: '聯繫客服', requiresAuth: true } },
  { path: '/invite', component: InvitePage, meta: { title: '邀請好友', requiresAuth: true } },
  { path: '/my-bookings', component: MyBookingsPage, meta: { title: '我的預約', requiresAuth: true } },
  { path: '/booking-detail/:type/:id', component: BookingDetailPage, meta: { title: '預約詳情', requiresAuth: true } },
  { path: '/followers', component: FollowersPage, meta: { title: '我的粉絲', requiresAuth: true } },
  { path: '/following', component: FollowingPage, meta: { title: '我的關注', requiresAuth: true } },
  { path: '/evaluations', component: MyEvaluationsPage, meta: { title: '我的評價', requiresAuth: true } },

  // === Booking ===
  { path: '/booking-guide/:id', component: BookingGuidePage, meta: { title: '預約導遊', requiresAuth: true } },
  { path: '/booking-merchant/:id', component: BookingMerchantPage, meta: { title: '預約商家', requiresAuth: true } },

  // === Publish ===
  { path: '/publish/attraction', component: PublishAttractionPage, meta: { title: '發布景點', requiresAuth: true } },
  { path: '/publish/transportation', component: PublishTransportationPage, meta: { title: '發布交通', requiresAuth: true } },
  { path: '/publish/facility', component: PublishFacilityPage, meta: { title: '發布設施', requiresAuth: true } },
  { path: '/publish/activity', component: PublishActivityPage, meta: { title: '發布活動', requiresAuth: true } },
  { path: '/publish/information', component: PublishInformationPage, meta: { title: '發布資訊', requiresAuth: true } },

  // === Merchant ===
  { path: '/merchant/manage', component: MerchantManagePage, meta: { title: '商家管理', requiresAuth: true } },
  { path: '/merchant/entry', component: MerchantEntryPage, meta: { title: '商家入駐', requiresAuth: true } },
  { path: '/merchant/bookings', component: MerchantBookingsPage, meta: { title: '商家預約', requiresAuth: true } },
  { path: '/merchant/booking-detail/:id', component: MerchantBookingDetailPage, meta: { title: '預約詳情', requiresAuth: true } },

  // === Integral ===
  { path: '/integral', component: IntegralPage, meta: { title: '積分商城', requiresAuth: true } },
  { path: '/integral/mall', redirect: '/integral' },
  { path: '/integral/goods/:id', component: IntegralGoodsPage, meta: { title: '商品詳情', requiresAuth: true } },
  { path: '/integral/exchange/:id', component: IntegralExchangePage, meta: { title: '積分兌換', requiresAuth: true } },
  { path: '/integral/exchange/result', component: IntegralExchangeResultPage, meta: { title: '兌換結果', requiresAuth: true } },
  { path: '/integral/exchange/order/:id', component: IntegralExchangeOrderPage, meta: { title: '訂單詳情', requiresAuth: true } },
  { path: '/integral/records', component: IntegralRecordsPage, meta: { title: '積分記錄', requiresAuth: true } },

  // === VIP ===
  { path: '/vip', component: VipPage, meta: { title: 'VIP會員', requiresAuth: true } },

  // === Address ===
  { path: '/address', component: AddressListPage, meta: { title: '地址管理', requiresAuth: true } },
  { path: '/address/edit', component: AddressEditPage, meta: { title: '編輯地址', requiresAuth: true } },

  // === Evaluation ===
  { path: '/evaluation/:id', component: EvaluationDetailPage, meta: { title: '評價詳情' } },
  { path: '/evaluate-list/:id', component: EvaluationListPage, meta: { title: '評價列表' } },
  { path: '/evaluation/submit', component: EvaluationSubmitPage, meta: { title: '發表評價', requiresAuth: true } },

  // === Misc ===
  { path: '/photo', component: PhotoViewerPage, meta: { title: '查看圖片' } },
  { path: '/web', component: WebViewPage, meta: { title: '網頁' } },

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
