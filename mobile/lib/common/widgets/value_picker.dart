import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../index.dart';

class ValuePicker extends StatelessWidget {
  ValuePicker({
    super.key,
    this.title,
    required this.datas,
    this.isMultiSelect = false,
    List<String>? selectedDatas,
  }) : selectedValues = (selectedDatas ?? <String>[]).obs;

  final String? title;
  final List<String> datas;
  final bool isMultiSelect;
  final RxList<String> selectedValues;

  final _keyword = ''.obs;
  String get keyword => _keyword.value;

  static Future<List<String>?> show({
    String? title,
    List<String> datas = const [],
    bool isMultiSelect = false,
    List<String>? selectedDatas,
  }) async {
    final result = await Get.bottomSheet(
      ValuePicker(
        title: title,
        datas: datas,
        isMultiSelect: isMultiSelect,
        selectedDatas: selectedDatas,
      ),
      // isScrollControlled: true,
    );
    return result;
  }

  List<String> get _getDatas {
    return datas
        .where((e) => e.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  void _onTap(String value) {
    if (isMultiSelect) {
      if (selectedValues.contains(value)) {
        selectedValues.remove(value);
      } else {
        selectedValues.add(value);
      }
    } else {
      selectedValues.clear();
      selectedValues.add(value);
      Get.back(result: selectedValues);
    }
    log(selectedValues.toString());
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
                      title ?? '',
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
              onChanged: (value) {
                _keyword.value = value;
              },
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
            Obx(() {
              final filteredDatas = _getDatas;
              keyword;
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.backgroundBlue,
                ),
                itemBuilder: (context, index) {
                  final item = filteredDatas[index];
                  return Obx(
                    () =>
                        Row(
                              children: [
                                Text(
                                  item,
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: AppFontSize.sm,
                                  ),
                                ).expanded(),
                                if (selectedValues.contains(item))
                                  const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                  ),
                              ],
                            )
                            .height(44)
                            .gestures(
                              onTap: () => _onTap(item),
                              behavior: HitTestBehavior.opaque,
                            ),
                  );
                },
                itemCount: filteredDatas.length,
              );
            }).expanded(),
            if (isMultiSelect)
              SubmitButton(
                title: '確認'.tr,
                onPressed: () => Get.back(result: selectedValues.toList()),
              ).padding(horizontal: 15.w),
          ],
        )
        .constrained(width: double.infinity, height: 400.h)
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
