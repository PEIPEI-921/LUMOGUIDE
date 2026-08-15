import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchPageController>();
    return Row(
          key: controller.searchBoxKey,
          children: [
            TextField(
              controller: controller.textController,
              maxLines: 1,
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              cursorColor: AppColors.primaryText,
              onChanged: (v) => controller.onSearchChanged(
                v,
                context,
                () => SearchResultsOverlay(controller: controller),
              ),
              onTapOutside: (_) {
                hideKeyboard(context);
              },
              decoration: InputDecoration(
                hintText: '請輸入城市/導遊/內容'.tr,
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                hintStyle: TextStyle(
                  color: AppColors.primaryText.withValues(alpha: 0.3),
                  fontSize: 14.sp,
                ),
              ),
            ).expanded(),
            Obx(
              () => controller.showSearchClose
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.clearSearch(all: true),
                      icon: const Icon(
                        Icons.cancel,
                        color: AppColors.assistantText,
                        size: 18,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Image.asset(Assets.iconSearchFill, height: 40.w).gestures(
              onTap: () => controller.onSearchTap(),
              behavior: HitTestBehavior.opaque,
            ),
          ],
        )
        .height(40.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        )
        .padding(horizontal: 14.w);
  }
}

class SearchResultsOverlay extends StatelessWidget {
  final SearchPageController controller;

  const SearchResultsOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.w, right: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.searchResults.isEmpty) {
          return _EmptySearchResult();
        }

        return Column(
          children: [
            ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: controller.searchResults.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final city = controller.searchResults[index];
                return _SearchResultItem(
                  item: city,
                  onTap: () => controller.onCitySearchTap(city),
                );
              },
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.primaryText.withValues(alpha: 0.1),
              ),
            ).constrained(maxHeight: 300.w),
          ],
        );
      }),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchHomeList item;
  final VoidCallback onTap;

  const _SearchResultItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
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
      onTap: onTap,
    );
  }

  _buildSubtitle(SearchHomeList item) {
    if (item.dataType == 2) {
      return Wrap(
        spacing: 6.w,
        runSpacing: 3.w,
        children: [
          ...item.language.map(
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
          ),
        ],
      ).padding(top: 3.w);
    } else if (item.dataType == 3) {
      return Text(
        item.cityName ?? '',
        style: TextStyle(
          color: AppColors.primaryText.withValues(alpha: 0.6),
          fontSize: 12.sp,
        ),
      );
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

class _EmptySearchResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            color: AppColors.primaryText.withValues(alpha: 0.3),
            size: 32.w,
          ),
          8.w.verticalSpace,
          Text(
            '未找到相關內容'.tr,
            style: TextStyle(
              color: AppColors.primaryText.withValues(alpha: 0.6),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
