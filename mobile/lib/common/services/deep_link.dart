import 'dart:convert';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:play_install_referrer/play_install_referrer.dart';

import '../apis/provider.dart';
import '../apis/urls.dart';
import '../routers/names.dart';
import '../services/storage.dart';
import '../stores/storage.dart';
import '../stores/user.dart';

/// 深度鏈接服務
///
/// 覆蓋暖啟動 + 冷啟動全場景：
/// - **暖啟動**：scheme URL / Universal Link 直接打開 → [_handleDeepLink]
/// - **冷啟動**：無 scheme URL 時，按優先級嘗試延遲深鏈三通道
///   1. 剪貼板 token → `GET /common/checkDeferredLink`（Web 端寫入，主通道）
///   2. Android InstallReferrer → token → 同上（Play Store 安裝）
///   3. 服務端 IP 匹配 → `GET /common/checkDeferredLink`（無參數，備用）
///
/// 所有入口最終統一保存 pending 參數，交由 [checkPendingDeepLink] 處理：
/// 已登錄即時綁定邀請 + 跳轉；未登錄保留到登錄後恢復。
class DeepLinkService {
  static final _appLinks = AppLinks();

  static void init() {
    // 监听 deep link（APP 在后台时收到）
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (Object e) {
      log('deepLink stream error: $e', name: 'DeepLink');
    });

