# 深鏈 & QR 分享 — 前端配合需求文檔

> 文件日期：2026-08-02（2026-08-03 更新：新增 P0-3 scheme 聲明、APK 簽名要求、落地頁 v4 分派策略；2026-08-04 更新：assetlinks 冒號格式修復、落地頁 v5 瀏覽器檢測修復、P1-1 驗證完成、冷啟動空白風險標記）| 後端部署狀態：已完成（對應文檔「Lumoguide Deep Link & QR 碼分享 — 後端配合文檔」）

---

## 一、現狀摘要（後端已完成，前端只需做下列事項）

後端已於 2026-08-02 全部部署完成並測試通過：

| 項目 | 線上地址 / 狀態 |
|------|----------------|
| iOS 驗證文件（AASA） | `https://lumoguide.com/.well-known/apple-app-site-association` ✅ 200 / application/json |
| Android 驗證文件（assetlinks） | `https://lumoguide.com/.well-known/assetlinks.json` ✅ 臨時密鑰指紋 `5BACAB02...` 已部署（2026-08-03）；⏳ 新密鑰指紋 `5F130901...` 待 Play 審核通過後追加 |
| 深鏈落地頁 | `https://lumoguide.com/share?c={code}&t={type}&i={id}` ✅（2026-08-04 升級 v5：修正國產瀏覽器誤判——華為/小米/UC/QQ/百度/360/OPPO/vivo 內置瀏覽器 UA 含 `Chrome/` 但不識別 intent://，此前被誤判走 intent:// 報錯；現排除後走 scheme 直跳。另排除 WebView） |
| 下載分發 | `https://lumoguide.com/dl` ✅ **全鏈路驗證通過（2026-08-04）**：中國 Android→APK 200、外國 Android→Play、iOS→App Store、桌面→share |
| 邀請綁定 API | `POST https://api.lumoguide.com/api/user/bindInviter` ✅ |
| 分享 QR 碼 | 後端 `shareQrcode` 已改為生成 `https://lumoguide.com/share?...` 格式 ✅ |
| 域名證書 | `lumoguide.com` 已配置 HTTPS（Let's Encrypt，2026-10-31 到期，自動續期）✅ |

**前端只需做 5 件事**（見第二章），做完後 App 掃碼即可直開。

---

## 二、前端待辦清單（按優先級）

### ✅ P0-1：提供 Android Release 簽名 SHA256（阻塞 App Links）

> **✅ 已完成（2026-08-03）**：前端提供 `5BACAB02269E9F8AAFEB0C3D0A5231271F800FFF2BAC8EC20840EDBBE105D579`（臨時密鑰 key.jks 指紋），後端已替換並部署到 assetlinks.json。

> **🔧 格式修復（2026-08-04，關鍵）**：初版部署的**無冒號**指紋被 Google 判定為 `malformed cert fingerprint`（Google Digital Asset Links API 驗證一直報錯），**導致所有 Android 設備 App Links 驗證失敗**——掃碼無法直開 App 的根因之一。已改為**冒號分隔格式** `5B:AC:AB:02:...:D5:79` 並部署，Google DAL API 驗證**通過**（返回有效 statement）。⚠️ **經驗教訓：Google 驗證器要求冒號格式，指紋必須以 `XX:XX:...:XX` 形式填入 assetlinks.json**。

> **⏳ 待辦（2026-08-04 前端通知）**：Play 上傳密鑰重置審核中。**審核通過後**，正式 Release 將用新密鑰簽名，需把新指紋 `5F130901D952F4E8C665AA26C78BF84A43E86086ED6D97E7F9F28A47DB9E9850` **追加**到 assetlinks.json 的 `sha256_cert_fingerprints` 數組（保留舊指紋，兩個共存，新舊 APK 都可用，同樣用冒號格式）。前端通知審核通過後請後端執行追加 + 重新驗證。
>
> ⚠️ **簽名變更提醒**：安裝了臨時密鑰 APK（當前 /dl 的 1.0.6）的用戶，升級到新密鑰版本時**無法覆蓋安裝**（Android 簽名不一致），需卸載重裝。請前端在版本更新時注意提示，或由產品決定如何處理已安裝用戶。

