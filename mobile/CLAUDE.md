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

### API layer

- `ApiProvider` is a singleton Dio wrapper. All HTTP methods return `ApiResult` (never throws).
- `ApiMixin` is a mixin that delegates to `ApiProvider` — mix this into any controller/service that needs network access.
- `ApiResult` provides `.isSuccess`, `.dataJson` (single object), `.dataList` (array), `.message`.
- `AuthInterceptor` attaches the Bearer token from `UserStore.to.token` to every request.
- API URLs are static string constants in `ApiUrl` class. Dev mode is toggled via `ApiUrl._isDev` (currently `false`).

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
| `/journey_detail` | `JourneyDetailPage` | Work detail with route info, link to bookings |
| `/journey_editor` | `JourneyEditorPage` | Create/edit work trip form with auto day-by-day content |

**Data model:** `JourneyWork` (`lib/common/models/journey_work.dart`) with `JourneyWorkStatus` enum (inProgress=1, pending=2, ended=3). Backend API `GET /user/journeyList` is TODO — `mockData()` provides 4 sample entries as fallback. Mock data loaded immediately (no API wait) to avoid blank screen.

**Dynamic status (`effectiveStatus`):** Status is computed from dates relative to today, not stored:
- 进行中：startDate ≤ today ≤ endDate
- 待出发：startDate > today
- 已结束：endDate < today
- Filtering and card display use `effectiveStatus`/`effectiveStatusValue`

**Calendar date backgrounds:** Each date cell is color-coded by work status:
- 进行中 → jadeGreen 25% background + green dot
- 待出发 → primary 15% background + purple dot
- 已结束 → assistantText 12% background + gray dot
- Priority when overlapping: inProgress > pending > ended
- `_JourneyCalendar` is StatefulWidget; only the header row uses `Obx`; `TableCalendar` has `ValueKey(focusedMonth)` to prevent `_dependents.isEmpty` assertion failures.

**Editor redesign (2026-07):** Simplified to natural trip-planning flow:
- Departure: date (tap → system date picker) + city
- Return: date + city
- **Auto day-by-day content:** When both dates are filled, automatically generates content fields for each day (e.g., 「第1天 (7/3)」, 「第2天 (7/4)」…) with light purple background
- Removed: arrival method/time/location, departure method, cities list, manual status selector (status is date-derived)

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

## New machine setup

见 `SETUP.md` — 含完整环境检查清单和安装命令，可供 Claude Code 逐条执行配置新 MacBook。
