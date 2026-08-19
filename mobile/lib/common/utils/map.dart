import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../values/colors.dart';
import 'loading.dart';

enum _MapAction { show, route }

/// 開啟地址地圖：先彈出「查看位置 / 規劃路線」選單，再開啟系統地圖 App。
///
/// - iOS：Apple Maps（maps.apple.com）
/// - Android：系統預設地圖（geo: URI）；規劃路線用 google.navigation，失敗退回 geo:
///
/// 優先使用經緯度座標（精準釘點），否則用地址文字搜尋。
Future<void> openAddressMap({
  String? name,
  String? address,
  String? latitude,
  String? longitude,
}) async {
  final lat = _toDouble(latitude);
  final lng = _toDouble(longitude);

  final hasCoord = lat != null && lng != null;
  if (!hasCoord && (address == null || address.isEmpty)) {
    Loading.toast('暫無地址資訊'.tr);
    return;
  }

  final action = await _showActionSheet();
  if (action == null) return;

  final ok = action == _MapAction.show
      ? await _openShowLocation(lat: lat, lng: lng, name: name, address: address)
      : await _openRoute(lat: lat, lng: lng, name: name, address: address);
  if (!ok) {
    Loading.toast('無法開啟地圖'.tr);
  }
}

/// 底部選單：查看位置 / 規劃路線
Future<_MapAction?> _showActionSheet() {
  return Get.bottomSheet<_MapAction>(
    SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.place, color: AppColors.primary),
            title: Text('查看位置'.tr),
            onTap: () => Get.back(result: _MapAction.show),
          ),
          ListTile(
            leading: const Icon(Icons.directions, color: AppColors.jadeGreen),
            title: Text('規劃路線'.tr),
            onTap: () => Get.back(result: _MapAction.route),
          ),
        ],
      ),
    ),
  );
}

/// 查看位置：地圖釘選該地點
Future<bool> _openShowLocation({
  required double? lat,
  required double? lng,
  String? name,
  String? address,
}) async {
  final Uri uri;
  if (Platform.isIOS) {
    if (lat != null && lng != null) {
      final q = name?.isNotEmpty == true ? '&q=${Uri.encodeQueryComponent(name!)}' : '';
      uri = Uri.parse('http://maps.apple.com/?ll=$lat,$lng$q');
    } else {
      uri = Uri.parse('http://maps.apple.com/?q=${Uri.encodeQueryComponent(address!)}');
    }
  } else {
    if (lat != null && lng != null) {
      final label =
          name?.isNotEmpty == true ? '(${Uri.encodeQueryComponent(name!)})' : '';
      uri = Uri.parse('geo:0,0?q=$lat,$lng$label');
    } else {
      uri = Uri.parse('geo:0,0?q=${Uri.encodeQueryComponent(address!)}');
    }
  }
  return _launch(uri);
}

/// 規劃路線：地圖進入路線規劃模式
Future<bool> _openRoute({
  required double? lat,
  required double? lng,
  String? name,
  String? address,
}) async {
  final query =
      lat != null && lng != null ? '$lat,$lng' : Uri.encodeQueryComponent(address!);
  if (Platform.isIOS) {
    return _launch(Uri.parse('http://maps.apple.com/?daddr=$query'));
  }
  // Android：先試 Google Maps 導航；失敗則退回 geo: 顯示位置
  if (await _launch(Uri.parse('google.navigation:q=$query'))) return true;
  final label =
      name?.isNotEmpty == true ? '(${Uri.encodeQueryComponent(name!)})' : '';
  final geoUri = lat != null && lng != null
      ? Uri.parse('geo:0,0?q=$lat,$lng$label')
      : Uri.parse('geo:0,0?q=${Uri.encodeQueryComponent(address!)}');
  return _launch(geoUri);
}

Future<bool> _launch(Uri uri) async {
  try {
    if (!await canLaunchUrl(uri)) return false;
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

double? _toDouble(String? v) {
  if (v == null || v.isEmpty) return null;
  return double.tryParse(v);
}
