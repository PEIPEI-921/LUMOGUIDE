import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:path_provider/path_provider.dart';

import '../../pages/guide_detail/widgets/share_preview_dialog.dart';
import 'index.dart';

class CityDetailController extends GetxController
    with ApiMixin, UserStoreMixin {
  int cityId = 0;

  final scrollController = ScrollController();
  final pageController = PageController();

  final _bannerIndex = 0.obs;
  int get bannerIndex => _bannerIndex.value;

  final _tabIndex = 0.obs;
  int get tabIndex => _tabIndex.value;

  final _showPinned = false.obs;
  bool get showPinned => _showPinned.value;

  final tabs = [
    CityDetailTab.overview,
    CityDetailTab.guide,
    CityDetailTab.scenic,
    CityDetailTab.restaurant,
    CityDetailTab.mall,
    CityDetailTab.ticket,
    CityDetailTab.hotel,
    CityDetailTab.traffic,
    CityDetailTab.facility,
    CityDetailTab.activity,
  ];

  var pages = <Widget>[];

  final _cityInfo = CityInfo().obs;
  CityInfo get cityInfo => _cityInfo.value;

  final _cityClass = CityClass().obs;
  CityClass get cityClass => _cityClass.value;

  final _showGuidePublishButton = false.obs;
  bool get showGuidePublishButton => _showGuidePublishButton.value;

  final guideCategoryIndex = 0.obs;
  final scenicCategoryIndex = 0.obs;
  final restaurantCategoryIndex = 0.obs;
  final shoppingCategoryIndex = 0.obs;
  final hotelCategoryIndex = 0.obs;
  final trafficCategoryIndex = 0.obs;
  final facilityCategoryIndex = 0.obs;
  final activityCategoryIndex = 0.obs;
  final ticketCategoryIndex = 0.obs;

  final guideList = <GuideList>[].obs;
  final scenicList = <MerchantList>[].obs;
  final restaurantList = <MerchantList>[].obs;
  final shoppingList = <MerchantList>[].obs;
  final hotelList = <MerchantList>[].obs;
  final trafficList = <MerchantList>[].obs;
  final facilityList = <MerchantList>[].obs;
  final activityList = <MerchantList>[].obs;
  final ticketList = <MerchantList>[].obs;

  double get bannerHeight => 235.w;
  double get tabHeight => 83.w;
  double get toolbarHeight => 50.0;
  double get adjustmentOffset => 15.w;

  double get expandedHeight =>
      bannerHeight +
      tabHeight +
      categoryTabHeight -
      ScreenUtil().statusBarHeight -
      adjustmentOffset;

  /// 固定点阈值
  double get pinThreshold =>
      bannerHeight -
      ScreenUtil().statusBarHeight -
      adjustmentOffset -
      toolbarHeight;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      cityId = Get.arguments['id'] ?? 0;
    }

    scrollController.addListener(() {
      final currentOffset = scrollController.offset;
      final shouldPin = currentOffset >= pinThreshold;
      if (_showPinned.value != shouldPin) {
        _showPinned.value = shouldPin;
      }
    });

    pages = tabs.map((e) => e.page).toList();

    fetchCityDetail();
    fetchCityClass();
    // _initCategory();
  }

  List<Category> categoryTypes(int id) {
    return cityClass.type.firstWhereOrNull((e) => e.id == id)?.child ?? [];
  }

  _initCategory() {
    guideCategoryIndex.value = 0;
    final guideCategory = cityClass.guideType.firstOrNull;
    if (guideCategory != null) {
      fetchGuides(guideCategory.id ?? 0);
    }
    scenicCategoryIndex.value = 0;
    final scenicCategory = categoryTypes(
      CommonDetailType.scenic.id,
    ).firstOrNull;
    if (scenicCategory != null) {
      fetchScenic(scenicCategory.id ?? 0);
    }
    final restaurantCategory = categoryTypes(
      CommonDetailType.restaurant.id,
    ).firstOrNull;
    if (restaurantCategory != null) {
      fetchRestaurant(restaurantCategory.id ?? 0);
    }
    final shoppingCategory = categoryTypes(
      CommonDetailType.shopping.id,
    ).firstOrNull;
    if (shoppingCategory != null) {
      fetchShopping(shoppingCategory.id ?? 0);
    }
    final hotelCategory = categoryTypes(CommonDetailType.hotel.id).firstOrNull;
    if (hotelCategory != null) {
      fetchHotel(hotelCategory.id ?? 0);
    }
    final trafficCategory = categoryTypes(
      CommonDetailType.traffic.id,
    ).firstOrNull;
    if (trafficCategory != null) {
      fetchTraffic(trafficCategory.id ?? 0);
    }
    final facilityCategory = categoryTypes(
      CommonDetailType.facility.id,
    ).firstOrNull;
    if (facilityCategory != null) {
      fetchFacility(facilityCategory.id ?? 0);
    }
    final activityCategory = categoryTypes(
      CommonDetailType.activity.id,
    ).firstOrNull;
    if (activityCategory != null) {
      fetchActivity(activityCategory.id ?? 0);
    }
    final ticketCategory = categoryTypes(
      CommonDetailType.ticket.id,
    ).firstOrNull;
    if (ticketCategory != null) {
      fetchTicket(ticketCategory.id ?? 0);
    }
  }

  onBannerChanged(int index) {
    _bannerIndex.value = index;
  }

  onChangeTab(int index) {
    if (userInfo.isUser && tabs[index] != CityDetailTab.overview) {
      AlertUtils.show(
        title: '提示'.tr,
        content: '升級成為 LuMo Guide 或合作商家，即可查看更多城市詳情內容'.tr,
      );
      return;
    }
    _tabIndex.value = index;
    pageController.jumpToPage(index);

    if (userInfo.isGuide && userInfo.isVip) {
      final tab = tabs[index];
      _showGuidePublishButton.value =
          tab == CityDetailTab.scenic ||
          tab == CityDetailTab.traffic ||
          tab == CityDetailTab.facility ||
          tab == CityDetailTab.activity;
    }
  }

  onPageChanged(int index) {
    _tabIndex.value = index;
  }

  onPublishTap() {
    switch (tabs[tabIndex]) {
      case CityDetailTab.scenic:
        Get.toNamed(
          AppRoutes.PUBLISH_ATTRACTION,
          arguments: {'city_id': cityId},
        );
        break;
      case CityDetailTab.traffic:
        Get.toNamed(
          AppRoutes.PUBLISH_TRANSPORTATION,
          arguments: {'city_id': cityId},
        );
        break;
      case CityDetailTab.facility:
        Get.toNamed(AppRoutes.PUBLISH_FACILITY, arguments: {'city_id': cityId});
        break;
      case CityDetailTab.activity:
        Get.toNamed(AppRoutes.PUBLISH_ACTIVITY, arguments: {'city_id': cityId});
        break;
      default:
        break;
    }
  }

  /// 當前頁面的分類標籤索引
  int get categoryTabIndex => switch (tabs[tabIndex]) {
    CityDetailTab.guide => guideCategoryIndex.value,
    CityDetailTab.scenic => scenicCategoryIndex.value,
    CityDetailTab.restaurant => restaurantCategoryIndex.value,
    CityDetailTab.mall => shoppingCategoryIndex.value,
    CityDetailTab.hotel => hotelCategoryIndex.value,
    CityDetailTab.traffic => trafficCategoryIndex.value,
    CityDetailTab.facility => facilityCategoryIndex.value,
    CityDetailTab.activity => activityCategoryIndex.value,
    CityDetailTab.ticket => ticketCategoryIndex.value,
    _ => 0,
  };

  /// 當前頁面是否需要分類欄
  bool get needsCategoryTabs {
    return currentCategoryTabs.isNotEmpty;
  }

  /// 獲取當前頁面的分類標籤
  List<String> get currentCategoryTabs {
    return _getCategoryTabs();
  }

  /// 分類標籤高度
  double get categoryTabHeight => needsCategoryTabs ? 44.w : 0;

  /// 獲取分類標籤列表
  List<String> _getCategoryTabs() {
    final tab = tabs[tabIndex];
    switch (tab) {
      case CityDetailTab.overview:
        return [];
      case CityDetailTab.guide:
        return cityClass.guideType.map((e) => e.name ?? '').toList();
      case CityDetailTab.scenic:
        return categoryTypes(
          CommonDetailType.scenic.id,
        ).map((e) => e.name ?? '').toList();
      case CityDetailTab.restaurant:
        return categoryTypes(
          CommonDetailType.restaurant.id,
        ).map((e) => e.name ?? '').toList();
      case CityDetailTab.mall:
        return categoryTypes(
          CommonDetailType.shopping.id,
        ).map((e) => e.name ?? '').toList();
      case CityDetailTab.hotel:
        return categoryTypes(
          CommonDetailType.hotel.id,
        ).map((e) => e.name ?? '').toList();
      case CityDetailTab.traffic:
        return categoryTypes(
          CommonDetailType.traffic.id,
        ).map((e) => e.name ?? '').toList();
      case CityDetailTab.facility:
        return categoryTypes(
          CommonDetailType.facility.id,
        ).map((e) => e.name ?? '').toList();
      case CityDetailTab.activity:
        return categoryTypes(
          CommonDetailType.activity.id,
        ).map((e) => e.name ?? '').toList();
      case CityDetailTab.ticket:
        return categoryTypes(
          CommonDetailType.ticket.id,
        ).map((e) => e.name ?? '').toList();
      default:
        return [];
    }
  }

  /// 切換分類標籤
  onCategoryTabChanged(int index) async {
    final tab = tabs[tabIndex];
    switch (tab) {
      case CityDetailTab.guide:
        guideCategoryIndex.value = index;
        await fetchGuides(cityClass.guideType[index].id ?? 0);
        break;
      case CityDetailTab.scenic:
        scenicCategoryIndex.value = index;
        await fetchScenic(
          categoryTypes(CommonDetailType.scenic.id)[index].id ?? 0,
        );
        break;
      case CityDetailTab.restaurant:
        restaurantCategoryIndex.value = index;
        await fetchRestaurant(
          categoryTypes(CommonDetailType.restaurant.id)[index].id ?? 0,
        );
        break;
      case CityDetailTab.mall:
        shoppingCategoryIndex.value = index;
        await fetchShopping(
          categoryTypes(CommonDetailType.shopping.id)[index].id ?? 0,
        );
        break;
      case CityDetailTab.hotel:
        hotelCategoryIndex.value = index;
        await fetchHotel(
          categoryTypes(CommonDetailType.hotel.id)[index].id ?? 0,
        );
        break;
      case CityDetailTab.traffic:
        trafficCategoryIndex.value = index;
        await fetchTraffic(
          categoryTypes(CommonDetailType.traffic.id)[index].id ?? 0,
        );
        break;
      case CityDetailTab.facility:
        facilityCategoryIndex.value = index;
        await fetchFacility(
          categoryTypes(CommonDetailType.facility.id)[index].id ?? 0,
        );
        break;
      case CityDetailTab.activity:
        activityCategoryIndex.value = index;
        await fetchActivity(
          categoryTypes(CommonDetailType.activity.id)[index].id ?? 0,
        );
        break;
      case CityDetailTab.ticket:
        ticketCategoryIndex.value = index;
        await fetchTicket(
          categoryTypes(CommonDetailType.ticket.id)[index].id ?? 0,
        );
        break;
      default:
        break;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    pageController.dispose();
    super.onClose();
  }

  onTapGuideItem(int id) {
    Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': id});
  }

  onTapScenicItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.scenic.id,
      },
    );
  }

  onTapShoppingItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.shopping.id,
      },
    );
  }

  onTapTrafficItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.traffic.id,
      },
    );
  }

  onTapTicketItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.ticket.id,
      },
    );
  }

  onTapActivityItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.activity.id,
      },
    );
  }

  onTapFacilityItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.facility.id,
      },
    );
  }

  onTapHotelItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.hotel.id,
      },
    );
  }

  onTapRestaurantItem(MerchantList item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': cityId,
        'type_id': CommonDetailType.restaurant.id,
      },
    );
  }

  // ---- 分享卡片 ----

  final shareCardKey = GlobalKey();

  Future<void> shareCityCard() async {
    if (cityInfo.id == null) return;

    File? tempFile;
    try {
      Loading.show('正在生成分享圖片...'.tr);

      try {
        log('[分享] 步驟1: 等待初始渲染完成');
        await _waitForInitRender();
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('分享失敗'.tr, content: '請稍後再試'.tr);
        return;
      }

      RenderRepaintBoundary renderObject;
      try {
        log('[分享] 步驟2: 獲取 RenderRepaintBoundary');
        final obj = await _getRenderObj();
        if (obj == null) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗'.tr);
          return;
        }
        renderObject = obj;
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }

      try {
        log('[分享] 步驟3: 等待渲染完成');
        final ready = await _waitForPaint(renderObject);
        if (!ready) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗，請稍後再試'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗，請稍後再試'.tr);
        return;
      }

      ui.Image? image;
      try {
        log('[分享] 步驟4: 捕獲圖片');
        image = await _captureImg(renderObject);
        if (image == null) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }

      Uint8List? pngBytes;
      try {
        log('[分享] 步驟5: 轉換圖片為字節數據');
        pngBytes = await _imgToBytes(image);
        if (pngBytes == null) {
          Loading.dismiss();
          AlertUtils.error('生成圖片失敗'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('生成圖片失敗'.tr);
        return;
      }

      try {
        log('[分享] 步驟6: 保存圖片到臨時文件');
        tempFile = await _saveFile(pngBytes, 'city_share');
        if (tempFile == null) {
          Loading.dismiss();
          AlertUtils.error('保存圖片失敗'.tr);
          return;
        }
      } catch (e) {
        Loading.dismiss();
        AlertUtils.error('保存圖片失敗'.tr);
        return;
      }

      Loading.dismiss();

      try {
        log('[分享] 步驟7: 顯示分享預覽');
        final shareText = '${cityInfo.name ?? ''} - ${'城市詳情'.tr}';
        bool shouldDelete = false;

        await Get.dialog(
          SharePreviewDialog(
            imageFile: tempFile,
            shareText: shareText,
            onShareComplete: () {
              shouldDelete = true;
            },
          ),
          barrierDismissible: true,
        );

        log('[分享] 步驟8: 清理臨時文件');
        await _cleanup(tempFile, shouldDelete);
      } catch (e) {
        log('[分享] 步驟7或8失敗: $e');
        AlertUtils.error('分享失敗'.tr);
        await _cleanup(tempFile, false);
      }
    } catch (e, stackTrace) {
      log('[分享] 發生未捕獲的錯誤: $e');
      log('[分享] 堆棧跟踪: $stackTrace');
      Loading.dismiss();
      AlertUtils.error('分享失敗'.tr);

      if (tempFile != null) {
        await _cleanup(tempFile, false);
      }
    }
  }

  Future<void> _waitForInitRender() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < 3; i++) {
      await SchedulerBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<RenderRepaintBoundary?> _getRenderObj() async {
    return shareCardKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
  }

  Future<bool> _waitForPaint(RenderRepaintBoundary renderObject) async {
    int retryCount = 0;
    const maxRetries = 20;

    bool needsPaint = false;
    try {
      needsPaint = renderObject.debugNeedsPaint;
    } catch (_) {
      needsPaint = false;
    }

    while (needsPaint && retryCount < maxRetries) {
      await Future.delayed(const Duration(milliseconds: 50));
      await SchedulerBinding.instance.endOfFrame;
      retryCount++;

      try {
        needsPaint = renderObject.debugNeedsPaint;
      } catch (_) {
        needsPaint = false;
        break;
      }
    }
    return true;
  }

  Future<ui.Image?> _captureImg(RenderRepaintBoundary renderObject) async {
    return await renderObject.toImage(pixelRatio: 3.0);
  }

  Future<Uint8List?> _imgToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  Future<File?> _saveFile(Uint8List bytes, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    if (!await file.exists()) return null;
    return file;
  }

  Future<void> _cleanup(File file, bool shouldDelete) async {
    try {
      await Future.delayed(
        Duration(seconds: shouldDelete ? 5 : 3),
      );
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      log('[分享] 清理臨時文件失敗: $e');
    }
  }
}

