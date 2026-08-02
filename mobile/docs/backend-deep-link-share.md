# Lumoguide Deep Link & QR 碼分享 — 後端配合文檔

> 文檔日期：2026-08-02（修訂版 v2 — 修復 iOS Safari 按鈕無法觸發 App + 自動跳轉問題）| 前端版本：1.0.6+24

---

## 一、背景說明

前端分享卡片中的 QR 碼已改用 `https://lumoguide.com/share?...` 格式（之前是 `lumoguide://share?...`），因為**手機相機/掃碼器只識別 http/https 鏈接**，不識別自定義 URL scheme。

掃碼後的理想流程：

```
用戶掃碼 → 手機識別 https:// URL
  ├─ 已安裝 App（iOS Universal Links / Android App Links）→ 直接打開 App 進入內容頁
  └─ 未安裝 App → 瀏覽器打開 share.html → 引導下載 App
```

要實現「已安裝 App → 直接打開」，**需要後端部署兩個驗證文件**（見第二、三節）。  
沒有這兩個文件時，所有掃碼都會走瀏覽器 → share.html（見第四節）。

---

## 二、iOS Universal Links 配置

### 2.1 驗證文件

在 `https://lumoguide.com/.well-known/apple-app-site-association` 提供以下 JSON 文件：

**重要：** 此文件必須滿足以下條件：
- **不帶任何文件擴展名**（不是 `.json`）
- Content-Type: `application/json`
- HTTPS 訪問（不能是 HTTP）
- 不要返回 301/302 重定向

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "FLVV24Q9HH.com.app.lumotrip",
        "paths": [
          "/share",
          "/share/*"
        ]
      }
    ]
  }
}
```

**欄位說明：**

| 欄位 | 值 | 說明 |
|------|-----|------|
| `appID` | `FLVV24Q9HH.com.app.lumotrip` | `<Team ID>.<Bundle ID>` — Team ID 來自 Apple Developer 帳號 |
| `paths` | `["/share", "/share/*"]` | 匹配 `lumoguide.com/share` 及 `lumoguide.com/share?c=...` |

### 2.2 iOS App 端配置（已完成）

- `Info.plist` 已註冊 `lumoguide` 自定義 URL scheme
- `Runner.entitlements` 已添加 `com.apple.developer.associated-domains` → `applinks:lumoguide.com`

---

## 三、Android App Links 配置

### 3.1 驗證文件

在 `https://lumoguide.com/.well-known/assetlinks.json` 提供以下 JSON 文件：

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

**獲取 SHA256 指紋的方法：**

```bash
# 方法 1：從 keystore 獲取
keytool -list -v -keystore <your-release.keystore> -alias <alias> | grep SHA256

# 方法 2：從已簽名的 APK 獲取
keytool -printcert -jarfile app-release.apk | grep SHA256
```

> **注意：** Debug 簽名和 Release 簽名的 SHA256 不同。此處應填 **Release 簽名**的 SHA256。如有需要調試，可同時填入 debug 和 release 兩個指紋。

### 3.2 Android App 端配置（已完成）

- `AndroidManifest.xml` 已添加 `https://lumoguide.com/share` 的 intent filter + `autoVerify="true"`
- 保留了 `lumoguide://share` 自定義 scheme（向下兼容）

---

## 四、share.html 落地頁

**URL:** `https://lumoguide.com/share?c={inviteCode}&t={type}&i={id}`

此頁面負責：當用戶未安裝 App 時，引導到對應商店下載。

### 4.1 URL 參數

| 參數 | 必填 | 說明 |
|------|------|------|
| `c` | 否 | 分享人邀請碼，用於綁定邀請關係 |
| `t` | 是 | 內容類型：`guide` / `city` / `content` / `trip` |
| `i` | 是 | 內容 ID（整數） |

### 4.2 頁面功能（修訂版）

```
1. 頁面載入 → 立即顯示「正在打開 LUMOGUIDE…」+ spinner
2. 自動嘗試打開 App（不依賴 Universal Links 作為兜底）：
   - iOS: window.open() + location.href 雙通道
   - Android: intent:// scheme + lumoguide:// scheme 雙通道
3. 2.5 秒超時 → 如果 App 沒打開：
   - 隱藏 loading，顯示「打開 App」+「下載 App」兩個按鈕
   - 用戶可手動點擊再次嘗試打開 App
4. 點擊按鈕 → 再次觸發 App 打開（同上雙通道策略）
5. 點擊下載 → 跳轉對應商店：
   - iOS → App Store
   - Android 中國 IP → APK
   - Android 非中國 IP → Google Play
```

