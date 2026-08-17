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
| **Helper Classes** | `app/Helpers/` | Namespaced helper classes (e.g., `ChineseConverter`) |
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
12. **Is it a helper class (namespace)?** → `app/Helpers/` (PSR-4 autoloaded, `App\Helpers\*`)
13. **Is it a translation string?** → `lang/en/res.php` (for response messages) or create a new file in `lang/en/`

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

# Run tests (requires phpunit.xml — create one if missing)
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

**Design system v4** (2026-08-07, 極簡高科技風 bright light mode):
- Primary: `#666FFF` (indigo — **accent only**: navbar hover / active indicator / CTA buttons / tags), Primary Dark: `#4A52E0`
- Page background: `#F8FAFC` (雲霧白 mist-white), Card: `#FFFFFF` + 1px border `#E2E8F0` (slate-200), Text: slate scale — `#0F172A` (slate-900) / `#475569` (slate-600) / `#94A3B8` (slate-400)
- Accent colors: `#EF4444` (red), `#F97316` (orange), `#F59E0B` (amber), `#10B981` (green), `#8B5CF6` (purple)
- Border: `rgba(226,232,240,.8)` (ultra-fine low-key hairline), shadows: ultra-faint slate `rgba(15,23,42,…)`, Radius: 20px (large) / 12px (small)
- Display typeface: `Georgia, 'Noto Serif TC', 'Noto Serif SC', serif`; Body: system font stack
- Header (navbar): **glassmorphism** — `rgba(255,255,255,.8)` + `backdrop-filter: saturate(180%) blur(12px)`, 1px hairline `rgba(226,232,240,.8)` (replaces heavy shadow), 52px. Nav text `#334155` (slate-700). Logo: `logo_lumoguide_indigo.png` (white logo recolored to `#666FFF` via GD, since light navbar can't show the white version)
- Body gradient (home shell): `linear-gradient(180deg, #F0F2FA 0%, #F5F7FC 120px, #F8FAFC 100%)` — ultra-faint cool ambient → mist-white
- Body font-weight: `650` (global bold)

**Responsive**: 3 breakpoints — ≥861px (32px padding) / ≤860px tablet (16px) / ≤480px mobile (12px). Container classes: `.ds-container-600` (forms/lists), `.ds-container-640` (messages/addresses), `.ds-container-760` (detail/articles), `.ds-container-960` (galleries), `.ds-container-1280` (wide dashboards). `.ds-page-wrapper` (max-width 1280px, auto margin) for tab pages.

**Auth pages**: Full-screen indigo gradient + centered white `.auth-card` (max-width 400px, radius 20px) + full-rounded inputs (radius 100px). Welcome page uses splash animation (characters write on via clip-path, 2s pause, auto-redirect). Full-screen pages (Welcome, Photo Viewer, Web View) are not constrained by `.ds-page-wrapper`.

**CDN versions (pinned)**:
```html
<script src="https://cdn.jsdelivr.net/npm/vue@3.4.38/dist/vue.global.js"></script>
<script src="https://cdn.jsdelivr.net/npm/vue-router@4.3.3/dist/vue-router.global.js"></script>
```
> ⚠️ **Do NOT use unpkg CDN or `vue.global.prod.js`**. The production build's template compiler silently fails — `app.mount('#app')` returns `null` without error, DOM unchanged. jsdelivr dev builds work correctly. Also, `app.js` (which calls `app.mount()`) **MUST be the last `<script>` at end of `<body>`**, after `<div id="app">`. If placed in `<head>`, `#app` doesn't exist yet and mount fails silently.

Key frontend directories (69 routes, 53 JS + 3 CSS files):
- `css/` — `variables.css` (design tokens), `app.css` (layout/typography), `components.css` (`.ds-*` classes)
- `js/api/` — `provider.js` (Fetch wrapper, never throws), `urls.js` (183 API endpoints)
- `js/stores/` — `user.js` (auth/state), `config.js` (system config cache)
- `js/i18n/` — `zh-CN.js`, `zh-TW.js`, `en.js`
- `js/utils/` — `storage.js` (localStorage), `helpers.js` (timeAgo, imageUrl, debounce, etc.)
- `js/components/` — DEPRECATED: all components inlined in parent. `app-topbar.js` kept as reference only.
- `js/pages/` — one file per feature area: `home/`, `city/`, `common/`, `news/`, `search/`, `message/`, `mine/`, `address/`, `guide/`, `publish/`, `merchant/`, `integral/`, `vip/`, `booking/`, `misc/`

**Architecture patterns**:
- **API**: `ApiProvider.get/post(path, data)` → always returns `{success, code, message, data}`. JWT automatically attached from `Storage.token`. Never throws — matches Flutter's `ApiResult` pattern. In local dev (`APP_ENV=local`), API proxy in `public/index.php` forwards `/api/*` to `https://api.lumoguide.com` so the frontend SPA works without a local database. On production, requests are handled by Laravel normally.
- **Auth**: `UserStore` (Vue.reactive) manages token + profile. Login stores credentials in localStorage under keys matching Flutter's `StorageStone` (`token`, `user_number`, `user_sig`, `user_info`). 401 responses trigger logout redirect. Route guard in `router.beforeEach` checks `meta.requiresAuth`. Profile refetched via `UserStore.fetchProfile()` after edits.
- **i18n**: Keys are Traditional Chinese characters (matching Flutter). `I18n.t('首頁')` returns locale-appropriate text. Language persisted to localStorage. Switchable via Settings page.
- **Pages**: Each page is a Vue Options API component definition object (`{template, data, methods, mounted}`). Multiple related components per file (e.g. `pages/city/detail.js` contains `CityDetailPage`, `pages/mine/extra.js` contains 11 components). Files loaded via `<script>` tags in `index.html` — order matters: dependencies must load before dependents.
- **Component resolution**: Shared components (`AppHeader`, `LoadingSpinner`, `EmptyState`) are registered on the root Vue instance's `components` option. Vue 3 resolves them through the parent chain via `<router-view>`, so they're available in all route components without `app.component()` global registration.
- ⚠️ **Vue 3 CDN component registration pitfall**: Components registered locally on the root component via `components: {}` may NOT be resolved in child components' templates (e.g., a component registered on root but used inside `AppShell`'s template). This differs from Vue 3 SFC/build-tool behavior. If a component renders blank with no errors, the ONLY reliable fix is to **inline the template HTML directly in the parent component.** Do NOT create separate component files — even `app.component()` global registration is unreliable in the CDN build. If a component renders blank: **inline the template HTML directly — do NOT create separate component files.** The `app-topbar.js` file is kept only as reference (marked `[REFERENCE]` / `⚠️ NOT USED at runtime`), with the actual template inlined in `app.js` AppShell. **Never repeat this mistake.** See [[vue3-cdn-component-pitfall]] and [[web-standard-layout-patterns]] in memory.
- **Routing**: Hash-based (`#/home`, `#/city/detail?id=1`). Tab bar shown only on 5 main routes; hidden on sub-pages (matches Flutter push navigation). Scroll position resets on navigation. Route params via `this.$route.params.id` and query via `this.$route.query.id`. Route changes watched via `watch: { '$route.params.id': handler }` for same-component navigation. `document.title` updated in `router.afterEach` via `I18n.t(to.meta.title)` — every route's `meta.title` doubles as the i18n key for the page title.
- **Top navigation bar**: Built inline in `AppShell` template (`app.js`). Shows full logo image (`logo_lumoguide_indigo.png`, 36px), 5 tabs (首頁/城市/資訊/🔔/👤) left-aligned, 🔍 search button on right, 🚪 login/logout toggle on far right. **v4 極簡高科技風 glassmorphism**: `rgba(255,255,255,.8)` + blur(12px), `#666FFF` on hover / active pill / 2px active indicator bar at navbar bottom edge. Always in 'tabs' mode on every page (back mode removed). Hidden only on `/welcome`, `/login`, `/register`, `/forget-password`, `/verify-code`, `/password-input`. Deprecates both `AppNav` and `AppHeader` components.
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
// Resolve SPA index — bundled dist in production, individual files in dev
$resolveSpaIndex = function () {
    if (app()->environment('production')) {
        $dist = base_path('frontend/dist/index.html');
        if (file_exists($dist)) return $dist;
    }
    return base_path('frontend/index.html');
};

