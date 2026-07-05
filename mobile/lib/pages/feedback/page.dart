import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());
    return IScaffold(
      title: '意見反饋'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller.titleController,
            hintText: '請輸入標題'.tr,
            backgroundColor: Colors.white,
          ),
          10.w.verticalSpace,
          Obx(
            () =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: controller.contentController,
                      hintText: '請將您遇到的問題/產品建議反饋給我們，建議您盡可能詳細地描述問題，便於我們幫您解決。'.tr,
                      backgroundColor: Colors.white,
                      maxLines: 6,
                    ),
                    if (controller.file == null) const _EmptyItem(),
                    if (controller.file != null)
                      Image.file(
                            controller.file!,
                            width: 80.w,
                            height: 80.w,
                            fit: BoxFit.cover,
                          )
                          .clipRRect(all: 6.w)
                          .gestures(
                            onTap: () {
                              controller.onAddImage();
                            },
                            behavior: HitTestBehavior.opaque,
                          )
                          .padding(left: 10.w, bottom: 10.w),
                    const ImageTipWidget().padding(left: 10.w, bottom: 10.w),
                  ],
                ).decorated(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.w),
                ),
          ),
          const Spacer(),
          SubmitButton(title: '提交'.tr, onPressed: controller.onSubmit),
        ],
      ).padding(horizontal: 16.w, bottom: 30.w, top: 10.w),
    );
  }
}

class _EmptyItem extends StatelessWidget {
  const _EmptyItem();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeedbackController>();
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 25.w,
              color: AppColors.primaryText.withOpacity(0.8),
            ),
            Text(
              '上傳圖片'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.primaryText.withOpacity(0.8),
              ),
            ),
          ],
        )
        .constrained(width: 80.w, height: 80.w)
        .decorated(
          color: AppColors.primaryText.withOpacity(0.03),
          borderRadius: BorderRadius.circular(6.w),
        )
        .gestures(
          onTap: () {
            controller.onAddImage();
          },
          behavior: HitTestBehavior.opaque,
        )
        .padding(left: 10.w, bottom: 10.w);
  }
}
