import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class NewsDetailCommentWidget extends StatelessWidget {
  const NewsDetailCommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsDetailController>();

    return Obx(
      () => controller.evaluateList.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      '評論'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                    .alignment(Alignment.centerLeft)
                    .padding(top: 10.w, bottom: 8.w, horizontal: 10.w)
                    .decorated(color: AppColors.primaryText.withOpacity(0.03)),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CommentWidget(
                      item: controller.evaluateList[index],
                      showStar: false,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 20,
                      thickness: 1,
                      color: AppColors.primaryText.withOpacity(0.05),
                    ).padding(left: 50.w);
                  },
                  itemCount: controller.evaluateList.length,
                ),
                TextButton(
                  onPressed: controller.onMoreEvaluate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '查看更多'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primaryText.withOpacity(0.6),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.w,
                        color: AppColors.primaryText.withOpacity(0.6),
                      ),
                    ],
                  ),
                ).padding(top: 10.w),
              ],
            ),
    );
  }
}
