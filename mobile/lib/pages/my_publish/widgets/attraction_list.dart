import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'icon_content.dart';
import 'operate.dart';
import 'status.dart';

class AttractionListController extends GetxController
    with RefreshableMixin, ApiMixin {
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  Future<void> fetchData() async {
    final res = await get(
      ApiUrl.guideAttraction,
      parameters: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess) {
      endLoad([]);
      return;
    }
    final data = res.dataJson['data'] as List<dynamic>? ?? [];
    final list = data.map((e) => GuidePublishAttraction.fromJson(e)).toList();
    endLoad(list);
  }

  onEditItem(GuidePublishAttraction item) async {
    if (item.isRead == 0) {
      item.isRead = 1;
      refreshItems();
    }
    final result = await Get.toNamed(
      AppRoutes.PUBLISH_ATTRACTION,
      arguments: {'id': item.id, 'type': GuidePublishEditor.edit},
    );
    if (result != true) {
      return;
    }
    onRefresh();
  }

  onDeleteItem(GuidePublishAttraction item) async {
    final flag = await AlertUtils.show(
      title: '確定要刪除這條內容嗎？'.tr,
      confirmText: '確定'.tr,
      cancelText: '取消'.tr,
    );
    if (!flag) {
      return;
    }
    Loading.show();
    final res = await post(ApiUrl.guideAttractionDel, data: {'id': item.id});
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    Loading.success('已刪除'.tr);
    onRefresh();
  }
}

class AttractionListWidget extends StatelessWidget {
  const AttractionListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttractionListController());

    return IRefresh(
      controller: controller,
      child: Obx(
        () => controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                itemBuilder: (context, index) =>
                    _Item(item: controller.items[index]),
                separatorBuilder: (context, index) => 10.w.verticalSpace,
                itemCount: controller.items.length,
              ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item});
  final GuidePublishAttraction item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttractionListController>();
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isRead == 0)
                      Container(
                        margin: EdgeInsets.only(right: 4.w),
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      '${'發佈時間'.tr}: ${item.createdAt}',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12.sp,
                      ),
                    ),
                    const Spacer(),
                    StatusWidget(status: item.auditStatus),
                  ],
                ),
                10.w.verticalSpace,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左侧图片
                    NetImageCached(
                      item.firstPicture,
                      width: 90.w,
                      height: 67.w,
                      fit: BoxFit.cover,
                    ).clipRRect(all: 6.w),
                    12.w.horizontalSpace,
                    // 右侧内容
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? '',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        8.w.verticalSpace,
                        IconContent(
                          assets: Assets.iconDial,
                          title: '開放時間'.tr,
                          content: item.startTime ?? '--',
                        ).padding(bottom: 4.w),
                        IconContent(
                          assets: Assets.iconLocation,
                          title: '地址'.tr,
                          content: item.address ?? '',
                        ).padding(bottom: 4.w).gestures(
                          onTap: () => openAddressMap(
                            name: item.name,
                            address: item.address,
                            latitude: item.latitude,
                            longitude: item.longitude,
                          ),
                          behavior: HitTestBehavior.opaque,
                        ),
                      ],
                    ).expanded(),
                  ],
                ),
                if (item.auditFeedback.isNotEmpty && item.auditStatus == 2)
                  Text(
                    '${'駁回原因'.tr}: ${item.auditFeedback ?? ''}',
                    style: const TextStyle(color: Color(0xFFDD0000)),
                  ).padding(top: 10.w),
              ],
            ).padding(all: 10.w).decorated(color: Colors.white),
            OperateWidget(
              onEdit: () {
                controller.onEditItem(item);
              },
              onDelete: () {
                controller.onDeleteItem(item);
              },
              // canDelete: item.auditStatus != 1, // 1审核通过
              canDelete: false,
            ),
          ],
        )
        .decorated(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        )
        .clipRRect(all: 8.w);
  }
}
