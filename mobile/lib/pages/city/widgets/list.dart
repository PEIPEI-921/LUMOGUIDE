import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class CityListController extends GetxController
    with ApiMixin, RefreshableMixin {
  final int continentId;
  CityListController({required this.continentId});

  final selectedCategoryId = 0.obs;

  final categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedCategoryId, (callback) {
      fetchData();
    });
    fetchCategory();
  }

  fetchCategory() async {
    final res = await get(
      ApiUrl.getContinents,
      parameters: {'parent_id': continentId},
    );
    if (!res.isSuccess) return;
    final data = res.dataList;
    final continents = data.map((e) => Category.fromJson(e)).toList();
    categories.value = continents;
    selectedCategoryId.value = categories.firstOrNull?.id ?? continentId;
  }

  selectCategory(Category category) {
    selectedCategoryId.value = category.id ?? 0;
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.cityList,
      parameters: {
        'continents_id': continentId,
        'area_id': selectedCategoryId,
        'page': page,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final lists = res.dataJson['list'] as List<dynamic>? ?? [];
    final cities = lists.map((e) => CityList.fromJson(e)).toList();
    endLoad(cities);
  }
}

class CityListWidget extends StatelessWidget {
  const CityListWidget({super.key, required this.continentId});
  final int continentId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CityListController(continentId: continentId),
      tag: 'city_list_controller_$continentId',
    );
    return Obx(
      () => Column(
        children: [
          if (controller.categories.isNotEmpty)
            ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) =>
                  Text(
                    controller.categories[index].name ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color:
                          controller.selectedCategoryId.value ==
                              controller.categories[index].id
                          ? AppColors.primary
                          : AppColors.primaryText,
                    ),
                  ).center().gestures(
                    onTap: () {
                      controller.selectCategory(controller.categories[index]);
                    },
                    behavior: HitTestBehavior.opaque,
                  ),
              separatorBuilder: (context, index) => 20.w.horizontalSpace,
              itemCount: controller.categories.length,
            ).height(40.w),
          if (controller.items.isEmpty) 15.w.verticalSpace,
          IRefresh(
            controller: controller,
            child: controller.items.isEmpty
                ? EmptyListWidget(text: '暫無城市數據'.tr)
                : GridView.builder(
                    padding: EdgeInsets.only(bottom: 20.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 115.w,
                      crossAxisSpacing: 7.w,
                      mainAxisSpacing: 7.w,
                    ),
                    itemBuilder: (context, index) =>
                        _Item(city: controller.items[index]),
                    itemCount: controller.items.length,
                  ),
          ).expanded(),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.city});
  final CityList city;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityController>();
    return Stack(
      children: [
        NetImageCached(
          city.firstPicture ?? '',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(6.w),
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      city.name ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).flexible(),
                    if (city.areaName != null)
                      Text(
                            city.areaName ?? '',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.white,
                            ),
                          )
                          .padding(horizontal: 4.w, vertical: 2.w)
                          .decorated(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.primary.withValues(alpha: 0.8),
                          )
                          .padding(left: 2.w),
                  ],
                ),
                Text(
                  city.nameEn ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ).expanded(),
            Text(
                  '首都'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                )
                .padding(horizontal: 4.w, vertical: 3.w)
                .decorated(
                  borderRadius: BorderRadius.circular(4.w),
                  border: Border.all(color: Colors.white),
                )
                .opacity(0),
          ],
        ).positioned(left: 10.w, bottom: 14.w, right: 10.w),
      ],
    ).gestures(
      onTap: () {
        controller.onCityTap(city);
      },
      behavior: HitTestBehavior.opaque,
    );
  }
}
