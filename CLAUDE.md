# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LuMo Guide（路盟）** — a professional platform for travel industry insiders (tour guides, merchants, content creators) built on Laravel 9. Slogan: **"路上有光，盟友相伴"**. Provides REST API for a Flutter mobile app, a Vue 3 SPA web frontend, and a Dcat Admin panel. The platform covers travel destinations (cities), tour guides, merchants/shops, information articles, reservations, Stripe VIP subscriptions, and a points/rewards system. **All users must log in and pass identity verification to access content.**

**Important**: Source files under `app/` are encoded with **swoole_loader**. The PHP extension `swoole_loader` must be loaded or the files will appear garbled. Do not edit encoded files directly — work through the admin panel or API layer. A few files (like `helpers.php`, `lang/`, `routes/`, `config/`, `.env`, `composer.json`) are plaintext.

## File Organization: Where to Put What

When creating or modifying files in this project, always follow these conventions. If you're unsure where a new file belongs, match the nearest existing example.

### Static Frontend Files (HTML / CSS / JavaScript)

> ⚠️ **CRITICAL**: All frontend files MUST be stored under `frontend/`. Never create or edit frontend files directly in `public/`.

`frontend/` is the **single source of truth** for all HTML, CSS, and JavaScript. The web server serves them through two mechanisms:

1. **`public/css/` and `public/js/` are symlinks** → `../frontend/css/` and `../frontend/js/`. PHP's built-in server resolves these via `server.php` → `file_exists(public/...)`. Do NOT break these symlinks or create real directories under `public/css/` or `public/js/`.
2. **HTML pages** are served by Laravel routes in `routes/web.php` pointing to `base_path('frontend/xxx.html')`.

| File Type | Location | Examples |
|-----------|----------|---------|
| HTML pages | `frontend/` | `frontend/index.html`, `frontend/404.html` |
| CSS stylesheets | `frontend/css/` | `frontend/css/style.css` |
| JavaScript | `frontend/js/` | `frontend/js/app.js` |

> If you find frontend files duplicated in `public/`, delete them — the symlinks make `public/` serve `frontend/` content automatically.

### Server-Side Templates (Blade)

| File Type | Location | Examples |
|-----------|----------|---------|
| Blade views | `resources/views/` | `resources/views/protocol.blade.php` |
| View partials | `resources/views/` | Create subdirectories as needed |

### Backend Source Code

> ⚠️ Most files under `app/` are **encoded with swoole_loader** and cannot be read or edited directly. Only the paths marked **plaintext** below can be modified.

| What | Location | Swoole | Pattern |
|------|----------|--------|--------|
| **API Controllers** | `app/Http/Controllers/Api/` | encoded | `*Controller.php`, extend `BaseController` |
| **Base Controller** | `app/Http/Controllers/Controller.php` | encoded | All controllers extend this |
| **Services** | `app/Services/` | encoded | `*Service.php`, one per domain |
| **Models** | `app/Models/` | encoded | `*.php`, extend Eloquent `Model` or `Authenticatable` |
| **Enums** | `app/Enums/` | encoded | `*.php`, class constants only |
| **Request Validation** | `app/Http/Requests/` | encoded | `*Request.php`, one per form/endpoint |
| **Middleware** | `app/Http/Middleware/` | encoded | `*.php` |
| **Admin Controllers** | `app/Admin/Controllers/` | encoded | `*Controller.php` |
| **Admin Repositories** | `app/Admin/Repositories/` | encoded | `*.php` |
| **Admin Forms** | `app/Admin/Forms/` | encoded | `*.php` |
| **Background Jobs** | `app/Jobs/` | encoded | `*Job.php` |
| **Mail Classes** | `app/Mail/` | encoded | `*Mail.php` |
| **Exceptions** | `app/Exceptions/` | encoded | `*.php` |
| **Providers** | `app/Providers/` | encoded | `*ServiceProvider.php` |
| **Console Commands** | `app/Console/` | encoded | `*.php` |
| **Helper Functions** | `app/helpers.php` | ✅ plaintext | Global PHP functions |
| **HTTP Kernel** | `app/Http/Kernel.php` | encoded | Middleware registration |
| **Console Kernel** | `app/Console/Kernel.php` | encoded | Schedule tasks |

### Routing

| What | Location | Swoole |
|------|----------|--------|
| API routes | `routes/api.php` | ✅ plaintext |
| Web routes | `routes/web.php` | ✅ plaintext |
| Admin routes | `app/Admin/routes.php` | ✅ plaintext |
| Console routes | `routes/console.php` | ✅ plaintext |
| Broadcast channels | `routes/channels.php` | ✅ plaintext |

### Configuration

