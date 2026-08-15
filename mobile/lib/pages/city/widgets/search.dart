import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class CitySearchWidget extends StatelessWidget {
  const CitySearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityController>();

    return Column(
      children: [
        Row(
          children: [
            Text(
              '搜索'.tr,
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            ),
            12.horizontalSpace,
            Row(
                  key: controller.searchBoxKey,
                  children: [
                    TextField(
                      controller: controller.searchController,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14.sp,
                      ),
                      cursorColor: AppColors.primaryText,
                      onChanged: (value) {
                        // 延迟访问 RenderBox，避免在布局过程中访问
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.onSearchChanged(
                            value,
                            context,
                            () => _CitySearchResultsOverlay(
                              controller: controller,
                            ),
                          );
                        });
                      },
                      onTapOutside: (_) {
                        hideKeyboard(context);
                      },
                      decoration: InputDecoration(
                        hintText: '請輸入城市名稱'.tr,
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
                .expanded(),
          ],
        ),
        const _HistoryWidget(),
      ],
    );
  }
}

class _HistoryWidget extends StatelessWidget {
  const _HistoryWidget();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CityHistoryStore.to.cityHistories.isEmpty
          ? const SizedBox.shrink()
          : Row(
              children: [
                Text(
                  '最近瀏覽的城市：'.tr,
                  style: TextStyle(
                    color: AppColors.primaryText.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                ),
                ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      Text(
                        CityHistoryStore.to.cityHistories[index].name,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14.sp,
                        ),
                      ).center().gestures(
                        onTap: () => Get.toNamed(
                          AppRoutes.CITY_DETAIL,
                          arguments: {
                            'id': CityHistoryStore.to.cityHistories[index].id,
                          },
                        ),
                      ),
                  separatorBuilder: (context, index) =>
                      VerticalDivider(width: 20.w, thickness: 1),
                  itemCount: CityHistoryStore.to.cityHistories.length,
                ).height(20.w).expanded(),
              ],
            ).padding(top: 12.w),
    );
  }
}

class _CitySearchResultsOverlay extends StatelessWidget {
  final CityController controller;

  const _CitySearchResultsOverlay({required this.controller});

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

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: controller.searchResults.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final city = controller.searchResults[index];
            return _CitySearchResultItem(
              city: city,
              onTap: () => controller.onCitySearchTap(city),
            );
          },
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: AppColors.primaryText.withValues(alpha: 0.1)),
        ).constrained(maxHeight: 200.w);
      }),
    );
  }
}

class _CitySearchResultItem extends StatelessWidget {
  final CityList city;
  final VoidCallback onTap;

  const _CitySearchResultItem({required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      leading: city.firstPicture != null
          ? NetImageCached(
              city.firstPicture,
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
      title: Text(
        city.name ?? '',
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: city.nameEn != null
          ? Text(
              city.nameEn!,
              style: TextStyle(
                color: AppColors.primaryText.withValues(alpha: 0.6),
                fontSize: 12.sp,
              ),
            )
          : null,
      onTap: onTap,
    );
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
            '未找到相關城市'.tr,
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
