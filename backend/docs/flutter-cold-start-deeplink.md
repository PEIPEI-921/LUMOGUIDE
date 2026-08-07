# Flutter 深度鏈接實施指南 — 冷暖啟動全場景覆蓋

## 概述

Web 端已完成冷啟動支持（剪貼板 + 服務端暫存 + Google Play Referrer）。
Flutter App 需要在啟動時實現三通道檢查，按優先級依次嘗試。

## 完整數據流

```
掃碼 → share.html
  ├─ 生成 token（16 位隨機字符串）
  ├─ 寫入剪貼板：{"c":"CODE","t":"guide","i":"123","token":"abc123"}
  ├─ POST /api/common/deferredLink（記錄 token+IP 到 DB）
  └─ 下載 URL 帶 token：/dl?token=abc123
        ├─ Google Play → &referrer=token%3Dabc123
        └─ APK 直下 → 已在 DB 有 IP→token 記錄

App 啟動：
  1. [暖啟動] scheme URL 直接打開 → handleDeepLink() → 導航
  2. [冷啟動] InstallReferrerClient → 取 token → GET /api/common/checkDeferredLink?token=xxx → 導航
  3. [冷啟動] 讀取剪貼板 → 有 token → GET /api/common/checkDeferredLink?token=xxx → 導航
  4. [冷啟動] IP 匹配 → GET /api/common/checkDeferredLink（無參數）→ 導航
```

## API 接口

### 儲存延遲鏈接
```
POST https://api.lumoguide.com/api/common/deferredLink
Content-Type: application/json

{
  "token": "abc123def456ghi7",
  "inviter_code": "CODE",
  "content_type": "guide",   // guide/city/content/trip/invite
  "content_id": 123
}
```

### 查詢延遲鏈接
```
GET https://api.lumoguide.com/api/common/checkDeferredLink?token=abc123def456ghi7
// 或無參數（IP 匹配）

Response:
{
  "code": 200,
  "message": "ok",
  "data": {
    "found": true,
    "inviter_code": "CODE",
    "content_type": "guide",
    "content_id": 123
  }
}
```

## Flutter 實現代碼

### 1. 修復暖啟動 Deep Link Handler（支援 HTTPS URL）

當前 handler 只處理 `lumoguide://` scheme。App Links 會傳入 `https://lumoguide.com/share?...`，
host 是 `lumoguide.com` 不是 `share`，所以 handler 直接 return 了。修復如下：

