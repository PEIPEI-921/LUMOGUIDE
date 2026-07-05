import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'widgets/all.dart';
import 'widgets/bar.dart';
import 'widgets/city.dart';
import 'widgets/content.dart';
import 'widgets/guide.dart';

class SearchPageController extends GetxController with ApiMixin {
  final _selectedType = CityDetailTab.all.obs;
  CityDetailTab get selectedType => _selectedType.value;

  final allTypes = [
    CityDetailTab.all,
    CityDetailTab.overview,
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

  final textController = TextEditingController();
  Worker? _searchDebounceWorker;

  int get currentIndex => allTypes.indexOf(selectedType);

  String keyword = '';

  final isSearching = false.obs;

  // 搜索相关变量
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

    if (Get.arguments != null) {
      keyword = Get.arguments['keyword'] ?? '';
      _selectedType.value = Get.arguments['type'] ?? CityDetailTab.all;
    }
    textController.text = keyword;
    pageController = PageController(initialPage: currentIndex);
    pages.value = allTypes.map((e) {
      switch (e) {
        case CityDetailTab.all:
          return const SearchAllWidget();
        case CityDetailTab.overview:
          return const SearchCityWidget();
        case CityDetailTab.guide:
          return const SearchGuideWidget();
        default:
          return SearchContentWidget(type: e);
      }
    }).toList();

    _searchDebounceWorker = debounce<String>(searchQuery, (value) {
      _performSearch(value);
    }, time: const Duration(seconds: 1));

    textController.addListener(() {
      _showSearchClose.value = textController.text.isNotEmpty;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(index: currentIndex, alignment: 0.5);
    });
  }

  @override
  void onClose() {
    textController.dispose();
    _searchDebounceWorker?.dispose();
    hideSearchOverlay();
    super.onClose();
  }

  void clearSearch({bool all = false}) {
    if (all) {
      textController.clear();
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

  void onSeeAllTap() {
    keyword = textController.text.trim();
    hideSearchOverlay();
    clearSearch();
    _refreshAllControllers();
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

  onChangeTab(CityDetailTab type) {
    _selectedType.value = type;
    pageController?.jumpToPage(currentIndex);
  }

  onPageChanged(int index) {
    _selectedType.value = allTypes[index];
  }

  onSearchTap() async {
    final keyword = textController.text.trim();
    // if (keyword.isEmpty) return;
    clearSearch();

    isSearching.value = true;

    // 更新关键词
    this.keyword = keyword;

    // 通知所有子控制器刷新数据
    _refreshAllControllers();

    isSearching.value = false;
  }

  // 添加刷新所有控制器的方法
  _refreshAllControllers() {
    // 刷新全部控制器
    if (Get.isRegistered<SearchAllController>()) {
      Get.find<SearchAllController>().updateKeyword(keyword);
    }

    // 刷新城市控制器
    if (Get.isRegistered<SearchCityController>()) {
      Get.find<SearchCityController>().updateKeyword(keyword);
    }

    // 刷新导游控制器
    if (Get.isRegistered<SearchGuideController>()) {
      Get.find<SearchGuideController>().updateKeyword(keyword);
    }

    for (var type in allTypes) {
      if (type != CityDetailTab.all &&
          type != CityDetailTab.overview &&
          type != CityDetailTab.guide) {
        final tag = type.id.toString();
        if (Get.isRegistered<SearchContentController>(tag: tag)) {
          Get.find<SearchContentController>(tag: tag).updateKeyword(keyword);
        }
      }
    }
  }
}