// Root route serves SPA shell
Route::get('/', fn() => response()->file($resolveSpaIndex()));

// Deep link bridge pages — open app or fallback to app store
Route::get('/share', fn() => response()->file(base_path('frontend/share.html')));
Route::get('/share.html', fn() => response()->file(base_path('frontend/share.html')));
Route::get('/invite.html', fn() => response()->file(base_path('frontend/invite.html')));

// Protocol pages (Blade views) — must be before SPA catch-all
Route::get('/protocol/{type}', function ($type) {
    $content = systemConfig($type);
    if (!$content) abort(404);
    return view('protocol', ['content' => $content]);
});

// SPA catch-all — admin prefix read dynamically from config (not hardcoded)
Route::get('/{any}', fn() => response()->file($resolveSpaIndex()))
    ->where('any', '^(?!api|' . config('admin.route.prefix', 'admin') . ')[^.]*$');
```
This ensures `/api/*` (mobile app), `/manage*` or `/admin*` (admin panel), and static files (`/css/...`, `/js/...`) are unaffected. Protocol pages (`/protocol/user`, `/protocol/privacy`) render Blade views with system config content, or 404 if config not found. `share.html` and `invite.html` are standalone deep-link bridge pages served before the SPA catch-all.

> ⚠️ **`public/index.html` sync**: `public/index.html` is served directly by Nginx (it's in the web root) and bypasses Laravel entirely. `frontend/index.html` is served by the PHP dev server via the catch-all route above. Both are SPA shells and **must be kept in sync**. The current divergence (viewport meta, fonts, script loading) means users hitting different entry URLs may get different page behavior.

**69/69 routes implemented** (100%). See `plan.md` for full details.

### App-Web Feature Parity

The web frontend replicates all Flutter mobile app features feasible in a browser. 69 Web routes = 71 Flutter pages (minus Chat/IM, QR scanning, group chat — mobile-only). All features aligned as of 2026-07-06 audit.

### Mobile Frontend Reference

Flutter app at `/Users/xuejingchen/Desktop/vscode/lumotrip/`. Use as reference for API endpoints and data models when building web pages.

## Architecture

### API Layer (`app/Http/Controllers/Api/`)

All API controllers extend `BaseController`, which provides two response helpers:
- `$this->success(message, data, code)` → `{code, message, data}`
- `$this->error(message, code)` → `{code, message, data: []}`

Authentication: JWT via `tymon/jwt-auth` (config in `config/jwt.php`). Routes use `auth:api` middleware. The `User` model implements `JWTSubject`. TTL is set to 10080 minutes (7 days). Login sends email verification codes via Gmail SMTP.

**Route groups** (prefixes in `routes/api.php`):
- (root) — public: `health` (health check), `data/{lang}` (i18n data export)
- `auth` — public: login, sendCode, register, resetPassword
- `common` — public + auth: config, fileUpload, home/search, area/continent lookups, type/class lookups, systemContinents, guideList (all guides by continent), merchantList (all merchants), shareQrcode (auth-required PNG QR code for deep-link sharing)
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

Business logic is extracted into service classes — one per domain (`AuthService`, `CityService`, `GuideService`, `CompanyService`, `InformationService`, `IntegralService`, `UserService`, `VipService`, `MessageService`, `CommonService`, `TripService`). API controllers call services rather than models directly.

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

### Company Audit & Auto-Create Shop (2026-07-26)

**Entry point**: `app/Admin/Repositories/Company.php` `update()` — NOT the Controller. Admin approval triggers a chain of effects:

1. Mark `is_finish = 1`, `audit_time = now`
2. If `CompanyEdit` pending, overwrite company fields with edit data
3. Sync Tencent IM nickname
4. Award auth points, send system messages
5. Grant default VIP company membership (30-day free trial from `vip_company` id=1)
6. Update user: `vip_type=2`, `identity=3`, `company_id`, `vip_company_auth` JSON
7. **Auto-create first shop** via `autoCreateFirstShop()` — copies company data into a `CityContent` record
8. Dispatch `VipExpiredJob` delayed 30 days

**`business_type` → `type_id` mapping** (supports both S2T/T2S):
`景點/景点→1`, `餐廳/餐厅→2`, `購物/购物→3`, `住宿→4`, `票務/票务→8`

**Shop data copied**: name, address, phone, email, website, introduction→introduce, picture JSON→pictures+first_picture. `city_id`/`continents_id`/`area_id` from company's city. `audit_status=1`, `is_finish=1`, `status=1`, `publisher_type='company'`.

**Graceful skip** if business_type not in map, type_class_id missing, or city not found.

**Image URL fix (2026-08-01)**: `autoCreateFirstShop()` now checks pictures for relative paths (starting with `/storage`) and prepends `config('app.url')`. Company `picture` field may have relative paths from uploads during `config:cache` windows. Without this fix, auto-created shop images would have broken URLs.

**Backfill missing shops**: Companies approved before this feature was deployed (2026-07-26) have `is_finish=1` but no auto-created shop — the method is `private` and only triggers on first approval. Three companies (4, 7, 8) were backfilled on 2026-08-01. To backfill more, replicate the logic or make the method public temporarily.

**Related**: `app/Mail/AuditMail.php` (was missing — created 2026-07-26, caused all content uploads to fail), [[company-audit-auto-create-shop]].

### Admin Menu Merge — Unified User Management (2026-07-26)

**Menu restructured**: 用戶管理 + 導遊管理 + 商家管理 merged into a single tabbed page at `/manage/users` with three tabs: 全部用户 / 導遊 / 企業.

**New menus created**:
- **訂單管理** (ID 37): 預約管理 (moved from 商家) + 會員訂單 (moved from 會費)
- **分類管理** (ID 38): 導遊類型 + 城市類型 + 城市類型分類 + 資訊分類 + 積分商品分類 (all type configs consolidated)

**Deleted**: 導遊管理(14), 導遊列表(26), 商家管理(16), 商家列表(34)

**Implementation**: `app/Admin/Controllers/UserController.php` rewritten — `grid()` dispatches to `userGrid()` / `guideGrid()` / `companyGrid()` based on `?tab=` query param. Guide/Company tabs use `setResource('guide')` / `setResource('company')` so audit quick-edit actions still route to original GuideController/CompanyController. Original controllers and routes **preserved** for audit workflow.

**Badge counts** (`bootstrap.php`): ID 30 (用戶管理) = guide pending + company pending combined.

**User model**: Added `guide()` and `company()` relations.

### Auto-Delete Rejected Content (2026-07-26)

**`app/Console/Commands/CleanRejectedContent.php`** — daily scheduled command:
- **Day 4** after rejection: sends system message warning "3天后自动删除"
- **Day 7** after rejection: hard deletes record + associated `*Edit` record

**Migration**: `2026_07_26_000001` — added `reject_notified_at` column to `city_content` and `city` tables (prevents duplicate notifications).

**Manual delete**: Rejected content (`audit_status == 2`) shows a row delete button in both `CityContentController` and `CityController`. Both override `destroy()` to also clean up `*Edit` records.

**Schedule** (`Kernel.php`): `$schedule->command('clean:rejected-content')->daily()`

**Cron required**: Must run as `www` user (`crontab -u www -e`): `* * * * * /www/server/php/80/bin/php /www/wwwroot/lumo/artisan schedule:run >> /dev/null 2>&1`

### Email Verification Code Debugging (2026-08-01)

**How verification codes work**:
1. `POST /api/auth/sendCode` → `AuthService::sendCode()` generates 6-digit code
2. `Mail::to($email)->queue(new SendCodeMail($code))` → dispatches to Redis `emails` queue
3. `Cache::put("verification_email_{$email}", $code, 600)` → caches code for 10 min (`CACHE_DRIVER=file`)
4. Queue worker (cron every minute) picks up job, sends via `smtp.easyname.com:465`
5. User enters code → `POST /api/auth/verifyCode` → compares against cache

**AuthService fixes (2026-08-01)**:
- **Error logging added** to all catch blocks (`sendCode`, `sendSmsCode`, `resetPassword`) — was silently swallowing errors
- **Email format validation** — `filter_var($email, FILTER_VALIDATE_EMAIL)` added before queuing, catches invalid emails early
- **Success logging** — `Log::info("sendCode: code generated and queued for {$email}, type={$type}")` for audit trail

**Debugging "not received" checklist**:
1. Check spam/junk folder (most common cause — `no-reply@lumoguide.com` via easyname may have poor deliverability vs old Gmail)
2. Check `storage/logs/laravel-*.log` for `sendCode:` entries (confirms code was generated)
3. Check `failed_jobs` table for SMTP errors (e.g., "550 Recipient not found")
4. Verify queue: `redis-cli LLEN "queues:emails"` (should be 0 or low)
5. Verify cron: `grep queue:work /var/log/syslog`
6. Test SMTP directly: `Mail::raw('test', fn($m) => $m->to('user@example.com'))` in tinker

### Draft Save for Multi-Step Forms (2026-07-31)

Multi-step certification forms auto-save drafts to `localStorage`. Pattern from `publish/form.js`:

- **Guide certification** (`guide/certify.js`): key `guide_certify_draft`, watches `form`, `selectedLangs`, `selectedTypes`, `photoPreview`, `carPics`
- **Company entry** (`merchant/entry.js`): key `merchant_entry_draft`, watches `form`, `selectedTypes`, `storePics`

**Flow**: `watch` (deep, 400ms debounce) → `saveDraft()` → on re-entry: `checkDraft()` after `loadData()` → show prompt card → `restoreDraft()` or `clearDraft()` → clear on submit success. Only saves serializable data (no File objects or blob URLs). Does not trigger in readOnly mode (approved/pending status).

### Publish Form Improvements (2026-07-26)

**Information publish** (`#/publish/information`):
- Replaced `name`/`name_en` fields with Flutter-matching fields: `title`, `class_id` (mapped from `type_class_id`), `content`, `look` (1=仅导游, 2=所有人)
- Payload maps `type_class_id` → `class_id` for API compatibility (`AddInformationRequest`)

**City publish** (`#/guide/publish-city-form`):
- Fixed cascade selector: `fetchContinents(parentId, target)` uses explicit `'continents'|'areas'|'countries'` target parameter (was broken by `this.form.area_id === parentId` logic)
- Added `longitude`/`latitude` fields to match Flutter app

**Draft auto-save** (both `publish/form.js` and `publish-city-form.js`):
- Deep `watch` on `form` + `pictures` with 400ms debounce auto-saves to localStorage
- Draft detection checks ALL text fields (not just `name`/`title`)
- On success: `localStorage.removeItem(draftKey)` — no more prompts

**Category loading** (`publish/form.js`): Fixed `res.data?.list` → `Array.isArray(res.data) ? res.data : (res.data?.list || [])` — `getInformationClass` returns array directly, not `{list: [...]}`.

**Error display** (`publish-city-form.js`): Validation errors shown below submit button with auto-scroll.

### Logo Sizing (2026-07-26)

`.topbar-logo-full` height is `40px` default with responsive scaling:
- Default (≥861px): 40px
- Tablet (≤860px): 34px
- Mobile (≤480px): 28px

### Flutter City Detail — Ticket Tab Missing (2026-08-01)

Flutter 手机端城市详情页看不到票務（type_id=8）内容，但 Web 端正常。**根因**：票務是后期新增类型，ID=8 不在 1-7 连续范围内，Flutter app 大概率硬编码了 `[1,2,3,4,5,6,7]` 漏掉了 8。

**验证过正常的部分**：后端 API `/city/ticket`、`cityClass`、`city_type` 表（id=8 name=票務）、图片文件、Web 端 `detail.js`。

**修复方向**：Flutter 项目 (`lumotrip/`) 城市详情页 tab 定义需包含 type_id=8。Web 端 tab 顺序参考（`frontend/js/pages/city/detail.js`）：概覽→導遊→景點→餐廳→購物→票務→住宿→交通→設施→活動，对应 type_id `[0,0,1,2,3,8,4,5,6,7]`。

文档：`docs/flutter-ticket-tab-missing.md`。See [[flutter-ticket-tab-missing]].

### Location / Longitude-Latitude Pattern (2026-07-27)

All coordinate inputs use a **single `location` field** in "latitude, longitude" format (Google Maps convention). The `longitude` and `latitude` columns are populated from this field on save.

| Layer | File | Implementation |
|-------|------|---------------|
| Admin City form | `CityController.php` | `$form->text('location')` + `saving` callback parses into `longitude`/`latitude` |
| Admin CityContent form | `CityContentController.php` | Same pattern. `CityContent` model has `getLocationAttribute` accessor that joins `latitude, longitude` for edit display |
| Web frontend | `publish-city-form.js` | Single `<input v-model="form.location">` — on submit, splits into `longitude`/`latitude` for the API |
| API | `GuideService::publishCity` | Still receives `longitude`/`latitude` separately (frontend splits on submit) |

**Format**: `纬度, 经度` (e.g., `48.86, 2.35`). The `saving` callback handles both full "lat,lng" and single-value inputs gracefully.

### 審核覆蓋清空經緯度 Bug（2026-08-05 修復）

**問題**：導遊提交城市審核後，審核通過時經緯度被清空。三層疊加根因：
1. **前端** `publish-city-form.js` 提交時初始 `longitude:''`/`latitude:''`，location 解析不出值（未填、全形逗號 `，`、空格分隔）就發**空字符串**；原解析只認半形逗號 `split(',')`
2. **後端** `GuideService::editCity` 的 `$data['longitude'] ?? null` 攔不住空字符串 → CityEdit 審核記錄存 `''`
3. **審核** `AuditCityForm::handle()` `foreach` 把 CityEdit **所有欄位逐欄覆蓋** city 表 → 空經緯度覆蓋清掉城市原有值；同時 `recommend`/`order`/`is_finish`/`status` 等管理字段也被用戶提交內容（全 0）覆蓋

**修復**（4 文件 + 構建）：
- `publish-city-form.js`：正則 `match(/-?\d+(?:\.\d+)?/g)` 提取數字解析（兼容全形逗號/空格/負數），**解析不出就省略字段**（不發空字符串）
- `GuideService::publishCity`：`!empty($data['longitude']) ? $data['longitude'] : null`（空→NULL 而非 `''`）
- `GuideService::editCity` 兩個分支：空值**繼承原城市值** `$city->longitude`；CityEdit 記錄同時寫入 `location` 列（`"lat, lng"` 格式，與管理後台一致）
- `AuditCityForm::handle()`：覆蓋循環**跳過管理字段**（`status, recommend, home_recommend, default_recommend, order, is_finish, is_read`）和**空值經緯度**（`longitude, latitude, location` 為 null/'' 時 continue）；`form()` 新增**經緯度顯示**（含修改前/後對比，管理員審核可核對）
- `AuditCityContentForm::handle()`：同根因，加空值經緯度跳過保護

**通用規則**：可選數值字段（經緯度等）前端**解析不出就不要發送**，後端用 `!empty()` 而非 `?? null` 判斷；審核覆蓋循環必須跳過管理字段和空值。測試數據已清理，PHP 修改已同步 lumo_test。

### Safari Vue 3 Reactive Getter Workaround (2026-07-27)

**Problem**: `Vue.reactive()` getters (e.g., `UserStore.isGuide`, `UserStore.isLogin`) may not trigger reactivity properly in Safari's JavaScriptCore engine. Computed properties that access these getters silently return stale values, causing UI elements (buttons, menus) to not render even when the user meets all conditions.

**Fix**: In page-level `computed` properties, access raw reactive properties directly instead of through getters:

```javascript
// BEFORE (broken in Safari)
isGuide() {
  return UserStore.isLogin && UserStore.isGuide;
}

// AFTER (works in all browsers)
isGuide() {
  const info = UserStore.userInfo;
  return !!UserStore.token && info && Number(info.identity) === 2;
}
```

**Pattern**: Access `UserStore.token` and `UserStore.userInfo` (plain reactive properties) directly. Never chain getter access (`UserStore.isGuide`, `UserStore.isLogin`) inside a `computed: {}` block. Template guards like `v-if="UserStore.isLogin"` are fine since Vue evaluates them differently.

**Identity checks**: Always use `Number(info.identity) === N` (not `info.identity === N`) since the API may return identity as a string. This applies to templates, computed properties, and store getters.

### Guide Certification — Resident City (2026-07-31)

When a guide applies for certification (`POST /user/applyGuide`), they can set a resident city (常駐城市):

- **Existing city** (`is_new_city=0`): sends `resident_city_id`
- **New city** (`is_new_city=1`): sends `new_city_name`, `new_city_name_en`, `new_city_continents_id/area_id/country_id`

Backend creates a `city` record with `audit_status=0` (pending) and stores `linked_city_id`. City dedup: checks `name + country_id` before creating.

**Audit linkage** (`app/Admin/Repositories/Guide.php`):
- Approval: `UPDATE city SET audit_status = 1 WHERE id = linked_city_id`
- Rejection: `UPDATE city SET audit_status = 2 WHERE id = linked_city_id`

**Migration**: `2026_07_31_000001_add_resident_city_to_guides.php` — adds 12 columns to both `guides` and `guide_edit` tables.

### Company Registration — Field Name Compatibility (2026-07-31)

`POST /user/applyCompany` uses `prepareForValidation()` in `ApplyCompanyRequest.php` to map incoming field names:

| Client sends | Mapped to | Notes |
|---|---|---|
| `license` | `documents_picture` | Flutter/web send individual image field |
| `type` (array) | `business_type` (string) | Web frontend fixed to send `business_type` |

This allows both old clients (Flutter sending `license`) and new clients (web sending `documents_picture`) to work.

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
- `escapeLike($value)` — escape `%` and `_` for safe LIKE queries
- `timeAgo($time)` — Chinese relative time formatting

### Chinese S2T/T2S Search

`App\Helpers\ChineseConverter` provides bidirectional Simplified ↔ Traditional Chinese conversion. `searchVariants('购物')` returns `['购物', '購物']`. All search queries in `CommonService` and `handleSearchData()` use `foreach ($variants as $v) { $query->orWhere('name', 'like', '%' . escapeLike($v) . '%'); }` to match both scripts. When adding new `WHERE name LIKE` queries on Chinese columns, apply this pattern.

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

### 預約拒絕模板（2026-08-07）

導遊/商家拒絕預約時可快速選擇專業多語言模板，而非手動輸入原因。

**資料存儲**：`system_config` mark=`reserve_reject_templates`，JSON 格式，三語（zh_TW/zh_CN/en），每語 4 個模板：
- `fully_booked` — 當日已滿
- `time_unavailable` — 時段無法配合
- `on_break` — 暫時休息中
- `out_of_scope` — 服務範圍不符

**API**：`GET /api/common/config` 新增 `reserve_reject_templates` 欄位回傳。`CommonService::config()` 已加入。

**前端**：從 config API 取模板 → 根據當前語言選對應列表 → 拒絕對話框顯示模板選擇器 + 可編輯文字區 → 選中模板自動填入 → 送出 `POST /guide/rejectReserve` 或 `POST /company/rejectReserve`

**現有 API 無需改動**：`rejectReserve` 的 `reason` 欄位即為模板文字。`reserveUserMessage()` 顯示 `"您的预约被拒绝:[reason]"`。

Flutter/Web 實施文檔：`docs/reserve-reject-templates.md`

### Share / Deep Link System (v6, 2026-08-07)

**QR 碼 URL 格式**：`https://lumoguide.com/share?c={inviteCode}&t={type}&i={id}`（2026-08-02 起。舊格式 `https://www.lumoguide.com/share.html?...` 僅向後兼容）。手機相機/掃碼器只識別 http(s) 鏈接，不識別自定義 scheme。

**域名架構**（Nginx，`/www/server/panel/vhost/nginx/lumoguide.com.conf`）：
- `lumoguide.com` 是完整站點（root = `/www/wwwroot/luomoguide`，與 www 同目錄），2026-08-02 由「純 301→www」改造
- 新 Let's Encrypt 證書：`/etc/letsencrypt/live/lumoguide.com/`（certbot webroot 申請，自動續期；注意 www 證書 SAN 不含 apex 域名）
- `.well-known` 不重定向 + `default_type application/json`（AASA 無擴展名必須 json。坑：`location ~ \.well-known` 先匹配時後面的 default_type location 永不生效，須寫在同一個 location 內）
- `/share`、`/share.html`、`/invite.html` 精確匹配直出（無 301 — Universal Links 要求）；其他路徑仍 301→www

**驗證文件**（`/www/wwwroot/luomoguide/.well-known/`）：
- `apple-app-site-association`：appID `FLVV24Q9HH.com.app.lumotrip`，paths `/share`,`/share/*`
- `assetlinks.json`：package `com.app.lumotrip`，**冒號分隔格式（2026-08-04 修復——無冒號格式被 Google 判定 `malformed cert fingerprint`，App Links 驗證全線失敗（掃碼不能直開 App 的根因之一）；改為 `5B:AC:AB:02:...:D5:79` 後 Google DAL API 驗證通過）**。⏳ **Play 上傳密鑰重置審核通過後需追加新指紋 `5F130901...9E9850`（同樣冒號格式）到 sha256_cert_fingerprints 數組**（2026-08-04 前端通知；新舊指紋共存，新舊 APK 都可驗證）。⚠️ 經驗教訓：Google 驗證器要求冒號格式

**share.html / invite.html（v6，2026-08-07）**：
- **國產瀏覽器修復**：非 Chrome 系 Android 瀏覽器（華為/小米/UC/QQ/百度/360/OPPO/vivo）的**自動觸發**改用 **iframe** 方式調用 scheme URL（取代 `window.location.href`），避免 scheme 失敗時導航到錯誤頁/空白頁導致 JS 計時器中斷。**按鈕點擊**保留 `location.href`（有用戶手勢時可靠）
- 增加 `pagehide` + `visibilitychange` 雙重監聽追蹤 App 是否已打開（`appOpened` 標記）
- 非 Chrome 瀏覽器超時從 2500ms 縮短到 1200ms（scheme 要嘛瞬間成功要嘛失敗）
- **冷啟動支持**：頁面載入時生成 16 位隨機 token → 寫入剪貼板（JSON: `{c, t, i, token}`）→ POST `/api/common/deferredLink` 上報服務端 → 下載 URL 帶 `?token=` 參數
- `invite.html` 已重寫，與 `share.html` 功能完全對齊（之前缺失自動打開、intent://、loading UI、/dl 下載分流）
- 文件位置：`/www/wwwroot/luomoguide/share.html` + `lumo/frontend/share.html`（兩處須保持同步）
- 同樣 `invite.html` 兩處副本已同步

**⚠️ App Links 衝突**：AASA/assetlinks 已配置 `/share` 路徑，iOS/Android 會攔截 `https://lumoguide.com/share?...` 直接打開 App。Flutter `DeepLinkService` 目前只處理 `lumoguide://share?...`（host=`share`），不處理 `https://lumoguide.com/share?...`（host=`lumoguide.com`）。**在 Flutter 修復 handler 之前，App Links 會導致暖啟動打開 App 但停留在首頁**（不導航到具體內容）。Flutter 修復見 `docs/flutter-cold-start-deeplink.md`。

**下載分發 `/dl`**（`/www/wwwroot/luomoguide/dl/index.php`）：
- UA + IP 自動分發：iOS→App Store（id6749853105）、Android+中國 IP→`/dl/app-release.apk`、Android+外國→Google Play、其他→`/share`
- 中國 IP 判斷：APNIC delegated 離線段表 `dl/cn_ipv4.txt`（8788 條合併為 4110 段）+ 二分查找；RFC1918 私有段按中國處理
- `dl/version.txt` 存版本號（現 1.0.6）；**`dl/app-release.apk`** 已上傳（153MB，2026-08-06）
- Google Play 鏈接附加 `&referrer=token%3D{token}` 用於冷啟動 InstallReferrerClient 匹配
- APK 響應頭（已配）：`Content-Type: application/vnd.android.package-archive` + `Content-Disposition: attachment`

**API `POST /user/bindInviter`**（auth:api，2026-08-02）：掃碼深鏈後補綁邀請關係
- 參數：`inviter_code`。錯誤：已綁定→`inviter_bind_repeat`、綁自己→`inviter_bind_self`、無效碼→`inviter_error`
- 成功：寫 `user_invite_log` + 給邀請人 `invite_user` 積分（與註冊邏輯一致）
- 實現：`BindInviterRequest` + `UserService::bindInviter` + `UserController::bindInviter` + `routes/api.php`

**配置**：`.env` `WEB_URL=https://lumoguide.com`（原 www.lumoguide.com）；`config/app.php` 新增 `'web_url'`；`shareQrcode`/`UserService` 的 `env('WEB_URL')` 已全部替換為 `config('app.web_url')`（2026-08-02）。

### Deferred Deep Link — 冷啟動延遲深度鏈接（2026-08-07）

使用者掃碼時 App 未安裝 → 下載安裝 → 打開 App 後自動恢復到分享的具體內容。

**數據流**：
```
share.html 載入 → 生成 16 位 token
  ├─ 寫入剪貼板：{"c":"CODE","t":"guide","i":"123","token":"abc123"}  ← 主通道
  ├─ POST /api/common/deferredLink（記錄 token+IP 到 DB）           ← 備用通道
  └─ 下載 URL：/dl?token=abc123
       ├─ Google Play → &referrer=token%3Dabc123                    ← Android 原生
       ├─ APK 直下 → IP+token 已在 DB
       └─ iOS → 靠剪貼板 + DB IP 備用
```

**Flutter App 啟動時三通道檢查**（按優先級）：
1. **InstallReferrerClient**（Android Play Store 原生） → token → `GET /api/common/checkDeferredLink?token=xxx`
2. **剪貼板** → 解析 JSON 取 token → 同上 API
3. **服務端 IP 匹配**（24h 窗口） → `GET /api/common/checkDeferredLink`（無參數）

**新增 API**（均在 `routes/api.php`，無需認證）：
- `POST /api/common/deferredLink` — 儲存 token + content_type + content_id + IP
- `GET /api/common/checkDeferredLink?token=xxx` — 查詢並消費（token 匹配優先，否則 IP 匹配）

**DB**：`deferred_deep_links` 表 — token(unique)、content_type、content_id、ip_address、inviter_code、consumed。Migration：`2026_08_07_000001_create_deferred_deep_links_table.php`

**覆蓋率**：Android Play Store ~99%、APK 直下 ~90%、iOS ~85%。綜合 ~95%。

Flutter 實施文檔：`docs/flutter-cold-start-deeplink.md`

### QR 碼資產管理（2026-08-07 清理）

**邀請 QR 碼快取**（`storage/app/public/user_invite/{id}.png`）：
- `UserService::index()` 生成時僅檢查檔案是否存在，舊 URL 格式的 QR 碼永久快取
- **2026-08-07 清理**：刪除全部 10 個快取檔案（9 個使用舊 `www.` 格式或相對路徑），下次請求時以正確 URL (`https://lumoguide.com/invite.html?code=X`) 自動重新生成

**下載頁 QR 碼**（`/www/wwwroot/luomoguide/QR-code.jpg`）：
- **2026-08-07 重新生成**：從 `https://www.lumoguide.com/invite.html?code=LSZ326Z`（舊域名+寫死個人碼）改為 `https://lumoguide.com/dl`
- `app-data.json` `qrImage` 從 base64 內嵌改為 `"QR-code.jpg"` 檔名引用
- `script.js` DEFAULT_DATA `qrImage` 同步更新

**SPA 下載頁 QR**（`public/images/download_ios_qr.png` / `download_android_qr.png`）：已驗證正確（iOS→App Store、Android→`/dl`）

**歷史（2026-07-24）**：`lumoguide://share` 自定義 scheme、App Store fallback、邀請碼 `c` 參數追蹤。API：`GET /api/common/shareQrcode?type=guide|city|content|trip&id=N`（auth required，返回 PNG）。Flutter 集成文檔：`docs/flutter-share-deeplink.md`；前端配合需求：`docs/deep-link-frontend-todo.md`。

## Key Integrations

| Integration | Config | Purpose |
|-------------|--------|---------|
| Stripe | `.env` STRIPE_* keys, `stripe/stripe-php` | VIP subscription payments, webhook at `/api/payment/webhook` |
| Tencent IM | `config/im.php`, SDK_APP_ID/SECRET_KEY in `.env` | Instant messaging for users |
| easyname SMTP | MAIL_* in `.env` | Verification codes (`SendCodeMail`), invoices, VIP expiry notices. Uses `smtp.easyname.com:465` SSL, `no-reply@lumoguide.com`. Previously Gmail (`zhouguanpei@gmail.com`). |
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
- **All source code is plaintext** (2026-07-22). No swoole_loader needed.
- **Admin panel** at `/manage` (not `/admin`), set by `ADMIN_ROUTE_PREFIX=manage` in `.env`.
- **Response format**: All API responses are `{code: int, message: string, data: object/array}`.
- **Queue driver**: Redis (`QUEUE_CONNECTION=redis`).
- **API parameter types**: PHP methods have strict types (`int $city_id`). Never send empty string `""` for numeric params — use `if (value) params.key = value` to omit empty values entirely. Route query params are always strings — use `parseInt()` before passing to APIs.
- **contentInfo API (`/city/contentInfo`)**: Requires ALL three params: `id`, `type_id`, AND `city_id`. Missing `city_id` returns error (not empty page — hard error). When linking to `#/detail/city_content`, always include all three query params. Response includes `is_reserve`: `0` for guide-uploaded content (no booking), `1` for company/merchant-uploaded content (booking available). Only types 1,2,3,4,8 (attraction/restaurant/shopping/accommodation/ticket) are reservable. Each call increments `view_count` on `city_content` — used for popularity sorting in merchantList.
- **Bug report**: 62 known bugs documented in `bug-report-2026-07-07.md` (all fixed).

### Backend — Security Rules (2026-07-24 security review)
- **File uploads**: MUST validate MIME type (whitelist: jpg/jpeg/png/gif/webp) and max size (10MB). File extension MUST be whitelisted as defense-in-depth. Uploaded files stored via `storage:link` are publicly accessible — never allow executable extensions.
- **LIKE queries**: ALWAYS escape user input with `escapeLike()` before using in LIKE patterns. Unescaped `%` and `_` wildcards allow bulk data extraction.
- **Error messages**: NEVER expose raw exception messages to API responses. Use generic `__('res.system_error')` in catch blocks. Log the real error server-side.
- **Login responses**: Return the same message for "account not found" and "wrong password" to prevent user enumeration.
- **Stripe webhooks**: Check `pay_status` before processing to ensure idempotency. Stripe may retry webhooks.
- **SSL verification**: NEVER disable `CURLOPT_SSL_VERIFYPEER` in production code.
- **Debug endpoints**: All debug/test routes MUST have `auth:api` middleware. The `/api/common/test` endpoint was secured 2026-07-24.

### Backend — Hard Pitfalls (2026-07-30)

- **`substr()` vs `mb_substr()` — CRITICAL**: ALWAYS use `mb_substr($str, 0, $len, 'UTF-8')` when truncating user content. `substr()` is byte-based and will slice multi-byte Chinese characters in half, producing invalid UTF-8 byte sequences (e.g., `\xE9\x81`) that MySQL rejects with "SQLSTATE[HY000]: General error: 1366 Incorrect string value". In `GuideService.php`, `informationAdd` correctly used `mb_substr()` but `informationEdit` used `substr()` — so creates worked but edits silently failed. Symptom: creates succeed, edits fail. Fix: grep for all `substr()` calls and replace with `mb_substr()`. See [[substr-mb-substr-encoding-bug]] in memory.

- **ALL catch blocks MUST log the actual exception**: Every `catch (Throwable $e)` in Service files MUST call `Log::error('methodName error: ' . $e->getMessage() . "\n" . $e->getTraceAsString())`. Without this, bugs are completely invisible — the `ApiException::report()` only logs WHERE the exception was re-thrown (the catch block line number), not the original error. In `GuideService.php`, only 3 of 12 catch blocks had logging before 2026-07-30; the other 9 silently swallowed the actual exceptions. This must never happen again — when adding a new try/catch to a Service, ALWAYS include error logging in the catch block.

- **Mail::queue() MUST be outside DB transactions**: If `Mail::queue()` throws inside a `DB::beginTransaction()`...`DB::commit()` block, the entire transaction rolls back and the user's data is lost. Move `Mail::queue()` AFTER the transaction commit/catch block, wrapped in its own try-catch. If mail fails, log it but don't fail the API response. The email is a notification — it's not critical to the operation.

- **`php artisan config:cache` DISABLES all `env()` calls in application code — CRITICAL**: After running `config:cache`, **EVERY `env()` call in Service/Controller/application code returns `null`/empty**. This is NOT a freeze — it's a complete shutdown. `config:cache` compiles all config files into a single cached array, and Laravel's `env()` helper is designed to only work during config bootstrapping. Once cached, `env('APP_URL')` returns `""`, `env('STRIPE_KEY')` returns `""`, etc. **You MUST NEVER use `env()` directly in Service or Controller code — always use `config()` instead.** After config:cache, if `.env` changes, you MUST run `config:clear` + `config:cache` to pick up changes. All `env('APP_URL')` in `CommonService`, `AuthService`, `GuideService`, `UserService` were replaced with `config('app.url')` (2026-08-01); `env('WEB_URL')` replaced with `config('app.web_url')` (2026-08-02, new `web_url` key in `config/app.php`). Remaining `env()` calls in Services/ (~12 instances: SDK_APP_ID, SECRET_KEY, STRIPE_KEY, AUDIT_EMAIL, APP_DEBUG) still need migration to `config()`. See [[app-timezone-upload-fix]] in memory.

- **Queue worker required for emails**: `Mail::queue()` dispatches to Redis but requires a queue worker to actually send. The worker runs via www user's crontab every minute. Without a running worker, emails pile up in Redis but are never delivered. Check with `ps aux | grep queue:work` and `redis-cli LLEN lumo_database_queues:emails`.

- **schedule:run cron required**: `Kernel.php` scheduled commands (`clean:rejected-content`, `member:expiry-remind`) only execute if the schedule:run cron runs every minute. Server must have BOTH entries in **www user's crontab** (`crontab -u www -l`), NOT root:
  ```
  * * * * * /www/server/php/80/bin/php /www/wwwroot/lumo/artisan queue:work --queue=emails,default --once --max-jobs=5 >> /dev/null 2>&1
  * * * * * /www/server/php/80/bin/php /www/wwwroot/lumo/artisan schedule:run >> /dev/null 2>&1
  ```
  These MUST run as `www` (not root) to avoid creating root-owned files that PHP-FPM cannot access.

- **`prepareForValidation()` for API field compatibility**: When mobile/web clients send different field names than what the backend expects (e.g., Flutter sends `license` but backend wants `documents_picture`), use `prepareForValidation()` in the FormRequest to map old field names BEFORE validation. This avoids breaking existing clients. Example in `ApplyCompanyRequest.php`: maps `license` → `documents_picture` when the latter is missing.

- **File upload error logging**: `CommonService::upload()` catch block now logs the actual exception. File upload failures (disk full, GD/compressImage errors, permission issues) were previously invisible — only a generic "System error" was returned. When debugging upload issues, check the Laravel log for `upload error:` entries.

- **`APP_TIMEZONE=Asia/Shanghai` MUST be set in `.env`**: Defaults to UTC if unset. Laravel calls `date_default_timezone_set('UTC')` on boot → `date('Ymd')` returns UTC date (previous day between 00:00-08:00 CST). `CommonService::upload()` uses `date('Ymd')` for upload directory names. If root cron creates the directory first (root:root 700), PHP-FPM (www) can't write → all uploads fail with `getimagesize(): Permission denied`. Both `.env` files updated 2026-08-01. See [[app-timezone-upload-fix]] in memory.

- **Crontab MUST run as `www` user, not root**: Root cron creates files/directories with `root:root` ownership that PHP-FPM (www) cannot read/write. This caused the `20260731` upload directory to have `drwx------ root root` permissions, blocking all uploads. Moved `queue:work` and `schedule:run` from root crontab to `www` user's crontab (2026-08-01). Use: `crontab -u www -e`. Both commands need full paths: `/www/server/php/80/bin/php /www/wwwroot/lumo/artisan ...`

- **Flutter Dart/3.10 uses `image` field name for file uploads**: The Flutter mobile app (Dart/3.10, starting ~July 28) sends files under the `image` field name, NOT `file`. `FileRequest` now accepts both via `required_without` rules, and `CommonService::upload()` resolves `$request->file('file') ?: $request->file('image')`. See [[flutter-image-field-name]] in memory.

- **`Company::AuditStatusArr`**: `Company` enum had `AuditStatus` but other enums (City, Guide) use `AuditStatusArr`. Added `const AuditStatusArr = self::AuditStatus` alias. Without this, admin page `/manage/users?tab=company` crashes with "Undefined constant".

- **JWT 過期 → 手機 App「我的」全分類空白（2026-08-14 排查）**: 「我的」頁面所有分類（城市/預約/發布/商城/邀請/歷程/認證/會員中心）空白、所有帳號皆中招時，**先檢查 token 過期**，不要急著深挖代碼。`JWT_TTL=10080` 分鐘（7 天）在 `.env`；過期 token 走 `AuthenticationException` 路徑 → `Handler::render()` 返回 401「未認證或登錄狀態已失效」→ Flutter App 把 401 錯誤當空內容顯示。診斷三步：(1) 確認空白接口是否 `auth:api`（公開接口如首頁正常 = 登錄層問題）(2) 從手機請求（nginx 日誌 UA 含 Dart）抓 Authorization 頭，base64url 解 JWT payload 看 `exp` (3) `exp < now` → 讓用戶在 App 登出重登即可，後端無需修。改進方向（未實施）：Flutter app 收到 401 應自動跳轉登入頁（`lumotrip/` 項目）。

- **Dcat 網格內聯編輯被 `prepareUpdate()` 過濾丟棄（2026-08-15）**: 網格內聯編輯（`->switch()` 開關、`->editable()` 排序）發 PUT 到資源 update 路由 → `Form::update()` → **`prepareUpdate()` 只保留表單（form()）裡定義的字段**，非表單字段（如審核表單沒有的 `recommend`/`home_recommend`/`order`）被**靜默丟棄**——後台怎麼改都不生效且無報錯。**在 Repository::update() 裡加循環沒用**（過濾發生在 repository 之前，`$form->updates()` 已是空）。校驗不是問題：`getValidator()` 對不在輸入中的字段直接跳過（required 不會攔截內聯請求）。**正確修法**：在 Controller 覆寫 `update()`，攔截內聯字段直接寫庫（`GuideController::update()`，2026-08-15）：
  ```php
  public function update($id) {
      foreach (['recommend', 'home_recommend', 'order'] as $field) {
          if (request()->exists($field)) {
              $res = \App\Models\Guide::find($id);
              $res->{$field} = (int) request()->input($field);
              $res->save();
              return response()->json(['status' => true, 'data' => ['message' => '設置成功']]);
          }
      }
      return parent::update($id);
  }
  ```
  switch 發 `{recommend: 0|1}`、editable 發 `{order: N, _inline_edit_: 1}`（注意此版本 dcat 的標記是 `_inline_edit_` 不是 `_editable`）。響應格式需 `{status, data:{message}}` 以兼容兩者 JS。同案新增 `CompanyRecommendSet`（企業 tab 設置其首個商鋪 city_content 的 recommend/home_recommend/banner_recommend/order，`Company::shops()` 關係 + `UserController` 企業 tab「推薦設置」列）。排序規則統一：首頁/城市頁/guideList 均 `orderBy('order','desc')`（後台提示「從大至小」；原首頁導遊是 `asc` 為 bug，城市頁導遊列表此前完全忽略 order，均已修正）。

### Frontend — Hard Pitfalls (will silently break with no errors)
- **白字在淺色背景上消失（v4 設計切換後）**: 舊版設計（2026-08-07 前）多個頁面頂部用白色文字，靠舊的 indigo 頂部漸層 `#666FFF` 提供深底。v4 改淺色背景後這些白字全部不可見（標題、搜尋列、tab、pill）。**2026-08-07 已修復 7 個檔案**：`city/index.js`、`guide/list.js`、`merchant/list.js`、`search/index.js`、`misc/download.js`、`city/extra.js`（攻略頁頭部）、`news/detail.js`（日期/瀏覽數）+ CSS `.sketch-search-input::placeholder`。修改後主題色時，必須全站掃描白字元素（可參考 Playwright 腳本：對每個路由找 computed color 為白色、且背景鏈（含祖先 background-image 漸層）為淺色的文字元素）。city 詳情頁標題雖是白字但下方有 `linear-gradient(to top, rgba(0,0,0,.6), transparent)` 暗色 overlay（sibling，非祖先），屬正常。見 [[v4-design-palette]] 記憶。
- **Vue 3 CDN component pitfall**: NEVER create separate component files. Components registered via `components: {}` silently render blank in child templates. ALWAYS inline templates in the parent component.
- **File upload silent failure in frontend**: `uploadFile()` in `entry.js` and `certify.js` catches errors and returns `existingUrl` (which is empty string for new uploads). If the file upload API fails, the user sees "證件圖片不能為空" with no indication that the upload itself failed. When debugging "upload failure" reports, check Nginx access logs for `fileUpload` 200 responses first — the upload API usually works, and the real issue is field name mismatch in the subsequent POST.
- **Draft save for multi-step forms**: Follow the pattern in `publish/form.js`: `watch` form+pics (deep) → `created()` debounced `saveDraft()` → `checkDraft()` after `loadData()` → prompt UI with restore/clear → clear on success → save in `beforeUnmount()`. Only save serializable data (skip File objects and blob URLs). Applied to `guide/certify.js` and `merchant/entry.js`. See [[draft-save-multi-step-forms]] in memory.
- **API response snake_case**: Access fields as the API returns them (`guide_type`, `city_id`, `first_picture`). Never use camelCase — JS returns `undefined` with no error.
- **i18n reactivity**: I18n MUST be `Vue.reactive()` and `I18n.init()` MUST run before `app.mount('#app')`.
- **File upload blob trap**: Store both `File` object AND blob URL for preview. Blob URLs are preview-only — upload File objects on submit. Revoke blob URLs in `beforeUnmount`.
- **Timer cleanup**: Every `setInterval`/`setTimeout` must be stored on `this._timer` and cleared in `beforeUnmount`.
- **CSS constraints**: `font-weight` must be multiples of 100. All `var(--xxx)` must match `variables.css`. Use centralized z-index variables.
- **JS block comment glob trap**: `/* */` blocks must NOT contain `*/` — common in glob patterns like `publish_*/controller.dart`. Use `//` line comments or `publish_<type>/controller.dart`.

