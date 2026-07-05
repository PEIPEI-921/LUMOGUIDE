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

# Clear caches
/opt/homebrew/bin/php artisan config:clear && /opt/homebrew/bin/php artisan cache:clear && /opt/homebrew/bin/php artisan route:clear && /opt/homebrew/bin/php artisan view:clear

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

All static frontend pages live in `frontend/` directory:

```
frontend/
├── css/        ← CSS files
├── js/         ← JavaScript files
├── index.html  ← Homepage
└── 404.html    ← 404 error page
```

Routes reference files via `base_path('frontend/xxx.html')`. Root route (`/`) serves `frontend/index.html`.

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
