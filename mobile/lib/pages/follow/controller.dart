import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/list.dart';

class FollowController extends GetxController with GetTickerProviderStateMixin, ApiMixin {
  bool isMyFollow = true;

  String get title => isMyFollow ? '我的關注'.tr : '關注我的'.tr;

  late final TabController tabController;
  late final PageController pageController;
  final titles = <String>[].obs;
  final pages = <Widget>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      isMyFollow = Get.arguments['isMyFollow'] ?? true;
    }
    _fetchFollowClass();
  }

  onChangeTab(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  onPageChanged(int index) {
    tabController.animateTo(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}


extension on FollowController {
  _fetchFollowClass() async {
    final res = await get(ApiUrl.followClass, parameters: {
      'parent_id': 0,
    });
    if (!res.isSuccess) return;
    final data = res.dataList;
    final categories = data.map((e) => Category.fromJson(e)).toList();
    tabController = TabController(length: categories.length, vsync: this);
    pageController = PageController();
    titles.value = categories.map((e) => e.name ?? '').toList();
    pages.value = categories.map((e) => FollowListWidget(categoryId: e.id ?? 0, isMyFollow: isMyFollow)).toList();
  }
}