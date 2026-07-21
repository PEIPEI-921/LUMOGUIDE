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
- **API proxy cache** (2026-07-08): GET requests are cached to disk (`storage/cache/api-proxy/`) with per-endpoint TTLs (2 min default, 30 min for `/common/config`, 10 min for `/common/getContinentsList`, 5 min for `/city/lists`). Second request hits disk cache in ~1ms instead of TLS round-trip. POST/PUT/DELETE bypass cache. Cache key includes auth token hash for user isolation. Response header `X-Proxy-Cache: HIT/MISS`. See [[api-cache-system]] in memory.
- **Frontend API cache** (2026-07-08): `provider.js` has in-memory Map cache for GET responses (1 min default TTL). Page navigation between already-visited routes → 0ms API responses. POST/PUT/DELETE automatically invalidate related cache. See [[api-cache-system]] in memory.

> **Important**: Local proxy software (Surge, ClashX, V2Ray) interferes with this. These tools hijack DNS for `api.lumoguide.com` to a virtual IP (`198.18.0.51`) and SSL handshakes time out. Disable the proxy software for local dev, or the API proxy will return 502 errors.

### PhpStorm Setup

Run Configuration (`start`) executes `start.sh`, which:
1. Checks if SSH tunnel on port 3307 exists → creates if missing
2. Starts `php artisan serve --host=0.0.0.0 --port=8000`

If the configuration breaks, recreate it manually: Settings → PHP → CLI Interpreter → `/opt/homebrew/opt/php@8.3/bin/php`, then Run → Edit Configurations → Shell Script pointing to `start.sh`.

## Frontend

### Web Frontend (SPA)

The web frontend is a **Vue.js 3 + Vue Router** single-page application served from `frontend/`. No build tools — all libraries loaded via CDN. The SPA replicates all functionality from the Flutter mobile app using the same backend REST APIs.

**Tech stack**: Vue 3 + Vue Router 4 (CDN), custom CSS (no framework), Fetch API, Google Fonts (Noto Serif SC for brand, ZCOOL KuaiLe for welcome Chinese, Caveat for welcome English).

**Design system** (refined 2025-07-05 via `frontend-design` skill, responsive refresh 2026-07-06):
- Primary: `#666FFF` (indigo), Primary Dark: `#4A52E0`
- Page background: `#F9F9F6` (warm paper-white), Card: `#FFFFFF`, Text: `#1a1a1a` (ink) / `#6B7280` (muted) / `#9CA3AF` (faint)
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
- **Auth pages**: Redesigned (2026-07-06) to match Flutter mobile: full-screen indigo gradient background + centered white `.auth-card` (max-width 400px, radius 20px) with full-rounded inputs (radius 100px). **Welcome page** (redesigned 2026-07-08): splash animation — characters write on one-by-one via `clip-path` reveal, pause 2s, auto-redirect. Chinese (ZCOOL KuaiLe) / English (Caveat) auto-switch based on `navigator.language`.
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
        │   ├── index.js            # City list — server-driven continents + area sub-filter, 4-column grid, premium minimal design
        │   ├── detail.js           # City detail — Banner + 10 Tabs + content grid + guide publish FAB
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
        │   ├── publish-city-form.js # GuidePublishCityFormPage（创建/编辑城市，14字段+6图+三级联动）
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
        │   └── index.js            # VipPage（會籍中心 / Membership Center — 付費導遊會員訂閱）
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
- **Top navigation bar**: Built inline in `AppShell` template (`app.js`). Shows full logo image (`logo_lumoguide.png`, 36px), 5 tabs (首頁/城市/資訊/🔔/👤) left-aligned, 🔍 search button on right, 🚪 login/logout toggle on far right. Indigo gradient background. Always in 'tabs' mode on every page (back mode removed). Hidden only on `/welcome`, `/login`, `/register`, `/forget-password`, `/verify-code`, `/password-input`. Deprecates both `AppNav` and `AppHeader` components.
- **Design system v2** (2025-07-05, ref PPCC): Warm paper-white bg `#F9F9F6`, ink text `#1a1a1a`, primary `#666FFF`, accent soft `#EEEDFF`. Radius: 20px/12px. Serif: `Georgia, Noto Serif TC, Noto Serif SC`.
- **Page templates** (4 patterns): (1) **列表页** — filter pills + card grid/list + empty/loading/error; (2) **详情页** — banner + info card + tab content + actions; (3) **表单页** — `.ds-input`/`.ds-textarea` + submit button + loading; (4) **仪表盘** — stats row + `.ds-menu-group` sections.

