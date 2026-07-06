import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:lumotrip/pages/index.dart';

import 'widgets/search_bar.dart';

class HomeController extends GetxController with RefreshableMixin, ApiMixin {
  static HomeController get to => Get.find();
  final searchController = TextEditingController();
  Worker? _searchDebounceWorker;

  final merchantCarouselIndex = 0.obs;

  final guideCategoryIndex = 0.obs;
  final merchantCategoryIndex = 0.obs;
  final informationCategoryIndex = 0.obs;

  // 导游分类自动轮播
  Timer? _guideAutoScrollTimer;
  static const _guideAutoScrollInterval = Duration(seconds: 3);

  // 商家分类自动轮播（轮播内容驱动）
  bool _merchantAutoRotateEnabled = true;
  int _previousMerchantBannerIndex = 0;
  Timer? _merchantSingleBannerTimer;

  final _home = Rxn<HomeModel>();
  HomeModel? get home => _home.value;

  // 搜索相关变量
  final isSearching = false.obs;
  final searchResults = <SearchHomeList>[].obs;
  final searchQuery = ''.obs;

  final searchBoxKey = GlobalKey();

  // Overlay 相关
  OverlayEntry? _searchOverlayEntry;

  final _showSearchClose = false.obs;
  bool get showSearchClose => _showSearchClose.value;

