import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class GuideChildListController extends GetxController
    with ApiMixin, RefreshableMixin {
  final int categoryId;
  final int cityId;
  GuideChildListController({required this.categoryId, required this.cityId});

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(ApiUrl.cityGuide, parameters: {
      'city_id': cityId,
      'guide_type': categoryId,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson;
    final list = (data['list'] as List<dynamic>)
        .map((e) => GuideList.fromJson(e as Map<String, dynamic>))
        .toList();
    endLoad(list);
  }

  onTapItem(GuideList item) {
    Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {
      'id': item.id,
    });
  }
}

class GuideChildListWidget extends StatelessWidget {
  const GuideChildListWidget(
      {super.key, required this.categoryId, required this.cityId});

  final int categoryId;
  final int cityId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        GuideChildListController(categoryId: categoryId, cityId: cityId),
        tag: 'guide_child_list_${cityId}_$categoryId');

    return IRefresh(
      controller: controller,
      child: Obx(() {
        if (controller.itemCount == 0) {
          return const EmptyListWidget();
        }
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 200.w,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.w,
          ),
          itemBuilder: (context, index) =>
              _Item(item: controller.items[index], controller: controller),
          itemCount: controller.itemCount,
        );
      }),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.controller});
  final GuideList item;
  final GuideChildListController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NetImageCached(
          item.photo ?? '',
          width: 105.w,
          height: 135.w,
          fit: BoxFit.cover,
        ),
        Text(
          item.name ?? '',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ).padding(top: 5, horizontal: 2),
        Text(
          item.language?.firstOrNull ?? '',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11.sp,
          ),
        )
            .padding(horizontal: 10.w, vertical: 5.w)
            .decorated(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            )
            .padding(top: 3.w),
      ],
    )
        .constrained(width: 105.w)
        .decorated(color: Colors.white)
        .clipRRect(all: 8.w)
        .gestures(
          onTap: () => controller.onTapItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
