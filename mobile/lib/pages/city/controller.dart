import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import 'widgets/list.dart';

class CityController extends GetxController
    with GetTickerProviderStateMixin, ApiMixin {
  final searchController = TextEditingController();
  late final TabController tabController;
  late final PageController pageController;
  final titles = <String>[].obs;
  final pages = <Widget>[].obs;

  // 搜索相关变量
  final isSearching = false.obs;
  final searchResults = <CityList>[].obs;
  final searchQuery = ''.obs;

  // Overlay 相关
  OverlayEntry? _searchOverlayEntry;

  final searchBoxKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();

    _fetchContinents();
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

  onSearchTap() {}

  onCityTap(CityList city) {
    Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': city.id});
  }

  // 搜索相关方法
  void onSearchChanged(
    String query,
    BuildContext context,
    Widget Function() builder,
  ) {
    final searchBox =
        searchBoxKey.currentContext?.findRenderObject() as RenderBox?;
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      hideSearchOverlay();
      return;
    }

    isSearching.value = true;
    _performSearch(query);

    // 只有在有有效的 searchBox 且有搜索结果时才显示悬浮框
    if (searchBox != null && searchResults.isNotEmpty) {
      showSearchOverlay(context, searchBox, builder);
    }
  }

  void _performSearch(String query) {
    if (CityListStore.to.cityList.isEmpty) return;

    final results = CityListStore.to.cityList.where((city) {
      final name = city.name?.toLowerCase() ?? '';
      final nameEn = city.nameEn?.toLowerCase() ?? '';
      final searchLower = query.trim().toLowerCase();

      return name.contains(searchLower) || nameEn.contains(searchLower);
    }).toList();

    searchResults.value = results;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;
    searchResults.clear();
    hideKeyboard(Get.context!);
    hideSearchOverlay();
  }

  void onCitySearchTap(CityList city) {
    Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': city.id});
    clearSearch();
  }

  onPublishCity() {
    if (!VIPCheckUtils.check()) {
      return;
    }
    Get.toNamed(AppRoutes.PUBLISH_CITY);
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
          // 半透明背景层，覆盖搜索框以下的区域
          Positioned(
            left: 0,
            top: searchBoxPosition.dy + searchBoxSize.height,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hideSearchOverlay,
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),
          ),
          // 搜索结果悬浮框
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

  void hideSearchOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

extension on CityController {
  _fetchContinents() async {
    final res = await get(ApiUrl.getContinents, parameters: {'parent_id': 0});
    if (!res.isSuccess) return;
    final data = res.dataList;
    final continents = data.map((e) => Category.fromJson(e)).toList();
    tabController = TabController(length: continents.length, vsync: this);
    pageController = PageController();
    titles.value = continents.map((e) => e.name ?? '').toList();
    pages.value = continents
        .map((e) => CityListWidget(continentId: e.id ?? 0))
        .toList();
  }
}