| What | Location | Swoole |
|------|----------|--------|
| Environment variables | `.env` | ✅ plaintext (never commit) |
| Env example | `.env.example` | ✅ plaintext |
| App config | `config/app.php` | ✅ plaintext |
| Database config | `config/database.php` | ✅ plaintext |
| Admin config | `config/admin.php` | ✅ plaintext |
| JWT config | `config/jwt.php` | ✅ plaintext |
| IM config | `config/im.php` | ✅ plaintext |
| Other config | `config/*.php` | ✅ plaintext |

### Database

| What | Location | Swoole |
|------|----------|--------|
| Migrations | `database/migrations/` | ✅ plaintext |
| Seeders | `database/seeders/` | ✅ plaintext |
| Factories | `database/factories/` | ✅ plaintext |

### Translations

| What | Location | Swoole |
|------|----------|--------|
| Language strings | `lang/en/*.php` | ✅ plaintext |

### Public Assets (Vendor / Compiled)

| What | Location | Notes |
|------|----------|-------|
| Dcat Admin assets | `public/vendor/dcat-admin/` | Managed by `php artisan admin:install` |
| Other vendor assets | `public/vendor/` | Published by `vendor:publish` |
| robots.txt | `public/robots.txt` | ✅ plaintext |
| Frontend CSS/JS | `public/css/` `public/js/` | Symlinks → `../frontend/css/` and `../frontend/js/` |

> `frontend/` is the single source of truth for all frontend files. `public/css` and `public/js` are symlinks so PHP's built-in server finds them via `server.php` while serving from ONE copy.

### Decision Rules for New Files

