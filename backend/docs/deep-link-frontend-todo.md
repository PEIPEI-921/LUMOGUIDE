# 深鏈 & QR 分享 — 前端配合需求文檔

> 文件日期：2026-08-02 | 後端部署狀態：已完成（對應文檔「Lumoguide Deep Link & QR 碼分享 — 後端配合文檔」）

---

## 一、現狀摘要（後端已完成，前端只需做下列事項）

後端已於 2026-08-02 全部部署完成並測試通過：

| 項目 | 線上地址 / 狀態 |
|------|----------------|
| iOS 驗證文件（AASA） | `https://lumoguide.com/.well-known/apple-app-site-association` ✅ 200 / application/json |
| Android 驗證文件（assetlinks） | `https://lumoguide.com/.well-known/assetlinks.json` ⚠️ **SHA256 還是佔位符，待前端提供** |
| 深鏈落地頁 | `https://lumoguide.com/share?c={code}&t={type}&i={id}` ✅ |
| 下載分發 | `https://lumoguide.com/dl`（按 UA + IP 自動分發：iOS→App Store、Android 中國→APK、Android 外國→Google Play）✅ |
| 邀請綁定 API | `POST https://api.lumoguide.com/api/user/bindInviter` ✅ |
| 分享 QR 碼 | 後端 `shareQrcode` 已改為生成 `https://lumoguide.com/share?...` 格式 ✅ |
| 域名證書 | `lumoguide.com` 已配置 HTTPS（Let's Encrypt，2026-10-31 到期，自動續期）✅ |

**前端只需做 4 件事**（見第二章），做完後 App 掃碼即可直開。

---

## 二、前端待辦清單（按優先級）

### ✅ P0-1：提供 Android Release 簽名 SHA256（阻塞 App Links）

**必須，否則 Android 已裝 App 掃碼不會直開。**

將以下 JSON 中 `<RELEASE_KEYSTORE_SHA256>` 替換為真實指紋：

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
> ⚠️ 如果同時需要調試用，可以把 debug 和 release 兩個指紋都填入數組。
> ⚠️ 填好後提供給後端部署，或告知後端自行修改。

### ✅ P0-2：上傳 APK 文件（阻塞中國 Android 用戶下載）

將 `app-release.apk` 上傳到服務器：

```
路徑：/www/wwwroot/luomoguide/dl/app-release.apk
```

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

### ✅ P1-1：App 內處理深鏈（Universal Links / App Links）

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

**實現要點**：
1. 處理系統回調（iOS `AppDelegate` 的 `continueUserActivity` / Android Intent），解析 `c`/`t`/`i`
2. 保存深鏈參數（供登錄後跳轉）— 建議存到與 Web 一致的 `localStorage` key：`lumoguide_deep_link`（JSON `{code, type, id, ts}`），或 App 內部存儲
3. 若用戶未登錄：先登錄 → 登錄後恢復深鏈跳轉 + 執行邀請綁定
4. 若已登錄：直接跳轉對應頁面

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
| Android 已裝 App，掃碼 | 直接打開 App → 對應內容頁 |
| Android 未裝（非中國），掃碼 | share.html → Google Play |
| Android 未裝（中國），掃碼 | share.html → APK 下載 |

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
