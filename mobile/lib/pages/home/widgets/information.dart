import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../index.dart';
import 'section.dart';

class HomeInformationWidget extends StatelessWidget {
  const HomeInformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => controller.home?.information.isEmpty == true
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeSectionWidget(section: HomeSection.information),
                13.w.verticalSpace,
                const _Category(),
                14.w.verticalSpace,
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => _Item(
                    information: controller
                        .home!
                        .information[controller.informationCategoryIndex.value]
                        .list[index],
                  ),
                  separatorBuilder: (context, index) => 10.w.verticalSpace,
                  itemCount:
                      controller
                          .home
                          ?.information[controller
                              .informationCategoryIndex
                              .value]
                          .list
                          .length ??
                      0,
                ),
              ],
            ).padding(horizontal: 14.w, top: 20.w),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final categories =
          controller.home?.information.map((e) => e.name ?? '').toList() ?? [];
      return Row(
        children: [
          ...categories.map(
            (e) => Obx(
              () =>
                  Text(
                        e,
                        style: TextStyle(
                          color:
                              controller.informationCategoryIndex.value ==
                                  categories.indexOf(e)
                              ? Colors.white
                              : AppColors.primaryText.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                      )
                      .padding(horizontal: 10.w, vertical: 7.w)
                      .decorated(
                        color:
                            controller.informationCategoryIndex.value ==
                                categories.indexOf(e)
                            ? AppColors.primary
                            : AppColors.primaryText.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(100),
                      )
                      .gestures(
                        onTap: () => controller.onInfoCategoryTap(
                            categories.indexOf(e)),
                        behavior: HitTestBehavior.opaque,
                      )
                      .padding(right: 5.w),
            ),
          ),
        ],
      ).scrollable(scrollDirection: Axis.horizontal);
    });
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.information});
  final HomeModelInformationList information;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleNetworkImage(
                  imageUrl: information.userAvatar ?? '',
                  radius: 16.w,
                ),
                10.w.horizontalSpace,
                Text(
                  information.userNickname ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).flexible(),
                10.w.horizontalSpace,
                Text(
                      information.guideType ?? '',
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
                  information.title ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  information.desc ?? '',
                  style: TextStyle(
                    color: AppColors.primaryText.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).padding(top: 8.w),
              ],
            ),
            if (information.pictures.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 10.w),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) => NetImageCached(
                  information.pictures[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ).clipRRect(all: 8.w),
                itemCount: information.pictures.length,
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
                      information.createdAt ?? '',
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
                      '${information.evaluateCount ?? 0}',
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
        )
        .gestures(
          onTap: () => controller.onTapInformationItem(information),
          behavior: HitTestBehavior.opaque,
        );
  }
}
