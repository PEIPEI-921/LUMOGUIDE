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

## New machine setup

见 `SETUP.md` — 含完整环境检查清单和安装命令，可供 Claude Code 逐条执行配置新 MacBook。
