import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/list.dart';

class MerchantListController extends GetxController with ApiMixin {
  MerchantListController(
      {required this.type, required this.categories, required this.cityId});

  final CityDetailTab type;
  final List<Category> categories;
  final int cityId;

  late final PageController pageController;
  final titles = <String>[].obs;
  final pages = <Widget>[].obs;

  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    _currentIndex.value = 0;
    pageController = PageController(initialPage: _currentIndex.value);
    titles.value = categories.map((e) => e.name ?? '').toList();
    pages.value = categories
        .map((e) => MerchantChildListWidget(
              categoryId: e.id ?? 0,
              type: type,
              cityId: cityId,
            ))
        .toList();
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

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
