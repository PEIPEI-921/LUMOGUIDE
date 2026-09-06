import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/comment_list.dart';
import 'widgets/share_card.dart';
import 'widgets/title.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewsDetailController());
    return IScaffold(
      appBar: IAppBar(
        title: '資訊詳情'.tr,
        actions: [
          Icon(Icons.share, size: 20.w, color: AppColors.primaryText)
              .padding(all: 12.w)
              .gestures(
                onTap: controller.shareNewsCard,
                behavior: HitTestBehavior.opaque,
              ),
        ],
      ),
      body: Obx(() {
        final loaded = controller.news.id != null;
        return Stack(
          children: [
            Column(
              children: [
                Column(
                  children: [
                    const NewsDetailTitleWidget(),

                    Text(
                          controller.news.fullContent ?? '',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primaryText,
                            height: 1.7,
                          ),
                        )
                        .padding(horizontal: 14.w, bottom: 10.w)
                        .alignment(Alignment.centerLeft),
                    _NewsDetailPictureWidget(
                      pictures: controller.news.pictures,
                    ),
                    const NewsDetailCommentWidget(),
                  ],
                ).scrollable().expanded(),
                controller.news.isEvaluate == 1
                    ? CommentBar(
                        count: controller.evaluateCount,
                        onTap: () => controller.onEvaluate(),
                      )
                    : const SizedBox.shrink(),
              ],
            ).decorated(color: Colors.white),
            // 隱形分享卡片（生成分享圖用，寬度固定 375）
            if (loaded)
              Positioned(
                left: 0,
                top: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.01,
                    child: SizedBox(
                      width: 375.w,
                      child: NewsShareCardWidget(
                        repaintKey: controller.shareCardKey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _NewsDetailPictureWidget extends StatelessWidget {
  final List<String> pictures;
  const _NewsDetailPictureWidget({required this.pictures});

  @override
  Widget build(BuildContext context) {
    if (pictures.isEmpty) {
      return const SizedBox.shrink();
    }

    if (pictures.length == 1) {
      return _buildSingleImage(pictures[0]);
    }

    if (pictures.length == 2) {
      return _buildTwoImages(pictures);
    }

    return _buildGridView(pictures);
  }

  Widget _buildSingleImage(String imageUrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 28.w;
        return NetImageCached(
              imageUrl,
              width: availableWidth,
              height: availableWidth,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8.w),
            )
            .padding(horizontal: 14.w, vertical: 10.w)
            .gestures(onTap: () => _previewImages([imageUrl], 0));
      },
    );
  }

  Widget _buildTwoImages(List<String> imageUrls) {
    return Row(
      children: [
        Expanded(
          child:
              NetImageCached(
                    imageUrls[0],
                    width: double.infinity,
                    height: 150.w,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8.w),
                  )
                  .padding(left: 14.w, right: 7.w, top: 10.w, bottom: 10.w)
                  .gestures(onTap: () => _previewImages(imageUrls, 0)),
        ),
        Expanded(
          child:
              NetImageCached(
                    imageUrls[1],
                    width: double.infinity,
                    height: 150.w,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8.w),
                  )
                  .padding(left: 7.w, right: 14.w, top: 10.w, bottom: 10.w)
                  .gestures(onTap: () => _previewImages(imageUrls, 1)),
        ),
      ],
    );
  }

  Widget _buildGridView(List<String> imageUrls) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 7.w,
        crossAxisSpacing: 7.w,
      ),
      itemBuilder: (context, index) {
        return NetImageCached(
          imageUrls[index],
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(5.w),
        ).gestures(onTap: () => _previewImages(imageUrls, index));
      },
      itemCount: imageUrls.length,
    );
  }

  void _previewImages(List<String> imageUrls, int initialIndex) {
    Get.toNamed(
      AppRoutes.PHOTO_VIEW,
      arguments: {'pictures': imageUrls, 'index': initialIndex},
    );
  }
}
