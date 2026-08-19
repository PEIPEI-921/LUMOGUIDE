import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/list.dart';

class GuideListController extends GetxController with ApiMixin {
  GuideListController({required this.cityId, required this.categories});

  final int cityId;
  final List<Category> categories;


  late final PageController pageController;
  final titles = <String>[].obs;
  final pages = <Widget>[].obs;

  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;


  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    titles.value = categories.map((e) => e.name ?? '').toList();
    pages.value = categories
        .map((e) => GuideChildListWidget(
              categoryId: e.id ?? 0,
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

}
