import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routers/names.dart';
import '../stores/user.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();

  static void init() {
    // 监听 deep link（APP 在后台时收到）
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (_) {});

    // 检查冷启动时的 deep link
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  static void _handleDeepLink(Uri uri) {
    try {
      if (uri.host != 'share') return;

      final code = uri.queryParameters['c'] ?? '';
      final type = uri.queryParameters['t'] ?? '';
      final id = uri.queryParameters['i'] ?? '';

      if (type.isEmpty || id.isEmpty) return;

      final idInt = int.tryParse(id);
      if (idInt == null) return;

      // 如果已登录，记录邀请关系
      if (UserStore.to.isLogin && code.isNotEmpty) {
        _bindInviter(code);
      }

      // 跳转到对应内容页
      _navigateToContent(type, idInt);
    } catch (_) {}
  }

  static void _navigateToContent(String type, int id) {
    switch (type) {
      case 'guide':
        Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': id});
      case 'city':
        Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': id});
      case 'content':
        Get.toNamed(AppRoutes.COMMON_DETAIL, arguments: {'id': id});
      case 'trip':
        Get.toNamed(AppRoutes.JOURNEY_DETAIL, arguments: {'id': id});
    }
  }

  static void _bindInviter(String code) {
    // TODO: 调用 /user/bindInviter 接口
  }
}

class ClipboardService {
  static Future<void> checkShareParams() async {
    final prefs = await SharedPreferences.getInstance();
    final checked = prefs.getBool('deep_link_clipboard_checked') ?? false;
    if (checked) return;

    await prefs.setBool('deep_link_clipboard_checked', true);

    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text ?? '';

      if (!text.startsWith('{') || !text.contains('"code"')) return;

      final json = jsonDecode(text) as Map<String, dynamic>;
      final code = json['code'] as String? ?? '';
      final type = json['type'] as String? ?? '';
      final idStr = json['id'] as String? ?? '';

      if (type.isNotEmpty && idStr.isNotEmpty) {
        final id = int.parse(idStr);
        Future.delayed(const Duration(seconds: 2), () {
          if (code.isNotEmpty && UserStore.to.isLogin) {
            DeepLinkService._bindInviter(code);
          }
          DeepLinkService._navigateToContent(type, id);
        });
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {}
  }
}
