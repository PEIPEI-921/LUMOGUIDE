import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'controller.dart';

class MyGroupsPage extends StatelessWidget {
  const MyGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyGroupsController());
    return IScaffold(
      appBar: IAppBar(title: '我的群聊'.tr),
      body: Obx(() {
        final controller = Get.find<MyGroupsController>();
        return controller.loading
            ? const Center(child: CircularProgressIndicator())
            : controller.groupList.isEmpty
            ? const Center(child: EmptyListWidget())
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
                itemCount: controller.groupList.length,
                separatorBuilder: (context, index) => 10.w.verticalSpace,
                itemBuilder: (context, index) {
                  final group = controller.groupList[index];
                  return _GroupItem(
                    groupInfo: group,
                    onTap: () => controller.onTapGroup(group),
                  );
                },
              );
      }),
    );
  }
}

class _GroupItem extends StatelessWidget {
  const _GroupItem({required this.groupInfo, required this.onTap});

  final V2TimGroupInfo groupInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = groupInfo.groupName?.isNotEmpty == true
        ? groupInfo.groupName!
        : groupInfo.groupID;
    final faceUrl = groupInfo.faceUrl;

    Widget avatar;
    if (faceUrl != null && faceUrl.isNotEmpty) {
      avatar = ClipRRect(
        borderRadius: BorderRadius.circular(20.w),
        child: CachedNetworkImage(
          imageUrl: faceUrl,
          width: 40.w,
          height: 40.w,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholderAvatar(),
          errorWidget: (_, __, ___) => _placeholderAvatar(),
        ),
      );
    } else {
      avatar = _placeholderAvatar();
    }

    return Row(
          children: [
            avatar,
            10.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 22.w,
              color: AppColors.assistantText,
            ),
          ],
        )
        .padding(horizontal: 14.w, vertical: 12.w)
        .decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        )
        .gestures(onTap: onTap, behavior: HitTestBehavior.opaque);
  }

  Widget _placeholderAvatar() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Icon(Icons.group, size: 24.w, color: Colors.white),
    );
  }
}
