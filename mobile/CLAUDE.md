# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LUMOGUIDE (`lumotrip`) — a Flutter travel guide app for iOS and Android. App name in code: **LUMOGUIDE**, version 1.0.6+21. Backend API at `https://api.lumoguide.com/api/`.

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
| `/journey` | `JourneyPage` | Work list with search (title+city+country), status/continent filters, calendar, work cards |
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

**Calendar (30-day grid, redesigned 2026-07-27):** `_JourneyCalendar` replaced `TableCalendar` with a custom 5×6 grid:
- **30 days, today centered:** 10 days before today (gray text, past) + today + 19 days after (black text, future)
- **No external dependency:** `table_calendar` package removed from journey page imports
- Each cell: weekday label (7.sp) + date number (12.sp) + colored dots per work (max 3 dots, status-colored: green=inProgress, purple=pending, gray=ended)
- **Today:** purple outlined circle (26.w, no background fill). **Past dates:** gray text. **Future dates:** black text.
- **Click date with works** → bottom sheet lists all works for that day (color-coded left border, title, date range, status badge) → tap work → detail page
- Sorting in bottom sheet: inProgress > pending > ended, then by startDate ascending
- `Obx(() { final _ = controller.allWorks; ... })` triggers rebuild on data change — StatelessWidget, no Worker/StatefulWidget needed
- `_DayCell` StatelessWidget, `_JourneyCalendar` StatelessWidget with Obx. `_kCalBefore = 10` controls past/future ratio (10 past + 1 today + 19 future = 30)
- See [[journey-feature]].

**Search (enhanced 2026-07-27):** Matches title + city name + country name + region:
  - `_workMatchesSearch(w, kw)` checks multiple fields; `_allCityNames(w)` collects city names from all sources (cities list, departureCity, endCity, cityBlocks)
  - `_cityNameToCountry` map filled by `_mergeCityNamesFromStore()` for country-name lookup

**Continent filter (fixed 2026-07-27):** Continent-level only (Asia, Europe, etc.):
  - **Root cause:** `systemContinents` API returns simplified Chinese but work data stores traditional Chinese city names → string mismatch
  - **Fix:** `_mergeCityNamesFromStore()` populates `_cityNameToContinent` via `CityListStore.to.cityList` names bridged by city ID → `_cityCountryMap` → `_countryContinentMap`
  - `_allCityNames(w)` aggregates from all sources; filter hidden when `regions.length <= 1`

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

**Template display in journey list (2026-07-27 redesigned):**
- **Templates no longer appear in the work card list.** Previously loaded via `_loadLocalTemplates()` and merged into `allWorks` as template cards. Now templates are only accessible via FAB → 「从模板创建」→ `TemplatePickerSheet`.
- `_loadLocalTemplates()`, `fromTemplate()` conversion, `isTemplate` skip-logic in `_applyFilters()`, `onTapWork()` template routing, and `_buildTemplateCard()` widget all removed.
- Template save/load still works via `TemplatePickerSheet` reading directly from `STORAGE_JOURNEY_TEMPLATES_KEY`.

**全部模式排序 & 已结束折叠 (2026-07):**
- 全部模式（`statusFilter==0`）下默认隐藏已结束行程，列表按 `startDate` 升序纯平排列（不分块）
- 图例 `_StatusLegend` 中「已结束」默认带删除线（`TextDecoration.lineThrough`），可点击 toggle
- `JourneyController` 新增 `showEnded.obs`（默认 false）和 `toggleShowEnded()`；`_applyFilters()` 中 `statusFilter==0 && !showEnded` 过滤 ended

**FAB create-options sheet (2026-07):** Journey list FAB replaced with `_showCreateOptions` bottom sheet:
- 4 entries: 空白创建 → editor / 从模板创建 → `TemplatePickerSheet` / 拍照导入 (reserved) / 文件导入 (reserved)
- Reserved entries show "即将上线" tag and `Loading.toast`

