import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/list.dart';

class IntegralMallController extends GetxController with ApiMixin {
  late final PageController pageController;
  final titles = <String>[].obs;
  final pages = <Widget>[].obs;

  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController();
    _fetchIntegralMallList();
  }

  onTapItem(int index) {
    // Get.toNamed(AppRoutes.NEWS_DETAIL);
  }

  onLoMoFunTap() {
    Get.toNamed(AppRoutes.MY_INTEGRAL);
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

extension on IntegralMallController {
  _fetchIntegralMallList() async {
    final res = await get(ApiUrl.integralGoodsClass);
    if (!res.isSuccess) return;
    final data = res.dataList;
    final categories = data.map((e) => Category.fromJson(e)).toList();
    titles.value = categories.map((e) => e.name ?? '').toList();
    pages.value = categories
        .map((e) => IntegralMallListWidget(id: e.id ?? 0))
        .toList();
  }
}
