# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LUMOGUIDE (`lumotrip`) — a Flutter travel guide app for iOS and Android. App name in code: **LUMOGUIDE**, version 1.0.6+19. Backend API at `https://api.lumoguide.com/api/`.

## Environment

Flutter 3.44.4 (Dart 3.12.2), installed at `~/flutter/`. Android Studio 2025.1.1 run configuration set up at `.idea/runConfigurations/main_dart.xml`. VS Code with Dart-Code.flutter extension v3.138.0. Project `.vscode/` config presets: settings (Flutter SDK paths, format-on-save, file excludes) + launch (macOS / Android / iOS / auto).

Git repo initialized (`main` branch), remote `origin`: `https://github.com/PEIPEI-921/LUMOGUIDE-frontend.git`.

### China mirrors (required for package downloads)

```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

These are already in `~/.zshrc`. Without them, `flutter pub get` and `flutter upgrade` downloads from `storage.googleapis.com` will fail with partial transfer errors.

### macOS desktop build

macOS desktop target was added with `flutter create . --platforms=macos`. Prerequisites:
- Xcode installed from App Store + `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- CocoaPods 1.16.2 installed via Homebrew (`brew install cocoapods`)
- Run from terminal: `flutter run -d macos` (Android Studio `--start-paused` causes debug connection to drop on macOS)

**Desktop window adaptation:** The app uses a mobile-first design (375×834). On desktop, `flutter_screenutil` would otherwise scale `.w` values by full window width (e.g. `scaleWidth = 1440/375 = 3.84`), making UI elements huge. Solution in `lib/main.dart`:
- `ScreenUtilInit` widget (not `ScreenUtil.init()`) — screenutil sees the constrained context
- On desktop (`Platform.isMacOS || Windows || Linux`): content wrapped in `Center` + `ConstrainedBox(maxWidth: 600)` with primary color background on sides
- `lib/global.dart` skips `setPreferredOrientations` on desktop (portrait lock is mobile-only)
- `macos/Runner/MainFlutterWindow.swift`: minSize 400×600, default 450×800 centered

## Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Static analysis
flutter analyze

# Run tests (widget test only)
flutter test

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

### In VS Code

- Open `lib/main.dart`, then **F5** to start debugging (or **Ctrl+F5** for Run Without Debugging)
- Select target device from the bottom status bar before launching
- Top-right ▶ provided by the Flutter extension only appears when `main()` is visible in the editor

**Do NOT use Code Runner** to run `.dart` files — it invokes the standalone `dart` VM, which cannot compile Flutter apps and will crash with FFI/kernel compilation errors.

No code generation (build_runner, json_serializable) is used — models are hand-written with `fromJson`/`toJson`.

## Architecture

### Stack
- **State management / DI / Routing**: GetX (`get: ^4.6.6`)
- **HTTP**: Dio (`dio: ^5.4.3`) — singleton `ApiProvider` + `ApiMixin` convenience mixin
- **IM / Push**: Tencent Cloud Chat (`tencent_cloud_chat_uikit`, `tencent_cloud_chat_push`)
- **Payments**: Stripe (`flutter_stripe`)
- **Screen adaptation**: flutter_screenutil (design size 375×834)
- **Local storage**: shared_preferences

### Layer structure (`lib/`)

