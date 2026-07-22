# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LuMo Guide（路盟）** — a professional platform for travel industry insiders (tour guides, merchants, content creators) built on Laravel 9. Slogan: **"路上有光，盟友相伴"**. Provides REST API for a Flutter mobile app, a Vue 3 SPA web frontend, and a Dcat Admin panel. The platform covers travel destinations (cities), tour guides, merchants/shops, information articles, reservations, Stripe VIP subscriptions, and a points/rewards system. **All users must log in and pass identity verification to access content.**

**All source code is plaintext** (2026-07-22: `app/Services/` decoded from swoole_loader, no longer requires the extension).

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

| What | Location | Pattern |
|------|----------|--------|
| **API Controllers** | `app/Http/Controllers/Api/` | `*Controller.php`, extend `BaseController` |
| **Base Controller** | `app/Http/Controllers/Controller.php` | All controllers extend this |
| **Services** | `app/Services/` | `*Service.php`, one per domain |
| **Models** | `app/Models/` | `*.php`, extend Eloquent `Model` or `Authenticatable` |
| **Enums** | `app/Enums/` | `*.php`, class constants only |
| **Request Validation** | `app/Http/Requests/` | `*Request.php`, one per form/endpoint |
| **Middleware** | `app/Http/Middleware/` | `*.php` |
| **Admin Controllers** | `app/Admin/Controllers/` | `*Controller.php` |
| **Admin Repositories** | `app/Admin/Repositories/` | `*.php` |
| **Admin Forms** | `app/Admin/Forms/` | `*.php` |
| **Background Jobs** | `app/Jobs/` | `*Job.php` |
| **Mail Classes** | `app/Mail/` | `*Mail.php` |
| **Exceptions** | `app/Exceptions/` | `*.php` |
| **Providers** | `app/Providers/` | `*ServiceProvider.php` |
| **Console Commands** | `app/Console/` | `*.php` |
| **Helper Functions** | `app/helpers.php` | Global PHP functions |
| **HTTP Kernel** | `app/Http/Kernel.php` | Middleware registration |
| **Console Kernel** | `app/Console/Kernel.php` | Schedule tasks |

### Routing

| What | Location |
|------|----------|
| API routes | `routes/api.php` |
| Web routes | `routes/web.php` |
| Admin routes | `app/Admin/routes.php` |
| Console routes | `routes/console.php` |
| Broadcast channels | `routes/channels.php` |

### Configuration

| What | Location |
|------|----------|
| Environment variables | `.env` (never commit) |
| Env example | `.env.example` |
| App config | `config/app.php` |
| Database config | `config/database.php` |
| Admin config | `config/admin.php` |
| JWT config | `config/jwt.php` |
| IM config | `config/im.php` |
| Other config | `config/*.php` |

### Database

| What | Location |
|------|----------|
| Migrations | `database/migrations/` |
| Seeders | `database/seeders/` |
| Factories | `database/factories/` |

### Translations

| What | Location |
|------|----------|
| Language strings | `lang/en/*.php` |

### Public Assets (Vendor / Compiled)

| What | Location | Notes |
|------|----------|-------|
| Dcat Admin assets | `public/vendor/dcat-admin/` | Managed by `php artisan admin:install` |
| Other vendor assets | `public/vendor/` | Published by `vendor:publish` |
| robots.txt | `public/robots.txt` | ✅ plaintext |
| Frontend CSS/JS | `public/css/` `public/js/` | Symlinks → `../frontend/css/` and `../frontend/js/` |

> `frontend/` is the single source of truth for all frontend files. `public/css` and `public/js` are symlinks so PHP's built-in server finds them via `server.php` while serving from ONE copy.

### Frontend Build Step (Production Bundling)

A zero-dependency esbuild build step bundles the 53 JS + 3 CSS files into 1 JS + 1 CSS for production, reducing HTTP requests from 57 → 4.

**How it works:**
- `frontend/build.mjs` reads `index.html` to determine the JS/CSS loading order
- Concatenates all files in that order, minifies with esbuild (`minifyIdentifiers: false` — critical, see below)
- Outputs content-hashed bundles to `frontend/dist/`
- `public/dist` is a symlink → `../frontend/dist` (same pattern as `public/css`, `public/js`)
- `routes/web.php` checks `app()->environment('production')` to serve `dist/index.html` vs `index.html`

**Usage:**
```bash
npm run build:prod         # Build production bundles
APP_ENV=production php artisan serve  # Test production mode
# Default (APP_ENV=local): individual files, no build needed
```

**Critical constraint — `minifyIdentifiers: false`**: esbuild MUST NOT rename identifiers. All 54 JS files use global variables (`HomePage`, `UserStore`, `ApiProvider`, etc.) and `router.js` references page components by these global names. If esbuild shortens variable names, the router breaks and the app renders blank.

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

