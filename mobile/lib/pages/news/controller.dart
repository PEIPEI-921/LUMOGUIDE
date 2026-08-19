import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/list.dart';

class NewsController extends GetxController
    with GetTickerProviderStateMixin, ApiMixin {
  late final PageController pageController;
  final titles = <String>[].obs;
  final pages = <Widget>[].obs;

  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _fetchNewsCategory();
  }

  onTapItem(int index) {
    Get.toNamed(AppRoutes.NEWS_DETAIL);
  }

  onChangeTab(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  onPageChanged(int index) {
    _currentIndex.value = index;
  }

  onPublishNews() async {
    Get.toNamed(AppRoutes.PUBLISH_INFORMATION);
  }
}

extension on NewsController {
  _fetchNewsCategory() async {
    final res = await get(ApiUrl.informationClass);
    if (!res.isSuccess) return;
    final data = res.dataList;
    final categories = data
        .map((e) => Category.fromJson(e))
        .where((e) => e.count != 0)
        .toList();
    titles.value = categories.map((e) => e.name ?? '').toList();
    pages.value = categories
        .map((e) => NewsListWidget(categoryId: e.id ?? 0))
        .toList();
  }
}
