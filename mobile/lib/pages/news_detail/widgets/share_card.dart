import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controller.dart';

/// 資訊詳情分享卡片（與導遊/城市/商家詳情分享卡片風格一致）
///
/// 卡片內容：發佈者 + 標題 + 完整內容 + 圖片（如有）+ LUMOGUIDE 品牌區。
/// 底部 QR 碼內容與其他分享內容保持一致（https://lumoguide.com/share?c=&t=news&i=）：
/// App 已安裝 → 直接打開詳情頁；未安裝 → share.html 下載流程。
class NewsShareCardWidget extends StatelessWidget {
  const NewsShareCardWidget({super.key, required this.repaintKey});

  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsDetailController>();
    final news = controller.news;

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 375.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: AppColors.assistantText.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 發佈者資訊
                Row(
                  children: [
                    CircleNetworkImage(
                      imageUrl: news.user?.photo ?? '',
                      radius: 12.w,
                    ),
                    8.w.horizontalSpace,
                    Text(
                      news.user?.name ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).flexible(),
                    if ((news.user?.identityType ?? '').isNotEmpty) ...[
                      8.w.horizontalSpace,
                      Text(
                            news.user?.identityType ?? '',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: AppColors.primary,
                            ),
                          )
                          .padding(horizontal: 6.w, vertical: 2.w)
                          .decorated(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(100),
                          ),
                    ],
                    if ((news.createdAt ?? '').isNotEmpty) ...[
                      8.w.horizontalSpace,
                      Text(
                        news.createdAt ?? '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.assistantText,
                        ),
                      ),
                    ],
                  ],
                ),
                12.w.verticalSpace,
                // 標題
                Text(
                  news.title ?? '',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    height: 1.4,
                  ),
                ),
                // 完整內容（content 優先，兼容舊數據用 desc 兜底）
                if ((news.fullContent ?? '').isNotEmpty) ...[
                  10.w.verticalSpace,
                  Text(
                    news.fullContent ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primaryText,
                      height: 1.7,
                    ),
                  ),
                ],
                // 圖片（如有）
                if (news.pictures.isNotEmpty) ...[
                  12.w.verticalSpace,
                  _NewsPicturesGrid(pictures: news.pictures),
                ],
                16.w.verticalSpace,
                Container(
                  height: 1.w,
                  color: AppColors.assistantText.withValues(alpha: 0.1),
                ),
                16.w.verticalSpace,
                // 底部：品牌 + QR 碼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              Assets.iconLogo,
                              height: 24.w,
                              fit: BoxFit.contain,
                            ).clipRRect(all: 20),
                            8.w.horizontalSpace,
                            Text(
                              'LUMOGUIDE',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ],
                        ),
                        5.w.verticalSpace,
                        Text(
                          '${UserStore.to.profile.nickname ?? ''}${'邀請您加入 LUMOGUIDE'.tr}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.assistantText,
                          ),
                        ),
                        if (UserStore.to.profile.inviterCode?.isNotEmpty ??
                            false)
                          Text(
                            '${'邀請碼'.tr}: ${UserStore.to.profile.inviterCode ?? ''}',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ).padding(top: 5.w),
                      ],
                    ).expanded(),
                    16.w.horizontalSpace,
                    QrImageView(
                      data: buildContentShareUrl('news', news.id ?? 0),
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      size: 80.w,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ],
                ),
              ],
            ),
            const ShareWatermark(),
          ],
        ),
      ),
    );
  }
}

/// 資訊圖片（與詳情頁一致的三列九宮格，最多 6 張）
class _NewsPicturesGrid extends StatelessWidget {
  final List<String> pictures;

  const _NewsPicturesGrid({required this.pictures});

  @override
  Widget build(BuildContext context) {
    final images = pictures.length > 6 ? pictures.sublist(0, 6) : pictures;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) => NetImageCached(
        images[index],
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ).clipRRect(all: 4.w),
      itemCount: images.length,
    );
  }
}