# Frontend production build (bundles 53 JS + 3 CSS → 1 JS + 1 CSS via esbuild)
npm run build:prod
# Output: frontend/dist/ — served when APP_ENV=production, dev uses individual files
```

## Development Environment

- **PHP**: 8.3.21 via Homebrew at `/opt/homebrew/opt/php@8.3/bin/php`
- **Composer**: `/opt/homebrew/bin/composer`
- **Node.js**: v23.11.0 via Homebrew, npm 11.15.0
- **IDE**: PhpStorm 2026.1, Run Configuration uses `start.sh` (Shell Script type)
### Local Dev

- **Database**: Import `mysql -u root -p lumo_guide < database/lumo_guide_full.sql`
- **Start**: `/opt/homebrew/bin/php artisan serve --host=0.0.0.0 --port=8000` (or `./start.sh`)
- **Uploads**: User-uploaded files in `storage-uploads.tar.gz` (342MB, 1201 files); extracted by deploy.sh step 9
- **Deploy**: `./deploy.sh` — 11-step one-click deployment (tested in Docker container)

### PhpStorm Setup

Run Configuration (`start`) executes `start.sh` which starts `php artisan serve --host=0.0.0.0 --port=8000`.

## Frontend

### Web Frontend (SPA)

The web frontend is a **Vue.js 3 + Vue Router** single-page application served from `frontend/`. No build tools — all libraries loaded via CDN. The SPA replicates all functionality from the Flutter mobile app using the same backend REST APIs.

**Tech stack**: Vue 3 + Vue Router 4 (CDN), custom CSS (no framework), Fetch API, Google Fonts (Noto Serif SC for brand, ZCOOL KuaiLe for welcome Chinese, Caveat for welcome English).

**Design system**:
- Primary: `#666FFF` (indigo), Primary Dark: `#4A52E0`
- Page background: `#F9F9F6` (warm paper-white), Card: `#FFFFFF`, Text: `#162539` (ink) / `#6B7280` (muted) / `#9CA3AF` (faint)
- Accent colors: `#EF4444` (red), `#F97316` (orange), `#F59E0B` (amber), `#10B981` (green), `#8B5CF6` (purple)
- Border: `rgba(0,0,0,.06)`, shadows: `rgba(0,0,0,.03)`, Radius: 20px (large) / 12px (small)
- Display typeface: `Georgia, 'Noto Serif TC', 'Noto Serif SC', serif`; Body: system font stack
- Header: `#7C5CFF` solid purple, 52px, no box-shadow. Logo: `logo_lumoguide.png` (36px, white via CSS filter)
- Body gradient: `linear-gradient(180deg, #7C5CFF 0%, #7C5CFF 52px, #F9F9F6 400px)` — solid topbar → fade to paper-white

**Responsive**: 3 breakpoints — ≥861px (32px padding) / ≤860px tablet (16px) / ≤480px mobile (12px). Container classes: `.ds-container-600` (forms/lists), `.ds-container-640` (messages/addresses), `.ds-container-760` (detail/articles), `.ds-container-960` (galleries), `.ds-container-1280` (wide dashboards). `.ds-page-wrapper` (max-width 1280px, auto margin) for tab pages.

**Auth pages**: Full-screen indigo gradient + centered white `.auth-card` (max-width 400px, radius 20px) + full-rounded inputs (radius 100px). Welcome page uses splash animation (characters write on via clip-path, 2s pause, auto-redirect). Full-screen pages (Welcome, Photo Viewer, Web View) are not constrained by `.ds-page-wrapper`.

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
- ⚠️ **Vue 3 CDN component pitfall**: Components registered via `components: {}` may not resolve in child templates — they render blank with no errors. ALWAYS inline templates in the parent component. Even `app.component()` global registration is unreliable in the CDN build. `app-topbar.js` is kept only as reference (template inlined in `app.js`).
- **Routing**: Hash-based (`#/home`, `#/city/detail?id=1`). Route params via `this.$route.params.id` and query via `this.$route.query.id`. Route changes watched via `watch: { '$route.params.id': handler }` for same-component navigation.
- **Top navigation bar**: Inline in `AppShell` template (`app.js`). Logo + 5 tabs (首頁/城市/資訊 + SVG icons for 消息/我的) + search + login/logout toggle. Hidden only on auth/welcome routes. `AppNav` and `AppHeader` are deprecated.

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

All 69 Web routes implemented, matching the 71 Flutter pages. Mobile-only features (IM chat via Tencent SDK, QR scanning, group chat) are not applicable to Web. 183 API endpoints defined in `urls.js` mirroring Flutter's `ApiUrl` class.

### Mobile Frontend Reference

The Flutter mobile app working copy is at `/Users/xuejingchen/Desktop/vscode/lumotrip/` (this project). The original reference source is at `/Users/guanpei/Downloads/LUMOGUIDE- Front/LUMOGUIDE-frontend/`. All API endpoints and data models are defined there — use as reference when building web pages. See `[[mobile-frontend-reference]]` in memory for full details.

## Server Connection (legacy — project now independent)

| Item | Value |
|------|-------|
| Cloud | Alibaba Cloud ECS (杭州) |
| Domain | easyname (DNS only) |
| IP | 47.76.27.105 |
| SSH user | root |
| SSH auth | password (see administrator) |
| Web root | `/www/wwwroot/lumo/public/` |
| MySQL DB | lumo_guide (MySQL 5.7.44, localhost:3306) |