### Frontend — Design/Architecture Rules
- **Web-Flutter feature parity**: Web MUST strictly match Flutter. No features that don't exist in Flutter. Reference: Flutter app at `lumotrip/lib/pages/`.
- **Flutter constraints**: No delete in publish content lists (`canDelete: false`). No inline confirm/reject in booking lists. No booking status filter tabs. VIP gate on add (not edit).
- **Design system v4**: Primary `#666FFF` (accent only), page bg `#F8FAFC`, card `#FFFFFF` + `#E2E8F0` border. Navbar glassmorphism `rgba(255,255,255,.8)` + blur(12px) + hairline `rgba(226,232,240,.8)`. Home shell gradient: `linear-gradient(180deg, #F0F2FA 0%, #F5F7FC 120px, #F8FAFC 100%)`. Serif: `Georgia, 'Noto Serif TC', 'Noto Serif SC', serif`.
- **Topbar visibility**: Hidden only on `/welcome`, `/login`, `/register`, `/forget-password`, `/verify-code`, `/password-input`. Must list ALL auth routes.
- **Reuse existing styles**: Check `.filter-pills`, `.card-grid-*`, `.h-scroll`, `.ds-*` before creating new CSS.
- **SPA architecture**: Correct choice. No multi-HTML. All content behind login wall (SEO irrelevant).

