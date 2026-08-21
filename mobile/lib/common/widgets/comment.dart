import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({super.key, required this.item, this.showStar = true});

  final EvaluateList item;
  final bool showStar;

  /// 点击评论用户头像/昵称 → 跳转用户详情（导游→导游详情、商家→商家详情、普通用户→提示）
  void _openUserDetail(EvaluateListUser? user) {
    if (user == null || (user.id ?? 0) <= 0) return;
    if (user.identity == 2 && (user.guideId ?? 0) > 0) {
      Get.toNamed(AppRoutes.GUIDE_DETAIL, arguments: {'id': user.guideId});
    } else if (user.identity == 3 && (user.companyId ?? 0) > 0) {
      Get.toNamed(AppRoutes.COMPANY_INFO, arguments: {'id': user.companyId});
    } else {
      Loading.toast('暫無詳細信息'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = item.user;
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _openUserDetail(user),
              behavior: HitTestBehavior.opaque,
              child: CircleNetworkImage(
                imageUrl: user?.avatar ?? '',
                radius: 16.w,
              ),
            ),
            5.w.horizontalSpace,
            GestureDetector(
              onTap: () => _openUserDetail(user),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.nickname ?? '',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
                  ),
                  if (user?.cityName?.isNotEmpty ?? false)
                    Text(
                      user!.cityName!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.assistantText,
                      ),
                    ).padding(top: 1.w),
                ],
              ),
            ),
            const Spacer(),
            Text(
              item.createdAt ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Column(
          children: [
            if (showStar)
              Row(
                children: [
                  ...List.generate(
                    item.star ?? 0,
                    (index) => Icon(
                      Icons.star,
                      size: 16.w,
                      color: const Color(0xFFF2A200),
                    ),
                  ),
                ],
              ).padding(bottom: 10.w),
            Text(
              item.content ?? '',
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            ).alignment(Alignment.centerLeft),
            if (item.pictures.isNotEmpty)
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.04,
                  mainAxisSpacing: 7,
                  crossAxisSpacing: 7,
                ),
                itemBuilder: (context, index) {
                  return NetImageCached(
                    item.pictures[index],
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(4.w),
                  );
                },
                itemCount: item.pictures.length,
              ).paddingOnly(top: 12.w),
          ],
        ).padding(left: 37.w),
      ],
    ).padding(horizontal: 14.w, vertical: 14.w).decorated(color: Colors.white);
  }
}