**2026-07-22**: Codebase fully decoupled. All source code plaintext. Database dump + upload files included in repo. Use `./deploy.sh` on any Ubuntu server.

## Architecture

### API Layer (`app/Http/Controllers/Api/`)

All API controllers extend `BaseController`, which provides two response helpers:
- `$this->success(message, data, code)` → `{code, message, data}`
- `$this->error(message, code)` → `{code, message, data: []}`

Authentication: JWT via `tymon/jwt-auth` (config in `config/jwt.php`). Routes use `auth:api` middleware. The `User` model implements `JWTSubject`. TTL is set to 10080 minutes (7 days). Login sends email verification codes via Gmail SMTP.

**Route groups** (prefixes in `routes/api.php`):
- `auth` — public: login, sendCode, register, resetPassword
- `common` — public + auth: config, fileUpload, home/search, area/continent lookups, type/class lookups, systemContinents
- `user` — auth required: profile, addresses, reservations, guide/company applications, **JourneyWork CRUD** (journeyList/Detail/Create/Update/Delete), **JourneyTemplate** (templateList/Save/Delete)
- `city` — mixed auth: listing (includes `country_name`), detail, content by type (attraction/restaurant/shopping/accommodation/transportation/facility/activity/ticket), evaluations, follows
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

MySQL 5.7 (`lumo_guide`), **56 tables** in production (15 migration files produce 50 tables; 6 added manually). Migrations in `database/migrations/`.

### Database Dump Files

| File | Size | Content |
|------|------|---------|
| `database/schema.sql` | 66K | 56 tables exact structure from production mysqldump |
| `database/seed.sql` | 349K | 22 config tables with production data (admin, system_config, city_type, VIP plans, etc.) |
| `database/data.sql` | 1.2M | 20 user-content tables with production data (users, cities, guides, content, orders, etc.) |
| `database/lumo_guide_full.sql` | 1.6M | Complete production dump (reference copy) |

### 6 Tables Missing from Migrations (added directly to production)

`city_content_edit` (city content audit), `city_edit` (city audit), `system_country` (countries), `trip_days` (trip itineraries), `trips` (tour packages), `migrations` (Laravel tracking, auto-created).

Deploy order on new server: `schema.sql` → `seed.sql` → `data.sql`.

## Critical Rules

### Backend
- **All source code is plaintext** — Services decoded 2026-07-22. No special extensions required.
- **Admin panel**: at `/manage` (not `/admin`), set by `ADMIN_ROUTE_PREFIX=manage` in `.env`.
- **Stripe**: `.env` keys must be configured per deployment. Do not commit `.env`.
- **Response format**: All API responses are `{code: int, message: string, data: object/array}`.
- **Queue driver**: Redis (`QUEUE_CONNECTION=redis`).
- **Bug report**: 62 known bugs documented in `.claude/bug-report-2026-07-07.md` (4 rounds: critical→high→medium→minor).

### Frontend — Hard Pitfalls
- **Vue 3 CDN component pitfall**: NEVER create separate component files. Components registered via `components: {}` silently render blank in child templates. ALWAYS inline templates in the parent component. `app-topbar.js` is kept only as reference.
- **API response snake_case**: Access fields exactly as the API returns them (`guide_type`, `city_id`, `first_picture`). Never use camelCase — JS silently returns `undefined` with no errors.
- **i18n reactivity**: I18n MUST be `Vue.reactive()` and `I18n.init()` MUST run before `app.mount('#app')`.
- **File upload blob trap**: Store both the `File` object AND blob URL. Blob URLs are preview-only — upload File objects on submit. Revoke blob URLs in `beforeUnmount`.
- **Timer cleanup**: Every `setInterval`/`setTimeout` must store its handle on `this._timer` and be cleared in `beforeUnmount`.
- **CSS constraints**: `font-weight` must be multiples of 100. All `var(--xxx)` must match `variables.css` definitions. Use centralized z-index variables.
- **Topbar visibility**: `showTopBar` must list ALL auth routes (`/login`, `/register`, `/forget-password`, `/verify-code`, `/password-input`).

### Frontend — Design Patterns
- **Web-Flutter parity**: Web MUST match Flutter. No features that Flutter doesn't have. Use defensive parsing (`Array.isArray(d) ? d : (d.list || d.data || [])`).
- **Reuse existing styles**: Check `.filter-pills`, `.card-grid-*`, `.h-scroll`, `.ds-*` before writing new CSS.
- **VIP gate**: Required for NEW publish content, not edits. `v-if="!isEdit && !UserStore.isVip"`.
- **Draft save/restore**: Save form drafts to `localStorage` (keyed by type) in `beforeUnmount`. Restore in `init()`. Clear on success.
- **UserStore identity**: Use `Number(this.userInfo?.identity)` — API returns identity as a string.
- **JS block comments**: `/* */` must not contain `*/` (e.g. glob patterns). Use `//` line comments or `node -c <file>` to verify.

Detailed page-level patterns are in the memory system — query when working on specific pages.