### Frontend — Debugging "No Content" Issues

When a detail page shows blank content (empty body, missing images), the most common cause is **backend response field name mismatch** with frontend template expectations. For example: `InformationService::info()` returned body text under `'desc'` key, but `detail.js` template looked for `news.content` → nothing rendered. **Fix**: read the backend service return array and cross-check every key against the frontend template bindings.

### Frontend — API Data Patterns
- **Search API**: `/common/homeSearch` returns flat array with `data_type`: 1=city, 2=guide, 3=content. Filter client-side.
- **VIP APIs**: `/vip/guide` and `/vip/company` return flat arrays — use `Array.isArray(d) ? d : (d.list || [])`.
- **City list API**: Returns `{total, list}` — extract `res.data.list`, NOT `res.data` as array.
- **Content type_id mapping**: attraction→1, restaurant→2, shopping→3, accommodation→4, transportation→5, facility→6, activity→7, ticket→8.
- **Activity API**: Uses `category_id` param (not `type_class_id` like other types).
- **UserStore identity**: Use `Number(this.userInfo?.identity)` — API returns identity as string.
- **Guide images**: Guides return `photo`, others return `first_picture`. Use `item.photo || item.first_picture`.
- **API 形状契约（2026-08-17）**: `config.languages` = 逗号分隔**字符串**；`getGuideType.data` = **`{list: [...]}`** 包裹。两者是 Flutter App 认证页的解析契约，勿改回数组/扁平数组（Web certify.js 已双形状兼容，后端改动不影响 Web）。`applyGuideInfo` 的 `language`/`industry_type` 仍是数组。

