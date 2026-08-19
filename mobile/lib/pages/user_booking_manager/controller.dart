import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/guide.dart';
import 'widgets/merchant.dart';

extension PageExt on UserBookingType {
  Widget get page {
    switch (this) {
      case UserBookingType.guide:
        return const UserBookingGuideWidget();
      case UserBookingType.merchant:
        return const UserBookingMerchantWidget();
    }
  }
}


class UserBookingManagerController extends GetxController {

  late final PageController pageController;
  final types = UserBookingType.values.obs;
  final pages = <Widget>[].obs;

  final _currentType = UserBookingType.guide.obs;
  UserBookingType get currentType => _currentType.value;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    pages.value = types.map((e) => e.page).toList();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  onChangeTab(UserBookingType type) {
    pageController.animateToPage(
      types.indexOf(type),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  onPageChanged(UserBookingType type) {
    _currentType.value = type;
  }
}