> **為甚麼會看到此頁面？** 如果 Universal Links 正常運作，掃描 QR 碼後系統會直接打開 App，用戶永遠不會看到此頁。但以下情況會 fallback 到這個網頁：
> - App 尚未安裝
> - 用戶從 App Store 剛下載 App，iOS 還未下載 AASA 驗證文件（通常在首次安裝後幾分鐘到幾小時內完成）
> - App 是 Debug/TestFlight 構建（Universal Links 的 `appID` 需要包含正確的 Team ID）
> - AASA 文件更新後用戶尚未重裝/更新 App

### 4.3 推薦實現（HTML/JS）— 2026-08-02 修訂版 v3（修復按鈕無反應）

**⚠️ v3 修復：iOS Safari 按鈕點擊完全無反應的問題。**

**v2 → v3 核心改進：**
1. **`<a href="#">` 改為 `<button>`** — `<a href="#">` 在 iOS Safari 中會干擾 JS 事件，`e.preventDefault()` 不一定生效
2. **區分「自動觸發」與「按鈕點擊」策略**：
   - **自動觸發**（頁面載入，無用戶手勢）→ iframe / window.open（較溫和）
   - **按鈕點擊**（有用戶手勢）→ **直接 `window.location.href`**（最可靠！）
   - 之前的版本對兩種場景用了同一套邏輯，但 iframe 方式在有用戶手勢時反而不可靠
3. **Android 使用 intent:// 優先 + lumoguide:// 兜底**
4. **保留微信內引導**（微信內無法打開 App）