1. **Is it a frontend page (HTML/CSS/JS)?** → `frontend/` (NOT `public/` — the `public/css` and `public/js` symlinks exist only to bridge PHP's built-in server)
2. **Is it a Blade template?** → `resources/views/`
3. **Is it an API endpoint?** → Create controller in `app/Http/Controllers/Api/`, add route in `routes/api.php`
4. **Is it business logic?** → `app/Services/`, one service per domain
5. **Is it a database table change?** → `database/migrations/`
6. **Is it a constant/enum?** → `app/Enums/`, one file per domain
7. **Is it a background job?** → `app/Jobs/`
8. **Is it input validation?** → `app/Http/Requests/`
9. **Is it admin CRUD?** → Controller in `app/Admin/Controllers/`, Repository in `app/Admin/Repositories/`, route in `app/Admin/routes.php`
10. **Is it an email?** → `app/Mail/` + `resources/views/email.blade.php`
11. **Is it a global helper function?** → `app/helpers.php`
12. **Is it a translation string?** → `lang/en/res.php` (for response messages) or create a new file in `lang/en/`

## Commands

```bash
# Local dev server (via wrapper — auto-establishes SSH tunnel)
./start.sh

# Or manual start
/opt/homebrew/bin/php artisan serve

# Clear caches (use after config/route changes)
/opt/homebrew/bin/php artisan config:clear && /opt/homebrew/bin/php artisan cache:clear && /opt/homebrew/bin/php artisan route:clear && /opt/homebrew/bin/php artisan view:clear

# Clear route cache specifically (after editing routes/web.php)
/opt/homebrew/bin/php artisan route:clear

# Run migrations
/opt/homebrew/bin/php artisan migrate

# Generate JWT secret (if not already set in .env)
/opt/homebrew/bin/php artisan jwt:secret

# Queue worker (Redis backend)
/opt/homebrew/bin/php artisan queue:work redis

# Run tests
/opt/homebrew/bin/php artisan test
# Single test
/opt/homebrew/bin/php artisan test --filter=TestClassName

# Dcat Admin commands
/opt/homebrew/bin/php artisan admin:install    # Install/reinstall admin panel assets
/opt/homebrew/bin/php artisan admin:make       # Scaffold a new admin controller

# Web frontend — validate files
# Open http://localhost:8000/ in browser after starting server
# Verify API compatibility: curl http://localhost:8000/api/common/config
# Verify SPA shell loads: curl http://localhost:8000/
```

## Development Environment

- **PHP**: 8.3.21 via Homebrew at `/opt/homebrew/opt/php@8.3/bin/php`
- **Composer**: `/opt/homebrew/bin/composer`
- **IDE**: PhpStorm 2026.1, Run Configuration uses `start.sh` (Shell Script type)
- **Local dev DB**: Connects to production MySQL via SSH tunnel. `.env` DB_HOST=127.0.0.1, DB_PORT=3307. The tunnel maps 3307 → server's 127.0.0.1:3306.

### Local Dev Without swoole_loader

Since `app/` source files are encoded with swoole_loader (not installed locally), `public/index.php` contains an **API proxy** at the top of the file. It intercepts all `/api/*` requests and forwards them to `https://api.lumoguide.com` via cURL, returning the production response directly — entirely bypassing Laravel's encoded controllers.

- Proxy code lives at the TOP of `public/index.php` (before `require autoload.php`)
- Requests are matched by `str_starts_with($requestUri, '/api/')`
- Timeout: 60s total, 10s connect
- Non-API requests (`/`, `/test.html`, etc.) fall through to normal Laravel bootstrap

> **Important**: Local proxy software (Surge, ClashX, V2Ray) interferes with this. These tools hijack DNS for `api.lumoguide.com` to a virtual IP (`198.18.0.51`) and SSL handshakes time out. Disable the proxy software for local dev, or the API proxy will return 502 errors.

### PhpStorm Setup

Run Configuration (`start`) executes `start.sh`, which:
1. Checks if SSH tunnel on port 3307 exists → creates if missing
2. Starts `php artisan serve --host=0.0.0.0 --port=8000`

If the configuration breaks, recreate it manually: Settings → PHP → CLI Interpreter → `/opt/homebrew/opt/php@8.3/bin/php`, then Run → Edit Configurations → Shell Script pointing to `start.sh`.

## Frontend

### Web Frontend (SPA)

The web frontend is a **Vue.js 3 + Vue Router** single-page application served from `frontend/`. No build tools — all libraries loaded via CDN. The SPA replicates all functionality from the Flutter mobile app using the same backend REST APIs.

**Tech stack**: Vue 3 + Vue Router 4 (CDN), custom CSS (no framework), Fetch API, Google Fonts (Noto Serif SC for brand display moments).

**Design system** (refined 2025-07-05 via `frontend-design` skill, responsive refresh 2026-07-06):
- Primary: `#666FFF` (indigo), Primary Dark: `#4A52E0`
- Page background: `#F9F9F6` (warm paper-white), Card: `#FFFFFF`, Text: `#162539` (ink) / `#6B7280` (muted) / `#9CA3AF` (faint)
- Accent colors: `#EF4444` (red), `#F97316` (orange), `#F59E0B` (amber), `#10B981` (green), `#8B5CF6` (purple)
- Border: `rgba(0,0,0,.06)`, subtle shadows with `rgba(0,0,0,.03)`
- Radius: large 20px / small 12px
- Display typeface: `Georgia, 'Noto Serif TC', 'Noto Serif SC', serif`; Body: system font stack
- **Glassmorphism Header**: Replaced (2026-07-06) by primary indigo gradient header `linear-gradient(135deg, #666FFF, #5A5FE8)`, height 52px, with white text/icons.
- **Signature element**: 路盟 badge (45° rotated square with "盟") — REMOVED. Replaced by `logo_lumoguide.png` full horizontal logo (36px high, transparent bg, white version via CSS filter on welcome page).

**Responsive layout system** (2026-07-06 global refresh):
- **3 breakpoints**: default ≥861px (32px side padding) → ≤860px tablet (16px) → ≤480px mobile (12px, reduced fonts/spacing)
- **Container classes**: `.ds-container-600` (forms/lists), `.ds-container-640` (messages/addresses/records), `.ds-container-760` (detail/articles), `.ds-container-960` (galleries/malls), `.ds-container-1280` (wide dashboards)
- **Default centering**: `.ds-page-wrapper` (max-width 1280px, margin auto) for tab pages; search/hero areas stay full-width
- **Auth pages**: Redesigned (2026-07-06) to match Flutter mobile: full-screen indigo gradient background + centered white `.auth-card` (max-width 400px, radius 20px) with full-rounded inputs (radius 100px). Welcome page uses gradient bg + white logo + glass-morphism role cards.
- **Full-screen pages** (not constrained): Welcome (`.welcome-page`), Photo Viewer, Web View

**CDN versions (pinned)**:
```html
<script src="https://cdn.jsdelivr.net/npm/vue@3.4.38/dist/vue.global.js"></script>
<script src="https://cdn.jsdelivr.net/npm/vue-router@4.3.3/dist/vue-router.global.js"></script>
```
> ⚠️ **Do NOT use unpkg CDN or `vue.global.prod.js`**. The production build's template compiler silently fails — `app.mount('#app')` returns `null` without error, DOM unchanged. jsdelivr dev builds work correctly. Also, `app.js` (which calls `app.mount()`) **MUST be the last `<script>` at end of `<body>`**, after `<div id="app">`. If placed in `<head>`, `#app` doesn't exist yet and mount fails silently.

```
frontend/
├── index.html                  # SPA shell (CDN links + <div id="app">)
├── 404.html                    # Error page
├── images/
│   ├── logo.png                # Logo icon (small square)
│   └── logo_lumoguide.png      # Full horizontal logo (5326×1024, transparent bg)
├── css/
│   ├── variables.css           # Design tokens (matches mobile AppColors)
│   ├── app.css                 # Global layout, typography, utilities
│   └── components.css          # .ds-* component classes, topbar, auth cards, skeleton screens, evaluation form
└── js/
    ├── app.js                  # Vue.createApp(), AppShell with inline topbar (indigo gradient), global components, mount
    ├── router.js               # Hash-based routes (69 routes + auth guard)
    ├── api/
    │   ├── provider.js         # Fetch wrapper — never throws, returns {success, data, message}
    │   └── urls.js             # All 183 API URL constants (mirrors Flutter ApiUrl class)
    ├── stores/
    │   ├── user.js             # Vue.reactive — auth state, token, profile, login/logout
    │   └── config.js           # System config cache from /common/config
    ├── i18n/
    │   ├── index.js            # Translation service (detects browser lang, persists to localStorage)
    │   ├── zh-CN.js            # Simplified Chinese (~180 keys)
    │   ├── zh-TW.js            # Traditional Chinese (identity mapping)
    │   └── en.js               # English
    ├── utils/
    │   ├── storage.js          # localStorage wrapper (mirrors Flutter StorageStone keys, incl. cityAreaMap)
    │   └── helpers.js          # timeAgo, imageUrl, safeInt/safeString, showToast, debounce, ListPageHelper, setupInfiniteScroll
    ├── components/
    │   ├── app-nav.js          # Bottom tab navigation (DEPRECATED — replaced by inline topbar in app.js)
    │   ├── app-header.js       # Sticky header with back button + title (DEPRECATED — topbar always tabs mode)
    │   ├── app-topbar.js       # Top bar component [REFERENCE only — template inline in app.js]
    │   ├── loading-spinner.js  # Loading indicator
    │   └── empty-state.js      # Empty data placeholder with retry
    └── pages/
        ├── welcome.js              # Landing page (indigo gradient bg, white logo, glass cards, full-rounded buttons)
        ├── auth/
        │   ├── login.js            # Login (gradient bg + white card, full-rounded inputs, matches Flutter LoginPage)
        │   ├── register.js         # Registration (same card style, inline verify-code send button)
        │   └── extra.js            # ForgetPassword, VerifyCode, PasswordInput (all auth card style)
        ├── home/index.js           # Home: search, city strategy, continent-grouped cities (auto-switch), guides (auto-switch 5s), merchants (banner carousel drives category switch), news
        ├── city/
        │   ├── index.js            # City list browser with continent tabs
        │   ├── detail.js           # City detail — Banner + 10 Tabs + content grid
        │   └── extra.js            # CityStrategy, CityGuideList
        ├── common/
        │   └── details.js          # GuideDetail, CommonDetail, CompanyDetail, EvaluationDetail, EvaluationList
        ├── news/
        │   ├── index.js            # Information/articles with category filter
        │   └── detail.js           # News detail + evaluations
        ├── search/
        │   └── index.js            # Search with tabs (city/guide/content)
        ├── message/
        │   ├── index.js            # Message center (5 categories)
        │   └── subpages.js         # MessageSystem, MessageFollow, MessageComments, MessageReserves
        ├── mine/
        │   ├── index.js            # My page — menu grid (legacy, being replaced by profile.js)
        │   ├── profile.js          # Profile (refactored) + ProfileEdit
        │   └── extra.js            # Settings, ModifyPassword, ModifyPhone, Feedback, Contact, Invite,
        │                           #   Followers, Following, MyEvaluations, MyBookings, BookingDetail
        ├── address/
        │   └── list.js             # AddressList + AddressEdit
        ├── guide/
        │   ├── certify.js          # GuideCertifyPage（3步认证向导）
        │   ├── publish.js          # GuidePublishPage（5 Tab发布管理）
        │   ├── publish-city.js     # GuidePublishCityPage（城市管理）
        │   ├── bookings.js         # GuideBookingsPage + GuideBookingDetailPage
        │   └── change-city.js      # GuideChangeCityPage（切换服务城市）
        ├── publish/
        │   └── form.js             # 5个发布表单组件（createPublishPage工厂函数）
        └── merchant/
            ├── entry.js            # MerchantEntryPage（4步入驻向导）
            ├── manage.js           # MerchantManagePage（店铺CRUD）
            └── bookings.js         # MerchantBookingsPage + MerchantBookingDetailPage
        ├── integral/
        │   ├── index.js            # IntegralPage（积分商城首页）
        │   ├── goods.js            # IntegralGoodsPage（商品详情）
        │   ├── exchange.js         # IntegralExchangePage + Result + Order
        │   └── records.js          # IntegralRecordsPage（积分记录）
        ├── vip/
        │   └── index.js            # VipPage（VIP会员中心）
        ├── booking/
        │   └── form.js             # BookingGuidePage + BookingMerchantPage
        ├── evaluation.js            # EvaluationSubmitPage（星级评价+图片上传）
        └── misc/
            ├── photo.js             # PhotoViewerPage（全屏图片查看器）
            └── web.js               # WebViewPage（内嵌网页）
```

**Architecture patterns**:
- **API**: `ApiProvider.get/post(path, data)` → always returns `{success, code, message, data}`. JWT automatically attached from `Storage.token`. Never throws — matches Flutter's `ApiResult` pattern. In local dev, API proxy in `public/index.php` forwards `/api/*` to `https://api.lumoguide.com`.
- **Auth**: `UserStore` (Vue.reactive) manages token + profile. Login stores credentials in localStorage under keys matching Flutter's `StorageStone` (`token`, `user_number`, `user_sig`, `user_info`). 401 responses trigger logout redirect. Route guard in `router.beforeEach` checks `meta.requiresAuth`. Profile refetched via `UserStore.fetchProfile()` after edits.
- **i18n**: Keys are Traditional Chinese characters (matching Flutter). `I18n.t('首頁')` returns locale-appropriate text. Language persisted to localStorage. Switchable via Settings page.
- **Pages**: Each page is a Vue Options API component definition object (`{template, data, methods, mounted}`). Multiple related components per file (e.g. `pages/city/detail.js` contains `CityDetailPage`, `pages/mine/extra.js` contains 11 components). Files loaded via `<script>` tags in `index.html` — order matters: dependencies must load before dependents.
- **Component resolution**: Shared components (`AppHeader`, `LoadingSpinner`, `EmptyState`) are registered on the root Vue instance's `components` option. Vue 3 resolves them through the parent chain via `<router-view>`, so they're available in all route components without `app.component()` global registration.
- ⚠️ **Vue 3 CDN component registration pitfall**: Components registered locally on the root component via `components: {}` may NOT be resolved in child components' templates (e.g., a component registered on root but used inside `AppShell`'s template). This differs from Vue 3 SFC/build-tool behavior. If a component renders blank with no errors, the ONLY reliable fix is to **inline the template HTML directly in the parent component.** Do NOT create separate component files — even `app.component()` global registration is unreliable in the CDN build. If a component renders blank: **inline the template HTML directly — do NOT create separate component files.** The `app-topbar.js` file is kept only as reference (marked `[REFERENCE]` / `⚠️ NOT USED at runtime`), with the actual template inlined in `app.js` AppShell. **Never repeat this mistake.** See [[vue3-cdn-component-pitfall]] and [[web-standard-layout-patterns]] in memory.
- **Routing**: Hash-based (`#/home`, `#/city/detail?id=1`). Tab bar shown only on 5 main routes; hidden on sub-pages (matches Flutter push navigation). Scroll position resets on navigation. Route params via `this.$route.params.id` and query via `this.$route.query.id`. Route changes watched via `watch: { '$route.params.id': handler }` for same-component navigation.
- **Top navigation bar**: Built inline in `AppShell` template (`app.js`). Shows full logo image (`logo_lumoguide.png`, 36px), 5 tabs (首頁/城市/資訊/🔔/👤) left-aligned, 🔍 search button on right. Indigo gradient background. Always in 'tabs' mode on every page (back mode removed). Hidden only on `/welcome`, `/login`, `/register`. Deprecates both `AppNav` and `AppHeader` components.
- **Design system v2** (2025-07-05, ref PPCC): Warm paper-white bg `#F9F9F6`, ink text `#162539`, primary `#666FFF`, accent soft `#EEEDFF`. Radius: 20px/12px. Serif: `Georgia, Noto Serif TC, Noto Serif SC`. All pages now use `.ds-*` component classes (`.ds-card`, `.ds-tab`, `.ds-type-tab`, `.ds-profile-card`, `.ds-menu-group`, `.ds-btn`, `.ds-input`, etc.) from `components.css`.
- **Page templates** (4 patterns): (1) **列表页** — filter pills + card grid/list + empty/loading/error; (2) **详情页** — banner + info card + tab content + actions; (3) **表单页** — `.ds-input`/`.ds-textarea` + submit button + loading; (4) **仪表盘** — stats row + `.ds-menu-group` sections.

