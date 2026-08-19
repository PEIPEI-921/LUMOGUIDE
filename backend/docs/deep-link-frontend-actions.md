# 深鏈掃碼直開 — 前端待辦清單（2026-08-05 整理）

> 完整參考：`docs/deep-link-frontend-todo.md`（含後端接口、測試清單）。本文檔只列**前端仍需做的事項**，按優先級排列，可直接轉交前端。
> 後端已全部就緒（2026-08-04 修復並驗證）：assetlinks.json 冒號格式 ✅、AASA ✅、落地頁 v5 ✅、QR 格式 ✅、/dl 分發 ✅。

---

## 現狀總覽

| 平台 | 狀態 |
|------|------|
| Android 1.0.6 APK（/dl 下載的版本） | 深鏈配置**已完整**（後端解剖 APK 驗證：manifest scheme + App Links + app_links 插件 + DeepLinkService + bindInviter 全在）——但有 **3 個潛在問題**待修（見二、三、四） |
| iOS App Store 1.0.7（2026-03-14 更新） | 🔴 **完全沒有深鏈代碼**——這個版本早於所有深鏈開發（2026-08-02 起），iOS 掃碼不可能直開。**必須構建新版**（見一） |

---

## 一、iOS：構建新版並補齊深鏈配置（最高優先級）

### 1.1 構建新版 iOS 並發布（TestFlight 先行）

App Store 現行版本 1.0.7 是 **2026-03-14** 發布的，不含任何深鏈處理。iOS 掃碼進 Safari 落地頁（後端日誌已確認真實 iPhone 用戶行為）。請構建包含以下 1.2–1.6 全部配置的新版本，先發 TestFlight 測試，通過後提審 App Store。

### 1.2 Associated Domains entitlement（掃碼直開的前提）

`Runner/` 目錄的 entitlements 文件（或 Xcode → Signing & Capabilities → Associated Domains）添加：

```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:lumoguide.com</string>
</array>
```

> ⚠️ 添加後必須**重新簽名**（新描述文件），否則 iOS 不認。域必須是 `lumoguide.com`（不是 www），後端 AASA 部署在 apex 域。

### 1.3 AppDelegate.swift 兩個轉發方法（App 被打開但不跳轉的根因）

app_links v6+ **不再自動接管 URL，必須手動轉發**。缺失時：App 被打開，但 URL 到不了 Dart → 永遠不跳轉。完整代碼：

```swift
import Flutter
import UIKit
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Universal Links（掃碼直開、冷啟動）——必須有
  override func application(_ application: UIApplication,
      continue userActivity: NSUserActivity,
      restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    AppLinks.shared.handleUniversalLink(userActivity: userActivity)
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // 自定義 scheme（落地頁「在 App 中打開」按鈕）——必須有
  override func application(_ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    AppLinks.shared.handleLink(url: url)
    return super.application(app, open: url, options: options)
  }
}
```

> 若 pubspec 鎖定的 app_links 是 3.x–5.x，API 不同，以該版本官方文檔為準（舊版用 `AppLinksIOS.shared.application(...)` 形式）。

### 1.4 Info.plist 註冊 `lumoguide` scheme（落地頁按鈕的前提）

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>lumoguide</string>
    </array>
  </dict>
</array>
```

### 1.5 Dart 冷啟動時機（getInitialLink 必須在 runApp 前）

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialLink = await getInitialLink();   // 冷啟動深鏈
  runApp(MyApp(initialLink: initialLink));       // 傳入根組件處理
}
```

不要放在頁面 `initState` 裡再讀（第一幀已渲染，深鏈可能丟失）。

### 1.6 熱啟動監聽（App 在後台時掃碼）

```dart
getLinksStream().listen((Uri? uri) {
  if (uri != null) handleDeepLink(uri.toString());
});
```

---

## 二、Android：冷啟動空白風險（flutter_deeplinking_enabled）

**現狀**：AndroidManifest 有 `<meta-data android:name="flutter_deeplinking_enabled" android:value="true"/>`。此標記讓 Flutter 引擎把深鏈 URL 作為**初始路由**（`Navigator.defaultRouteName`）傳給 Dart。但 App 用的是 **app_links + 具名路由**（`pushNamed('/city_detail')`），`_onGenerateRoute` 不認識完整的 `https://lumoguide.com/share?...` URL 字符串 → **冷啟動可能空白**（與「App 非開啟狀態就空白」症狀吻合）。

**修復（二選一，推薦方案 A）**：

- **方案 A（推薦）**：刪除該 meta-data。app_links 不需要它，深鏈完全由 app_links 處理，引擎不再干預路由：
  ```xml
  <!-- 刪除：<meta-data android:name="flutter_deeplinking_enabled" android:value="true"/> -->
  ```
- **方案 B**：保留，但給 `_onGenerateRoute` 增加 URL 兜底——把深鏈 URL 轉為對應頁面，避免空白。

---

## 三、Android：launchMode 改為 singleTask