**Editor draft auto-save (2026-07, fixed 2026-07-27):**
- 新建工作模式下，表单有内容后自动定时保存草稿到 SharedPreferences（`STORAGE_JOURNEY_DRAFT_KEY`）
- 30 秒定时器 + `onClose()` 最终保存（编辑模式不保存草稿）
- 下次打开新建编辑器时检测草稿：弹窗提示「发现未完成的行程」→ 继续编辑 / 重新开始
- 继续编辑：恢复所有字段（标题、日期、起止城市、交通、人员、费用、应急、每日行程、展开状态）
- 重新开始：清除草稿，空白表单
- 提交成功后自动清除草稿
- 核心方法：`_saveDraft()` (序列化→JSON→SharedPreferences)、`_loadDraft()` / `_restoreFromDraft()` (反序列化恢复)、`_clearDraft()`、`checkDraftAndPrompt(context)` (弹窗)
- `_hasContent()` 判断是否有填写内容；`_toDraftJson()` 序列化所有表单字段
- **Bug fix (2026-07-27): `_restoring` flag** — prevents `_syncDays` and `_autoGenerateTitle` from overwriting the saved title during draft restore (date controllers trigger `_syncDays` → `_autoGenerateTitle` before `_cityCountryMap` is loaded). After `_loadSystemContinents()` completes, regenerates title with proper country info.
- **Bug fix (2026-07-27): `_restoreDayRecommendations()`** — after restoring itinerary days from draft, iterates all city blocks and calls `_loadDayRecommendations()` to fetch attraction/activity/restaurant/shopping recommendations. Also rebuilds `usedResourceKeys` from restored items.
- **Bug fix (2026-07-27): `_submitted` flag** — prevents `onClose()` from re-saving draft after successful submit. Root cause: `onSubmit()` → `_clearDraft()` → `Get.back()` → `onClose()` → `_hasContent()` still true → `_saveDraft()` re-creates draft.
- **Bug fix (2026-07-27): Resource dedup** — `usedResourceKeys` (`Set<String>.obs`, format: `"$type:$id"`) tracks which recommendation items have been added to the itinerary. `isResourceUsed(r)` filters UI, `_markResourceUsed(r)` on add, key released on `removeDayItem()`/`removeDayCity()`. Ensures same recommendation is selected only once per work.

**Template picker/viewer (2026-07):** `TemplatePickerSheet` (`lib/pages/journey/widgets/template_picker_sheet.dart`):
- Bottom sheet (75% height) listing saved templates from SharedPreferences
- Cards show: title, region/days/useCount tags, cities, creation date
- Tap to select → returns `JourneyTemplate`; long-press → `Get.defaultDialog` confirm delete
- `JourneyEditorController.loadFromTemplate()` pre-fills form: title, peopleCount, cities, itineraryDays (dates left empty)

**Detail page redesign (2026-07):** Merged 3 tabs → 2 tabs:
- Tab 0: **行程** (moved to first position, with 「保存为模板」&「生成客户行程」buttons at bottom)
- Tab 1: **详情** (merged 概览 + 原详情: cities/description/personnel → flights/costs/emergency → action buttons)

**Save as template (2026-07, fixed 2026-07-27):** 
- Detail page: `onSaveAsTemplate()` → `TemplateSaveDialog` → builds `JourneyTemplate` → saves to SharedPreferences (`STORAGE_JOURNEY_TEMPLATES_KEY`).
- Editor page: **Fixed from stub.** `onSaveAsTemplate()` was a no-op (only showed toast). Now implemented: collects cities/hotels from form → shows `TemplateSaveDialog` for naming → builds `JourneyTemplate` → appends to SharedPreferences list. Imports `TemplateSaveDialog` from `journey_detail/widgets/template_save_dialog.dart`.

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
4. ~~**Calendar month switching not working:**~~ **Obsolete (2026-07-27).** `TableCalendar` removed entirely. Replaced with custom 5×6 grid calendar (`_JourneyCalendar` StatelessWidget + Obx).

### IM (Tencent Cloud Chat)

