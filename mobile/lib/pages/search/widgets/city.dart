import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class SearchCityController extends GetxController
    with ApiMixin, RefreshableMixin {
  String keyword = '';

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
      parameters: {'name': keyword, 'type': 'city'},
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
    Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': item.id});
  }
}

class SearchCityWidget extends StatelessWidget {
  const SearchCityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchCityController());
    return IRefresh(
      controller: controller,
      child: Obx(
        () => controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                separatorBuilder: (context, index) => 10.w.verticalSpace,
                itemBuilder: (context, index) =>
                    _Section(controller.items[index]),
                itemCount: controller.itemCount,
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.item);
  final SearchSectionModel item;

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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 115.w,
            crossAxisSpacing: 7.w,
            mainAxisSpacing: 7.w,
          ),
          itemBuilder: (context, index) => _Item(item: item.data[index]),
          itemCount: item.data.length,
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item});
  final SearchSectionItem item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchCityController>();
    return Stack(
      children: [
        NetImageCached(
          item.firstPicture ?? '',
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
                Text(
                  item.name ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.nameEn ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.6),
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
        controller.onTapItem(item);
      },
      behavior: HitTestBehavior.opaque,
    );
  }
}
