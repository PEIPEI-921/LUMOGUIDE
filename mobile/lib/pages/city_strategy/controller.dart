import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/guide_list/page.dart';
import 'package:lumotrip/pages/merchant_list/index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CityStrategyController extends GetxController with ApiMixin {
  final _selectedType = CityDetailTab.hotel.obs;
  CityDetailTab get selectedType => _selectedType.value;

  Position? _position;

  final _currentCity = Rxn<CityList>();
  CityList? get currentCity => _currentCity.value;

  final _cityClass = CityClass().obs;
  CityClass get cityClass => _cityClass.value;

  final cities = <CityList>[].obs;

  final allTypes = [
    CityDetailTab.guide,
    CityDetailTab.restaurant,
    CityDetailTab.scenic,
    CityDetailTab.mall,
    CityDetailTab.hotel,
    CityDetailTab.ticket,
    CityDetailTab.traffic,
    CityDetailTab.facility,
    CityDetailTab.activity,
  ];

  PageController? pageController;
  final scrollController = ItemScrollController();
  final pages = <Widget>[].obs;

  int get currentIndex => allTypes.indexOf(selectedType);

  final _isCityPanelVisible = false.obs;
  bool get isCityPanelVisible => _isCityPanelVisible.value;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      _selectedType.value = Get.arguments['type'] ?? CityDetailTab.hotel;
    }
  }

  @override
  void onReady() async {
    super.onReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(index: currentIndex, alignment: 0.7);
    });

    Loading.show();
    _fetchCity();
    await _determinePosition();
    await _fetchLocation();
    await _fetchCityClass();
    Loading.dismiss();
  }

  onChangeTab(CityDetailTab type) {
    _selectedType.value = type;
    pageController?.jumpToPage(
      currentIndex,
    );
  }

  onPageChanged(int index) {
    _selectedType.value = allTypes[index];
  }

  showCitySelection() {
    _isCityPanelVisible.value = !isCityPanelVisible;
  }

  hideCitySelection() {
    _isCityPanelVisible.value = false;
  }

  selectCity(CityList city) {
    if (city.id == currentCity?.id) {
      return;
    }
    _currentCity.value = city;
    _isCityPanelVisible.value = false;
    _fetchCityClass();
  }

  @override
  void onClose() {
    pageController?.dispose();
    super.onClose();
  }
}

extension on CityStrategyController {
  _fetchCity() async {
    final res = await get(ApiUrl.cityList, parameters: {
      'limit': 1000,
      'page': 1,
    });
    if (!res.isSuccess) return;
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    cities.value = data.map((e) => CityList.fromJson(e)).toList();
  }

  _fetchLocation() async {
    final res = await get(ApiUrl.getLocation, parameters: {
      'longitude': _position?.longitude,
      'latitude': _position?.latitude,
    });
    if (!res.isSuccess) return;
    _currentCity.value = CityList.fromJson(res.dataJson);
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    _position = null;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    _position = await Geolocator.getCurrentPosition();
    log('position: $_position');
  }

  _cleanupOldControllers() {
    for (var type in allTypes) {
      if (type != CityDetailTab.guide) {
        final tag = '${currentCity?.id ?? 5}_$type';
        if (Get.isRegistered<MerchantListController>(tag: tag)) {
          Get.delete<MerchantListController>(tag: tag);
        }
      }
    }
  }

  _fetchCityClass() async {
    Loading.show();
    final res = await get(ApiUrl.cityClass, parameters: {
      'city_id': currentCity?.id ?? 5,
    });
    Loading.dismiss();
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    _cityClass.value = CityClass.fromJson(data);

    _cleanupOldControllers();

    pages.clear();

    final initialIndex = allTypes.indexOf(selectedType);
    pageController?.dispose();
    pageController = PageController(initialPage: initialIndex);

    for (var type in allTypes) {
      final categories =
          cityClass.type.firstWhereOrNull((e) => e.id == type.id)?.child ?? [];
      if (type == CityDetailTab.guide) {
        pages.add(GuideListPage(
          cityId: currentCity?.id ?? 5,
          categories: cityClass.guideType,
        ));
      } else {
        pages.add(MerchantListPage(
          type: type,
          categories: categories,
          cityId: currentCity?.id ?? 5,
        ));
      }
    }
  }
}