`TIMStore` manages the IM SDK lifecycle: init → login with userSig → register push → maintain conversation/friend lists. SDK App ID: `1600121769`. User credentials (`userNumber`, `userSig`) come from the login API response and are stored in shared_preferences. On `onKickedOffline` or `onUserSigExpired`, the user is force-logged-out.

### System Messages（系統消息 / 系统消息，2026-07-27）

消息模塊位於 `lib/pages/message/`，系統消息子模塊在 `lib/pages/message_system/`。

**架構：**
| 路由 | 頁面 | 說明 |
|------|------|------|
| `/message` | `MessagePage` | 消息大廳：頂部固定入口（關注/評論/預定）+ IM 會話列表 |
| `/message_system` | `MessageSystemPage` | 系統消息列表，分頁加載，點擊進入詳情 |
| 詳情（push） | `MessageSystemDetailPage` | 系統消息詳情頁，支援富文本及跳轉 |

**數據模型：** `MessageSystemModel`（`lib/common/models/message.dart:133`）
- `title` — 標題（列表和詳情頁標題行顯示）
- `desc` — 簡短摘要（列表頁顯示）
- `content` — 完整正文（詳情頁 RichText 渲染）
- `content_type` — 內容類型，決定跳轉行為：
  - `"city"` → 城市詳情（`/city_detail`）
  - `"city_content"` → 通用詳情（景點/活動/餐廳等）
  - `"membership"` → 會員中心（`/member_center`）
- `content_id` / `city_id` / `cityContentType` — 跳轉參數

**詳情頁富文本（2026-07-27 重構）：**
- 城市名高亮顯示（`#666FFF`），中英雙語格式「首爾 (Seoul)」，可點擊跳轉城市詳情
- 會員類型消息連結文字顯示「前往會員中心」，點擊跳轉會員中心頁面
- 使用 `StatefulWidget` + `TapGestureRecognizer` 管理手勢生命週期
- 當城市名已高亮可點擊時，不再重複顯示「查看詳情」連結

**會員到期提醒（2026-07-27）：**
- 前端 `MessageSystemModel` 已支援 `content_type: "membership"`，後端排程發送消息後前端自動適配
- 詳情頁連結文字為「前往會員中心」，點擊跳轉 `/member_center`
- 後端實現文檔：`docs/backend-member-expiry-reminder.md`（含 Laravel Command、Mailable、四階段雙語內容模板、API 合約）

### Multi-language

`TranslationService` extends `GetxController` + `Translations`. Three locales: `zh_CN`, `zh_TW`, `en_US`. UI strings use `.tr` extension. Language preference persisted via `LocalizationService`.

### Plugins override

`plugins/tencent_cloud_chat_uikit/` contains a patched copy of the more-panel widget (adds custom buttons). This overrides the package's source.

### Stripe

`StripeService.presentPaymentSheet` handles the payment flow: present sheet → verify PaymentIntent status → verify order with backend via `vipPayStatus` endpoint. Publishable key in code (live key), fallback if system config has a custom key.

### Deep Link & Share QR Code（2026-07-24）

**URL Scheme:** `lumoguide://share?c=INVCODE&t=<type>&i=<id>`，两端已注册。

| 文件 | 用途 |
|------|------|
| `lib/common/services/deep_link.dart` | `DeepLinkService` — stream 监听 + 冷启动 URI，解析后跳转详情页；`ClipboardService` — 首次安装从剪贴板恢复 deep link |
| `lib/common/widgets/share_qrcode_dialog.dart` | `ShareQrcodeDialog` — 调用 `/common/shareQrcode` API 获取 PNG 二维码并展示 |
| `lib/common/apis/provider.dart` | 新增 `getBytes()` 方法，用于二进制图片响应（不走 JSON 解析） |

**Deep link 路由映射：**
| type | 目标页面 | 参数 |
|------|---------|------|
| `guide` | `/guide_detail` | `{'id': id}` |
| `city` | `/city_detail` | `{'id': id}` |
| `content` | `/common_detail` | `{'id': id}` |
| `trip` | `/journey_detail` | `{'id': id}` |

**分享入口：** 导游详情、城市详情、景点/餐厅等详情、工作详情 四个页面的 AppBar 均有 `qr_code` 图标。

