import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/index.dart';

class GuideDetailPage extends StatelessWidget {
  const GuideDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuideDetailController());
    return IScaffold(
      appBar: IAppBar(
      title: '導遊詳情'.tr,
        actions: [
          Icon(
            Icons.share,
            size: 20.w,
            color: AppColors.primaryText,
          )
              .padding(all: 12.w)
              .gestures(
                onTap: controller.shareGuideCard,
                behavior: HitTestBehavior.opaque,
              ),
          Icon(
            Icons.qr_code,
            size: 20.w,
            color: AppColors.primaryText,
          )
              .padding(all: 12.w)
              .gestures(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ShareQrcodeDialog(type: 'guide', id: controller.id),
                ),
                behavior: HitTestBehavior.opaque,
              ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F8F9),
      body: Obx(() => controller.guideInfo == null
          ? const SizedBox.shrink()
          : Stack(
              children: [
                Column(
              children: [
                Column(
                  children: [
                    const GuideDetailHeaderWidget(),
                    12.w.verticalSpace,
                    const GuideDetailInfoWidget(),
                    12.w.verticalSpace,
                    const GuideDetailIntroWidget(),
                  ],
                ).padding(all: 16.w).scrollable().expanded(),
                const GuideDetailBottomBarWidget(),
                  ],
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.01,
                      child: SizedBox(
                        width: 375.w,
                        child: GuideShareCardWidget(
                          repaintKey: controller.shareCardKey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
    );
  }
}