extension CityDetailOverviewExt on CityDetailController {
  String briefValue(CityDetailOverviewType type) {
    switch (type) {
      case CityDetailOverviewType.currency:
        return cityInfo.currency ?? '';
      case CityDetailOverviewType.language:
        return cityInfo.language ?? '';
      case CityDetailOverviewType.population:
        return cityInfo.population ?? '';
      case CityDetailOverviewType.race:
        return cityInfo.race ?? '';
    }
  }
}

const limit = 100;

extension CityDetailApiExt on CityDetailController {
  fetchCityDetail() async {
    Loading.show();
    final res = await get(ApiUrl.cityInfo, parameters: {'city_id': cityId});
    Loading.dismiss();
    if (!res.isSuccess) {
      await AlertUtils.error(res.message);
      Get.back();
      return;
    }
    final data = res.dataJson;
    _cityInfo.value = CityInfo.fromJson(data);
    CityHistoryStore.to.addCity(cityId, _cityInfo.value.name ?? '');
  }

  fetchCityClass() async {
    final res = await get(ApiUrl.cityClass, parameters: {'city_id': cityId});
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    _cityClass.value = CityClass.fromJson(data);
    _initCategory();
  }

  fetchGuides(int categoryId) async {
    final res = await get(
      ApiUrl.cityGuide,
      parameters: {
        'city_id': cityId,
        'guide_type': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => GuideList.fromJson(e as Map<String, dynamic>))
        .toList();
    guideList.value = list;
  }

  fetchScenic(int categoryId) async {
    final res = await get(
      ApiUrl.cityAttraction,
      parameters: {
        'city_id': cityId,
        'type_class_id': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    scenicList.value = list;
  }

  fetchRestaurant(int categoryId) async {
    final res = await get(
      ApiUrl.cityRestaurant,
      parameters: {
        'city_id': cityId,
        'type_class_id': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    restaurantList.value = list;
  }

  fetchShopping(int categoryId) async {
    final res = await get(
      ApiUrl.cityShopping,
      parameters: {
        'city_id': cityId,
        'type_class_id': categoryId,
        'page': 1,
        'limit': 10,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    shoppingList.value = list;
  }

  fetchHotel(int categoryId) async {
    final res = await get(
      ApiUrl.cityAccommodation,
      parameters: {
        'city_id': cityId,
        'type_class_id': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    hotelList.value = list;
  }

  fetchTraffic(int categoryId) async {
    final res = await get(
      ApiUrl.cityTransportation,
      parameters: {
        'city_id': cityId,
        'type_class_id': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    trafficList.value = list;
  }

  fetchFacility(int categoryId) async {
    final res = await get(
      ApiUrl.cityFacility,
      parameters: {
        'city_id': cityId,
        'type_class_id': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    facilityList.value = list;
  }

  fetchActivity(int categoryId) async {
    final res = await get(
      ApiUrl.cityActivity,
      parameters: {
        'city_id': cityId,
        'category_id': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    activityList.value = list;
  }

  fetchTicket(int categoryId) async {
    final res = await get(
      ApiUrl.cityTicket,
      parameters: {
        'city_id': cityId,
        'type_class_id': categoryId,
        'page': 1,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    ticketList.value = list;
  }
}