**依赖：** `app_links: ^6.4.0`（deep link 监听）

**设计文档：** `flutter-share-deeplink.md`（服务端配合的完整流程，含 share.html 落地页、延迟 deep link、邀请码绑定）

**Bug fix（2026-07-26）：** `_handleDeepLink` 中 `int.parse(id)` 在非数字 ID 时会抛 FormatException → stream 订阅被取消 → 后续所有 deep link 永久失效。已修复：`int.tryParse()` + try-catch + stream `onError` handler。

### TestFlight 部署

`docs/testflight-deploy-with-claude.md` — 配合 Claude Code 使用的 TestFlight 上传教程，供同事的 Claude Code 逐步骤引导操作。

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
7. **`Obx` 包裹 `CustomScrollView` 或含 StatefulWidget 的子组件会导致 `_dependents.isEmpty` 崩溃:** GetX 的 `Obx` 重建时会 dispose 旧 widget tree。如果包裹了 StatefulWidget（如 `CustomScrollView` 内建的 `Scrollable` 等），旧 state 被 dispose 时仍有依赖残留，触发断言失败。解决方案：① 只用 `Obx` 包裹非 StatefulWidget 的叶子组件（如 `Text`、`Container`）；② 如果必须包裹 StatefulWidget，用 `ValueKey` 强制重建；③ 把 StatefulWidget 拆成独立 StatefulWidget + 内部局部 `Obx`。
8. **macOS App Sandbox 缺网络权限导致所有 API 请求失败:** `DebugProfile.entitlements` 和 `Release.entitlements` 需要添加 `com.apple.security.network.client` 权限，否则沙箱会阻止所有 HTTP 请求。已在两个 entitlements 文件中添加。详见 [[macos-network-entitlement]]。
9. ✅ **Journey Editor `onSubmit()` 已对接 API（2026-07-27 更新）:** 
   - `onSubmit()` 实现完整 API 调用：新建调 `POST /user/journeyCreate`，编辑调 **`PUT /user/journeyUpdate`**（后端对 POST 返回 405 Method Not Allowed，必须用 PUT）
   - `_buildSubmitPayload()` 构建完整提交数据（航班、日行程、费用、应急、区域等）
   - `_buildFlightJson()` 从 3 个独立 controller 组装航班 JSON
   - `_computeRegion()` 根据城市集合计算所属大洲/地区
   - JSON 字段采用 snake_case（如 `departure_city`、`arrival_flight`），匹配后端 `expandJourneyWork()` 输出格式
   - 新增 API 地址常量：`userJourneyDetail`/`Create`/`Update`/`Delete`/`TemplateList`/`TemplateSave`/`TemplateDelete`
   - `JourneyDetailController` 已添加 `ApiMixin`，详情优先使用传入 work 对象，兜底调 API
   - **Mock 数据已移除:** `JourneyWork.mockData()` 返回空数组，`JourneyController.fetchData()` 直接从 API 加载
   - 编辑模式需通过 `isEdit.obs` + `_workId` 判断，`_workId` 从传入的 `work.id` 获取
10. **Android NDK 下载损坏导致编译失败:** AGP 自动下载的 NDK 可能缺少 `source.properties`，报错 `[CXX1101] NDK at ... did not have a source.properties file`。解决方案：删除损坏的 NDK 目录（如 `~/Library/Android/sdk/ndk/28.2.13676358`），重新编译时 AGP 会自动重新下载。Flutter 也会提示具体路径和修复步骤。
11. **Flutter 3.44.4 Android 版本要求:** Flutter 3.44.4 会警告并要求以下最低版本，否则编译会失败（不仅仅是 warning）：
    - Gradle ≥ 8.14.0（`android/gradle/wrapper/gradle-wrapper.properties`）
    - AGP ≥ 8.11.1（`android/settings.gradle` 中 `com.android.application`）
    - Kotlin ≥ 2.2.20（`android/settings.gradle` 中 `org.jetbrains.kotlin.android`）
    
    当前已升级到这些版本（2026-07-24）。