**Welcome page design** (路盟品牌入口):
- 路盟 badge (45° rotated rounded square with "盟" character) + radial background glow
- Slogan "路上有光，盟友相伴" in Noto Serif SC
- Platform positioning: "旅游行业人士的信息资源交流平台"
- Three role cards: 导游 (publish city content), 商家 (manage shop bookings), 创作者 (share industry news)
- Login/Register CTAs + "已通过身份审核的成员方可进入" lock notice
- No guest browsing path — all access requires authentication

**Backend route for SPA** (`routes/web.php`):
```php
// Root route serves SPA shell
Route::get('/', fn() => response()->file(base_path('frontend/index.html')));

// Protocol pages (Blade views) — must be before SPA catch-all
Route::get('/protocol/{type}', function ($type) {
    return view('protocol', ['content' => systemConfig($type)]);
});

// SPA catch-all — all non-API, non-admin routes serve index.html
// Regex excludes paths with dots (static files) and api/manage prefixes
Route::get('/{any}', fn() => response()->file(base_path('frontend/index.html')))
    ->where('any', '^(?!api|manage)[^.]*$');
```
This ensures `/api/*` (mobile app), `/manage*` (admin panel), and static files (`/css/...`, `/js/...`) are unaffected. Protocol pages (`/protocol/user`, `/protocol/privacy`) render Blade views with system config content.