```
lib/
├── main.dart              # Entry point, GetMaterialApp setup
├── global.dart            # App init: services → stores, system UI config
├── common/                # Shared layer (barrel-exported via common/index.dart)
│   ├── apis/              # Dio wrapper (ApiProvider), ApiMixin, ApiResult, interceptor, URL constants
│   ├── models/            # Data classes with fromJson/toJson
│   ├── services/          # GetX services: ConfigService, StorageService, ImageCacheService, LocalizationService, StripeService
│   ├── stores/            # GetX reactive stores: UserStore, TIMStore, CityListStore, CityHistoryStore
│   ├── routers/           # AppRoutes (name constants), AppPages (GetPage list), RouteObservers
│   ├── langs/             # i18n: TranslationService, en_US/zh_CN/zh_TW string maps
│   ├── utils/             # Helpers: image_picker, loading, alert, keyboard, etc.
│   ├── values/            # Constants: colors, assets paths, enums, storage keys, font sizes
│   ├── widgets/           # Reusable widgets: app_bar, calendar, comment, refresh wrapper, etc.
│   └── extensions/        # Dart extension methods on String, Map, DateTime, Optional
└── pages/                 # Feature pages (barrel-exported via pages/index.dart)
    └── <feature>/
        ├── index.dart     # Barrel exports for this feature
        ├── controller.dart # GetX controller (logic, API calls, reactive state)
        ├── page.dart      # StatelessWidget page/view
        ├── value.dart     # Optional: page-specific enums/constants
        └── widgets/       # Page-specific sub-widgets
```

### Page pattern

Every page follows a strict 3-file pattern:
1. **`controller.dart`** — `GetxController` with reactive `.obs` state. Mixes in `ApiMixin` for API calls. Often uses `RefreshableMixin` for pull-to-refresh.
2. **`page.dart`** — `StatelessWidget`. Gets controller via `Get.find()` or creates it via `Get.put()` on first access.
3. **`index.dart`** — barrel exports both controller and page.

**`RefreshableMixin`** (`lib/common/widgets/refresh/mix.dart`) provides paginated list state with pull-to-refresh and load-more via `easy_refresh`. Controllers mix it in, configure with `initRefresh()`, override `fetchData()` (calls API with `page`/`limit`), and feed results to `endLoad(lists)`. The mixin manages `.obs` items list, page counter, refresh/load completion signals, and "no more" footer state.

### API layer

- `ApiProvider` is a singleton Dio wrapper. All HTTP methods return `ApiResult` (never throws).
- `ApiMixin` is a mixin that delegates to `ApiProvider` — mix this into any controller/service that needs network access.
- `ApiResult` provides `.isSuccess`, `.dataJson` (single object), `.dataList` (array), `.message`.
- `AuthInterceptor` attaches the Bearer token from `UserStore.to.token` to every request.
- API URLs are static string constants in `ApiUrl` abstract class (`lib/common/apis/urls.dart`). Dev mode is toggled via `ApiUrl._isDev` (compile-time const, currently `false` — requires code change + rebuild to switch).

### State management

- **Services** (`GetxService`): long-lived singletons initialized in `Global.init()` — `StorageService`, `ConfigService`, `ImageCacheService`, `LocalizationService`, `StripeService`.
- **Stores** (`GetxController`): reactive state holders — `UserStore` (auth, profile), `TIMStore` (IM login, conversations, friends), `CityListStore`, `CityHistoryStore`.
- **Page controllers** (`GetxController`): per-page logic and state, disposed when page is popped.

### Root navigation

`RootPage` is the main shell: 5-tab `BottomNavigationBar` + `IndexedStack`:
1. Home (`/home`) — hero sections, search, guides, merchants, information
2. City (`/city`) — city list/browser
3. News (`/news`) — information/articles list
4. Message (`/message`) — notification categories + IM conversations
5. Mine (`/mine`) — user profile, settings, bookings, publish management

Initial route is `/welcome` (landing page), which flows into `/root` after auth.

**Homepage guide auto-scroll:** The 「推荐導遊」 section auto-rotates through guide category pills every 3 seconds (`Timer.periodic` in `HomeController`). Manual tap pauses for 3s then resumes. See [[guide-auto-scroll]].

**Homepage merchant auto-scroll:** The 「推薦商家」 section auto-rotates through merchant categories driven by **banner carousel cycle completion** (not a timer). When the `CarouselSlider` finishes one full cycle through all banners, it advances to the next category. Single-banner categories use a 4s fallback timer. Manual swipe on the carousel or tap on a category pill permanently stops auto-rotation. See [[merchant-auto-scroll]].

**Homepage merchant category height stabilization:** Different categories may have different banner/grid item counts. To prevent layout jumping when switching categories, the merchant section pre-computes the maximum banner count and grid row count across all categories, and reserves fixed-height `SizedBox` containers for both the carousel area and the grid area. See `lib/pages/home/widgets/merchant.dart`.