**背景**（已解決，保留供參考）：將以下 JSON 中 `<RELEASE_KEYSTORE_SHA256>` 替換為真實指紋：

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.app.lumotrip",
      "sha256_cert_fingerprints": [
        "<RELEASE_KEYSTORE_SHA256>"
      ]
    }
  }
]
```

獲取方式（二選一）：

```bash
# 方法 1：從 keystore
keytool -list -v -keystore <your-release.keystore> -alias <alias> | grep SHA256

# 方法 2：從已簽名的 APK
keytool -printcert -jarfile app-release.apk | grep SHA256
```

> ⚠️ 指紋的 SHA256 去掉冒號分隔符後填入（例如 `12:AB:34:CD...` → `12AB34CD...`）。
> ⚠️ **必須使用 Release keystore 的指紋**，且與上傳到 Google Play 的 APK 簽名一致（見 P0-2）。如果用 debug keystore 簽 APK，App Links 驗證一樣失敗。
> ⚠️ 如果同時需要調試用，可以把 debug 和 release 兩個指紋都填入數組。
> ⚠️ 填好後提供給後端部署，或告知後端自行修改。

### ✅ P0-2：上傳 APK 文件（阻塞中國 Android 用戶下載）

> **✅ 已完成（2026-08-04 前端上傳，後端驗證通過）**：
> - APK 已上傳（160MB），`version.txt` = 1.0.6
> - `/dl/app-release.apk` 直接訪問：**200** + `application/vnd.android.package-archive` + `Content-Disposition: attachment; filename="LUMOGUIDE.apk"` ✅
> - 分發全鏈路實測：中國 IP Android → 302 → APK **200**（不再 404）✅；外國 Android → Google Play ✅；iOS → App Store ✅；桌面 → share.html ✅
> - APK 簽名：前端已用 keytool 確認 `5BACAB02...` 對應當前 APK（服務器無 apksigner/keytool，未能獨立復驗，前端 apksigner 為權威）

將 `app-release.apk` 上傳到服務器：

```
路徑：/www/wwwroot/luomoguide/dl/app-release.apk
```

> ⚠️ **必須用 Release keystore 簽名**，與 Google Play 上傳的版本一致。否則：安裝 APK 的用戶 App Links 驗證失敗（指紋不匹配 P0-1 的 SHA256），掃碼不能直開。
> ⚠️ **Play 密鑰重置後**：新密鑰簽名的 APK 需替換 /dl 文件，且舊版用戶無法覆蓋安裝（簽名變更，需卸載重裝）。

上傳後請同時更新版本號文件：

```
路徑：/www/wwwroot/luomoguide/dl/version.txt
內容：1.0.6（改為實際版本號）
```

已配置好的響應頭（無需前端處理）：

```
Content-Type: application/vnd.android.package-archive
Content-Disposition: attachment; filename="LUMOGUIDE.apk"
```

### ✅ P0-3（新增 2026-08-03）：AndroidManifest 聲明 `lumoguide` 自定義 scheme（阻塞落地頁「在 App 中打開」按鈕）

**背景**：落地頁 v4 已按瀏覽器分派——Chrome 用 `intent://`，華為/小米等瀏覽器用 `lumoguide://` scheme 直跳。**但前提是 App 的 AndroidManifest 聲明了 `lumoguide` scheme**。未聲明時所有 Android 瀏覽器點「在 App 中打開」都沒反應（華為問題的根因）。

在 `AndroidManifest.xml` 的 MainActivity（或深鏈處理 Activity）添加：

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <!-- 自定義 scheme：落地頁「打開 App」按鈕使用（host 必須是 share，與落地頁 lumoguide://share 一致） -->
  <data android:scheme="lumoguide" android:host="share" />
</intent-filter>