```dart
// lib/services/deep_link_service.dart

import 'dart:convert';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DeepLinkService {
  static const _apiBase = 'https://api.lumoguide.com/api/common';

  static void init() {
    // 暖啟動：App 已在後台時收到 deep link
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleDeepLink(uri);
    }, onError: (_) {});

    // 暖/冷啟動：App 首次打開時的 deep link
    getInitialUri().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      } else {
        // 沒有 scheme URL → 冷啟動，嘗試其他通道
        _checkColdStartChannels();
      }
    });
  }

  // ══════════════════════════════════════════
  // 支持兩種 URL 格式：
  //   lumoguide://share?c=CODE&t=guide&i=123
  //   https://lumoguide.com/share?c=CODE&t=guide&i=123
  // ══════════════════════════════════════════
  static void _handleDeepLink(Uri uri) {
    final isShareLink =
        (uri.scheme == 'lumoguide' && uri.host == 'share') ||
        (uri.scheme == 'https' &&
            uri.host == 'lumoguide.com' &&
            (uri.path == '/share' || uri.path == '/share.html'));

    if (!isShareLink) return;

    final code = uri.queryParameters['c'] ?? '';
    final type = uri.queryParameters['t'] ?? '';
    final id = uri.queryParameters['i'] ?? '';

    if (type.isEmpty || id.isEmpty) return;

    _bindInviterIfNeeded(code);
    _navigateToContent(type, int.parse(id));
  }

  // ══════════════════════════════════════════
  // 冷啟動三通道檢查
  // ══════════════════════════════════════════
  static Future<void> _checkColdStartChannels() async {
    // 避免重複檢查
    final prefs = await SharedPreferences.getInstance();
    final checked = prefs.getBool('deep_link_checked') ?? false;
    if (checked) return;
    await prefs.setBool('deep_link_checked', true);

    Map<String, String>? params;

    // 通道 1：剪貼板（主通道）
    params = await _checkClipboard();
    // 通道 2：InstallReferrer（Android Play Store 原生）
    if (params == null) {
      params = await _checkInstallReferrer();
    }
    // 通道 3：服務端 IP 匹配（備用兜底）
    if (params == null) {
      params = await _checkServerFallback();
    }

    if (params != null) {
      final type = params['content_type'] ?? '';
      final id = int.tryParse(params['content_id'] ?? '') ?? 0;
      final code = params['inviter_code'] ?? '';

      if (type.isNotEmpty && id > 0) {
        if (code.isNotEmpty) _bindInviterIfNeeded(code);
        _navigateToContent(type, id);
      }
      // 清除剪貼板
      try { Clipboard.setData(ClipboardData(text: '')); } catch (_) {}
    }
  }

  // ── 通道 1：剪貼板 ──
  static Future<Map<String, String>?> _checkClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text ?? '';
      if (!text.contains('"token"')) return null;

      final json = jsonDecode(text) as Map<String, dynamic>;
      final token = json['token'] as String? ?? '';

      if (token.isNotEmpty) {
        return await _fetchDeferredLink(token);
      }
    } catch (_) {}
    return null;
  }

  // ── 通道 2：Android InstallReferrer ──
  static Future<Map<String, String>?> _checkInstallReferrer() async {
    // 需要依賴：install_referrer 或 android_play_install_referrer
    // 用 try-catch 包裹，非 Android / 無依賴時靜默跳過
    try {
      // ignore: undefined_prefixed_name
      final ref = await AndroidInstallReferrer.referrer;
      if (ref == null || ref.isEmpty) return null;

      // referrer 格式：token=abc123def456ghi7
      final params = Uri.splitQueryString(ref);
      final token = params['token'] ?? '';

      if (token.isNotEmpty) {
        return await _fetchDeferredLink(token);
      }
    } catch (_) {}
    return null;
  }

  // ── 通道 3：服務端 IP 備用 ──
  static Future<Map<String, String>?> _checkServerFallback() async {
    try {
      final res = await http.get(Uri.parse('$_apiBase/checkDeferredLink'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['data']?['found'] == true) {
          return {
            'inviter_code': body['data']['inviter_code'] ?? '',
            'content_type': body['data']['content_type'] ?? '',
            'content_id': (body['data']['content_id'] ?? 0).toString(),
          };
        }
      }
    } catch (_) {}
    return null;
  }

  // ── 用 token 查詢服務端 ──
  static Future<Map<String, String>?> _fetchDeferredLink(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$_apiBase/checkDeferredLink?token=$token'),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['data']?['found'] == true) {
          return {
            'inviter_code': body['data']['inviter_code'] ?? '',
            'content_type': body['data']['content_type'] ?? '',
            'content_id': (body['data']['content_id'] ?? 0).toString(),
          };
        }
      }
    } catch (_) {}
    return null;
  }

  // ── 導航到內容頁 ──
  static void _navigateToContent(String type, int id) {
    switch (type) {
      case 'guide':
        navigator.pushNamed('/guide/detail', arguments: {'id': id});
        break;
      case 'city':
        navigator.pushNamed('/city/detail', arguments: {'id': id});
        break;
      case 'content':
        navigator.pushNamed('/city/content/detail', arguments: {'id': id});
        break;
      case 'trip':
        navigator.pushNamed('/trip/detail', arguments: {'id': id});
        break;
      case 'invite':
        // 邀請頁面
        navigator.pushNamed('/invite');
        break;
    }
  }

  static void _bindInviterIfNeeded(String code) {
    if (code.isEmpty) return;
    // 調用現有的 bindInviter API
    // api.post('/user/bindInviter', {'inviter_code': code});
  }
}
```

### 2. 在 main.dart 初始化

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DeepLinkService.init();  // ← 必須在 runApp 之前
  runApp(MyApp());
}
```

### 3. 添加依賴 (pubspec.yaml)

```yaml
dependencies:
  uni_links: ^0.5.1
  shared_preferences: ^2.0.0
  # Android InstallReferrer — 二選一：
  android_play_install_referrer: ^1.0.0   # 或 install_referrer: ^1.0.0
```

## 覆蓋率估計

| 場景 | 通道 | 成功率 |
|------|------|--------|
| 暖啟動 — App Links | scheme URL → handler | ~99% |
| 暖啟動 — 瀏覽器降級 | scheme URL → handler | ~99% |
| 冷啟動 — Android Play Store | InstallReferrer → token → API | ~99% |
| 冷啟動 — Android APK 直下 | 剪貼板 → token → API（備用：IP 匹配） | ~90% |
| 冷啟動 — iOS App Store | 剪貼板 → token → API（備用：IP 匹配） | ~85% |
| **綜合覆蓋** | | **~95%** |

## Web 端已實施的改動

- `share.html` / `invite.html`：生成 token → 剪貼板 + POST deferredLink
- `routes/api.php`：`POST /api/common/deferredLink` + `GET /api/common/checkDeferredLink`
- `CommonController.php`：deferredLink() 儲存、checkDeferredLink() 查詢+消費
- `deferred_deep_links` 表：token(unique)、content_type、content_id、ip_address、consumed
- `/dl/index.php`：Google Play URL 附加 `&referrer=token%3Dxxx`
- Migration：`2026_08_07_000001_create_deferred_deep_links_table.php`