```html
<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>LUMOGUIDE - 分享內容</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: linear-gradient(135deg, #666FFF 0%, #4B4FEE 100%);
    min-height: 100vh; min-height: 100dvh;
    display: flex; align-items: center; justify-content: center;
    color: #fff;
  }
  .card { text-align: center; padding: 40px 30px; max-width: 360px; width: 90%; }
  .logo { font-size: 32px; font-weight: 700; letter-spacing: 2px; margin-bottom: 8px; }
  .subtitle { font-size: 14px; opacity: 0.85; margin-bottom: 8px; }
  .loading { margin: 24px 0; }
  .spinner {
    width: 36px; height: 36px; border: 3px solid rgba(255,255,255,0.3);
    border-top-color: #fff; border-radius: 50%; margin: 0 auto 12px;
    animation: spin 0.8s linear infinite;
  }
  @keyframes spin { to { transform: rotate(360deg); } }
  .loading-text { font-size: 13px; opacity: 0.85; }
  .btn {
    display: block; width: 100%; padding: 14px 0; border-radius: 12px;
    font-size: 16px; font-weight: 600; text-decoration: none; margin-bottom: 12px;
    cursor: pointer; border: none; -webkit-tap-highlight-color: transparent;
    -webkit-appearance: none;
  }
  .btn:active { opacity: 0.8; }
  .btn-primary { background: #fff; color: #666FFF; }
  .btn-secondary { background: rgba(255,255,255,0.2); color: #fff; }
  .hint { font-size: 12px; opacity: 0.7; margin-top: 24px; }
  .hidden { display: none !important; }
  .wechat-guide {
    margin-top: 20px; padding: 16px;
    background: rgba(255,255,255,0.15); border-radius: 12px;
    font-size: 13px; color: #fff; line-height: 1.8;
  }
</style>
</head>
<body>
<div class="card">
  <div class="logo">LUMOGUIDE</div>
  <div class="subtitle">路上有光，盟友相伴</div>

  <!-- 正在打開 App（初始顯示，超時後隱藏） -->
  <div id="loading" class="loading">
    <div class="spinner"></div>
    <div class="loading-text">正在打開 LUMOGUIDE…</div>
  </div>

  <!-- 打開/下載按鈕（初始隱藏，超時後顯示） -->
  <div id="actions" class="hidden">
    <button id="btn-open" class="btn btn-primary" type="button">在 LUMOGUIDE App 中打開</button>
    <button id="btn-download" class="btn btn-secondary" type="button">下載 App</button>
  </div>

  <div class="hint">掃描 QR 碼分享的內容將在 App 內查看</div>

  <!-- 微信內引導（僅微信內顯示） -->
  <div class="wechat-guide hidden" id="wechat-guide">
    請點擊右上角 <span style="font-size:20px;vertical-align:middle">⋯</span> 選單<br>
    選擇<span id="browser-name">瀏覽器</span>開啟後再點擊上方按鈕
  </div>
</div>

<script>
(function () {
  var params = new URLSearchParams(window.location.search);
  var c = params.get('c') || '';
  var t = params.get('t') || '';
  var i = params.get('i') || '';

  // 保存參數供 App 安裝後使用
  if (t && i) {
    try {
      localStorage.setItem('lumoguide_deep_link', JSON.stringify({
        code: c, type: t, id: i, ts: Date.now()
      }));
    } catch (_) {}
  }

  var schemeUrl = 'lumoguide://share?c=' + encodeURIComponent(c)
                + '&t=' + encodeURIComponent(t)
                + '&i=' + encodeURIComponent(i);

  var ua = navigator.userAgent;
  var isWeChat = /MicroMessenger/i.test(ua);
  var isIOS = /iPhone|iPad|iPod/i.test(ua);
  var isAndroid = /Android/i.test(ua);
  var dlUrl = 'https://lumoguide.com/dl';

  var elLoading = document.getElementById('loading');
  var elActions = document.getElementById('actions');

  // ── 微信內無法打開 App，顯示瀏覽器引導 ──
  if (isWeChat) {
    document.getElementById('browser-name').textContent = isIOS ? 'Safari' : '瀏覽器';
    document.getElementById('wechat-guide').classList.remove('hidden');
    elLoading.classList.add('hidden');
    return;
  }

  // ══════════════════════════════════════════
  // 策略分離：自動觸發 vs 按鈕點擊
  // ══════════════════════════════════════════

  // 【自動觸發】頁面載入時 — 無用戶手勢，用溫和方式
  function openAppAuto() {
    if (isIOS) {
      // iOS 無手勢：iframe 方式避免彈出「無效 URL」錯誤
      var iframe = document.createElement('iframe');
      iframe.style.display = 'none';
      iframe.src = schemeUrl;
      document.body.appendChild(iframe);
      setTimeout(function () {
        if (document.body.contains(iframe)) document.body.removeChild(iframe);
      }, 3000);
    } else if (isAndroid) {
      // Android 無手勢：intent:// 優先
      var intentUrl = 'intent://share?c=' + encodeURIComponent(c)
                    + '&t=' + encodeURIComponent(t)
                    + '&i=' + encodeURIComponent(i)
                    + '#Intent;scheme=lumoguide;package=com.app.lumotrip;end';
      window.location.href = intentUrl;
      setTimeout(function () {
        if (!document.hidden) window.location.href = schemeUrl;
      }, 500);
    }
  }

  // 【按鈕點擊】有用戶手勢 — 直接 navigation，最可靠！
  function openAppClick() {
    if (isIOS) {
      // 有用戶手勢 → 直接 location.href（Safari 不會攔截）
      window.location.href = schemeUrl;
    } else if (isAndroid) {
      // Android：intent:// 優先
      var intentUrl = 'intent://share?c=' + encodeURIComponent(c)
                    + '&t=' + encodeURIComponent(t)
                    + '&i=' + encodeURIComponent(i)
                    + '#Intent;scheme=lumoguide;package=com.app.lumotrip;end';
      window.location.href = intentUrl;
      setTimeout(function () {
        if (!document.hidden) window.location.href = schemeUrl;
      }, 500);
    }
  }

  function showButtons() {
    elLoading.classList.add('hidden');
    elActions.classList.remove('hidden');
  }

  // ── 按鈕事件 ──
  document.getElementById('btn-open').addEventListener('click', function (e) {
    e.preventDefault();
    openAppClick();
  });

  document.getElementById('btn-download').addEventListener('click', function (e) {
    e.preventDefault();
    window.location.href = dlUrl;
  });

  // ── 頁面載入自動嘗試 ──
  if (isIOS || isAndroid) {
    openAppAuto();

    // 2.5 秒後仍在頁面 → App 未打開，顯示按鈕
    setTimeout(function () {
      if (!document.hidden) showButtons();
    }, 2500);
  } else {
    // 桌面瀏覽器直接顯示按鈕
    showButtons();
  }
})();
</script>
</body>
</html>
```

### 4.4 後端需要提供的下載地址

| 場景 | URL |
|------|-----|
| iOS App Store | `https://apps.apple.com/app/id[APP_ID]` |
| Android Google Play | `https://play.google.com/store/apps/details?id=com.app.lumotrip` |
| Android APK（中國） | `https://lumoguide.com/dl/app-release.apk` |