<!-- App Links：掃碼直開（與 P0-1 的 assetlinks 對應） -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="lumoguide.com" android:pathPrefix="/share" />
</intent-filter>
```

> ⚠️ `android:autoVerify="true"` 是 Android 12+ 深鏈驗證的必需項（P0-1 的 SHA256 只是 assetlinks 文件側，App 側也要 autoVerify 才能驗證通過）。
> ⚠️ scheme 的 `host=share` 必須與落地頁一致（落地頁使用 `lumoguide://share?c=...&t=...&i=...`）。

### ✅ P1-1：App 內處理深鏈（Universal Links / App Links）

> **✅ 1.0.6 APK 已包含完整深鏈實現（2026-08-04 後端 APK 解剖驗證）**：
> - AndroidManifest：`lumoguide://share` scheme + `https://lumoguide.com/share` App Links（autoVerify）+ `flutter_deeplinking_enabled=true` + `launchMode="1"`(singleTop)，全部在 MainActivity
> - 使用 **app_links** 插件（classes2/4.dex 確認原生註冊），Dart 端 `DeepLinkService`：`getInitialLink`（冷啟動）+ stream（熱啟動）+ `pending_deep_link` 存儲（登錄後恢復）+ `/user/bindInviter` 調用 + 四個目標路由（`/guide_detail`、`/city_detail`、`/common_detail`、`/journey`）
> - APK 簽名證書 SHA256 = assetlinks.json 指紋 ✅（androguard 驗證一致）

> **⚠️ 冷啟動空白風險（2026-08-04 後端分析）**：`flutter_deeplinking_enabled=true` 時，Flutter 引擎會把深鏈 URL 作為**初始路由**（`Navigator.defaultRouteName`）傳給 Dart。若 App 的 `_onGenerateRoute` 不識別完整 URL 字符串（App 用的是 `pushNamed('/city_detail')` 這種具名路由），冷啟動可能**空白/報錯**。App 已用 app_links 自行導航，兩者可能衝突。**建議前端驗證**：若冷啟動深鏈仍空白，刪除 AndroidManifest 中的 `flutter_deeplinking_enabled` meta-data（app_links 不需要它），或為 `_onGenerateRoute` 增加 URL 兜底。

App 端配置已完成（`Info.plist`、`Runner.entitlements`、`AndroidManifest.xml`），但**收到深鏈後的處理邏輯**需要實現：

**URL 格式**：`https://lumoguide.com/share?c={code}&t={type}&i={id}`

**參數說明**：

| 參數 | 必填 | 說明 |
|------|------|------|
| `c` | 否 | 分享人邀請碼（用於綁定邀請關係） |
| `t` | 是 | 內容類型：`guide` / `city` / `content` / `trip` |
| `i` | 是 | 內容 ID |

**路由映射**：

| `t` 參數 | 目標頁面 | 路由 | 參數 |
|---------|---------|------|------|
| `guide` | 導遊詳情 | `/guide_detail` | `{'id': id}` |
| `city` | 城市詳情 | `/city_detail` | `{'id': id}` |
| `content` | 通用詳情 | `/common_detail` | `{'id': id}` |
| `trip` | 行程詳情 | `/journey_detail` | `{'id': id}` |

**實現要點**（2026-08-04 用戶實測反饋補充——**此項未實現時的所有症狀**：iOS 點「在 App 中打開」能進 App 但不跳詳情頁；Android 掃碼直接嘗試拉起 App，App 非開啟（冷啟動）狀態下空白/打不開）：
1. 處理系統回調（iOS `AppDelegate` 的 `continueUserActivity` / Android Intent），解析 `c`/`t`/`i`
2. **冷啟動場景（App 未開啟）必須處理**：
   - iOS：`AppDelegate` 的 `application:didFinishLaunchingWithOptions`（launchOptions 裡的 `UIApplicationLaunchOptionsUserActivityDictionaryKey` / `UIApplicationLaunchOptionsURLKey`）——冷啟動時深鏈從 launchOptions 進來，不走 `continueUserActivity`
   - Android：`MainActivity.onCreate` 的 `intent.data`（冷啟動）+ `onNewIntent`（App 在後台時，須設 `android:launchMode="singleTask"`，否則每次拉起都重建 Activity）