**現狀**：MainActivity 是 `android:launchMode="1"`（singleTop）。app_links 官方文檔要求 **singleTask**——保證 App 在後台時深鏈走 `onNewIntent` 到**同一個實例**，不會重建 Activity 丟失狀態：

```xml
<activity
    android:name="com.app.lumotrip.MainActivity"
    android:launchMode="singleTask"
    ... />
```

---

## 四、Android：Stripe SDK 的 autoVerify 污染（已知問題）

**現狀**：APK manifest 中 Stripe SDK（flutterstripe）自動注入了：

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="flutterstripe" android:host="safepay"/>
</intent-filter>
```

自定義 scheme 加 `autoVerify="true"` 是 Stripe 的已知問題——部分 Android 12+ 設備會因此導致 App Links 整體驗證失敗。**修復**：在 App 自己的 AndroidManifest.xml 中覆蓋為 false：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <application>
        <activity android:name=".MainActivity">
            <intent-filter android:autoVerify="false" tools:replace="android:autoVerify">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="flutterstripe" android:host="safepay" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

> 該 scheme 用於 Stripe 支付回跳，不需要 autoVerify，覆蓋無副作用。

---

## 五、跨平台 Dart：確認 scheme 形式（lumoguide://）能解析

**現狀**：後端解剖 Android 1.0.6 APK 的 Dart 快照，只發現 `https://lumoguide.com/share?c=` 字符串，**未發現 `lumoguide://`**。若 DeepLinkService 只按 https 前綴匹配，則落地頁按鈕用 scheme 拉起時（`lumoguide://share?c=...&t=...&i=...`）**App 打開但不會跳轉**。

**請確認**：`share_url.dart` / `deep_link.dart` 的解析是否兼容兩種形式。最穩妥的統一寫法：

```dart
String normalizeDeepLink(String raw) {
  if (raw.startsWith('lumoguide://')) {
    return raw.replaceFirst('lumoguide://share', 'https://lumoguide.com/share');
  }
  return raw;
}
// 之後統一按 https://lumoguide.com/share?c=X&t=Y&i=Z 解析 queryParameters
```

---

## 六、測試與發布事項

### 6.1 Android 已安裝設備需重裝（刷新 autoVerify）

assetlinks 修復（08-04）前，已安裝設備的 App Links 驗證是**失敗緩存**狀態。Android 不會立即重試——**測試時請卸載重裝 App**（新裝立即重新驗證）。或等 24h+ 系統自動重試。也可手動：系統設置 → App → 打開支持的鏈接 → 手動開啟。

### 6.2 版本號對齊

iOS App Store = 1.0.7（3 月舊版），Android = 1.0.6（昨天構建），**版本號已錯位**（iOS 數字高但實際更舊）。建議新版 iOS/Android 統一版本號，避免混淆。

### 6.3 Play 上傳密鑰重置（協同步驟）

審核通過後：
1. 前端用**新密鑰**構建正式版 → 上傳 Google Play + 替換 `/dl` APK
2. **通知後端** → 後端把新指紋 `5F130901...`（冒號格式）追加到 assetlinks.json
3. ⚠️ 新密鑰版本與舊版**簽名不一致**：已裝臨時密鑰 APK 的用戶升級時**無法覆蓋安裝，需卸載重裝**——發布時需提示

### 6.4 trip（行程）分享 404（產品決策）

後端 `journeyDetail` 接口僅限行程本人查看——分享給他人掃碼打開會 404。已發現真實用戶掃了 `t=trip&i=7` 的 QR。**需產品決策**：是否新增「按分享碼訪問行程」接口（後端可做），或維持現狀（行程分享僅本人可見）。

---

## 七、真機驗收清單（新版本構建後）

| # | 場景 | 預期 |
|---|------|------|
| 1 | iPhone 未開啟 App，相機掃碼 | 直接打開 App → 對應詳情頁（冷啟動） |
| 2 | iPhone App 在後台，掃碼 | 回到 App → 對應詳情頁（熱啟動） |
| 3 | iPhone 未裝 App，掃碼 | Safari 落地頁 → 下載/App Store |
| 4 | iPhone 落地頁點「在 App 中打開」 | 打開 App → 對應詳情頁 |
| 5 | Android（Chrome）已裝未開啟，掃碼 | 直接打開 App → 對應詳情頁（冷啟動，不空白） |
| 6 | Android App 在後台，掃碼 | 回到 App → 對應詳情頁 |
| 7 | Android（華為/小米瀏覽器）掃碼 | 直接打開 App（系統級 App Links，與瀏覽器無關） |
| 8 | Android 落地頁點按鈕（華為瀏覽器） | scheme 直跳打開 App → 詳情頁 |
| 9 | 未登錄用戶深鏈進入 | 登錄頁 → 登錄後恢復深鏈跳轉 + 綁定邀請 |
| 10 | 老用戶掃新用戶邀請碼 | 綁定成功，邀請人獲積分 |

**測試前提**：安裝的是新版（iOS 用 TestFlight 新包；Android 卸載重裝 1.0.6+）。