### System Messages (`#/message/system`)

System messages stored in `system_message` table with structured fields:
- `content_type`: `'city_content'` | `'system'` | `null`
- `city_id`, `content_id`, `city_content_type`: populated for city_content messages
- `is_read`: per-message read status (MessageService::systemList must include this in select)

**Inline linking pattern**: For `city_content` messages, parse the content text, strip Chinese brackets （）, and render names as inline clickable links:
- City name → `#/city/detail?id={city_id}` (purple `#8B5CF6`)
- Content name → `#/detail/city_content?id={content_id}&type_id={city_content_type}&city_id={city_id}` (purple `#8B5CF6`)
- MUST include `city_id` in content detail URLs — the API requires it

**Design**: White card container with subtle shadow, list items with unread dot + `#FAFAFF` tint, centered detail modal (not bottom sheet).

### City Detail Tab Bar (`#/city/detail`)

Sticky tab bar (v4, 2026-08-07) matches navbar glassmorphism — inline styles in `frontend/js/pages/city/detail.js`:
- Bar: `rgba(255,255,255,.8)` + `backdrop-filter: saturate(180%) blur(12px)`, 1px hairline `rgba(226,232,240,.8)`
- Active tab: `#666FFF`, bold, 2px indigo bottom border
- Inactive tab: `rgba(51,65,85,.6)` (slate-700 60%)
- Sub-category bar: `rgba(255,255,255,.6)` glass, same indigo-active pattern
- Sticky position: `top:52px` (below topbar)