**Implementation status** (updated 2026-07-06):
| Phase | 名称 | 页面数 | 状态 |
|-------|------|--------|------|
| Phase 0 | 顶部导航栏 + LOGO | — | ✅ |
| Phase 1 | 外壳 + 认证 + 5 Tab | 8 | ✅ |
| Phase 2 | 详情页 + 设计系统刷新 | 14 | ✅ |
| Phase 3 | 用户操作 | 18 | ✅ |
| Phase 4 | 发布功能 | 12 | ✅ |
| Phase 5 | 电商功能 | 13 | ✅ |
| Phase 6 | 打磨收尾 | 2 + 全局 | ✅ (含 2026-07-06 响应式布局刷新) |
| Phase 7 | 评价提交 + App/Web 一致性审计 | 1 + 审计 | ✅ (2026-07-06) |
| Phase 8 | 导航栏+认证页+商家区块改造 | 全局 | ✅ (2026-07-06) |

**69/69 routes implemented** (100%). See `plan.md` for full details. Top nav bar redesigned with primary indigo gradient, auth pages match Flutter mobile layout, shop section has banner carousel driving category auto-switch.

### App-Web Feature Parity

The web frontend replicates all Flutter mobile app features that are feasible in a browser environment. A comprehensive audit (2026-07-06) confirmed functional alignment across all 71 Flutter pages vs 69 Web routes.