**Welcome page design** (2026-07-08 splash animation):
- Minimal splash: characters reveal left-to-right via clip-path (simulates handwriting), fade-blur + float up
- Chinese: ZCOOL KuaiLe font. "路上有光，盟友相伴" (52px) / "——路盟" (48px, right-aligned)
- English: Caveat font. "LUMO leads, GUIDE exceeds" (46px) / "-- LUMO" (42px, right-aligned)
- Auto-detect navigator.language for Chinese vs English
- After animation + 2s pause: logged in → /home, not logged in → /login
- Removed old role cards, CTA buttons, lock notice

**Backend route for SPA** (`routes/web.php`):
```php
// Root route serves SPA shell
Route::get('/', fn() => response()->file(base_path('frontend/index.html')));

// Protocol pages (Blade views) — must be before SPA catch-all
Route::get('/protocol/{type}', function ($type) {
    $content = systemConfig($type);
    if (!$content) abort(404);
    return view('protocol', ['content' => $content]);
});

// SPA catch-all — admin prefix read dynamically from config (not hardcoded)
Route::get('/{any}', fn() => response()->file(base_path('frontend/index.html')))
    ->where('any', '^(?!api|' . config('admin.route.prefix', 'admin') . ')[^.]*$');
```
This ensures `/api/*` (mobile app), `/manage*` or `/admin*` (admin panel), and static files (`/css/...`, `/js/...`) are unaffected. Protocol pages (`/protocol/user`, `/protocol/privacy`) render Blade views with system config content, or 404 if config not found.

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
| Phase 9 | 城市攻略 + 卡片系统 + 全局渐变 + 城市详情重构 + 交叉导航 + 页面改造 | 2 + 全局 | ✅ (2026-07-06) |

**69/69 routes implemented** (100%). See `plan.md` for full details. Top nav bar uses solid `#666FFF` indigo (no shadow, unified with primary), body gradient seamlessly matches, all pages share unified gradient background, auth pages match Flutter mobile layout, shop section has banner carousel driving category auto-switch, city strategy page uses GPS location to find nearest city with rectangular pill type navigation.

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

