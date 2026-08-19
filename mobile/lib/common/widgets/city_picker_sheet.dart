import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import '../models/city_list.dart';
import '../stores/user.dart';
import '../utils/chinese_search_normalize.dart';
import '../routers/names.dart';
import '../values/colors.dart';
import '../values/font.dart';

class CityPickerSheet extends StatefulWidget {
  const CityPickerSheet({
    super.key,
    this.title,
    required this.cities,
    this.selectedCityId,
  });

  final String? title;
  final List<CityList> cities;
  final int? selectedCityId;

  static Future<CityList?> show({
    String? title,
    required List<CityList> cities,
    int? selectedCityId,
  }) async {
    final list = cities.where((e) => e.id != null).toList();
    if (list.isEmpty) return null;
    return Get.bottomSheet<CityList>(
      CityPickerSheet(
        title: title,
        cities: list,
        selectedCityId: selectedCityId,
      ),
      isScrollControlled: true,
    );
  }

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  final Map<int, String> _normNameById = {};
  String _keywordRaw = '';
  String _normKeyword = '';
  String _keywordTrad = '';

  bool get _showGuideAddCityFooter =>
      Get.isRegistered<UserStore>() && UserStore.to.profile.isGuide;

  /// 简体归一子串、繁体原文子串、简体词转繁体后命中繁体城市名、[CityList.nameEn] 英文。
  List<CityList> get _filtered {
    final kw = _keywordRaw.trim();
    final kwLower = kw.toLowerCase();
    if (kw.isEmpty) return widget.cities;
    return widget.cities.where((c) {
      final id = c.id!;
      final normName = _normNameById[id] ?? '';
      final rawName = c.name ?? '';
      final en = (c.nameEn ?? '').toLowerCase();
      if (en.contains(kwLower)) return true;
      if (kw.isNotEmpty && rawName.contains(kw)) return true;
      if (_keywordTrad.isNotEmpty && rawName.contains(_keywordTrad)) {
        return true;
      }
      if (_normKeyword.isNotEmpty && normName.contains(_normKeyword)) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    for (final c in widget.cities) {
      final id = c.id;
      if (id == null) continue;
      final raw = c.name ?? '';
      _normNameById[id] = raw.isEmpty
          ? ''
          : chineseTextToSimplifiedForMatch(raw);
    }
  }

  void _onKeywordChanged(String value) {
    final trimmed = value.trim();
    setState(() {
      _keywordRaw = value;
      if (trimmed.isEmpty) {
        _normKeyword = '';
        _keywordTrad = '';
      } else {
        _normKeyword = chineseTextToSimplifiedForMatch(trimmed);
        _keywordTrad = chineseTextToTraditionalForMatch(trimmed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title ?? '',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: AppFontSize.md,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: AppColors.primaryText),
                ).positioned(right: 0),
              ],
            ).constrained(height: 40),
            TextField(
              onChanged: _onKeywordChanged,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 10.w,
                ),
                isCollapsed: true,
                hintText: '搜索'.tr,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ).decorated(
              color: AppColors.backgroundBlue,
              borderRadius: BorderRadius.circular(10.w),
            ),
            ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.backgroundBlue,
              ),
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final selId = widget.selectedCityId;
                final checked = selId != null && selId == item.id;
                return Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name ?? '',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: AppFontSize.sm,
                              ),
                            ),
                            Text(
                              item.nameEn ?? '',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: AppFontSize.xs,
                              ),
                            ),
                          ],
                        ).expanded(),
                        if (checked)
                          const Icon(Icons.check, color: AppColors.primary),
                      ],
                    )
                    .padding(vertical: 8.h)
                    .gestures(
                      onTap: () => Get.back(result: item),
                      behavior: HitTestBehavior.opaque,
                    );
              },
              itemCount: _filtered.length,
            ).expanded(),
            if (_showGuideAddCityFooter)
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.PUBLISH_CITY);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  foregroundColor: AppColors.primary,
                ),
                child: Text(
                  '找不到城市？去添加'.tr,
                  style: TextStyle(
                    fontSize: AppFontSize.sm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).constrained(width: double.infinity),
          ],
        )
        .constrained(width: double.infinity, height: 460.h)
        .safeArea()
        .padding(horizontal: 15.w, top: 10.h)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.w),
            topRight: Radius.circular(16.w),
          ),
        );
  }
}
