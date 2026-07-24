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

**Design system**:
- Primary: `#666FFF` (indigo), Primary Dark: `#4A52E0`
- Page background: `#F9F9F6` (warm paper-white), Card: `#FFFFFF`, Text: `#1a1a1a` (ink) / `#6B7280` (muted) / `#9CA3AF` (faint)
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
- **All source code is plaintext** (2026-07-22). No swoole_loader needed.
- **Admin panel** at `/manage` (not `/admin`), set by `ADMIN_ROUTE_PREFIX=manage` in `.env`.
- **Response format**: All API responses are `{code: int, message: string, data: object/array}`.
- **Queue driver**: Redis (`QUEUE_CONNECTION=redis`).
- **API parameter types**: PHP methods have strict types (`int $city_id`). Never send empty string `""` for numeric params — use `if (value) params.key = value` to omit empty values entirely. Route query params are always strings — use `parseInt()` before passing to APIs.
- **Bug report**: 62 known bugs documented in `bug-report-2026-07-07.md` (all fixed).

### Backend — Security Rules (2026-07-24 security review)
- **File uploads**: MUST validate MIME type (whitelist: jpg/jpeg/png/gif/webp) and max size (10MB). File extension MUST be whitelisted as defense-in-depth. Uploaded files stored via `storage:link` are publicly accessible — never allow executable extensions.
- **LIKE queries**: ALWAYS escape user input with `escapeLike()` before using in LIKE patterns. Unescaped `%` and `_` wildcards allow bulk data extraction.
- **Error messages**: NEVER expose raw exception messages to API responses. Use generic `__('res.system_error')` in catch blocks. Log the real error server-side.
- **Login responses**: Return the same message for "account not found" and "wrong password" to prevent user enumeration.
- **Stripe webhooks**: Check `pay_status` before processing to ensure idempotency. Stripe may retry webhooks.
- **SSL verification**: NEVER disable `CURLOPT_SSL_VERIFYPEER` in production code.
- **Debug endpoints**: All debug/test routes MUST have `auth:api` middleware. The `/api/common/test` endpoint was secured 2026-07-24.

### Frontend — Hard Pitfalls (will silently break with no errors)
- **Vue 3 CDN component pitfall**: NEVER create separate component files. Components registered via `components: {}` silently render blank in child templates. ALWAYS inline templates in the parent component.
- **API response snake_case**: Access fields as the API returns them (`guide_type`, `city_id`, `first_picture`). Never use camelCase — JS returns `undefined` with no error.
- **i18n reactivity**: I18n MUST be `Vue.reactive()` and `I18n.init()` MUST run before `app.mount('#app')`.
- **File upload blob trap**: Store both `File` object AND blob URL for preview. Blob URLs are preview-only — upload File objects on submit. Revoke blob URLs in `beforeUnmount`.
- **Timer cleanup**: Every `setInterval`/`setTimeout` must be stored on `this._timer` and cleared in `beforeUnmount`.
- **CSS constraints**: `font-weight` must be multiples of 100. All `var(--xxx)` must match `variables.css`. Use centralized z-index variables.
- **JS block comment glob trap**: `/* */` blocks must NOT contain `*/` — common in glob patterns like `publish_*/controller.dart`. Use `//` line comments or `publish_<type>/controller.dart`.

### Frontend — Design/Architecture Rules
- **Web-Flutter feature parity**: Web MUST strictly match Flutter. No features that don't exist in Flutter. Reference: Flutter app at `lumotrip/lib/pages/`.
- **Flutter constraints**: No delete in publish content lists (`canDelete: false`). No inline confirm/reject in booking lists. No booking status filter tabs. VIP gate on add (not edit).
- **Design system**: Primary `#666FFF`, page bg `#F9F9F6`, card `#FFFFFF`. Topbar solid `#7C5CFF` 52px no box-shadow. Body gradient: `linear-gradient(180deg, #7C5CFF 0%, #7C5CFF 52px, #F9F9F6 400px)`. Serif: `Georgia, 'Noto Serif TC', 'Noto Serif SC', serif`.
- **Topbar visibility**: Hidden only on `/welcome`, `/login`, `/register`, `/forget-password`, `/verify-code`, `/password-input`. Must list ALL auth routes.
- **Reuse existing styles**: Check `.filter-pills`, `.card-grid-*`, `.h-scroll`, `.ds-*` before creating new CSS.
- **SPA architecture**: Correct choice. No multi-HTML. All content behind login wall (SEO irrelevant).

### Frontend — API Data Patterns
- **Search API**: `/common/homeSearch` returns flat array with `data_type`: 1=city, 2=guide, 3=content. Filter client-side.
- **VIP APIs**: `/vip/guide` and `/vip/company` return flat arrays — use `Array.isArray(d) ? d : (d.list || [])`.
- **City list API**: Returns `{total, list}` — extract `res.data.list`, NOT `res.data` as array.
- **Content type_id mapping**: attraction→1, restaurant→2, shopping→3, accommodation→4, transportation→5, facility→6, activity→7, ticket→8.
- **Activity API**: Uses `category_id` param (not `type_class_id` like other types).
- **UserStore identity**: Use `Number(this.userInfo?.identity)` — API returns identity as string.
- **Guide images**: Guides return `photo`, others return `first_picture`. Use `item.photo || item.first_picture`.

### Frontend — Key Patterns
- **VIP gate**: `v-else-if="!isEdit && !UserStore.isVip"`. `isVip` = `vip_type > 0 && vip_expiration_time > 0` OR `vip_free === 1 && vip_free_day > 0`.
- **Draft save/restore**: Save to `localStorage` keyed by type in `beforeUnmount` when `!isEdit && !success`. Clear on success.
- **Three-level cascade (continent→area→country)**: `getContinentsList` with `parent_id` param. Selection resets downstream.
- **Publish form factory**: `createPublishPage(typeKey)` with `PUBLISH_TYPES[typeKey].has` config for conditional fields.
- **Cross-navigation**: All detail pages link to related entities. Guide detail → city (`guide.city_id`), News detail → guide (`news.user.guide_id`) + city.
- **Home page auto-switch**: Guide categories auto-switch 5s, manual tap resets timer. Use placeholder slots (`visibility: hidden`) for layout stability.
- **City detail FAB**: Visible for guides on 景點/交通/設施/活動 tabs. VIP gate checked on click.
- **Publish form city_id pre-fill** (2026-07-07): `publish/form.js` reads `$route.query.city_id` in `init()` to pre-select city dropdown when navigating from city detail FAB. Enables seamless "add content from city page" flow.