3. 保存深鏈參數（供登錄後跳轉）— 建議存到與 Web 一致的 `localStorage` key：`lumoguide_deep_link`（JSON `{code, type, id, ts}`），或 App 內部存儲
4. 若用戶未登錄：先登錄 → 登錄後恢復深鏈跳轉 + 執行邀請綁定
5. 若已登錄：直接跳轉對應頁面
6. **App 收到深鏈但未登錄時**：跳轉登錄頁，登錄成功後從本地存儲恢復深鏈參數再跳轉
7. **異常防護**：深鏈參數缺失/類型無效時靜默忽略（不 crash、不黑屏）——Android 空白頁/閃退常見於深鏈 Activity 處理代碼拋異常

> **🔴 iOS 獨家問題（2026-08-05 後端查明）**：**App Store 上的 iOS 版本是 1.0.7（2026-03-14 更新），早於所有深鏈開發（2026-08-02+）**——該版本沒有任何深鏈處理（無 app_links、無 Associated Domains、可能無 lumoguide scheme）。iOS 真機掃碼進 Safari 落地頁即為此因。**解決：前端需構建並發布新版 iOS（TestFlight 先行），包含與 Android 1.0.6 相同的深鏈代碼**。新版 iOS 構建必須確認以下三點：
>
> **① Associated Domains（Universal Links 掃碼直開的前提）**——`Runner.entitlements` 或 Xcode → Signing & Capabilities：
> ```xml
> <key>com.apple.developer.associated-domains</key>
> <array>
>   <string>applinks:lumoguide.com</string>
> </array>
> ```
> ⚠️ 添加後須重新簽名/描述文件更新，否則 iOS 不認。
>
> **② AppDelegate.swift 必須有 app_links 的兩個轉發方法**（app_links v6+ 不再自動接管，必須手動調用；缺失時 App 被打開但 URL 不進 Dart → 進 App 不跳轉）：
> ```swift
> import Flutter
> import UIKit
> import app_links
>
> @main
> @objc class AppDelegate: FlutterAppDelegate {
>   override func application(_ application: UIApplication,
>       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
>     GeneratedPluginRegistrant.register(with: self)
>     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
>   }
>
>   // Universal Links（掃碼直開、冷啟動）
>   override func application(_ application: UIApplication,
>       continue userActivity: NSUserActivity,
>       restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
>     AppLinks.shared.handleUniversalLink(userActivity: userActivity)
>     return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
>   }
>
>   // 自定義 scheme（落地頁「在 App 中打開」按鈕）
>   override func application(_ app: UIApplication,
>       open url: URL,
>       options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
>     AppLinks.shared.handleLink(url: url)
>     return super.application(app, open: url, options: options)
>   }
> }
> ```
> （app_links 舊版 3.x-5.x API 不同，以 pubspec 鎖定版本對應文檔為準。）
>
> **③ 冷啟動時機**：`getInitialLink()` 須在 `main()` 中 `WidgetsFlutterBinding.ensureInitialized()` 之後、`runApp` 之前 await 獲取，再傳入 App 根組件處理；熱啟動用 `getLinksStream().listen()`。登錄後恢復用 `pending_deep_link`（已確認 App 有此機制）。
>
> **測試注意**：iOS Universal Links 安裝後可能需先手動啟動一次 App；新裝/重裝後立即測試最可靠。舊版 App Store 1.0.7 用戶需升級才能掃碼直開。

### ✅ P1-2：調用邀請綁定 API（bindInviter）

用戶通過 QR 碼/深鏈進入 App 後，若**當前用戶未綁定過邀請人**，應調用綁定 API：

```
POST https://api.lumoguide.com/api/user/bindInviter
Authorization: Bearer <TOKEN>
Content-Type: application/json

{ "inviter_code": "ABC123" }   // 來自深鏈的 c 參數
```

**響應**：

```json
{ "code": 200, "message": "success", "data": [] }
```