### Login page

Debug mode default credentials (in `lib/pages/login/controller.dart`): `zhouguanpei@hotmail.com` / `zhou123`.

### User booking appointments

**Calendar:** The `DatePickerCalendarWidget` (`lib/common/widgets/date_picker_calendar.dart`) was redesigned:
- Full month view (`CalendarFormat.month`) instead of week view
- Year/month selected via `ListWheelScrollView` wheel pickers with direct text input
- Year range: 1970–3000 (firstDay/lastDay set accordingly to prevent `TableCalendar` assertion failures)
- Navigation arrows removed; tap year/month chips to open pickers
- Used by 4 pages: user booking (guide/merchant), guide booking manager, merchant booking manager

**Booking list items** (`lib/pages/user_booking_manager/widgets/guide.dart`, `merchant.dart`):
- Sorted by `arrivalTime` ascending
- Color-coded left border (3.w):
  - status=1 (pending) → `AppColors.primary` (#666FFF purple)
  - status=2 (confirmed) → `AppColors.jadeGreen` (#44D7B6 green)
  - status≥3 (completed/cancelled/rejected/expired) → `AppColors.assistantText` (#999999 gray)
- `StatusWidget` badge colors updated to match

See [[calendar-redesign]], [[booking-color-coding]].

### Journey feature（我的历程）

`MineMenu.journey` entry in 「我的 → 我的服务」, icon: `icon_account_menu_journey.png`. See [[journey-feature]].

**3 pages:**
| Route | Page | Purpose |
|-------|------|---------|
| `/journey` | `JourneyPage` | Work list with search, status/region filters, calendar, work cards |
| `/journey_detail` | `JourneyDetailPage` | Work detail: 2 tabs (行程/详情), save as template, generate & share client itinerary |
| `/journey_editor` | `JourneyEditorPage` | Create/edit work trip form with auto day-by-day content |

**Data models:**
- `JourneyWork` (`lib/common/models/journey_work.dart`) — main work entity with `JourneyWorkStatus` enum (inProgress=1, pending=2, ended=3). Also contains `FlightInfo`, `HotelInfo`, `DayCityBlock`, `ItineraryDay`, `ItineraryItem`. Backend CRUD APIs now available at `/user/journeyList|Detail|Create|Update|Delete`. `mockData()` still provides 4 sample entries as fallback if API fails.
- `DayCityBlock` (`lib/common/models/journey_work.dart`) — **NEW (2026-07-25)**: each city within a day has its own independent block with `cityId`, `cityName`, and `items` list. Replaces the old flat `cityIds`/`cityNames`/`items` on `ItineraryDay`. `fromJson` handles backward compatibility with old-format data.
- `JourneyTemplate` (`lib/common/models/journey_template.dart`) — reusable template saved from a work; used by `TemplatePickerSheet` and `TemplateSaveDialog`. Backend APIs at `/user/journeyTemplateList|Save|Delete`.
- **Backend data storage:** Journey CRUD uses Laravel JSON `content` column — all fields stored as JSON blob. `expandJourneyWork()` in backend expands content to flat fields on response. Frontend sends flat JSON; backend stores in `content`. See `docs/backend-requirements.md`.

**Dynamic status (`effectiveStatus`):** Status is computed from dates relative to today, not stored:
- 进行中：startDate ≤ today ≤ endDate
- 待出发：startDate > today
- 已结束：endDate < today
- Filtering and card display use `effectiveStatus`/`effectiveStatusValue`

**Calendar (iPhone-style event bars):** `_JourneyCalendar` redesigned (2026-07):
- Events span **continuously across days** (no cell margins): `margin: EdgeInsets.zero` + `CalendarStyle(cellMargin: EdgeInsets.zero)`
- Event titles **flow across cells**: `TextPainter` binary search measures actual character widths per cell, fills each cell completely before flowing to next cell
- **Responsive**: cell content width computed from `MediaQuery.of(context).size.width`, recalculated when width changes >2px
- `_DayEvent` data class: `work` + `dayIndex` + `totalDays` + `segments` (pre-computed text segments per cell)
- `_JourneyCalendarState`: uses `ever(_ctrl.focusedMonthRx, setState)` to trigger rebuild on month change; `ValueKey(focusedMonth)` on `TableCalendar`
- Title font: 9.sp, `rowHeight: 42.w`. Priority when overlapping: inProgress > pending > ended. See [[journey-feature]].
- **Month switching fix:** `JourneyController` exposes `focusedMonthRx` getter; StatefulWidget listens via `ever` + `setState` (TableCalendar NOT wrapped in Obx to avoid `_dependents.isEmpty` crash).

**Editor redesign (2026-07):** Simplified to natural trip-planning flow:
- Departure: date (tap → system date picker) + city
- Return: date + city
- **Auto day-by-day content:** When both dates are filled, automatically generates content fields for each day (e.g., 「第1天 (7/3)」, 「第2天 (7/4)」…) with light purple background
- Removed: arrival method/time/location, departure method, cities list, manual status selector (status is date-derived)

**Editor redesign v2 (2026-07):** Further refined quick-create flow:
- **Auto group name (2026-07-25 redesigned):** Multi-level naming based on country count:
  - 1国 → 国家全名 + N日游（奥地利7日游）
  - 2-3国 → 各国首字拼接 + N日游（奥匈7日游 / 奥捷匈7日游）
  - 4-5国 → 地区首字拼接 + N国 + N日游（中东欧四国7日游）
  - ≥6国 → 洲名 + N日游（欧洲7日游）
  - 跨洲 → 前三国首字 + 等多国 + N日游
  - Collects cities from 3 sources: `startCity`/`endCity` + all `day.cityBlocks[].cityName` + scanning item titles/descriptions for known city names via `_extractCityFromTitle()`.
  - Country mapping: `cityCountry(c)` checks `CityList.country` → `_cityCountryMap` (from `systemContinents`) → `areaName`.
  - `_countryRegionMap` and `_countryContinentMap` built alongside `_cityCountryMap` during `_walkTree` for region/continent lookup.
  - Triggered on: date selection, city picker selection, day item add/remove/edit, resource add.
- **Date range picker:** `showDateRangePicker` replaces two separate `showDatePicker`. Single calendar, select start + end. Display: "7月3日 → 7月9日 共7天".
- **Journey start/end cities:** Two independent `_CityPickerRow` widgets (游览起始城市 / 游览结束城市). Distinct from flight departure/arrival cities in the 大交通 section.
- **Reactive totalPeople:** Changed from plain getter to `RxInt` with TextEditingController listeners. `Obx` wraps `.value` for live display.
- **`daysCount` reactive:** `daysCount.obs` for UI binding, avoiding GetX "improper use" errors when Obx wraps non-reactive `TextEditingController.text`.
- New model fields in `JourneyWork`: `departureCity`, `departureCityCountry`, `endCity`, `endCityCountry`.

**Editor city recommendations (2026-07):** When a city is selected for a day, `_loadDayRecommendations` calls 4 real backend APIs to fetch content:
| API | type field | Display name |
|-----|-----------|--------------|
| `/city/attraction` | `attraction` | 景点 |
| `/city/activity` | `activity` | 活动 (expired filtered by `endTime < today`) |
| `/city/restaurant` | `merchant` | 餐厅 |
| `/city/shopping` | `shopping` | 购物 |
- Fallback: 4 generic labels when all APIs fail. `CityResource` extended with `id`/`name`/`imageUrl`/`startTime`/`endTime`.
- **Collapsible categories:** Recommendations grouped by type with tappable section headers (icon + name + count badge + expand arrow). Default collapsed. `_DayCard` converted to StatefulWidget, `_expandedCategories` Set tracks expand state. `_CategoryDef` helper class holds type/label/icon.
- **Type badges on itinerary items:** Items added from recommendations show colored type icons: 🏔 green (`#44B89D`), 🎉 amber (`#F5A623`), 🍽 coral (`#E8734A`), 🛍 blue (`#5B8DEF`). `_typeMeta` Map + `_typeBadge()` method in `_DayCardState`.

**Editor redesign v4 (2026-07):** Country-based titles via city→country mapping:
- **Problem:** Backend `/city/lists` only returns `area_id`/`area_name` (region, e.g. "中歐"), not `country`. Titles fell back to areaName → "中歐几日游".
- **Solution:** Backend `/common/systemContinents` API returns continent→country→city hierarchy tree (with `Cache::remember` 24h TTL). Frontend `ApiUrl.systemContinents = '/common/systemContinents'` routes through standard Dio base URL. Also backend `CityController::enrichCityCountry()` injects `country_name` via `City::whereIn('id', $cityIds)->with('country')` query (with `Cache::remember('city_country_map', 3600)` 1h TTL).
- **`_cityCountryMap`:** `Map<int, String>` mapping city ID → country name, built by `_loadSystemContinents()` which is called after `_loadCityList()`.
- **`_walkTree(node, List<String> ancestors)`:** Recursive tree walker with ancestor chain. **Leaf nodes = cities, ancestors[-1] = country, ancestors[-2] = region (4-level) or continent (3-level), ancestors[0] = continent.** Simultaneously builds three maps: `_cityCountryMap` (city ID→country), `_countryRegionMap` (country→region), `_countryContinentMap` (country→continent). Handles both 3-level and 4-level structures. Includes `debugPrint` logging for diagnostics.
- **`cityCountry(CityList c)`:** Unified country lookup: `CityList.country` (from `country_name` JSON field) → `_cityCountryMap` → `areaName`.
- **`_autoGenerateTitle()`:** Multi-level naming rules (see Editor redesign v2 above). Collects cities from `startCity`/`endCity` + `day.cityBlocks[].cityName` + scanning item titles/descriptions for known city names via `_extractCityFromTitle()`.
- **Labels renamed:** "出发城市"→"游览起始城市", "结束城市"→"游览结束城市" in both `page.dart` (`_CityPickerRow` labels) and `controller.dart` (picker sheet titles, comments).
- City picker subtitles (3 pickers) now use `cityCountry(c)` instead of raw `c.country ?? c.areaName ?? ''`.
- **Bug fix (2026-07-21):** `CityListStore.fetchCityList()` used wrong JSON key `res.dataJson['lists']` (plural) — corrected to `res.dataJson['list']` (singular), matching all other callers of `/city/lists`. Previously `CityListStore.to.cityList` was always empty.
- **Bug fix (2026-07-21):** `_CityPickerRow` now uses `controller.cityCountry(c)` instead of raw `c.country`, matching city picker subtitles.
- **Bug fix (2026-07-25):** `CityList.fromJson` read `json['country']` but backend `enrichCityCountry()` injects `country_name`. Fixed to `json.safeString('country_name') ?? json.safeString('country')`. Previously `CityList.country` was always null, breaking auto-title generation.

**Multi-city per day — `DayCityBlock` (2026-07-25):**
- Each day supports multiple independent city blocks via `ItineraryDay.cityBlocks: List<DayCityBlock>`.
- Each `DayCityBlock` has: `cityId`, `cityName`, `items` (独立活动列表).
- **UI:** Each city block rendered as bordered sub-section within the day card, with its own city name header, items list, add-item button, and city-specific recommendations. «添加城市» button at bottom of day appends new city blocks.
- **Controller methods** all take `blockIndex` parameter: `addDayItem(dayIndex, blockIndex)`, `removeDayItem(dayIndex, blockIndex, itemIndex)`, `updateDayItem(dayIndex, blockIndex, itemIndex, ...)`, `addResourceToDay(dayIndex, blockIndex, resource)`, `pickItemTime(context, dayIndex, blockIndex, itemIndex)`.
- `_CityBlockSection` (StatefulWidget) manages its own expanded-categories state; `_typeBadge` moved to top-level function with top-level `_typeMeta` const.
- `fromJson` backward-compatible: migrates old `city_ids`/`city_names`/`items` format → `cityBlocks` (items assigned to first city block).
- PDF/Word/HTML exports and detail page adapted to render city blocks as sub-sections with `📍 cityName` headers.

**Template display in journey list (2026-07-25):**
- Saved templates automatically appear in the journey list as cards with a 📑「模板」badge (amber color).
- `JourneyWork.fromTemplate()` factory converts `JourneyTemplate` → `JourneyWork` with `isTemplate: true` and `templateSource` reference.
- `JourneyController.fetchData()` calls `_loadLocalTemplates()` to merge templates from SharedPreferences into `allWorks` list.
- Template cards show: region tag, title, people count, day count, cities, and 「点击使用模板创建行程」hint. No date range or status badge.
- Clicking a template card opens editor pre-filled with template data (via `JOURNEY_EDITOR` route with `template` argument).
- Templates are excluded from status/date filtering (always visible).
- Bug fix: API empty response no longer overwrites mock data — `fetchData()` skips replacing `allWorks` if API returns empty list.

**全部模式排序 & 已结束折叠 (2026-07):**
- 全部模式（`statusFilter==0`）下默认隐藏已结束行程，列表按 `startDate` 升序纯平排列（不分块）
- 图例 `_StatusLegend` 中「已结束」默认带删除线（`TextDecoration.lineThrough`），可点击 toggle
- `JourneyController` 新增 `showEnded.obs`（默认 false）和 `toggleShowEnded()`；`_applyFilters()` 中 `statusFilter==0 && !showEnded` 过滤 ended

**FAB create-options sheet (2026-07):** Journey list FAB replaced with `_showCreateOptions` bottom sheet:
- 4 entries: 空白创建 → editor / 从模板创建 → `TemplatePickerSheet` / 拍照导入 (reserved) / 文件导入 (reserved)
- Reserved entries show "即将上线" tag and `Loading.toast`

**Editor draft auto-save (2026-07):**
- 新建工作模式下，表单有内容后自动定时保存草稿到 SharedPreferences（`STORAGE_JOURNEY_DRAFT_KEY`）
- 30 秒定时器 + `onClose()` 最终保存（编辑模式不保存草稿）
- 下次打开新建编辑器时检测草稿：弹窗提示「发现未完成的行程」→ 继续编辑 / 重新开始
- 继续编辑：恢复所有字段（标题、日期、起止城市、交通、人员、费用、应急、每日行程、展开状态）
- 重新开始：清除草稿，空白表单
- 提交成功后自动清除草稿
- 核心方法：`_saveDraft()` (序列化→JSON→SharedPreferences)、`_loadDraft()` / `_restoreFromDraft()` (反序列化恢复)、`_clearDraft()`、`checkDraftAndPrompt(context)` (弹窗)
- `_hasContent()` 判断是否有填写内容；`_toDraftJson()` 序列化所有表单字段

**Template picker/viewer (2026-07):** `TemplatePickerSheet` (`lib/pages/journey/widgets/template_picker_sheet.dart`):
- Bottom sheet (75% height) listing saved templates from SharedPreferences
- Cards show: title, region/days/useCount tags, cities, creation date
- Tap to select → returns `JourneyTemplate`; long-press → `Get.defaultDialog` confirm delete
- `JourneyEditorController.loadFromTemplate()` pre-fills form: title, peopleCount, cities, itineraryDays (dates left empty)

**Detail page redesign (2026-07):** Merged 3 tabs → 2 tabs:
- Tab 0: **行程** (moved to first position, with 「保存为模板」&「生成客户行程」buttons at bottom)
- Tab 1: **详情** (merged 概览 + 原详情: cities/description/personnel → flights/costs/emergency → action buttons)

**Save as template (2026-07):** `onSaveAsTemplate()` → `TemplateSaveDialog` → builds `JourneyTemplate` → saves to SharedPreferences (`STORAGE_JOURNEY_TEMPLATES_KEY`). New files: `widgets/template_save_dialog.dart`.

**Generate client itinerary (2026-07):** `onGenerateClientItinerary()` → `FormatPickerDialog` (image/PDF/Word) → preview dialog with `ClientItineraryPreview` watermark card → generate file → `Share.shareXFiles()`. See [[journey-feature]].
- Three export formats: RepaintBoundary capture (PNG), `pdf: ^3.11.1` package (PDF), HTML string → `.doc` (Word)
- Watermark: centered, 45° tilted **LUMO** text (36.sp, opacity 0.08) — applied across all 3 formats
- New files: `widgets/client_itinerary_preview.dart`, `widgets/format_picker_dialog.dart`
- Controller: `_shareAsImage`, `_shareAsPdf` (_buildPdfDocument), `_shareAsWord` (_buildHtmlDocument)

**UI design spec:**
- Search bar: white capsule input (38.h) + separate purple square search button (10.w border radius)
- Calendar card: 14.w radius, light shadow
- Legend: small squares (2.w radius) not circles
- Work cards: NO left color strip. Header row (region tag + title + status capsule), detail rows stacked vertically (icon + text per row), 14.w card radius with light shadow
- Date format: short `MM/dd - MM/dd日`

**Critical bug fixes:**
1. **`Obx` wrapping `CustomScrollView` → `_dependents.isEmpty` crash:** `CustomScrollView` internally creates `Scrollable` (StatefulWidget). Fixed by removing outer `Obx` and using local `Obx` only for the sliver list/empty section (returns `SliverPadding` > `SliverList` or `SliverToBoxAdapter`, neither is StatefulWidget).
2. **Nested ScrollView → RenderViewport error:** `EmptyListWidget` (contains `ListView`) inside `SliverToBoxAdapter` caused Viewport nesting. Fixed with `_JourneyEmptyWidget` (Center + Column, no ListView).
3. **Page blank for 2-3 seconds:** `fetchData()` waited for API timeout before fallback. Fixed: mock data renders immediately, API request runs in background.
4. **Calendar month switching not working:** `_focusedMonth` Rx updated but `TableCalendar` outside `Obx` so it didn't rebuild. Fixed: expose `focusedMonthRx` in controller, use `ever(focusedMonthRx, setState)` in `_JourneyCalendarState.initState`.

### IM (Tencent Cloud Chat)

`TIMStore` manages the IM SDK lifecycle: init → login with userSig → register push → maintain conversation/friend lists. SDK App ID: `1600121769`. User credentials (`userNumber`, `userSig`) come from the login API response and are stored in shared_preferences. On `onKickedOffline` or `onUserSigExpired`, the user is force-logged-out.

### Multi-language

`TranslationService` extends `GetxController` + `Translations`. Three locales: `zh_CN`, `zh_TW`, `en_US`. UI strings use `.tr` extension. Language preference persisted via `LocalizationService`.

### Plugins override

`plugins/tencent_cloud_chat_uikit/` contains a patched copy of the more-panel widget (adds custom buttons). This overrides the package's source.

### Stripe

`StripeService.presentPaymentSheet` handles the payment flow: present sheet → verify PaymentIntent status → verify order with backend via `vipPayStatus` endpoint. Publishable key in code (live key), fallback if system config has a custom key.

## Patched dependencies

`patched_packages/extended_text_field/` is a locally patched copy of `extended_text_field` 16.0.2, loaded via `dependency_overrides` in pubspec.yaml. 

**Why:** Flutter 3.44 removed `ExtendSelectionByPageIntent` from the services package. `extended_text_field` (a transitive dependency of `tencent_cloud_chat_uikit`) references this class in `editable_text.dart`, causing compile errors on all platforms. The patch removes the `_extendSelectionByPage` method and its action binding.

## Known issues

1. **`extended_text_field` 与 Flutter 3.44 不兼容:** 上述补丁已修复。若 `flutter pub get` 后补丁失效，检查 `pubspec.yaml` 中 `dependency_overrides` 是否仍指向 `patched_packages/extended_text_field`。
2. **macOS `--start-paused` 断连:** Android Studio 运行 macOS 时 `--start-paused` 会导致 "Lost connection to device"。从终端直接 `flutter run -d macos` 或在 Run Configuration 中去掉该参数。
3. **`_loadConfig()` 网络超时:** `lib/pages/welcome/controller.dart` 中版本检查请求已加 try-catch + 10s 超时，请求失败不再阻塞导航。
4. **Code Runner 抢占 VS Code ▶ 按钮导致 FFI 编译崩溃:** Code Runner 扩展的 `dart` executor 会直接调用 `dart` VM 而非 Flutter 框架，导致 `InvalidType/FfiUseSiteTransformer` kernel 编译错误。永远用 **F5** 或菜单栏 **Run → Start Debugging** 启动 Flutter 应用，不要用 Code Runner。
5. ✅ **flutter_screenutil 在 macOS 上等比放大导致 UI 过大:** `ScreenUtil.init()` + 桌面大窗口 → scaleWidth 可达 3.84，`.w` 组件超大。已修复：用 `ScreenUtilInit` widget 替代，桌面端套 `ConstrainedBox(maxWidth: 600)` 居中内容，`MainFlutterWindow.swift` 设 minSize 400×600 + 默认 450×800。
6. **iOS CocoaPods 依赖版本冲突（`flutter pub get` 后必须修复）:** `pubspec.lock` 中的 `stripe_ios 12.6.0` 和 `tencent_cloud_chat_push 8.9.7538` 需要比 `Podfile.lock` 更新的原生 SDK 版本，且 `tencent_cloud_chat_push` 和 `tencent_cloud_chat_sdk` 对 `TXIMSDK_Plus_iOS_XCFramework` 的 `~>` 约束互斥。**每次 `flutter pub get` 后**需修改两个 podspec 文件：
   - `ios/.symlinks/plugins/tencent_cloud_chat_push/ios/tencent_cloud_chat_push.podspec` — `TXIMSDK_Plus_iOS_XCFramework` 加 `'>= 8.9.7537'` 约束
   - `ios/.symlinks/plugins/tencent_cloud_chat_sdk/ios/tencent_cloud_chat_sdk.podspec` — 将 `"~> 8.8.7373"` 改为 `">= 8.8.7373"`
   - 然后删除 `ios/Podfile.lock`，运行 `pod install --repo-update`
   - 详见 [[ios-podspec-patches]]
7. **`Obx` 包裹 `CustomScrollView` 或含 StatefulWidget 的子组件会导致 `_dependents.isEmpty` 崩溃:** GetX 的 `Obx` 重建时会 dispose 旧 widget tree。如果包裹了 StatefulWidget（如 `CustomScrollView` 内建的 `Scrollable`、`TableCalendar` 等），旧 state 被 dispose 时仍有依赖残留，触发断言失败。解决方案：① 只用 `Obx` 包裹非 StatefulWidget 的叶子组件（如 `Text`、`Container`）；② 如果必须包裹 StatefulWidget，用 `ValueKey` 强制重建；③ 把 StatefulWidget 拆成独立 StatefulWidget + 内部局部 `Obx`。
8. **macOS App Sandbox 缺网络权限导致所有 API 请求失败:** `DebugProfile.entitlements` 和 `Release.entitlements` 需要添加 `com.apple.security.network.client` 权限，否则沙箱会阻止所有 HTTP 请求。已在两个 entitlements 文件中添加。详见 [[macos-network-entitlement]]。
9. **Journey Editor `onSubmit()` 未调用 API:** 后端 JourneyWork CRUD 接口已就绪（`/user/journeyList|Detail|Create|Update|Delete`），但前端 `lib/pages/journey_editor/controller.dart:714` 的 `onSubmit()` 和 `onSaveAsTemplate()` 仍是 stub（仅显示 toast 并关闭页面，不发送 HTTP 请求）。后续需对接 API。

## New machine setup

见 `SETUP.md` — 含完整环境检查清单和安装命令，可供 Claude Code 逐条执行配置新 MacBook。
