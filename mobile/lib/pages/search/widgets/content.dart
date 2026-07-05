import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class SearchContentController extends GetxController
    with ApiMixin, RefreshableMixin {
  SearchContentController({required this.type});
  String keyword = '';
  final CityDetailTab type;
  @override
  void onInit() {
    super.onInit();
    initRefresh();
    keyword = Get.find<SearchPageController>().keyword;
    fetchData();
  }

  updateKeyword(String newKeyword) {
    keyword = newKeyword;
    onRefresh();
  }

  @override
  fetchData() async {
    // if (keyword.isEmpty) return;
    final res = await get(
      ApiUrl.search,
      parameters: {'name': keyword, 'type': 'city_content', 'type_id': type.id},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataList;
    final list = data.map((e) => SearchSectionModel.fromJson(e)).toList();
    endLoad(list);
  }

  onTapItem(SearchSectionItem item) {
    Get.toNamed(
      AppRoutes.COMMON_DETAIL,
      arguments: {
        'id': item.id,
        'city_id': item.cityId,
        'type_id': item.typeId,
      },
    );
  }
}

class SearchContentWidget extends StatelessWidget {
  const SearchContentWidget({super.key, required this.type});
  final CityDetailTab type;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SearchContentController(type: type),
      tag: type.id.toString(),
    );
    return IRefresh(
      controller: controller,
      child: Obx(
        () => controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                separatorBuilder: (context, index) => 10.w.verticalSpace,
                itemBuilder: (context, index) =>
                    _Section(controller.items[index], controller: controller),
                itemCount: controller.itemCount,
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.item, {required this.controller});
  final SearchSectionModel item;
  final SearchContentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name ?? '',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        8.w.verticalSpace,
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 180.w,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.w,
          ),
          itemBuilder: (context, index) =>
              _Item(item.data[index], controller: controller),
          itemCount: item.data.length,
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item, {required this.controller});

  final SearchSectionItem item;
  final SearchContentController controller;

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
                if (!(controller.type == CityDetailTab.scenic ||
                    controller.type == CityDetailTab.activity)) ...[
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
                  if (item.address != null &&
                      controller.type != CityDetailTab.ticket)
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
                ],
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
                        maxLines: 1,
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
                if (controller.type == CityDetailTab.scenic &&
                    item.ticketsFree.isNotEmpty) ...[
                  Row(
                    children: [
                      Image.asset(
                        Assets.iconTicket,
                        width: 12.w,
                        color: AppColors.assistantText,
                      ),
                      4.w.horizontalSpace,
                      Text(
                        '${'門票'.tr}：${item.ticketsFree ?? '--'}',
                        style: TextStyle(
                          color: AppColors.assistantText,
                          fontSize: 11.sp,
                        ),
                      ).expanded(),
                    ],
                  ),
                ],
              ],
            ).padding(horizontal: 8.w),
          ],
        )
        .decorated(color: Colors.white)
        .clipRRect(all: 8.w)
        .gestures(
          onTap: () => controller.onTapItem(item),
          behavior: HitTestBehavior.opaque,
        );
  }
}
