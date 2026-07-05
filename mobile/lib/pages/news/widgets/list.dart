import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

import 'package:get/get.dart';

class NewsListController extends GetxController
    with ApiMixin, RefreshableMixin<News> {
  final int categoryId;
  NewsListController({required this.categoryId});

  @override
  void onInit() {
    super.onInit();
    // initRefresh();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.informationLists,
      parameters: {'class_id': categoryId, 'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final lists = res.dataJson['list'] as List<dynamic>? ?? [];
    final news = lists.map((e) => News.fromJson(e)).toList();
    endLoad(news);
  }

  onTapItem(News news) async {
    await Get.toNamed(AppRoutes.NEWS_DETAIL, arguments: {'id': news.id});
  }
}

class NewsListWidget extends StatelessWidget {
  const NewsListWidget({super.key, this.categoryId});
  final int? categoryId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NewsListController(categoryId: categoryId ?? 0),
      tag: 'news_list_$categoryId',
    );

    return Obx(
      () => IRefresh(
        controller: controller,
        child: controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                itemBuilder: (context, index) =>
                    _Item(news: controller.items[index]).gestures(
                      onTap: () =>
                          controller.onTapItem(controller.items[index]),
                      behavior: HitTestBehavior.opaque,
                    ),
                separatorBuilder: (context, index) => 10.w.verticalSpace,
                itemCount: controller.itemCount,
              ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.news});
  final News news;

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleNetworkImage(
                  imageUrl: news.user?.photo ?? '',
                  radius: 16.w,
                ),
                10.w.horizontalSpace,
                Text(
                  news.user?.name ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).flexible(),
                10.w.horizontalSpace,
                Text(
                      news.user?.identityType ?? '',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.sp,
                      ),
                    )
                    .padding(horizontal: 7.w, vertical: 4.w)
                    .decorated(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.primary.withOpacity(0.1),
                    ),
              ],
            ),
            10.w.verticalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  news.desc ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).padding(top: 8.w),
                if (news.pictures.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 10.w),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          mainAxisSpacing: 7,
                          crossAxisSpacing: 7,
                        ),
                    itemBuilder: (context, index) => NetImageCached(
                      news.pictures[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ).clipRRect(all: 5),
                    itemCount: news.pictures.length,
                  ),
              ],
            ),
            12.w.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      Assets.iconDial,
                      width: 12.w,
                      height: 12.w,
                      color: AppColors.assistantText,
                    ),
                    5.w.horizontalSpace,
                    Text(
                      news.createdAt ?? '',
                      style: TextStyle(
                        color: AppColors.primaryText.withOpacity(0.6),
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(Assets.iconComment, width: 12.w, height: 12.w),
                    5.w.horizontalSpace,
                    Text(
                      news.evaluateCount?.toString() ?? '',
                      style: TextStyle(
                        color: AppColors.primaryText.withOpacity(0.6),
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ],
        )
        .padding(all: 10.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        );
  }
}