12. **Android APK 编译需要代理/VPN:** 国内网络环境无法直接访问 `repo.maven.apache.org`（Cloudflare 403）和 `dl.google.com`（Connection refused），导致 Gradle 插件依赖（kotlin-dsl、AGP buildscript classpath）和 Android SDK 组件无法下载。解决方案：开启系统代理后在 `android/gradle.properties` 中配置 `systemProp.java.net.useSystemProxies=true`，或配置 `systemProp.https.proxyHost/Port`。
13. ✅ **发布页面文本字段/图片未提交 bug（2026-07-26 修复，2026-07-30 补齐提交）:** 6 个发布页面（city/activity/attraction/facility/information/transportation）的 `onSubmit()` 直接调用 `model.toJson()`，但 TextEditingController 的值和 RxList pictures 从未同步到 model 对象。级联选择器正常是因为直接调 `_publish.update()`。**⚠️ 2026-07-30 发现：此修复只存在于 working tree，从未 git commit。** 修复已补齐提交：在每个 `onSubmit()` 调 `toJson()` 之前，先 `_publish.update()` 同步所有 controller 值 + `pictures.toList()`。受影响文件：`lib/pages/publish_*/controller.dart`（6 个文件）。详见 [[publish-form-sync-bug]]。
14. ✅ **macOS 桌面端图片选择器不工作（2026-07-26 修复）:** 两个原因：
    - `macOS/Runner/*.entitlements` 缺少 `com.apple.security.files.user-selected.read-only` 权限，系统文件选择器无法弹出
    - `image_cropper` 插件不支持 macOS 桌面端，`ImageCropper().cropImage()` 返回 null 导致 `selectImage()` 返回空字符串
    - 修复：entitlements 添加文件权限；`ImagePickerUtil` 新增 `_supportsCrop` getter（`!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux`），桌面端跳过裁剪直接返回原图
15. ✅ **发布页面图片上传缺失（2026-07-27 修复，2026-07-30 补齐提交）:** 6 个发布页面的 `onSubmit()` 直接把本地文件路径发给后端，未先上传图片获取远程 URL。其他页面（评价、商家编辑等）都使用 `ConfigService.to.uploadFile()` 先上传再提交 URL。**⚠️ 2026-07-30 发现：此修复只存在于 working tree，从未 git commit。** 修复已补齐提交：每个 `onSubmit()` 开始前调 `_uploadFiles()` 逐一上传本地图片（已是远程 URL 的跳过），最后用 URL 列表替换本地路径提交。`_uploadFiles()` 方法：遍历 `pictures` 列表，`http` 开头的保留原值，其余调 `ConfigService.to.uploadFile(e)` 上传。受影响文件：`lib/pages/publish_*/controller.dart`（6 个文件）。
16. **Journey 详情页增强（2026-07-27）:**
    - **删除按钮**：AppBar 新增 🗑 图标，编辑器底部新增「删除此工作」红色按钮。`onDeleteWork()`（注意不能叫 `onDelete`，GetX 生命周期有同名方法）先弹确认框，再调 `POST /user/journeyDelete`。两处入口：详情页 `JourneyDetailController` + 编辑器 `JourneyEditorController`。
    - **行程内容可点击**：`_DayDetailCard` 中城市名和行程项改为 `GestureDetector` 包裹。城市点击：有 `cityId` → `/city_detail?id=cityId`，无 → `/publish_city`。行程项点击：有 `resourceId` + `resourceType` → `/common_detail` 对应详情，无 → 对应发布页（attraction→publish_attraction, activity→publish_activity, restaurant/meal→publish_facility, shopping→publish_facility, transport→publish_transportation）。映射方法：`_mapResourceTypeToCommonDetailType()`（attraction→scenic, activity→activity, restaurant→restaurant, shopping→shopping, transport→traffic, hotel→hotel）。
