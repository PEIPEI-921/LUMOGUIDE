import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/image_upload.dart';
import 'widgets/visibility_selector.dart';

class PublishInformationPage extends StatelessWidget {
  const PublishInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PublishInformationController());
    return IScaffold(
      appBar: IAppBar(title: '發佈資訊'.tr),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelSelectField(
              label: '分類'.tr,
              hintText: '請選擇資訊分類'.tr,
              value: controller.guidePublish.className ?? '',
              onTap: controller.onSelectCategory,
            ),
            20.w.verticalSpace,
            CustomTextField(
              controller: controller.titleController,
              hintText: '請輸入資訊標題'.tr,
              labelText: '資訊標題'.tr,
              maxLines: 1,
            ),
            20.w.verticalSpace,
            CustomTextField(
              controller: controller.contentController,
              hintText: '請輸入資訊內容'.tr,
              labelText: '資訊內容'.tr,
              maxLines: 10,
            ),
            20.w.verticalSpace,
            const ImageUploadWidget(),
            20.w.verticalSpace,
            const VisibilitySelectorWidget(),
            40.w.verticalSpace,
            SubmitButton(
              title: '確認發佈資訊'.tr,
              onPressed: controller.onSubmit,
            ).clipRRect(all: 100),
            20.w.verticalSpace,
          ],
        ).scrollable().safeArea().padding(horizontal: 14.w),
      ),
    );
  }
}