**Mobile-only features (not applicable to Web):**
- Chat/IM (Tencent Cloud Chat SDK — native only)
- QR code scanning (requires camera hardware)
- Group chat management (select members, group profiles, group QR codes)

**Key feature alignment validations:**
- **Evaluation submission** (Phase 7): Star rating (1-5★) + text content + image upload (up to 9), matching Flutter's `EvaluationPage`. Entry points added to news detail and common detail pages. Uses `addContentEvaluate` and `addInformationEvaluate` APIs.
- **Booking rejection**: Web uses `prompt()` dialog for rejection reason vs Flutter's dedicated `RejectReservationPage` — functionally equivalent.
- **All other features** (auth, city browsing, guide/merchant profiles, content publishing, bookings, points/VIP, search, messages, address management, etc.) are fully aligned.

**Audit findings & fixes (2026-07-06):**
- ✅ Added evaluation submission page (critical gap)
- ✅ Added "Write Evaluation" buttons to news detail & common detail pages
- ✅ Fixed integral exchange result page hardcoded `order/0` → dynamic `order_id` from route query

**API coverage**: 183 API endpoints defined in `urls.js`, mirroring Flutter's `ApiUrl` class. A few endpoints are intentionally unused in Web (e.g., `getContinents`, `getLocation`) — they serve mobile-specific flows.

### Mobile Frontend Reference

The Flutter mobile app source is at `/Users/guanpei/Downloads/LUMOGUIDE- Front/LUMOGUIDE-frontend/` (see `[[mobile-frontend-reference]]` in memory for full details). All API endpoints and data models are defined there — use as reference when building web pages.

## Server Connection

| Item | Value |
|------|-------|
| Provider | easyname |
| IP | 47.76.27.105 |
| SSH user | root |
| MySQL DB | lumo_guide |
| MySQL port | 3306 (server) → 3307 (local tunnel) |

**SSH Tunnel** (run manually if needed):
```bash
ssh -L 3307:127.0.0.1:3306 root@47.76.27.105 -N
```

## Architecture

### API Layer (`app/Http/Controllers/Api/`)

All API controllers extend `BaseController`, which provides two response helpers:
- `$this->success(message, data, code)` → `{code, message, data}`
- `$this->error(message, code)` → `{code, message, data: []}`

Authentication: JWT via `tymon/jwt-auth` (config in `config/jwt.php`). Routes use `auth:api` middleware. The `User` model implements `JWTSubject`. TTL is set to 10080 minutes (7 days). Login sends email verification codes via Gmail SMTP.

