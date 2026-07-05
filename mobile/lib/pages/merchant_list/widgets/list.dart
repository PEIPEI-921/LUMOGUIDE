import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class MerchantChildListController extends GetxController
    with ApiMixin, RefreshableMixin {
  final int categoryId;
  final CityDetailTab type;
  final int cityId;
  MerchantChildListController({
    required this.categoryId,
    required this.type,
    required this.cityId,
  });

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    switch (type) {
      case CityDetailTab.restaurant:
        fetchRestaurant(categoryId);
        break;
      case CityDetailTab.mall:
        fetchShopping(categoryId);
        break;
      case CityDetailTab.hotel:
        fetchHotel(categoryId);
        break;
      case CityDetailTab.ticket:
        fetchTicket(categoryId);
        break;
      case CityDetailTab.traffic:
        fetchTraffic(categoryId);
        break;
      case CityDetailTab.facility:
        fetchFacility(categoryId);
        break;
      case CityDetailTab.activity:
        fetchActivity(categoryId);
        break;
      case CityDetailTab.scenic:
        fetchScenic(categoryId);
        break;
      default:
        break;
    }
  }

  fetchRestaurant(int categoryId) async {
    final res = await get(ApiUrl.cityRestaurant, parameters: {
      'city_id': cityId,
      'type_class_id': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  fetchShopping(int categoryId) async {
    final res = await get(ApiUrl.cityShopping, parameters: {
      'city_id': cityId,
      'type_class_id': categoryId,
      'page': page,
      'limit': 10,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  fetchHotel(int categoryId) async {
    final res = await get(ApiUrl.cityAccommodation, parameters: {
      'city_id': cityId,
      'type_class_id': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  fetchTicket(int categoryId) async {
    final res = await get(ApiUrl.cityTicket, parameters: {
      'city_id': cityId,
      'type_class_id': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  fetchScenic(int categoryId) async {
    final res = await get(ApiUrl.cityAttraction, parameters: {
      'city_id': cityId,
      'type_class_id': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  fetchTraffic(int categoryId) async {
    final res = await get(ApiUrl.cityTransportation, parameters: {
      'city_id': cityId,
      'type_class_id': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  fetchFacility(int categoryId) async {
    final res = await get(ApiUrl.cityFacility, parameters: {
      'city_id': cityId,
      'type_class_id': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  fetchActivity(int categoryId) async {
    final res = await get(ApiUrl.cityActivity, parameters: {
      'city_id': cityId,
      'category_id': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => MerchantList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  onTapItem(MerchantList merchant) async {
    Get.toNamed(AppRoutes.COMMON_DETAIL, arguments: {
      'id': merchant.id,
      'city_id': cityId,
      'type_id': type.id,
    });
  }
}

class MerchantChildListWidget extends StatelessWidget {
  const MerchantChildListWidget({
    super.key,
    required this.categoryId,
    required this.type,
    required this.cityId,
  });
  final int categoryId;
  final CityDetailTab type;
  final int cityId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        MerchantChildListController(
          categoryId: categoryId,
          type: type,
          cityId: cityId,
        ),
        tag: 'merchant_child_list_controller_${cityId}_${type.id}_$categoryId');
    return IRefresh(
      controller: controller,
      child: Obx(() {
        if (controller.itemCount == 0) {
          return const EmptyListWidget();
        }
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: type == CityDetailTab.ticket ? 160.w : 180.w,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.w,
          ),
          itemBuilder: (context, index) =>
              _Item(controller.items[index], controller),
          itemCount: controller.itemCount,
        );
      }),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item, this.controller);

  final MerchantList item;
  final MerchantChildListController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NetImageCached(
          item.firstPicture ?? '',
          width: double.infinity,
          height: 95.w,
          fit: BoxFit.cover,
        ),
        10.w.verticalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            5.w.verticalSpace,
            if (item.phone.isNotEmpty) ...[
              Row(
                children: [
                  Image.asset(
                    Assets.iconTel,
                    width: 12.w,
                    color: AppColors.assistantText,
                  ),
                  4.w.horizontalSpace,
                  Text(
                    '${'電話'.tr}：${item.phone ?? '--'}',
                    style: TextStyle(
                      color: AppColors.assistantText,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).expanded(),
                ],
              ),
              2.w.verticalSpace,
            ],
            if (item.address != null)
              Row(
                children: [
                  Image.asset(
                    Assets.iconLocation,
                    width: 12.w,
                    color: AppColors.assistantText,
                  ),
                  4.w.horizontalSpace,
                  Text(
                    '${'地址'.tr}：${item.address ?? '--'}',
                    style: TextStyle(
                      color: AppColors.assistantText,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).expanded(),
                ],
              ),
            if (item.startTime.isNotEmpty &&
                (controller.type == CityDetailTab.scenic ||
                    controller.type == CityDetailTab.activity)) ...[
              Row(
                children: [
                  Image.asset(
                    Assets.iconClock,
                    width: 12.w,
                    color: AppColors.assistantText,
                  ),
                  4.w.horizontalSpace,
                  Text(
                    '${controller.type == CityDetailTab.scenic ? '開放時間'.tr : '開始時間'.tr}：${item.startTime ?? '--'}',
                    style: TextStyle(
                      color: AppColors.assistantText,
                      fontSize: 11.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).expanded(),
                ],
              ).padding(bottom: 2.w),
              if (item.endTime.isNotEmpty) ...[
                Row(
                  children: [
                    Image.asset(
                      Assets.iconClock,
                      width: 12.w,
                      color: AppColors.assistantText,
                    ),
                    4.w.horizontalSpace,
                    Text(
                      '${'結束時間'.tr}：${item.endTime ?? '--'}',
                      style: TextStyle(
                        color: AppColors.assistantText,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).expanded(),
                  ],
                ),
              ],
            ],
          ],
        ).padding(horizontal: 8.w)
      ],
    ).decorated(color: Colors.white).clipRRect(all: 8.w).gestures(
          onTap: () => controller.onTapItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