17. ✅ **Journey 列表地区筛选修复 v2（2026-07-27）:** API 返回的 `region` 字段为 null，且 `_cityNameToContinent` 的 77 个条目无法匹配到任何工作的城市名 → 地区筛选消失。**根因：繁简中文不匹配** — `systemContinents` API 返回简体中文城市名（萨尔茨堡），但工作数据是繁体中文（薩爾茨堡），字符串匹配失败。**修复：** 新增 `_mergeCityNamesFromStore()` 方法，用 `CityListStore.to.cityList`（app 当前语言，与编辑器一致）的城市名通过 city ID 桥接填充 `_cityNameToContinent`。同时填充 `_cityNameToCountry`（城市名→国家名）供搜索使用。`_allCityNames(w)` 汇总所有城市名来源（cities + departureCity + endCity + cityBlocks）。搜索增强：`_workMatchesSearch()` 匹配标题 + 城市名 + 国家名 + region。
18. **ApiResult 错误消息增强（2026-07-27）:** `_getBasicErrorMessage()` 在 `response.data` 非 Map 时，现在返回 `Request failed [状态码] 响应体` 格式（原只返回 `Request failed`），便于调试后端 405/500 等错误。
19. ✅ **发布流程健壮性增强 + 401 拦截修复（2026-07-30）:** 详见 [[publish-form-sync-bug]]。
20. ✅ **導遊認證新增「常駐城市」（2026-07-31）:** 導遊認證「基礎信息」頁新增必填欄位「我的常駐城市」。兩種模式：① 選擇現有城市 → `CityPickerSheet`；② 新增城市 → 輸入中/英文名 + 大洲→地區→國家三級聯動。Model 新增 12 個字段（`resident_city_id/name`, `is_new_city`, `new_city_*`）。提交 payload 區分 `is_new_city=0`（現有）和 `is_new_city=1`（新增）。後端文檔：`docs/backend-guide-resident-city.md`。詳見 [[guide-certification]]。
21. ✅ **導遊認證 + 企業入駐 — 草稿自動保存/恢復（2026-07-31）:** 表單任一字段變化 → 400ms 防抖 → `SharedPreferences` 保存 JSON。進入頁面 → 非只讀 → 檢測草稿 → `DraftPromptCard` 彈窗「繼續編輯/重新填寫」。圖片只保存 http URL，不保存本地路徑。提交成功或點擊重新填寫時清除。`guide_certify_draft` / `merchant_entry_draft`。共用 widget：`lib/common/widgets/draft_prompt.dart`。詳見 [[guide-certification]]、[[publish-form-sync-bug]]。
22. ✅ **企業入駐三個 Bug 修復（2026-07-31）:** ① `_uploadImages()` 改用逐文件串行上傳（不再 `Future.wait` 批量），單文件失敗不影響其他；② `_restoreFromDraft()` 補回 `cityId` 恢復邏輯；③ 所在城市/經營類型/簡介/Email/聯繫電話補上 `isRequired: true` + 驗證邏輯取消註解。詳見 [[publish-form-sync-bug]]。
23. ✅ **城市詳情頁 5 個內容 tab 列表渲染 bug（2026-07-31 修復）:** 票務(type=8)、活動(type=7)、設施(type=6)、住宿(type=4)、餐廳(type=2) 五個 tab 的 widget 中，`if (list.isEmpty)` 和 `else` 分支都返回 `EmptyListWidget()` → 即使 API 成功返回數據也永遠顯示空白。**根因：這 5 個 widget 是未完成的 stub，非空分支未實現實際列表渲染。**

   **修復：** 5 個 widget 的非空分支改為 2 列 `GridView.builder`（卡片佈局：封面圖 + 名稱 + 電話 + 地址），與已正常工作的交通(traffic)/購物(shopping) widget 一致。同時 controller 新增 5 個 `onTap*Item()` 方法（ticket/activity/facility/hotel/restaurant），點擊卡片導航到 `/common_detail` 對應 type_id。

   **受影響文件：**
   - `lib/pages/city_detail/widgets/ticket.dart` — `_TicketItem` + `onTapTicketItem()`
   - `lib/pages/city_detail/widgets/activity.dart` — `_Item` + `onTapActivityItem()`
   - `lib/pages/city_detail/widgets/facility.dart` — `_Item` + `onTapFacilityItem()`
   - `lib/pages/city_detail/widgets/hotel.dart` — `_Item` + `onTapHotelItem()`
   - `lib/pages/city_detail/widgets/restaurant.dart` — `_Item` + `onTapRestaurantItem()`
   - `lib/pages/city_detail/controller.dart` — 新增 5 個 `onTap*Item()` 方法 + 保留已有的 `onTapTicketItem()`

   **注意：** 各 `_Item` 類是 widget 文件私有的（非共用），因為每個需要調用不同的 `controller.onTap*Item()` 方法。未來可考慮抽取共用卡片 widget 通過 callback 參數區分導航目標。

   詳見 [[city-detail-tab-rendering-bug]]。