    // 检查冷启动时的 deep link
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      } else {
        // 沒有 scheme URL → 冷啟動，嘗試延遲深鏈三通道
        _checkColdStartChannels();
      }
    });
  }

  static void _handleDeepLink(Uri uri) {
    try {
      final parsed = parseDeepLinkUri(uri);
      if (parsed == null) return;

      // 保存待處理深鏈參數（未登錄時登錄後恢復跳轉 + 綁定邀請）
      // 保存成功後再檢查處理，確保讀到最新值
      _savePendingDeepLink(code: parsed.code, type: parsed.type, id: parsed.id)
          .then((_) => checkPendingDeepLink())
          .catchError((Object e) {
        log('save pending deepLink error: $e', name: 'DeepLink');
      });
    } catch (e) {
      log('handle deepLink error: $e', name: 'DeepLink');
    }
  }

  /// 解析深鏈 URI → `(code, type, id)`。不匹配或參數無效時返回 `null`。
  ///
  /// 支持兩種格式（自定義 scheme 與 Universal/App Link）：
  /// - `lumoguide://share?c=INV&t=type&i=id`
  /// - `https://lumoguide.com/share?c=INV&t=type&i=id`（`/share.html` 同）
  ///
  /// 純函數（無副作用），便於單元測試。`invite` 類型無需 `id`（恒為 0）；
  /// 其餘類型要求 `id` 為正整數，否則視為無效。
  static ({String code, String type, int id})? parseDeepLinkUri(Uri uri) {
    String? code, type, id;

    // 自定義 scheme: lumoguide://share?c=...&t=...&i=...
    if (uri.scheme == 'lumoguide' && uri.host == 'share') {
      code = uri.queryParameters['c'] ?? '';
      type = uri.queryParameters['t'] ?? '';
      id = uri.queryParameters['i'] ?? '';
    }
    // Universal Link / App Link: https://lumoguide.com/share?c=...&t=...&i=...
    else if (uri.scheme == 'https' &&
        uri.host == 'lumoguide.com' &&
        (uri.path == '/share' || uri.path == '/share.html')) {
      code = uri.queryParameters['c'] ?? '';
      type = uri.queryParameters['t'] ?? '';
      id = uri.queryParameters['i'] ?? '';
    } else {
      return null;
    }

    if (type.isEmpty) return null;

    int idInt;
    if (type == 'invite') {
      // invite 只有邀請碼，無需 id
      idInt = 0;
    } else {
      if (id.isEmpty) return null;
      idInt = int.tryParse(id) ?? 0;
      if (idInt <= 0) return null;
    }

    return (code: code, type: type, id: idInt);
  }

  /// 檢查並處理待處理的深鏈（登錄後 / 已登錄收到深鏈時調用）
  ///
  /// 未登錄時只保存不處理，登錄後自動：綁定邀請 → 跳轉對應內容頁 → 清除待處理參數。
  ///
  /// **冷啟動時序說明：** `getInitialLink()` 可能在 `runApp()` 之前就 resolve，
  /// 此時 GetMaterialApp 尚未構建、導航器未就緒。因此處理前先等待導航器就緒
  /// （最多 5 秒），確保 `Get.toNamed` 不會因導航器未就緒而靜默失敗。
  static Future<void> checkPendingDeepLink() async {
    try {
      final raw = StorageStone.pendingDeepLink;
      if (raw.isEmpty) return;
      // 未登錄：保持待處理，等待登錄
      if (!Get.isRegistered<UserStore>() || !UserStore.to.isLogin) return;

      // 等待導航器就緒（冷啟動深鏈早於 runApp 時，GetMaterialApp 尚未構建）
      await _waitForNavigator();
      if (Get.context == null) return;

      // 主導航尚未完成（仍停留在 welcome / login）：此刻跳轉會被
      // welcome 的 offAll(ROOT) 或登錄後的 offAllNamed(ROOT) 清掉，
      // 因此保留待處理參數，等主導航完成後由對應頁面補調用處理。
      final currentRoute = Get.currentRoute;
      if (currentRoute == AppRoutes.WELCOME || currentRoute == AppRoutes.LOGIN) {
        return;
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final code = json['code'] as String? ?? '';
      final type = json['type'] as String? ?? '';
      final id = int.tryParse('${json['id']}');
      if (type.isEmpty || id == null) {
        await _clearPendingDeepLink();
        return;
      }

      // 執行邀請綁定
      if (code.isNotEmpty) {
        await _bindInviter(code);
      }
      // 跳轉到對應內容頁
      _navigateToContent(type, id);
      await _clearPendingDeepLink();
    } catch (e) {
      log('check pending deepLink error: $e', name: 'DeepLink');
    }
  }

  /// 等待 Get 導航器就緒（GetMaterialApp 構建完成）。
  ///
  /// 冷啟動時 `getInitialLink()` 在 `Global.init()` 中註冊，可能比
  /// `runApp()` 更早 resolve。此處輪詢等待 `Get.context` 非空，
  /// 最多 5 秒（20 次 × 250ms），超時返回，待處理參數保留給後續入口重試。
  static Future<void> _waitForNavigator() async {
    for (int i = 0; i < 20; i++) {
      if (Get.context != null) return;
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  // ══════════════════════════════════════════════════════════
  // 冷啟動延遲深鏈三通道
  // ══════════════════════════════════════════════════════════

  /// 冷啟動：無 scheme URL 時，按優先級嘗試剪貼板 → InstallReferrer → IP 匹配。
  ///
  /// 每次安裝只完整檢查一次（deferred token 服務端一次性消費），
  /// 標記在檢查完成後寫入，避免中途被殺進程後漏檢。
  static Future<void> _checkColdStartChannels() async {
    try {
      // 等待 StorageService 就緒（getInitialLink 理論上可能早於 Global.init 完成，
      // 雖然實際幾乎都在 runApp 後才 resolve，加守衛讓流程確定化）
      for (int i = 0; i < 20; i++) {
        if (Get.isRegistered<StorageService>()) break;
        await Future.delayed(const Duration(milliseconds: 250));
      }
      if (!Get.isRegistered<StorageService>()) return;

      if (StorageStone.deepLinkColdChecked) return;

      Map<String, dynamic>? link;

      // 通道 1：剪貼板（Web 端掃碼寫入，主通道）
      link = await _checkClipboard();
      // 通道 2：InstallReferrer（Android Play Store 安裝，token 在 referrer 中）
      link ??= await _checkInstallReferrer();
      // 通道 3：服務端 IP 匹配（備用兜底）
      link ??= await _checkServerFallback();

      // 無論是否找到，本次檢查完成（防止每次冷啟動都重掃剪貼板）
      await StorageStone.setDeepLinkColdChecked(true);

      if (link == null) return;

      final code = (link['inviter_code'] as String? ?? '').trim();
      final type = (link['content_type'] as String? ?? '').trim();
      final id = int.tryParse('${link['content_id'] ?? 0}') ?? 0;
      if (type.isEmpty || id <= 0) return;

      // 保存待處理參數，交由 checkPendingDeepLink 統一處理
      // （已登錄即時跳轉；未登錄等登錄後由 login() 補調用）
      await _savePendingDeepLink(code: code, type: type, id: id);
      await checkPendingDeepLink();
      // 清除剪貼板中的深鏈數據，避免下次誤觸發
      try {
        await Clipboard.setData(const ClipboardData(text: ''));
      } catch (e) {
        log('clear clipboard error: $e', name: 'DeepLink');
      }
    } catch (e) {
      log('check cold start channels error: $e', name: 'DeepLink');
    }
  }

  /// 通道 1：剪貼板。Web 端寫入 `{"c","t","i","token"}`，優先 token → API 驗證；
  /// 兼容舊格式 `{"code","type","id"}`（無 token 時直接取參數）。
  static Future<Map<String, dynamic>?> _checkClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text ?? '';
      if (!text.contains('{')) return null;

      final json = jsonDecode(text) as Map<String, dynamic>;

      // token 通道：POST 延遲深鏈由 Web 端完成，App 只需用 token 查詢
      final token = (json['token'] as String? ?? '').trim();
      if (token.isNotEmpty) {
        final link = await _fetchDeferredLink(token);
        if (link != null) return link;
      }

      // 直接參數兜底（新格式 c/t/i，或舊格式 code/type/id）
      final code =
          (json['c'] as String? ?? json['code'] as String? ?? '').trim();
      final type =
          (json['t'] as String? ?? json['type'] as String? ?? '').trim();
      final idStr =
          (json['i'] as String? ?? json['id'] as String? ?? '').trim();
      if (type.isNotEmpty && idStr.isNotEmpty && int.tryParse(idStr) != null) {
        return {
          'inviter_code': code,
          'content_type': type,
          'content_id': idStr,
        };
      }
    } catch (e) {
      log('check clipboard error: $e', name: 'DeepLink');
    }
    return null;
  }

  /// 通道 2：Android Google Play Install Referrer。
  ///
  /// 掃碼落地頁下載 URL 帶 `&referrer=token%3Dxxx`，Play 安裝後
  /// InstallReferrer API 返回該 token。非 Android / 無 Play 環境拋異常 → 靜默跳過。
  static Future<Map<String, dynamic>?> _checkInstallReferrer() async {
    try {
      final details = await PlayInstallReferrer.installReferrer;
      final ref = details.installReferrer ?? '';
      if (ref.isEmpty) return null;

      final params = Uri.splitQueryString(ref);
      final token = params['token'] ?? '';
      if (token.isNotEmpty) {
        return await _fetchDeferredLink(token);
      }
    } catch (e) {
      log('check install referrer error: $e', name: 'DeepLink');
    }
    return null;
  }

  /// 通道 3：服務端 IP 匹配（無 token，備用兜底）。
  static Future<Map<String, dynamic>?> _checkServerFallback() async {
    return _fetchDeferredLink(null);
  }

  /// 用 token 查詢服務端延遲深鏈；token 為空時走 IP 匹配。
  /// 響應格式：`{found, inviter_code, content_type, content_id}`。
  static Future<Map<String, dynamic>?> _fetchDeferredLink(String? token) async {
    try {
      final res = await ApiProvider().get(
        ApiUrl.commonCheckDeferredLink,
        parameters: {
          if (token != null && token.isNotEmpty) 'token': token,
        },
      );
      if (!res.isSuccess) return null;
      final data = res.dataJson;
      if (data['found'] != true) return null;
      return {
        'inviter_code': data['inviter_code'] ?? '',
        'content_type': data['content_type'] ?? '',
        'content_id': '${data['content_id'] ?? 0}',
      };
    } catch (e) {
      log('fetch deferred link error: $e', name: 'DeepLink');
    }
    return null;
  }

  static Future<void> _savePendingDeepLink({
    required String code,
    required String type,
    required int id,
  }) async {
    final json = jsonEncode({
      'code': code,
      'type': type,
      'id': id,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    await StorageStone.setPendingDeepLink(json);
  }

  static Future<void> _clearPendingDeepLink() async {
    await StorageStone.setPendingDeepLink('');
  }

  static void _navigateToContent(String type, int id) {
    switch (type) {
      case 'guide':
        Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': id});
        break;
      case 'city':
        Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': id});
        break;
      case 'content':
        Get.toNamed(AppRoutes.COMMON_DETAIL, arguments: {'id': id});
        break;
      case 'trip':
        Get.toNamed(AppRoutes.JOURNEY_DETAIL, arguments: {'id': id});
        break;
      case 'invite':
        Get.toNamed(AppRoutes.INVITE);
        break;
    }
  }

  static Future<void> _bindInviter(String code) async {
    try {
      await ApiProvider().post(ApiUrl.bindInviter, data: {'inviter_code': code});
    } catch (e) {
      log('bind inviter error: $e', name: 'DeepLink');
    }
  }
}
