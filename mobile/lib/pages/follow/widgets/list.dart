import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class FollowListController extends GetxController
    with ApiMixin, RefreshableMixin, UserStoreMixin {
  final int categoryId;
  final bool isMyFollow;
  FollowListController({required this.categoryId, required this.isMyFollow});

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
      ApiUrl.followClass,
      parameters: {'parent_id': categoryId},
    );
    if (!res.isSuccess) return;
    final data = res.dataList;
    final temps = data.map((e) => Category.fromJson(e)).toList();
    categories.value = temps;
    selectedCategoryId.value = temps.firstOrNull?.id ?? categoryId;
  }

  selectCategory(Category category) {
    selectedCategoryId.value = category.id ?? 0;
  }

  @override
  Future<void> fetchData() async {
    final url = isMyFollow
        ? ApiUrl.messageMyFollow
        : userInfo.isEnterprise
        ? ApiUrl.messageFollowMyShop
        : ApiUrl.messageFollowMe;
    final res = await get(
      url,
      parameters: {
        'continents_id': categoryId,
        'area_id': selectedCategoryId,
        'page': page,
        'limit': limit,
      },
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['list'] as List<dynamic>? ?? [];
    final users = data.map((e) => FollowUser.fromJson(e)).toList();
    endLoad(users);
  }

  onTapItem(FollowUser user) {
    if (user.userIdentity == 2) {
      Get.toNamed(
        AppRoutes.GUIDE_DETAIL,
        arguments: {'id': user.userIdentityId},
      );
    } else if (user.userIdentity == 4) {
      Get.toNamed(
        AppRoutes.COMMON_DETAIL,
        arguments: {
          'id': user.userIdentityId,
          'city_id': user.shopInfo?.cityId,
          'type_id': user.shopInfo?.typeId,
        },
      );
    } else if (user.userIdentity == 3) {
      Get.toNamed(
        AppRoutes.COMPANY_INFO,
        arguments: {'id': user.userIdentityId},
      );
    }
  }

  onUnfollow(FollowUser user) async {
    final flag = await AlertUtils.show(
      title: '確定要取消關注麼？'.tr,
      cancelText: '取消'.tr,
      confirmText: '確定'.tr,
    );
    if (!flag) return;
    Loading.show();
    final url = user.userIdentity == 4
        ? ApiUrl.unfollowShop
        : ApiUrl.messageFollow;
    final res = await post(
      url,
      data: {
        'user_id': user.userId,
        'shop_id': user.userIdentityId,
        'follow': 0,
      },
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      await AlertUtils.error(res.message);
      return;
    }
    onRefresh();
    reloadUserInfo();
  }

  onFollow(FollowUser user) async {
    Loading.show();
    final res = await post(
      ApiUrl.messageFollow,
      data: {'user_id': user.userId, 'follow': 1},
    );
    Loading.dismiss();
    if (!res.isSuccess) {
      await AlertUtils.error(res.message);
      return;
    }
    onRefresh();
    reloadUserInfo();
  }
}

class FollowListWidget extends StatelessWidget {
  const FollowListWidget({
    super.key,
    required this.categoryId,
    required this.isMyFollow,
  });
  final int categoryId;
  final bool isMyFollow;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      FollowListController(categoryId: categoryId, isMyFollow: isMyFollow),
      tag: 'follow_list_controller_$categoryId',
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
                ? const EmptyListWidget()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => _Item(
                      item: controller.items[index],
                      controller: controller,
                    ),
                    separatorBuilder: (context, index) => 10.w.verticalSpace,
                    itemCount: controller.items.length,
                  ),
          ).expanded(),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.controller});
  final FollowUser item;
  final FollowListController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            CircleNetworkImage(
              imageUrl: item.userAvatar ?? '',
              radius: 24.w,
            ).gestures(
              onTap: () {
                controller.onTapItem(item);
              },
              behavior: HitTestBehavior.opaque,
            ),
            8.w.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      item.userNickname ?? '',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).flexible(),
                    if (item.userCityName != null) ...[
                      4.w.horizontalSpace,
                      Text(
                            item.userCityName ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                          )
                          .padding(horizontal: 4.w, vertical: 2.w)
                          .decorated(
                            borderRadius: BorderRadius.circular(100),
                            color: AppColors.primary,
                          ),
                    ],
                    if (item.userIdentityTag != null) ...[
                      8.w.horizontalSpace,
                      Text(
                            item.userIdentityTag ?? '',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10.sp,
                            ),
                          )
                          .padding(horizontal: 8.w, vertical: 2.w)
                          .decorated(
                            borderRadius: BorderRadius.circular(100),
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                    ],
                  ],
                ),
                if (item.shopsName.isNotEmpty && !controller.isMyFollow) ...[
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${'關注了您的店舖'.tr} '),
                        TextSpan(
                          text: item.shopsName.join('、 '),
                          style: const TextStyle(color: AppColors.primaryText),
                        ),
                      ],
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 10.sp,
                      ),
                    ),
                  ).padding(top: 5),
                ],
              ],
            ).expanded(),
            10.w.horizontalSpace,
            if (item.userIdentity == 2 || controller.isMyFollow)
              Text(
                    item.isFollow == 1 ? '已關注'.tr : '關注'.tr,
                    style: TextStyle(
                      color: item.isFollow == 1
                          ? AppColors.primaryText.withOpacity(0.4)
                          : AppColors.primary,
                      fontSize: 12.sp,
                    ),
                  )
                  .center()
                  .constrained(width: 55.w, height: 24.w)
                  .decorated(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.isFollow == 1
                          ? AppColors.primaryText.withOpacity(0.2)
                          : AppColors.primary,
                    ),
                  )
                  .gestures(
                    onTap: () {
                      if (controller.isMyFollow) {
                        controller.onUnfollow(item);
                      } else {
                        item.isFollow == 1
                            ? controller.onUnfollow(item)
                            : controller.onFollow(item);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                  ),
          ],
        )
        .padding(vertical: 10.w)
        .constrained(minHeight: 68.w)
        .padding(horizontal: 10.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        )
        .gestures(
          onTap: () {
            controller.onTapItem(item);
          },
          behavior: HitTestBehavior.opaque,
        );
  }
}