**Route groups** (prefixes in `routes/api.php`):
- `auth` — public: login, sendCode, register, resetPassword
- `common` — public + auth: config, fileUpload, home/search, area/continent lookups, type/class lookups
- `user` — auth required: profile, addresses, reservations, guide/company applications
- `city` — mixed auth: listing, detail, content by type (attraction/restaurant/shopping/accommodation/transportation/facility/activity/ticket), evaluations, follows
- `guide` — auth required: publish/edit/delete city content, manage reservations
- `company` — auth required: shop CRUD, reservation management
- `information` — mixed: articles listing and evaluations
- `integral` — auth required: points balance, goods catalog, exchange orders
- `vip` — auth required: Stripe subscription for guide/company memberships
- `message` — auth required: follows, evaluations, system messages
- `payment` — public: Stripe webhook

### Service Layer (`app/Services/`)

Business logic is extracted into service classes — one per domain (`AuthService`, `CityService`, `GuideService`, `CompanyService`, `InformationService`, `IntegralService`, `UserService`, `VipService`, `MessageService`, `CommonService`). API controllers call services rather than models directly.

### Admin Panel (`app/Admin/`)

Uses **Dcat Admin** (Laravel-admin fork) accessible at `/manage` (configured via `ADMIN_ROUTE_PREFIX` in `.env`). Structure:
- `Controllers/` — CRUD controllers extending Dcat\Admin controllers
- `Repositories/` — Data access layer for admin grids/forms (one per model)
- `Forms/` — Custom form components (e.g., `AuditCityForm`, `CompanyVipSet`, `UserIntegralSet`)
- `Actions/` — Custom grid actions (`AuditCity`, `AdminSetting`)
- `Metrics/Examples/` — Dashboard metric cards
- `Renderable/` — Custom table renderers
- `routes.php` — Admin routes, all under the admin prefix

### Models (`app/Models/`)

Standard Eloquent models. Key relationships:
- `City` → `Guide` (guide_id), `SystemContinents` (country, continents, area)
- `CityContent` → `City`, `CityType`
- `Guide`/`Company` have corresponding `*Edit` models for audit workflows (submit→audit→approve/reject)
- `User` implements `JWTSubject`, has `SoftDeletes`

### Enums (`app/Enums/`)

Constants organized by domain: `City`, `Company`, `Guide`, `Information`, `Integral`, `Reserve`, `System`, `User`, `Vip`. Used for status codes, type mappings, and error codes.

### Helpers (`app/helpers.php`)

Global functions loaded via composer autoload:
- `systemConfig($mark)` — get system config from Redis with DB fallback
- `createOrderSn($type)` — generate order numbers
- `generateUniqueInviteCode()` — base36 invite codes
- `handleGuideVip($user)` / `handleUserVip($user)` — VIP status check, throws `ApiException` on failure
- `handleSearchData($where, $name, $type)` — unified search across cities/guides/content
- `compressImage($source, $dest, $quality)` — JPEG compression with EXIF rotation fix
- `timeAgo($time)` — Chinese relative time formatting

### Middleware

- `auth:api` — JWT authentication for API routes
- `auth:sanctum` — unused in practice (JWT is the primary auth)
- `SetLanguage` — sets locale on API requests (in `api` middleware group)
- Admin panel uses Dcat's built-in session auth (`admin` guard)

### Background Jobs (`app/Jobs/`)

- `VipExpiredJob` — handles VIP subscription expiry
- `CityContentExpiredJob` — handles time-limited city content
- `InvoiceJob` / `EmailRemindJob` — email notifications

Queue driver: **Redis** (`QUEUE_CONNECTION=redis`).

## Key Integrations

| Integration | Config | Purpose |
|-------------|--------|---------|
| Stripe | `.env` STRIPE_* keys, `stripe/stripe-php` | VIP subscription payments, webhook at `/api/payment/webhook` |
| Tencent IM | `config/im.php`, SDK_APP_ID/SECRET_KEY in `.env` | Instant messaging for users |
| Gmail SMTP | MAIL_* in `.env` | Verification codes (`SendCodeMail`), invoices, VIP expiry notices |
| JWT | `config/jwt.php`, HS256 | API authentication |
| Redis | `config/queue.php` | Queue backend + system config cache |

## Database

MySQL (`lumo_guide`). Migrations in `database/migrations/` — custom tables start from `2025_06_06`. Admin tables use Dcat Admin defaults (`admin_users`, `admin_roles`, `admin_permissions`, etc.). The `.env` contains live DB credentials — do not commit them.

## Important Notes

