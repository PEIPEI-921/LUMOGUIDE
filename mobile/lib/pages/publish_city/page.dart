import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class PublishCityPage extends StatelessWidget {
  const PublishCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PublishCityController());
    return IScaffold(
      appBar: IAppBar(title: '發布城市'.tr),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.nameController,
              hintText: '請輸入城市中文名'.tr,
              labelText: '城市名稱（中文名）'.tr,
              isRequired: true,
              isReadOnly: controller.id > 0,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.nameEnController,
              hintText: '請輸入城市英文名'.tr,
              labelText: '城市名稱（英文名）'.tr,
              isRequired: true,
              isReadOnly: controller.id > 0,
            ),
            12.w.verticalSpace,
            LabelSelectField(
              label: '城市地理區塊'.tr,
              value: controller.cityInfo.continentsName ?? '',
              hintText: '請選擇所在大洲'.tr,
              isRequired: true,
              onTap: controller.onSelectContinent,
            ),
            12.w.verticalSpace,
            LabelSelectField(
              label: '城市所屬地區'.tr,
              value: controller.cityInfo.areaName ?? '',
              hintText: '請選擇城市所屬地區'.tr,
              isRequired: true,
              onTap: controller.onSelectSubContinent,
            ),
            12.w.verticalSpace,
            LabelSelectField(
              label: '城市所屬國家'.tr,
              value: controller.cityInfo.countryName ?? '',
              hintText: '請選擇城市所屬國家'.tr,
              isRequired: true,
              onTap: controller.onSelectCountry,
            ),
            12.w.verticalSpace,
            const _CapitalSelectWidget(),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.currencyController,
              hintText: '請輸入貨幣'.tr,
              labelText: '貨幣'.tr,
              isRequired: true,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.languageController,
              hintText: '請輸入官方語言'.tr,
              labelText: '官方語言'.tr,
              isRequired: true,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.populationController,
              hintText: '請輸入人口數量'.tr,
              labelText: '人口數量'.tr,
              isRequired: true,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.raceController,
              hintText: '請輸入種族'.tr,
              labelText: '種族'.tr,
              isRequired: true,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.overviewController,
              hintText: '請輸入城市概覽'.tr,
              labelText: '城市概覽'.tr,
              maxLines: 10,
              isRequired: true,
            ),
            12.w.verticalSpace,
            CustomTextField(
              controller: controller.historyController,
              hintText: '請輸入城市歷史'.tr,
              labelText: '城市歷史'.tr,
              maxLines: 10,
              isRequired: true,
            ),
            14.w.verticalSpace,
            const _ImagesWidget(),
            24.w.verticalSpace,
            SubmitButton(
              title: '確認發布城市'.tr,
              onPressed: controller.onSubmit,
            ).clipRRect(all: 100),
            20.w.verticalSpace,
          ],
        ).scrollable().padding(horizontal: 14.w).safeArea(),
      ),
    );
  }
}

class _ImagesWidget extends StatelessWidget {
  const _ImagesWidget();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PublishCityController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '*',
              style: TextStyle(color: AppColors.red, fontSize: 14),
            ),
            Text('城市封面'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
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

class _CapitalSelectWidget extends StatelessWidget {
  const _CapitalSelectWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PublishCityController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
            Text('是否是首都城市'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
          ],
        ),
        6.w.verticalSpace,
        Obx(
          () => Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.cityInfo.isCapital == 1
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: controller.cityInfo.isCapital == 1
                        ? AppColors.primary
                        : AppColors.assistantText,
                    size: 18.w,
                  ),
                  5.w.horizontalSpace,
                  Text('是'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
                ],
              ).gestures(
                onTap: () => controller.onToggleCapital(true),
                behavior: HitTestBehavior.opaque,
              ),
              20.w.horizontalSpace,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.cityInfo.isCapital == 0
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: controller.cityInfo.isCapital == 0
                        ? AppColors.primary
                        : AppColors.assistantText,
                    size: 18.w,
                  ),
                  5.w.horizontalSpace,
                  Text('否'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
                ],
              ).gestures(
                onTap: () => controller.onToggleCapital(false),
                behavior: HitTestBehavior.opaque,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
