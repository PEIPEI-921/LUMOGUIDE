import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class PublishTransportationPage extends StatelessWidget {
  const PublishTransportationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PublishTransportationController());
    return IScaffold(
      appBar: IAppBar(title: '發布交通'.tr),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              12.w.verticalSpace,
              LabelSelectField(
                label: '城市'.tr,
                value: controller.publish.cityName ?? '',
                hintText: '請選擇所屬城市'.tr,
                isRequired: true,
                onTap: controller.onSelectCity,
              ),
              12.w.verticalSpace,
              LabelSelectField(
                label: '分類'.tr,
                value: controller.publish.typeClassName ?? '',
                hintText: '請選擇分類'.tr,
                isRequired: true,
                onTap: controller.onSelectCategory,
              ),
              12.w.verticalSpace,
              CustomTextField(
                controller: controller.nameController,
                hintText: '請輸入交通名稱'.tr,
                labelText: '交通名稱'.tr,
                isRequired: true,
              ),
              12.w.verticalSpace,
              CustomTextField(
                controller: controller.phoneController,
                hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
                hintFontSize: 12.sp,
                labelText: '電話'.tr,
                keyboardType: TextInputType.phone,
                inputFormatters: [LeadingPlusPhoneFormatter()],
              ),
              12.w.verticalSpace,
              CustomTextField(
                controller: controller.addressController,
                hintText: '請輸入地址'.tr,
                labelText: '地址'.tr,
                isRequired: true,
              ),
              12.w.verticalSpace,
              CustomTextField(
                controller: controller.introController,
                hintText: '請輸入介紹內容'.tr,
                labelText: '交通介紹'.tr,
                maxLines: 6,
              ),
              14.w.verticalSpace,
              const _ImagesWidget(),
              24.w.verticalSpace,
              SubmitButton(
                title: '確認發佈交通'.tr,
                onPressed: controller.onSubmit,
              ).clipRRect(all: 100),
              20.w.verticalSpace,
            ],
          ).padding(horizontal: 14.w),
        ).safeArea(),
      ),
    );
  }
}

class _ImagesWidget extends StatelessWidget {
  const _ImagesWidget();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PublishTransportationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '*',
              style: TextStyle(color: AppColors.red, fontSize: 14),
            ),
            Text('交通封面'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          ],
        ),
        10.w.verticalSpace,
        Obx(
          () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.w,
              childAspectRatio: 1,
            ),
            itemCount: controller.pictures.length >= 6
                ? 6
                : controller.pictures.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.pictures.length &&
                  controller.pictures.length < 6) {
                return Image.asset(
                  Assets.iconPhotoAdd,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ).gestures(onTap: () => controller.selectImage(index: index));
              }
              final image = controller.pictures[index];
              return Stack(
                children: [
                  image.startsWith('http')
                      ? NetImageCached(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: BorderRadius.circular(4.w),
                          fit: BoxFit.cover,
                        )
                      : Image.file(File(image), fit: BoxFit.cover),
                  Positioned(
                    top: 5.w,
                    right: 5.w,
                    child:
                        Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14.w,
                            color: Colors.white,
                          ),
                        ).gestures(
                          onTap: () {
                            controller.removeImage(index);
                          },
                          behavior: HitTestBehavior.opaque,
                        ),
                  ),
                ],
              ).clipRRect(all: 4.w);
            },
          ),
        ),
        const ImageTipWidget().padding(vertical: 10.w),
      ],
    );
  }
}