  @override
  void onInit() {
    super.onInit();
    initRefresh();
    fetchData();
    CityListStore.to.fetchCityList();

    _searchDebounceWorker = debounce<String>(searchQuery, (value) {
      _performSearch(value);
    }, time: const Duration(seconds: 1));

    searchController.addListener(() {
      _showSearchClose.value = searchController.text.isNotEmpty;
    });

    // 商家分类切换时，处理单 banner 或无 banner 的分类
    ever(merchantCategoryIndex, (_) {
      if (!_merchantAutoRotateEnabled) return;
      final banners = _home.value?.shop[merchantCategoryIndex.value].banner ?? [];
      if (banners.length <= 1) {
        _startMerchantSingleBannerTimer();
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchDebounceWorker?.dispose();
    _stopGuideAutoScroll();
    _resetMerchantBannerState();
    super.onClose();
  }

  void clearSearch({bool all = false}) {
    if (all) {
      searchController.clear();
      searchQuery.value = '';
    }
    searchResults.clear();
    hideKeyboard(Get.context!);
    hideSearchOverlay();
  }

  void onCitySearchTap(SearchHomeList item) {
    switch (item.dataType) {
      case 1:
        Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': item.id});
        break;
      case 2:
        Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': item.id});
        break;
      case 3:
        Get.toNamed(
          AppRoutes.COMMON_DETAIL,
          arguments: {
            'id': item.id,
            'city_id': item.cityId,
            'type_id': item.typeId,
          },
        );
        break;
      default:
        break;
    }
    clearSearch();
  }

  // Overlay 管理方法
  void showSearchOverlay(
    BuildContext context,
    RenderBox searchBox,
    Widget Function() builder,
  ) {
    hideSearchOverlay();

    final overlay = Overlay.of(context);
    final searchBoxPosition = searchBox.localToGlobal(Offset.zero);
    final searchBoxSize = searchBox.size;

    _searchOverlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            left: 0,
            top: searchBoxPosition.dy + searchBoxSize.height,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hideSearchOverlay,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
          Positioned(
            left: searchBoxPosition.dx,
            top: searchBoxPosition.dy + searchBoxSize.height + 8,
            width: searchBoxSize.width,
            child: Material(
              color: Colors.white,
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: builder(),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_searchOverlayEntry!);
  }

  onSeeAllTap() {
    final keyword = searchController.text;
    Get.toNamed(AppRoutes.SEARCH, arguments: {'keyword': keyword});
    clearSearch();
  }

  void hideSearchOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  // 輸入變更（帶防抖）
  void onSearchChanged(
    String query,
    BuildContext context,
    Widget Function() builder,
  ) {
    final RenderBox? searchBox =
        searchBoxKey.currentContext?.findRenderObject() as RenderBox?;
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      hideSearchOverlay();
      return;
    }

    isSearching.value = true;

    if (searchBox != null && searchResults.isNotEmpty) {
      showSearchOverlay(context, searchBox, builder);
    }
  }

  Future<void> _performSearch(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      hideSearchOverlay();
      return;
    }

    final res = await get(ApiUrl.homeSearch, parameters: {'name': trimmed});
    isSearching.value = false;
    if (!res.isSuccess) {
      return;
    }

    final data = res.dataList.map((e) => SearchHomeList.fromJson(e)).toList();
    searchResults.value = data;

    final RenderBox? renderBox =
        searchBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      showSearchOverlay(
        Get.context!,
        renderBox,
        () => SearchResultsOverlay(controller: this),
      );
    }
  }

  _resetCategoryIndex() {
    guideCategoryIndex.value = 0;
    merchantCategoryIndex.value = 0;
    informationCategoryIndex.value = 0;
    _stopGuideAutoScroll();
    _merchantAutoRotateEnabled = true;
    _resetMerchantBannerState();
  }

  void _startGuideAutoScroll() {
    _stopGuideAutoScroll();
    final count = _home.value?.guide.length ?? 0;
    if (count <= 1) return;
    _guideAutoScrollTimer = Timer.periodic(_guideAutoScrollInterval, (_) {
      guideCategoryIndex.value = (guideCategoryIndex.value + 1) % count;
    });
  }

  void _stopGuideAutoScroll() {
    _guideAutoScrollTimer?.cancel();
    _guideAutoScrollTimer = null;
  }

  void onGuideCategoryTap(int index) {
    guideCategoryIndex.value = index;
    _stopGuideAutoScroll();
    _guideAutoScrollTimer = Timer(_guideAutoScrollInterval, () {
      _startGuideAutoScroll();
    });
  }

  void _advanceMerchantCategory() {
    final count = _home.value?.shop.length ?? 0;
    if (count <= 1) return;
    _resetMerchantBannerState();
    merchantCategoryIndex.value = (merchantCategoryIndex.value + 1) % count;
  }

  void _resetMerchantBannerState() {
    _previousMerchantBannerIndex = 0;
    _merchantSingleBannerTimer?.cancel();
    _merchantSingleBannerTimer = null;
  }

  void _startMerchantSingleBannerTimer() {
    _resetMerchantBannerState();
    _merchantSingleBannerTimer =
        Timer(const Duration(seconds: 4), _advanceMerchantCategory);
  }

  void onMerchantBannerPageChanged(
    int index,
    CarouselPageChangedReason reason,
    int bannerCount,
  ) {
    if (!_merchantAutoRotateEnabled) return;

    // 手动滑动 → 永久停止自动轮播
    if (reason == CarouselPageChangedReason.manual) {
      _merchantAutoRotateEnabled = false;
      _resetMerchantBannerState();
      return;
    }

    // 自动轮播：检测是否完成一轮（从最后一张回到第一张）
    if (bannerCount > 1 &&
        index == 0 &&
        _previousMerchantBannerIndex == bannerCount - 1) {
      _advanceMerchantCategory();
    }

    _previousMerchantBannerIndex = index;
  }

  void onMerchantCategoryTap(int index) {
    _merchantAutoRotateEnabled = false;
    _resetMerchantBannerState();
    merchantCategoryIndex.value = index;
  }

  @override
  Future<void> fetchData() async {
    _resetCategoryIndex();

    try {
      final cacheData = StorageStone.homeData;
      if (cacheData.isNotEmpty) {
        final jsonData = jsonDecode(cacheData) as Map<String, dynamic>;
        _home.value = HomeModel.fromJson(jsonData);
        _startGuideAutoScroll();
        endLoad([]);
      }
    } catch (e) {}

    final res = await get(ApiUrl.homeData);
    if (!res.isSuccess) {
      if (_home.value == null) {
        endLoad([]);
        _home.refresh();
      }
      return;
    }

    _home.value = HomeModel.fromJson(res.dataJson);
    _home.refresh();
    StorageStone.setHomeData(jsonEncode(_home.value!.toJson()));
    _startGuideAutoScroll();
    endLoad([]);
  }
}

extension HomeControllerExt on HomeController {
  onSearchTap() async {
    if (searchController.text.isEmpty) {
      return;
    }

    final keyword = searchController.text;

    isSearching.value = true;
    final res = await get(ApiUrl.homeSearch, parameters: {'name': keyword});
    isSearching.value = false;
    if (!res.isSuccess) {
      return;
    }

    final data = res.dataList.map((e) => SearchHomeList.fromJson(e)).toList();
    searchResults.value = data;

    if (_searchOverlayEntry != null) {
      return;
    }

    final RenderBox? renderBox =
        searchBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      showSearchOverlay(
        Get.context!,
        renderBox,
        () => SearchResultsOverlay(controller: this),
      );
    }
  }

  onSectionTap(HomeSection section) {
    print('onSectionTap: $section');
    switch (section) {
      case HomeSection.information:
        RootController.to.handlePageChanged(2);
      case HomeSection.city:
        RootController.to.handlePageChanged(1);
      case HomeSection.guide:
        Get.toNamed(AppRoutes.SEARCH, arguments: {'type': CityDetailTab.guide});
      case HomeSection.merchant:
        final shop = home?.shop[merchantCategoryIndex.value];
        if (shop != null) {
          final tab = CityDetailTabExt.fromId(shop.typeId ?? 0);
          Get.toNamed(AppRoutes.SEARCH, arguments: {'type': tab});
        }
        break;
      default:
        break;
    }
  }

  onCityGuideTap(CityDetailTab type) {
    Get.toNamed(AppRoutes.CITY_STRATEGY, arguments: {'type': type});
  }

  onTapGuideItem(GuideList item) {
    Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': item.id});
  }

  onTapMerchantItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': item.cityId,
        'type_id': item.typeId,
      },
    );
  }

  onTapInformationItem(HomeModelInformationList item) {
    Get.toNamed(AppRoutes.NEWS_DETAIL, arguments: {'id': item.id});
  }
}