24. ✅ **企業入駐經營類型二級聯動（2026-08-01）:** 企業入駐表單第二步「商家類型」從單一平鋪字串選擇器改造為二級聯動選擇器。第一級選 `MerchantShopType`（餐廳/購物/住宿/票務/景點），第二級根據第一級動態載入子分類（來自 `ConfigService.typeCategories`，快取空時即時請求 `/common/getTypeClass`）。`MerchantEntry` 模型新增 `typeId`(int)、`typeClassId`(int)、`typeClassName`(String)，保留 `businessType` 相容舊資料。提交 payload 同時輸出 `type_id`/`type_class_id`/`type_class_name`，後端審核通過後可直接建立對應商鋪。詳見 [[enterprise-business-type-cascade]]。

    **受影響文件：**
    - `lib/common/models/merchant_entry.dart` — 新增 3 個字段
    - `lib/pages/merchant_entry/widgets/business_type.dart` — 單一選擇器 → 二級聯動
    - `lib/pages/merchant_entry/controller.dart` — `selectBusinessType()` 改用枚舉 + 新增 `selectBusinessSubtype()` + 驗證/草稿適配

25. ✅ **企業會員隱藏「我的歷程」（2026-08-01）:** `MineController.menus` getter 中，企業會員（`isEnterprise`）分支移除 `MineMenu.journey`。導遊和普通用戶不受影響。詳見 [[enterprise-hide-journey]]。

    **受影響文件：** `lib/pages/mine/controller.dart`

26. ✅ **圖片上傳支援所有格式 HEIC/GIF/WebP/BMP（2026-08-01）:** `ConfigService.uploadFile()` 重構為智能上傳流程：
    - GIF → 跳過壓縮，直接上傳原檔以保留動畫
    - 其他格式 → 先嘗試 `compressImageToSize()` 壓縮為 JPEG
    - 壓縮失敗（HEIC 在部分平台）→ 自動回退上傳原檔（保留原始 MIME 類型）
    - `readAsBytesSync()` → `await readAsBytes()` 避免阻塞主線程
    - MIME 根據副檔名自動檢測（heic→`image/heic`, webp→`image/webp`…）
    - `uploadFileDebug()` 同步更新為相同邏輯
    
    詳見 [[image-upload-all-formats]]。

    **受影響文件：** `lib/common/services/config.dart`

27. ✅ **首頁資訊分類自動輪播（2026-08-01）:** 首頁資訊區塊自動每 5 秒切換下一個分類（與導遊輪播類似）。
    - 用戶手動點擊分類 pill → 暫停 5 秒後恢復
    - 用戶向下滑動頁面（`ScrollUpdateNotification.dragDetails != null`）→ **永久停止**自動輪播
    - 下拉刷新後恢復自動輪播
    
    詳見 [[homepage-info-auto-scroll]]。

    **受影響文件：**
    - `lib/pages/home/controller.dart` — 新增 `_infoAutoScrollTimer` + 3 個公開方法
    - `lib/pages/home/page.dart` — `NotificationListener<ScrollUpdateNotification>` 包裹 `EasyRefresh`
    - `lib/pages/home/widgets/information.dart` — 分類點擊改用 `onInfoCategoryTap()`

## New machine setup

见 `SETUP.md` — 含完整环境检查清单和安装命令，可供 Claude Code 逐条执行配置新 MacBook。