**業務規則（後端已實現）**：

| 場景 | 返回 |
|------|------|
| 綁定成功 | `code: 200`，寫入邀請關係 + 邀請人獲得積分 |
| 已綁定過（不可重複） | 錯誤：`You have already bound an inviter` |
| 綁定自己 | 錯誤：`You cannot bind yourself` |
| 邀請碼不存在 | 錯誤：`無效邀請碼` |

**調用時機建議**：登錄後、首次拿到深鏈的 `c` 參數時調用一次；收到「已綁定」錯誤時忽略即可（表示之前已綁）。

### ✅ P2-3：確認分享 QR 碼 URL 格式

- **後端 `shareQrcode` API 已改為生成**：`https://lumoguide.com/share?c=...&t=...&i=...`（不再使用 `www.lumoguide.com/share.html`）
- 如果前端分享卡片是**自行生成 QR 碼**，請確認也使用上述新格式（不要再用 `lumoguide://share?...` scheme 或 `/share.html`）
- `lumoguide://share` 自定義 scheme 已保留在 share.html 中用於「打開 App」按鈕，但 **QR 碼必須是 https:// 鏈接**（相機/掃碼器不識別自定義 scheme）

---

## 三、測試清單（前端驗收用）

### 3.1 掃碼測試（需真機）

| 測試場景 | 預期結果 |
|---------|---------|
| iPhone 已裝 App，掃碼 `https://lumoguide.com/share?c=X&t=city&i=1` | 直接打開 App → 城市詳情頁 |
| iPhone 未裝 App，掃碼 | Safari 打開 share.html 落地頁（可下載） |
| Android 已裝 App，掃碼（Chrome） | 直接打開 App → 對應內容頁 |
| Android 已裝 App，掃碼（華為瀏覽器） | 直接打開 App → 對應內容頁（系統級 App Links，與瀏覽器無關） |
| Android 已裝 App + 落地頁按鈕（Chrome） | `intent://` 拉起 App；找不到時自動跳下載頁（fallback_url） |
| Android 已裝 App + 落地頁按鈕（華為/小米等瀏覽器） | `lumoguide://` scheme 直跳拉起 App（P0-3 完成後） |
| Android 未裝（非中國），掃碼 | share.html → Google Play |
| Android 未裝（中國），掃碼 | share.html → APK 下載（P0-2 完成後，不再 404） |

### 3.2 深鏈綁定測試

1. 用戶 A 在 App 內分享（生成含 A 邀請碼的 QR 碼）
2. 新用戶 B 掃碼安裝 App → 打開
3. B 登錄後應自動跳到對應內容頁，且 B 的邀請關係 = A
4. 在 B 的「我的邀請」頁面確認：A 的邀請記錄 +1、A 獲得邀請積分

### 3.3 落地頁測試

- 瀏覽器訪問 `https://lumoguide.com/share?c=TEST&t=city&i=1`
- 確認品牌頁面正常顯示（LUMOGUIDE logo、打開 App / 下載 App 按鈕）
- 微信內打開 → 顯示「在瀏覽器中開啟」引導

---

## 四、後端聯絡人待辦（協助項）

如果前端需要後端協助：

1. **替換 assetlinks.json 的 SHA256** — 提供指紋後由後端更新文件並驗證
2. **上傳 APK** — 提供 APK 文件路徑或直接上傳（建議上傳後立即測試 `/dl` 下載）

---

## 五、附錄：share.html 深鏈存儲規範

新版 share.html 會把掃碼參數寫入瀏覽器 localStorage（key：`lumoguide_deep_link`）：

```json
{ "code": "ABC123", "type": "city", "id": 1, "ts": 1785679227 }
```

若 App 從 share.html 拉起（自定義 scheme），參數會同時附在 scheme URL 上（`lumoguide://share?c=...&t=...&i=...`），App 可直接解析；localStorage 僅作為安裝後補救手段（App 安裝後首次啟動可讀取 WebView/瀏覽器的 localStorage 或由前端協調）。
