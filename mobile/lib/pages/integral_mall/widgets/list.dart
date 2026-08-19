import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class IntegralMallListController extends GetxController
    with ApiMixin, RefreshableMixin {
  final int id;

  IntegralMallListController({required this.id});

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(ApiUrl.integralGoods, parameters: {
      'class_id': id,
      'page': page,
      'limit': limit,
    });
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final lists = res.dataJson['list'] as List<dynamic>? ?? [];
    final goods = lists.map((e) => IntegralGoods.fromJson(e)).toList();
    endLoad(goods);
  }

  onTapItem(IntegralGoods goods) {
    Get.toNamed(AppRoutes.INTEGRAL_GOODS_DETAIL, arguments: {
      'id': goods.id,
    });
  }
}

class IntegralMallListWidget extends StatelessWidget {
  final int id;
  const IntegralMallListWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegralMallListController(id: id),
        tag: 'integral_mall_list_$id');

    return IRefresh(
      controller: controller,
      child: Obx(() => controller.items.isEmpty
          ? const EmptyListWidget()
          : GridView.builder(
              padding: EdgeInsets.only(bottom: 20.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 222.w,
              ),
              itemBuilder: (context, index) =>
                  _Item(controller.items[index], controller),
              itemCount: controller.itemCount,
            )),
    );
  }
}

class _Item extends StatelessWidget {
  final IntegralGoods goods;
  final IntegralMallListController controller;
  const _Item(this.goods, this.controller);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NetImageCached(
          goods.picture ?? '',
          height: 148.w,
          width: double.infinity,
          borderRadius: BorderRadius.circular(4.w),
        ),
        Text(
          goods.name ?? '',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Row(
              children: [
                Text(
                  goods.price.toString(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).flexible(),
                Image.asset(
                  Assets.iconIntegral,
                  color: AppColors.primary,
                  width: 14.w,
                ).padding(left: 3.w),
              ],
            ).expanded(),
            2.w.horizontalSpace,
            Text(
              '去兌換'.tr,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10.sp,
              ),
            ).center().constrained(width: 50.w, height: 20.w).decorated(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
          ],
        ),
      ],
    )
        .padding(all: 10.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.w),
        )
        .gestures(
          onTap: () {
            controller.onTapItem(goods);
          },
          behavior: HitTestBehavior.opaque,
        );
  }
}
