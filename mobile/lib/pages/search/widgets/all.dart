import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class SearchAllController extends GetxController
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
      parameters: {'name': keyword, 'type': 'all'},
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
    switch (item.dataType) {
      case 1:
        Get.toNamed(AppRoutes.CITY_DETAIL, arguments: {'id': item.id});
      case 2:
        Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': item.id});
      case 3:
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
}

class SearchAllWidget extends StatelessWidget {
  const SearchAllWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchAllController());
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
        ListView.separated(
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => 10.w.verticalSpace,
          itemBuilder: (context, index) => _Item(item.data[index]),
          itemCount: item.data.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item);
  final SearchSectionItem item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchAllController>();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
      leading: item.firstPicture != null
          ? NetImageCached(
              item.firstPicture,
              width: 40.w,
              height: 40.w,
              borderRadius: BorderRadius.circular(4.w),
            )
          : Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primaryText.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Icon(
                Icons.location_city,
                color: AppColors.primaryText.withValues(alpha: 0.3),
                size: 20.w,
              ),
            ),
      title: Row(
        children: [
          Text(
            item.name ?? '',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).flexible(),
          if (item.dataType == 2) ...[
            if (item.cityName != null) ...[
              Text(
                    item.cityName!,
                    style: TextStyle(color: AppColors.primary, fontSize: 10.sp),
                  )
                  .padding(horizontal: 4.w, vertical: 1.w)
                  .decorated(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.w),
                  )
                  .padding(left: 6.w),
            ],
            if (item.typeName != null) ...[
              Text(
                    item.typeName!,
                    style: TextStyle(color: AppColors.primary, fontSize: 10.sp),
                  )
                  .padding(horizontal: 4.w, vertical: 1.w)
                  .decorated(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.w),
                  )
                  .padding(left: 6.w),
            ],
          ] else if (item.tag != null) ...[
            Text(
                  item.tag!,
                  style: TextStyle(color: AppColors.primary, fontSize: 10.sp),
                )
                .padding(horizontal: 4.w, vertical: 1.w)
                .decorated(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.w),
                )
                .padding(left: 6.w),
          ],
        ],
      ),
      subtitle: _buildSubtitle(item),
      onTap: () => controller.onTapItem(item),
    ).decorated(color: Colors.white, borderRadius: BorderRadius.circular(8.w));
  }

  _buildSubtitle(SearchSectionItem item) {
    if (item.dataType == 2) {
      return Wrap(
        spacing: 6.w,
        runSpacing: 3.w,
        children: [
          ...item.language?.map(
                (e) =>
                    Text(
                          e,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11.sp,
                          ),
                        )
                        .padding(horizontal: 6.w, vertical: 3.w)
                        .decorated(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
              ) ??
              [],
        ],
      ).padding(top: 3.w);
    } else if (item.nameEn != null) {
      return Text(
        item.nameEn!,
        style: TextStyle(
          color: AppColors.primaryText.withValues(alpha: 0.6),
          fontSize: 12.sp,
        ),
      );
    }
    return null;
  }
}
