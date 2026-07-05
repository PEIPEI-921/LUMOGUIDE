# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LuMo Guide** — a travel guide platform backend built on Laravel 9. Provides REST API for a mobile app and an admin panel for content management. The platform covers travel destinations (cities), tour guides, merchants/shops, information articles, reservations, Stripe VIP subscriptions, and a points/rewards system.

**Important**: Source files under `app/` are encoded with **swoole_loader**. The PHP extension `swoole_loader` must be loaded or the files will appear garbled. Do not edit encoded files directly — work through the admin panel or API layer. A few files (like `helpers.php`, `lang/`, `routes/`, `config/`, `.env`, `composer.json`) are plaintext.

## File Organization: Where to Put What

When creating or modifying files in this project, always follow these conventions. If you're unsure where a new file belongs, match the nearest existing example.

### Static Frontend Files (HTML / CSS / JavaScript)

| File Type | Location | Examples |
|-----------|----------|---------|
| HTML pages | `frontend/` | `frontend/index.html`, `frontend/404.html` |
| CSS stylesheets | `frontend/css/` | `frontend/css/style.css` |
| JavaScript | `frontend/js/` | `frontend/js/app.js` |

> Routes serve these files via `base_path('frontend/xxx.html')`. See `routes/web.php`.

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

### Decision Rules for New Files

1. **Is it a frontend page (HTML/CSS/JS)?** → `frontend/`
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

### PhpStorm Setup

Run Configuration (`start`) executes `start.sh`, which:
1. Checks if SSH tunnel on port 3307 exists → creates if missing
2. Starts `php artisan serve --host=0.0.0.0 --port=8000`

If the configuration breaks, recreate it manually: Settings → PHP → CLI Interpreter → `/opt/homebrew/opt/php@8.3/bin/php`, then Run → Edit Configurations → Shell Script pointing to `start.sh`.

## Frontend

### Web Frontend (SPA)

The web frontend is a **Vue.js 3 + Vue Router** single-page application served from `frontend/`. No build tools — all libraries loaded via CDN. The SPA replicates all functionality from the Flutter mobile app using the same backend REST APIs.

**Tech stack**: Vue 3 (global prod), Vue Router 4 (hash mode), custom CSS (no framework), Fetch API.

```
frontend/
├── index.html                  # SPA shell (CDN links + <div id="app">)
├── 404.html                    # Error page
├── css/
│   ├── variables.css           # Design tokens (matches mobile AppColors)
│   ├── app.css                 # Global layout, typography, utilities
│   └── components.css          # Card, nav, form, button, badge, etc.
└── js/
    ├── app.js                  # Vue.createApp(), global components, mount
    ├── router.js               # Hash-based routes (56 routes + auth guard)
    ├── api/
    │   ├── provider.js         # Fetch wrapper — never throws, returns {success, data, message}
    │   └── urls.js             # All 120+ API URL constants (mirrors mobile ApiUrl)
    ├── stores/
    │   ├── user.js             # Vue.reactive — auth state, token, profile, login/logout
    │   └── config.js           # System config cache from /common/config
    ├── i18n/
    │   ├── index.js            # Translation service (detects browser lang, persists to localStorage)
    │   ├── zh-CN.js            # Simplified Chinese (~180 keys)
    │   ├── zh-TW.js            # Traditional Chinese (identity mapping)
    │   └── en.js               # English
    ├── utils/
    │   ├── storage.js          # localStorage wrapper (mirrors Flutter StorageStone keys)
    │   └── helpers.js          # timeAgo, imageUrl, safeInt/safeString, showToast, debounce
    ├── components/
    │   ├── app-nav.js          # 5-tab bottom navigation (Home/City/News/Message/Mine)
    │   ├── app-header.js       # Sticky header with back button + title
    │   ├── loading-spinner.js  # Loading indicator
    │   └── empty-state.js      # Empty data placeholder with retry
    └── pages/
        ├── welcome.js          # Landing page
        ├── auth/
        │   ├── login.js        # Email/password login with remember-me
        │   └── register.js     # Registration with email code verification
        ├── home/index.js       # Home: search, city strategy, hot cities, guides, merchants, news
        ├── city/index.js       # City list browser with continent tabs
        ├── news/index.js       # Information/articles with category filter
        ├── message/index.js    # Message center (5 categories)
        └── mine/index.js       # Profile, VIP status, service menu grid
```

**Architecture patterns**:
- **API**: `ApiProvider.get/post(path, data)` → always returns `{success, code, message, data}`. JWT automatically attached from `Storage.token`. Never throws — matches Flutter's `ApiResult` pattern.
- **Auth**: `UserStore` (Vue.reactive) manages token + profile. Login stores credentials in localStorage under keys matching Flutter's `StorageStone` (`token`, `user_number`, `user_sig`, `user_info`). 401 responses trigger logout redirect. Route guard in `router.beforeEach` checks `meta.requiresAuth`.
- **i18n**: Keys are Traditional Chinese characters (matching Flutter). `I18n.t('首頁')` returns locale-appropriate text. Language persisted to localStorage.
- **Pages**: Each page is a Vue Options API component definition object (`{template, data, methods, mounted}`). Registered globally via `app.component()`. Full pages for 5 tabs + auth; remaining 40+ routes use `ComingSoon` placeholder — ready for Phase 2.
- **Routing**: Hash-based (`#/home`, `#/city/detail?id=1`). Tab bar shown only on 5 main routes; hidden on sub-pages (matches Flutter push navigation). Scroll position resets on navigation.

**Backend route for SPA** (`routes/web.php`):
```php
// Root route serves SPA shell
Route::get('/', fn() => response()->file(base_path('frontend/index.html')));

// SPA catch-all — all non-API, non-admin routes serve index.html
Route::get('/{any}', fn() => response()->file(base_path('frontend/index.html')))
    ->where('any', '^(?!api|manage).*$');
```
This ensures `/api/*` (mobile app) and `/manage*` (admin panel) are unaffected.

**Implementation status**: Phase 1 complete (shell, auth, 5 tabs, i18n). Phases 2-6 pending (detail pages, forms, publishing, commerce, polish). See plan at `.claude/plans/modular-swimming-sky.md`.

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
