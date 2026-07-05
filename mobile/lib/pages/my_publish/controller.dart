import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/attraction_list.dart';
import 'widgets/information_list.dart';
import 'widgets/transportation_list.dart';
import 'widgets/facility_list.dart';
import 'widgets/activity_list.dart';

extension CityWidgetExt on GuidePublishType {
  Widget get page {
    switch (this) {
      case GuidePublishType.attraction:
        return const AttractionListWidget();
      case GuidePublishType.information:
        return const InformationListWidget();
      case GuidePublishType.transportation:
        return const TransportationListWidget();
      case GuidePublishType.facility:
        return const FacilityListWidget();
      case GuidePublishType.activity:
        return const ActivityListWidget();
    }
  }
}

class MyPublishController extends GetxController
    with GetTickerProviderStateMixin {
  late final PageController pageController;
  final types = GuidePublishType.values.obs;
  final pages = <Widget>[].obs;

  final _currentType = GuidePublishType.attraction.obs;
  GuidePublishType get currentType => _currentType.value;

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

  onChangeTab(GuidePublishType type) {
    pageController.animateToPage(
      types.indexOf(type),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  onPageChanged(GuidePublishType type) {
    _currentType.value = type;
  }

  onPublishTap() async {
    if (!VIPCheckUtils.check()) {
      return;
    }
    var result;
    switch (currentType) {
      case GuidePublishType.attraction:
        result = await Get.toNamed(AppRoutes.PUBLISH_ATTRACTION);
        break;
      case GuidePublishType.information:
        result = await Get.toNamed(AppRoutes.PUBLISH_INFORMATION);
        break;
      case GuidePublishType.transportation:
        result = await Get.toNamed(AppRoutes.PUBLISH_TRANSPORTATION);
        break;
      case GuidePublishType.facility:
        result = await Get.toNamed(AppRoutes.PUBLISH_FACILITY);
        break;
      case GuidePublishType.activity:
        result = await Get.toNamed(AppRoutes.PUBLISH_ACTIVITY);
        break;
    }
    if (result == null) {
      return;
    }
    switch (currentType) {
      case GuidePublishType.attraction:
        final controller = Get.find<AttractionListController>();
        controller.onRefresh();
        break;
      case GuidePublishType.information:
        final controller = Get.find<InformationListController>();
        controller.onRefresh();
        break;
      case GuidePublishType.transportation:
        final controller = Get.find<TransportationListController>();
        controller.onRefresh();
        break;
      case GuidePublishType.facility:
        final controller = Get.find<FacilityListController>();
        controller.onRefresh();
        break;
      case GuidePublishType.activity:
        final controller = Get.find<ActivityListController>();
        controller.onRefresh();
        break;
    }
  }
}