The Flutter mobile app working copy is at `/Users/xuejingchen/Desktop/vscode/lumotrip/` (this project). The original reference source is at `/Users/guanpei/Downloads/LUMOGUIDE- Front/LUMOGUIDE-frontend/`. All API endpoints and data models are defined there — use as reference when building web pages. See `[[mobile-frontend-reference]]` in memory for full details.

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
- **Feature parity audit** (updated 2026-07-08, repass 2026-07-08): The web frontend MUST strictly match the Flutter mobile app. **Web cannot have features that don't exist in Flutter.** If Flutter disabled a feature (e.g. `canDelete: false`), Web must also disable it. Key rules: (1) No delete in publish content lists (Flutter `canDelete: false`); (2) No inline confirm/reject in booking lists; (3) No booking status filter tabs; (4) VIP gate on add, not edit; (5) API response format varies — always use defensive parsing. **2026-07-08 publish page realignment**: Rewrote `publish.js` cards to match Flutter my_publish widgets — type-specific fields (attraction: opening time+address; transportation/facility: phone+address; activity: start/end time; information: title+desc), bordered status badges (0=primary/1=green/2=red), unread dot, rejection reason (red text), pill-style tabs, operate bar (edit only, no delete). **2026-07-08 publish-city realignment**: Rewrote `publish-city.js` cards to match Flutter my_publish_city — 180px cover image with primary gradient overlay (city name + capital badge + English name), info banner, city selector panel, FAB, delete limited to audit_status==2 only. Flutter reference at `/tmp/lumotrip_ref/lumotrip/lib/pages/`. See [[flutter-web-feature-parity]], [[guide-publish-city-alignment]], and [[mobile-frontend-reference]] in memory.
- **Home page city continents**: Recommended cities from `homeData.city` don't include `area_name`. Use `cityList` API in parallel (`Promise.all`) to enrich with continent data. Process `cityAreaMap` first, then update `homeData` so `continentGroups` computed renders correctly on first trigger. See [[home-page-city-continents]] and [[parallel-api-data-enrichment]] in memory.
- **Home page guide auto-switch**: Guide categories auto-switch every 5s (matching Flutter's `_guideAutoScrollTimer`). Manual tap resets the timer. Keep original `.h-scroll` layout — do NOT change guide card visual style.
- **Reuse existing styles**: Before creating new CSS classes, check if existing utility classes (`.filter-pills`, `.filter-pill`, `.card-grid-*`, `.h-scroll`, `.ds-*`) already provide the needed style. Creating custom styles when existing ones suffice causes visual inconsistency. See [[reuse-existing-styles]] in memory.
- **Layout stability during auto-switch**: Use placeholder slots (invisible cards with `visibility: hidden`) to pad to the max row count across all categories, preventing page height from jumping. City placeholders work via `aspect-ratio: 16/9`; Guide/Shop placeholders MUST have full DOM structure (image + info + text) — an empty `<div>` collapses to zero height because there's no content to push it open. See [[shop-banner-carousel]] and [[home-page-city-continents]] in memory.
- **Topbar (top navigation bar)**: Redesigned 2026-07-06, unified 2026-07-16 — solid `#666FFF` indigo background (unified with primary), height 52px, **no box-shadow**. Logo uses `logo_lumoguide.png` with `filter: brightness(0) invert(1)` to appear white on dark bg (36px high, far left). Logo uses `logo_lumoguide.png` with `filter: brightness(0) invert(1)` to appear white on dark bg (36px high, far left). Tabs (首頁/城市/資訊 + SVG 简笔画图标 for 消息/我的) are left-aligned after logo. Search button with magnifying glass SVG icon at far right. **Auth toggle button** (2026-07-08): login/logout SVG icon to the right of search — shows login arrow when logged out, logout arrow when logged in; click logs out and redirects to `/login`. `topBarMode` always `'tabs'` — nav bar visible on ALL pages except welcome/login/register. See [[topbar-redesign]] and [[topbar-auth-button]] in memory.
- **Auth pages**: Redesigned 2026-07-06 to match Flutter mobile layout — full-screen indigo gradient bg + centered white `.auth-card` (max-width 400px, border-radius 20px) + full-rounded inputs (border-radius 100px). **Login page** (updated 2026-07-08): title replaced by app icon image (`logo-app-icon.png`, 100×100px, purple rounded square), email/password icons use SVG line icons (not emoji), password visibility toggle uses SVG eye icons, form uses `<form @submit.prevent>` to trigger browser password manager. **Remember password** (2026-07-08): checkbox actually saves password to localStorage; credentials survive explicit logout and token expiry; only cleared when user unchecks the box. Login/Register/Welcome/ForgetPassword/VerifyCode/PasswordInput all use this unified style. See [[auth-pages-redesign]], [[login-page-app-icon]], and [[remember-password-feature]] in memory.
- **Shop/Business section**: Banner carousel from `cat.banner` drives category switching — all banner slides shown (4s each), then auto-advance to next category. Categories with no banner AND no list are filtered out. Placeholder padding prevents layout jumping between categories. Merchant card images use `aspect-ratio: 16/9` (same as city cards). List: 4 columns on desktop, 2 on mobile. See [[shop-banner-carousel]] in memory.
- **Spacing (web traditional)**: Card grids (`.card-grid-*`) and horizontal scroll (`.h-scroll`) use `--spacing-lg` (16px) gap — the web standard, not the tight 8px mobile-native spacing. On mobile ≤480px, reduced to `--spacing-md` (12px). See [[reuse-existing-styles]] in memory.
- **City strategy GPS location**: Clicking any city strategy category navigates to `/city/strategy?type=X`. Page uses browser Geolocation API → `/common/location` API to find the nearest city, then filters content by `city_id`. Manual city switching via picker panel. City name displayed in white text, right-aligned. Falls back to first city from `cityList` if GPS denied. **API endpoint fix (2026-07-06)**: Guide type uses `cityGuide` (`/city/guide`), NOT `guideCityList` (`/guide/cityList` — that's for guides managing their own cities). Guide detail links use `#/guide/:id`, not `#/detail/guide`. Image field: `item.photo || item.first_picture` (guides return `photo`, others return `first_picture`). See [[city-strategy-gps-location]] in memory.
- **Strategy cards design**: Home page city strategy uses 6-column CSS Grid, always one row (never wraps — icons/text shrink on narrow screens). Cards: square, pastel macaron backgrounds, 14px border radius, flat no-shadow. Icons: thin line SVG (`#1a1a1a`, 1.6px stroke) + small solid color accents. Text: 24px bold below icon. **City strategy page variant**: 9 type pills — rectangular (icon left of text), not square — using `.strategy-pills` / `.strategy-pill` classes. See [[strategy-cards-design]] and [[city-strategy-gps-location]] in memory.
- **Global gradient background** (2026-07-06, unified 2026-07-16): All pages share `body` gradient: `linear-gradient(180deg, #666FFF 0%, #666FFF 52px, #F9F9F6 400px)`. First 52px is solid `#666FFF` — seamlessly matches topbar. Then fades to `#F9F9F6` (warm paper-white). `.app-shell` is `transparent` to let it through. Replaced the old messy multi-layer radial blob approach. Auth/welcome pages unaffected (full-screen overlays). Do NOT add radial blobs or textures — they clash with the solid topbar. See [[global-gradient-background]] in memory.
- **City list page continent grouping** (2026-07-06): City list page (`city/index.js`) fetches `/city/lists` API (139 cities), then groups by continent using `AREA_TO_CONTINENT` mapping from home page. The API returns `{total, list}` with `area_name` field per city — must extract `res.data.list`, NOT treat `res.data` as array. Continent tabs in order: 亚洲→欧洲→北美洲→南美洲→非洲→大洋洲. Uses `card-grid-2` (2 columns). Fallback empty state with retry button for API failures. See [[home-page-city-continents]] in memory.
- **City detail page design** (2026-07-06): Redesigned with 4-column grid (`.city-content-grid`), smaller images (100px height), and two-level classification. **一级分类**: `.ds-tabs` underline tabs (概覽/導遊/景點/餐廳/購物/票務/住宿/交通/設施/活動, matching Flutter order). **二级分类**: `.ds-type-tab` pills with **「全部」as default** (`subTabIndex: -1` means no sub-category filter). Responsive: 4 cols→3 cols (≤860px)→2 cols (≤480px). Image height: 100px→90px→80px. Container: `ds-container-1280`. **Activity API fix**: activity type uses `category_id` parameter, NOT `type_class_id` (all other types use `type_class_id`). See [[city-detail-page-design]] in memory.
- **Cross-navigation links** (2026-07-06): All detail pages link to related entities — clicking a city name anywhere navigates to city detail, clicking an author/guide name navigates to guide detail. Guide detail → city (via `guide.city_id`), News detail → guide (via `news.user.guide_id`) + city (via `news.user.city_id`), Common/Company detail → city (via `item.city_id` or route query). City names styled in primary color when clickable. List APIs within city context don't return `city_id` (already filtered), so no cross-links needed in city-internal lists. See [[cross-navigation-links]] in memory.
- **News/Message/Mine page redesign** (2026-07-06, v2 refresh 2026-07-16): **News** → `.news-card-v2` with avatar header (`.nc-header` + `.nc-avatar` container + `.nc-title` + `.nc-desc`). ⚠️ `.nc-avatar-img` MUST be wrapped in `.nc-avatar` (36×36px container); without it, images render at natural size. **Messages** → `.card` > `.msg-item` with `.msg-icon` (ALL SVG, no emoji! use `:style="{ background: item.bg }"` for per-item colors), `.msg-body`, `.msg-count`, `.msg-arrow`. **Mine** → `.profile-card-v2` (pc-avatar, pc-info, pc-name, pc-id, `.badge-guide`/`.badge-company`/`.badge-vip`), `.stats-row-v2` + `.stat-card`, `.menu-card` + `.menu-item-v2` (mi-icon, mi-label, mi-arrow). See [[v2-redesign-patterns]] in memory.
- **SPA architecture confirmed**: SPA is the correct choice for this project (not multi-HTML). All content is behind login wall so SEO is irrelevant. The SPA advantages — no-refresh navigation between 69 routes, shared topbar/design-system, in-memory UserStore/ConfigStore — outweigh the CDN component registration pitfalls. See [[spa-architecture-decision]] in memory.
- **Comprehensive bug scan (2026-07-07)**: Full project scan found 62 bugs across 53 frontend + 9 backend files → **all 62 fixed (2026-07-07)** in 4 rounds (5 critical / 13 high / 29 medium / 15 minor). Report at `bug-report-2026-07-07.md` in project root. See [[bug-scan-2026-07-07]] in memory.
- **i18n reactivity**: I18n object MUST be wrapped in `Vue.reactive()` and `I18n.init()` MUST run before `app.mount('#app')`. Otherwise locale changes don't trigger re-renders and first render always uses default `zh-CN`. See [[i18n-reactivity]] in memory.
- **File upload pattern (blob URL trap)**: When previewing local files with `URL.createObjectURL()`, you MUST also store the `File` object itself. The blob URL is only for preview — it cannot be uploaded to the server. On submit, upload the stored File objects individually, then collect server URLs. Also, revoke old blob URLs with `URL.revokeObjectURL()` in `beforeUnmount` to prevent memory leaks. See [[file-upload-blob-pattern]] in memory.
- **Timer cleanup**: Every `setInterval` / `setTimeout` MUST store its handle on the component instance (`this._timer`) and be cleared in `beforeUnmount`. Uncancelled timers on unmounted components cause memory leaks and console errors. See [[timer-cleanup]] in memory.
- **CSS constraints**: (1) `font-weight` values must be multiples of 100 — non-standard values like 530/650 render inconsistently across browsers; (2) All `var(--xxx)` references must match variables defined in `variables.css` — typos like `--color-text-primary` vs actual `--color-primary-text` silently fall back to browser defaults; (3) z-index values should use centralized variables, not raw numbers. See [[css-constraints]] in memory.
- **API URL naming**: API URL constant names in `urls.js` MUST match the business object they operate on. Never use `messageUnFollowShop` to unfollow a user, or `guideRejectReserve` to mark a booking as completed. Wrong endpoint names cause silent incorrect behavior that is hard to debug.
- **Topbar visibility**: The `showTopBar` computed in `AppShell` must list ALL auth-related routes (not just `/login`, `/register`). Missing `/forget-password`, `/verify-code`, `/password-input` — users see nav tabs on auth pages.
- **API response field names**: API returns snake_case keys (`guide_type`, `city_id`, `first_picture`). The Web frontend's `ApiProvider` does NOT transform key names — access fields exactly as the API returns them. Never use camelCase (`guideType`, `cityId`) to access API response data. JavaScript silently returns `undefined` for missing keys, making these bugs invisible (no errors, just empty/filtered-out data). **Always verify with `curl`** when unsure about an API response format. See [[api-snake-case-keys]] in memory.
- **Router parameter naming**: When passing query params between pages (e.g., search keyword), define the param name as a shared constant. Mismatches like `?keyword=` vs `query.q` cause silent data loss on navigation.
- **Web-Flutter data parity** (audited 2026-07-07, updated 2026-07-07): 15 differences found between Web and Flutter data display. Key gaps FIXED: (1) Web lacks city detail authorization check for non-guide users, (2) ~~city list continent grouping is client-side hardcoded~~ → FIXED: now server-driven via `getContinentsList` API with area sub-filtering, (3) guide cards missing `city_name`, (4) info cards missing `user_avatar`/`guide_type`/`pictures`/`created_at`, (5) `have_vehicle`/`vehicle_rent` type mismatch (`=== 1` vs `String?`). See [[web-flutter-data-comparison]] and [[city-list-server-driven]] in memory.
- **Guide feature parity** (audited & fixed 2026-07-07, realigned 2026-07-08): Full Flutter-Web guide feature comparison. CRITICAL fix: created `publish-city-form.js` (city creation/editing form, 14 fields + 3-level cascade + 6-image upload). HIGH fixes: profile menu navigation (3 broken links), publish form expansion (category selectors, phone/email/website/tickets/images). **2026-07-08 realignment**: Removed Web-only features not in Flutter — publish content delete buttons (Flutter `canDelete: false`), booking list inline confirm/reject, booking status filter tabs, 「申請已有城市」panel (replaced with VIP gate → form navigation). Fixed guideCityList API data format (flat array vs wrapped). **2026-07-08 UI realignment**: Publish page (`publish.js`) and publish-city page (`publish-city.js`) card designs fully rewritten to match Flutter — type-specific fields, status colors, unread dots, rejection reasons, cover images with overlays, operate bars, FABs, pill-style tabs. Delete on city cards limited to `auditStatus == 2` only (matching Flutter). See [[guide-feature-parity-2026-07-07]] and [[flutter-web-feature-parity]] in memory.
- **Member center page (會籍中心)** (rewritten 2026-07-08): The `/vip` page was completely rewritten to match Flutter `member_center` — it's a **paid guide/merchant membership subscription page**, not a generic "VIP lounge". Key changes: (1) Top section — user info card with avatar, identity badge (guide/company), VIP name badge, membership expiry status (NOT dark gradient + emoji); (2) Products — selectable card grid (2 cols guide / 3 cols company) with 月/年 tags, using a unified 「立即訂閱」 button (NOT per-plan buttons); (3) Benefits — dynamic from `vipAbility` API (NOT hardcoded emoji); (4) Agreement links above subscribe button. **Critical API parsing fix**: `/vip/guide` and `/vip/company` return flat arrays `[{id, name, ...}]` — use `Array.isArray(d) ? d : (d.list || d.data || [])` defensive parsing (NOT `data?.list || data?.data` which always returns `[]` for arrays). **vipExpired bug**: Must split into `vipExpiredDate` (display string) and `isVipExpired` (boolean: `ts < Date.now()/1000`). **UserStore method**: `getProfile()` not `fetchProfile()`. Integral icon: `fotos/O.png` → `frontend/images/icon-integral.png`. See [[member-center-page]] in memory.
- **VIP gate pattern**: Guide publishing features require VIP membership for NEW content only, not editing. Gate in template: `v-else-if="!isEdit && !UserStore.isVip"`. `UserStore.isVip` computed checks `vip_type > 0 && vip_expiration_time > 0` (paid) OR `vip_free === 1 && vip_free_day > 0` (free). Aligns with Flutter `VIPCheckUtils.check()` called before navigating to publish forms. Editing existing content bypasses VIP check — matches Flutter behavior.
- **Draft save/restore pattern**: Publish forms save draft to `localStorage` keyed by type (e.g., `publish_attraction_draft`). Save in `beforeUnmount` when `!isEdit && !success`. Check in `init()` after determining edit mode. Clear on success. Draft includes all `form` fields + picture URLs (not File objects — those can't be serialized). City form uses same pattern with key `publish_city_draft`.
- **Three-level cascade selector (continent→area→country)**: Uses `getContinentsList` API with `parent_id` param: `parent_id=0` returns continents, `=<continent_id>` returns areas, `=<area_id>` returns countries. Selection resets downstream selectors and their values. Edit mode: after loading saved IDs, cascade-fetch each level to populate option lists.
- **Publish form factory pattern**: `createPublishPage(typeKey)` generates 5 type-specific forms from one factory. `PUBLISH_TYPES[typeKey].has` config object controls which fields render via template literal `${f.fieldName ? 'true' : 'false'}` in `v-if`. This avoids 5 separate page files while supporting different field sets per content type.
- **JS block comment glob trap**: `/* */` block comments MUST NOT contain `*/` character sequence — it prematurely closes the comment. Common culprit: glob patterns like `publish_*/controller.dart`. Fix: use `publish_<type>/controller.dart` or `//` line comments. Use `node -c <file>` to catch this. See [[js-block-comment-glob-trap]] in memory.
- **City list page server-driven** (refactored 2026-07-07): Replaced client-side `AREA_TO_CONTINENT` hardcoded grouping with server-driven architecture: (1) `getContinentsList?parent_id=0` → continents, (2) `getContinentsList?parent_id=<id>` → areas, (3) `cityList?continents_id=X&area_id=Y` → cities. Area sub-filter pills within each continent tab. Cards: 4-column grid, 1:1 aspect ratio, bottom gradient overlay, minimal underline-style continent tabs. See [[city-list-server-driven]] in memory.
- **City detail publish FAB** (added 2026-07-07): Floating action button on city detail page for guides to publish content. Visible when user is guide on tabs: 景點→`/publish/attraction`, 交通→`/publish/transportation`, 設施→`/publish/facility`, 活動→`/publish/activity`. FAB visible for ALL guides (not just VIP); VIP gate checked on click with redirect to `/vip`. Matching Flutter `CityDetailPage.floatingActionButton`. See [[city-detail-publish-fab]] in memory.
- **City list publish city entry** (added 2026-07-07): Two entry points for guides to add cities: (1) prominent solid primary button at top-right of city list page, (2) entry via profile menu "我的城市". Both gate VIP on click → redirect `/vip` if not VIP. Matching Flutter `CityPage` FAB.
- **Search API response format** (fixed 2026-07-07): `/common/homeSearch` returns a **flat array** where each item has `data_type`: 1=city, 2=guide, 3=content. Must filter by `data_type` to group results. The API does NOT return `{city: [], guide: [], content: []}` structure. See [[search-api-flat-array]] in memory.
- **UserStore identity getters** (fixed 2026-07-07): `isGuide`/`isEnterprise`/`isUser` must use `Number(this.userInfo?.identity)` — the API returns identity as a string. All other pages use `Number(profile.identity) === 2` pattern; UserStore was the only place using strict `=== 2` which fails for string `"2"`. See [[userstore-identity-type-fix]] in memory.
- **City card overlay redesign** (2026-07-07): Changed from top-aligned gradient (`to bottom`) to bottom-aligned (`to top`), matching Flutter design. Name + area badge side-by-side in `.city-name-row`, english name below. Text: white with subtle shadow, no heavy background. CSS in `components.css` affects both home page and city list page. See [[city-list-server-driven]] in memory.
- **V2 card class override** (2026-07-16): The v2 `.card` definition (components.css line ~3205) overloads the original (line ~1156). Key difference: v2 `.card` has **NO padding** (original had `padding: var(--spacing-lg)`), and adds `box-shadow: var(--shadow-card)` + `border: 1px solid var(--color-border)`. When using `.card`, add explicit padding if needed or wrap content in a padded child like `.empty-state-v2` (which has `padding: 64px 24px`). See [[v2-redesign-patterns]] in memory.
- **V2 section headers** (2026-07-16): Replace old `.section-header`/`.section-header-left`/`.section-accent`/`.section-title`/`.section-subtitle`/`.section-more` patterns with `.sec-head` > `.sec-head-title` + `.sec-head-more`. The `.sec-head` class provides: flex row, bottom border, 20px bottom margin. `.sec-head-title` uses serif font at 22px.
- **PHP API proxy cache httpCode bug** (fixed 2026-07-16): In `public/index.php`, the cache-hit path was missing `$httpCode = 200;`. This caused `http_response_code($httpCode)` to receive undefined, PHP cast it to 0, and browser `fetch()` could treat HTTP 0 as a network error — silently returning no data. Always set `$httpCode = 200;` in the cache-hit branch. Clear cache after fixing: `rm -rf storage/cache/api-proxy/*.cache`. See [[php-proxy-cache-httpcode]] in memory.
- **Template method existence check** (2026-07-16): Always verify that every function/method referenced in Vue templates actually exists. Example: v2 news cards used `formatRelativeTime(info.created_at)` but the function doesn't exist (correct name is `timeAgo`). Vue 3 emits a console warning and renders empty string. Check with `grep -rn "FunctionName" frontend/` before committing.
- **API response cache lifecycle** (2026-07-16): The PHP proxy caches GET responses to `storage/cache/api-proxy/` with per-endpoint TTLs (2 min default, 30 min for `/common/config`, 10 min for `/common/getContinentsList`, 5 min for `/city/lists`). The frontend `provider.js` has an **additional** in-memory Map cache (1 min default). This means bug fixes may not take effect until both caches expire or are cleared. Always `rm -rf storage/cache/api-proxy/*.cache` + hard refresh browser after fixing API-related bugs.
- **Publish form city_id pre-fill** (2026-07-07): `publish/form.js` reads `$route.query.city_id` in `init()` to pre-select city dropdown when navigating from city detail FAB. Enables seamless "add content from city page" flow.