### UI 效果圖 / 全站白字掃描（Playwright，2026-08-07）

伺服器已裝 Playwright Chromium，工具在 `/tmp/mockup/`：
- **設計效果圖**：`mockup.html`（示意圖，含導航欄三態 + 配色表）→ `node shot.js` 輸出 `mockup-desktop.png` / `mockup-mobile.png`（1440 / 390，2x）
- **線上截圖**：`shot2.js` / `final.js` / `final2.js` → `live-*.png`、`效果圖-*.png`
- **白字掃描**（改主題色後必跑）：`scan.js` — 逐路由檢查「文字 computed color 白（alpha>0.3）+ 背景鏈（含祖先 background-image，解析漸層色階明暗）為淺色」，輸出問題清單
- **像素驗證**：`verify*.php` — 截圖取樣/計數（指示條、logo、背景色）
- **DOM 樣式驗證**：`diag3.js` — 讀線上 topbar 的 `backgroundColor` / `backdropFilter` / `borderBottomColor` / `::after` 等計算樣式
- **預覽發布**：效果圖放 `public/design-preview/` → `https://api.lumoguide.com/design-preview/`（確認後刪除）
- 換機安裝：`npm i playwright && npx playwright install chromium && npx playwright install-deps chromium`


### Frontend — Key Patterns
- **VIP gate**: `v-else-if="!isEdit && !UserStore.isVip"`. `isVip` = `vip_type > 0 && vip_expiration_time > 0` OR `vip_free === 1 && vip_free_day > 0`.
- **Draft save/restore**: Save to `localStorage` keyed by type in `beforeUnmount` when `!isEdit && !success`. Clear on success.
- **Three-level cascade (continent→area→country)**: `getContinentsList` with `parent_id` param. Selection resets downstream.
- **Publish form factory**: `createPublishPage(typeKey)` with `PUBLISH_TYPES[typeKey].has` config for conditional fields.
- **Cross-navigation**: All detail pages link to related entities. Guide detail → city (`guide.city_id`), News detail → guide (`news.user.guide_id`) + city.
- **Home page auto-switch**: Guide categories auto-switch 5s, manual tap resets timer. Use placeholder slots (`visibility: hidden`) for layout stability.
- **City detail FAB**: Visible for guides on 景點/交通/設施/活動 tabs. VIP gate checked on click.
- **Publish form city_id pre-fill** (2026-07-07): `publish/form.js` reads `$route.query.city_id` in `init()` to pre-select city dropdown when navigating from city detail FAB. Enables seamless "add content from city page" flow.
- **Booking button on content detail** (2026-07-25): Only company/merchant content shows the 預約 button. Guide-uploaded content returns `is_reserve: 0` — use truthy check `v-if="item.is_reserve"`, NOT `!== undefined`. Backend checks `publisher_type == 'company'` and `type_id in [1,2,3,4,8]`. Also hides when the current user is the uploader (`user_id == $user->id`).
- **Merchant list sorting** (2026-07-25): `merchantList` sorts by `view_count desc` primary, `order desc` secondary. `view_count` is incremented in `CityService::getContentInfo()` on each content detail view. Migration `2026_07_25_000001` added the column. **Pitfall**: always run new migrations before deploying code that references new columns — missing column causes 500 on the entire endpoint.