> 建議 `/dl` 路由由後端根據 `User-Agent` + IP 地理位置自動分發。

---

## 五、APK 託管

### 5.1 APK 文件

- 路徑：`https://lumoguide.com/dl/app-release.apk`
- 每次發布新版 APK 時更新此文件
- 建議同時提供版本號文本文件：`https://lumoguide.com/dl/version.txt`（內容如 `1.0.6`）

### 5.2 HTTP 頭配置

APK 文件需要正確的 MIME 類型，否則下載可能失敗：

```
Content-Type: application/vnd.android.package-archive
Content-Disposition: attachment; filename="LUMOGUIDE-1.0.6.apk"
```

### 5.3 中國用戶 APK 安裝說明

Android 在中國無法訪問 Google Play，用戶直接下載 APK 後需要手動安裝。建議 `/dl` 頁面（或 share.html 下載引導）包含簡要安裝提示：

- 下載完成後點擊打開
- 如提示「未知來源」，前往設定 → 安全性 → 允許安裝未知應用
- 部分廠商（華為/小米/OPPO）可能有額外安全提示

---

## 六、API：邀請碼綁定

### 6.1 接口定義

| 項目 | 說明 |
|------|------|
| 方法 | `POST` |
| 路徑 | `/user/bindInviter` |
| 認證 | Bearer Token（用戶需登錄） |
| 用途 | 通過 QR 碼中的邀請碼綁定邀請關係 |

### 6.2 請求

```json
{
  "inviter_code": "ABC123"
}
```

### 6.3 預期響應

```json
{
  "code": 200,
  "message": "success"
}
```

### 6.4 業務邏輯建議

- 被邀請人已綁定過邀請碼 → 返回錯誤（不可重複綁定）
- 被邀請人等於邀請人 → 返回錯誤（不可綁定自己）
- 邀請碼不存在 → 返回錯誤
- 綁定成功後可觸發獎勵邏輯（如積分、會員權益等）

---

## 七、測試檢查清單

部署完成後，按以下步驟驗證：

### 7.1 驗證文件

```bash
# iOS
curl -I https://lumoguide.com/.well-known/apple-app-site-association
# 預期: HTTP 200, Content-Type: application/json

# Android
curl -I https://lumoguide.com/.well-known/assetlinks.json
# 預期: HTTP 200, Content-Type: application/json
```

### 7.2 QR 碼掃碼測試

| 測試場景 | 預期結果 |
|----------|---------|
| iPhone 已裝 App，掃碼 | 直接打開 App，跳轉到對應內容頁 |
| iPhone 未裝 App，掃碼 | Safari 打開 share.html，顯示下載引導 |
| Android 已裝 App，掃碼 | 直接打開 App，跳轉到對應內容頁 |
| Android 未裝 App（非中國），掃碼 | 瀏覽器打開 share.html → Google Play |
| Android 未裝 App（中國），掃碼 | 瀏覽器打開 share.html → APK 下載 |

### 7.3 share.html 測試

- 直接在瀏覽器訪問 `https://lumoguide.com/share?c=TEST&t=city&i=1`
- 確認頁面顯示正常（品牌、按鈕、文案）
- 確認「打開 App」按鈕能觸發 scheme URL

### 7.4 API 測試

```bash
curl -X POST https://api.lumoguide.com/api/user/bindInviter \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"inviter_code": "ABC123"}'
```

---

## 八、相關 App 資訊一覽

| 項目 | 值 |
|------|-----|
| App 名稱 | LUMOGUIDE |
| iOS Bundle ID | `com.app.lumotrip` |
| iOS Team ID | `FLVV24Q9HH` |
| Android Package | `com.app.lumotrip` |
| 自定義 URL Scheme | `lumoguide://` |
| API Base URL | `https://api.lumoguide.com/api/` |
| 前端倉庫 | `https://github.com/PEIPEI-921/LUMOGUIDE-frontend` |

---

## 九、Deep Link 路由映射（供參考）

掃碼後 App 內部跳轉的 type 參數和目標頁面對應關係：

| `t` 參數值 | 目標頁面 | 路由 | 參數 |
|-----------|---------|------|------|
| `guide` | 導遊詳情 | `/guide_detail` | `{'id': id}` |
| `city` | 城市詳情 | `/city_detail` | `{'id': id}` |
| `content` | 通用詳情（景點/餐廳等） | `/common_detail` | `{'id': id}` |
| `trip` | 行程詳情 | `/journey_detail` | `{'id': id}` |