- **Source code is encoded**: Most `.php` files in `app/` require `swoole_loader` extension. Attempting to read them returns garbled content. The plaintext files are: `helpers.php`, route files, config files, language files, migrations, and the `public/` directory.
- **Custom admin prefix**: Admin panel is at `/manage`, not `/admin` (set via `ADMIN_ROUTE_PREFIX=manage` in `.env`).
- **API base URL**: `https://api.lumoguide.com` (local dev overrides via `.env` `APP_URL`).
- **Stripe is live**: `.env` contains production Stripe keys. Webhook secret is `whsec_ia...`. Test keys are commented out.
- **System config Redis caching**: Config loaded via `systemConfig()` caches all `system_config` table rows into a Redis hash, refreshing on cache miss.
- **Response format**: All API responses follow `{code: int, message: string, data: object/array}`.
- **Claude Code Skills**: 18 skills installed via `npx skills add anthropics/skills` in `.agents/skills/`, including `frontend-design` for UI work. Use `Skill` tool to invoke (e.g., `/frontend-design`). See also [[frontend-design-skill]] in memory.
- **Web-standard layout patterns**: The web frontend follows web-standard patterns, not mobile patterns. Key rules: (1) Never extract inline templates into separate component files in Vue 3 CDN build — the component will silently render blank; (2) Use `.ds-container-*` + `.ds-page-wrapper` for content centering, not inline `max-width`; (3) Top navigation bar (not bottom tabs) — `AppNav` is deprecated; (4) New pages should be audited against the Flutter app for feature parity. See [[web-standard-layout-patterns]] in memory.
- **Feature parity audit**: The web frontend should stay aligned with the Flutter mobile app. When the mobile app adds new features, the web frontend should follow. When unsure about a feature's behavior, reference the Flutter source at `/Users/guanpei/Downloads/LUMOGUIDE- Front/LUMOGUIDE-frontend/lib/pages/`. See [[mobile-frontend-reference]] in memory.
- **Home page city continents**: Recommended cities from `homeData.city` don't include `area_name`. Use `cityList` API in parallel (`Promise.all`) to enrich with continent data. Process `cityAreaMap` first, then update `homeData` so `continentGroups` computed renders correctly on first trigger. See [[home-page-city-continents]] and [[parallel-api-data-enrichment]] in memory.
- **Home page guide auto-switch**: Guide categories auto-switch every 5s (matching Flutter's `_guideAutoScrollTimer`). Manual tap resets the timer. Keep original `.h-scroll` layout — do NOT change guide card visual style.
- **Reuse existing styles**: Before creating new CSS classes, check if existing utility classes (`.filter-pills`, `.filter-pill`, `.card-grid-*`, `.h-scroll`, `.ds-*`) already provide the needed style. Creating custom styles when existing ones suffice causes visual inconsistency. See [[reuse-existing-styles]] in memory.
- **Layout stability during auto-switch**: Use placeholder slots (invisible cards with `visibility: hidden`) to pad to the max row count across all categories, preventing page height from jumping. City placeholders work via `aspect-ratio: 16/9`; Guide/Shop placeholders MUST have full DOM structure (image + info + text) — an empty `<div>` collapses to zero height because there's no content to push it open. See [[shop-banner-carousel]] and [[home-page-city-continents]] in memory.
- **Topbar (top navigation bar)**: Redesigned 2026-07-06 — indigo gradient background `linear-gradient(135deg, #666FFF, #5A5FE8)`, height 52px. Logo uses `logo_lumoguide.png` (36px high, far left). Tabs (首頁/城市/資訊/🔔/👤) are left-aligned after logo, never centered. Search button 🔍 at far right. `topBarMode` always `'tabs'` — nav bar visible on ALL pages except welcome/login/register. See [[topbar-redesign]] in memory.
- **Auth pages**: Redesigned 2026-07-06 to match Flutter mobile layout — full-screen indigo gradient bg + centered white `.auth-card` (max-width 400px, border-radius 20px) + full-rounded inputs (border-radius 100px) + title with small primary underline bar. Login/Register/Welcome/ForgetPassword/VerifyCode/PasswordInput all use this unified style. See [[auth-pages-redesign]] in memory.
- **Shop/Business section**: Banner carousel from `cat.banner` drives category switching — all banner slides shown (4s each), then auto-advance to next category. Categories with no banner AND no list are filtered out. Placeholder padding prevents layout jumping between categories. Merchant card images use `aspect-ratio: 16/9` (same as city cards). List: 4 columns on desktop, 2 on mobile. See [[shop-banner-carousel]] in memory.
- **Spacing (web traditional)**: Card grids (`.card-grid-*`) and horizontal scroll (`.h-scroll`) use `--spacing-lg` (16px) gap — the web standard, not the tight 8px mobile-native spacing. On mobile ≤480px, reduced to `--spacing-md` (12px). See [[reuse-existing-styles]] in memory.
