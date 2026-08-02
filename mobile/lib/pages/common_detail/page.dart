import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/comment.dart';
import 'widgets/index.dart';

class CommonDetailPage extends StatelessWidget {
  const CommonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommonDetailController());
    return IScaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      backgroundImage: null,
      body: EasyRefresh(
        onRefresh: controller.onRefresh,
        header: const MaterialHeader(),
        child: NestedScrollView(
          controller: controller.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [_CustomAppBar(controller: controller)];
          },
          body: Obx(
            () => controller.merchantInfo.id == null
                ? const SizedBox.shrink()
                : Stack(
                    children: [
                      Column(
                        children: [
                          const Column(
                            children: [
                              CommonDetailInfoWidget(),
                              CommonDetailIntroWidget(),
                              CommonDetailCommentWidget(),
                            ],
                          ).scrollable().expanded(),
                          if (controller.merchantInfo.isEvaluate == 1)
                            CommentBar(
                              showSafeArea: false,
                              showShadow: false,
                              onTap: controller.openComment,
                              count: controller.evaluateCount,
                            ).safeArea(
                              bottom: controller.merchantInfo.isReserve != 1,
                              top: false,
                            ),
                          if (controller.merchantInfo.isReserve == 1)
                            const CommonDetailBottomBarWidget(),
                        ],
                      ).clipRRect(topLeft: 15.w, topRight: 15.w),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.01,
                            child: SizedBox(
                              width: 375.w,
                              child: MerchantShareCardWidget(
                                repaintKey: controller.shareCardKey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget with UserStoreMixin {
  const _CustomAppBar({required this.controller});

  final CommonDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SliverAppBar(
        expandedHeight: controller.expandedHeight,
        toolbarHeight: controller.toolbarHeight,
        pinned: true,
        foregroundColor: controller.showPinned ? Colors.black : Colors.white,
        leadingWidth: 100.w,
        leading:
            Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                    ).padding(right: 2.w),
                    Text(
                      controller.title,
                      style: TextStyle(
                        color: controller.showPinned
                            ? Colors.black
                            : Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                )
                .paddingOnly(left: 14.w)
                .gestures(
                  onTap: () => Get.back(),
                  behavior: HitTestBehavior.opaque,
                ),
        actions: [
          Icon(
                Icons.share,
                size: 20.w,
                color: controller.showPinned ? Colors.black : Colors.white,
              )
              .padding(all: 12.w)
              .gestures(
                onTap: controller.shareMerchantCard,
                behavior: HitTestBehavior.opaque,
              ),
          if (controller.merchantInfo.isShop == 1 &&
              controller.merchantInfo.canFollow == 1)
            Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.merchantInfo.isFollow == 1
                          ? Icons.check
                          : Icons.add,
                      size: 14.w,
                      color: controller.showPinned
                          ? Colors.black
                          : Colors.white,
                    ),
                    4.w.horizontalSpace,
                    Text(
                      controller.merchantInfo.isFollow == 1
                          ? '已關注'.tr
                          : '關注'.tr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: controller.showPinned
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                .padding(horizontal: 10.w, vertical: 6.w)
                .decorated(
                  border: Border.all(
                    color: controller.showPinned ? Colors.black : Colors.white,
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(5.w),
                )
                .gestures(
                  onTap: () => controller.onFollowStore(),
                  behavior: HitTestBehavior.opaque,
                )
                .padding(right: 10.w),
        ],
        systemOverlayStyle: controller.showPinned
            ? customOverlayStyle
            : SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarColor: Colors.white,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
        flexibleSpace: Stack(
          children: [
            const CommonDetailBannerWidget(),
            if (controller.showPinned) Container(color: Colors.white),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: const SizedBox()
              .decorated(color: const Color(0xFFF8F8F9))
              .clipRRect(topLeft: 15.w, topRight: 15.w),
        ),
      ),
    );
  }
}
