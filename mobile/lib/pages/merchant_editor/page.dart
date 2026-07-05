import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class MerchantEditorPage extends StatelessWidget {
  const MerchantEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantEditorController());
    return IScaffold(
      appBar: IAppBar(title: '商家發布'.tr),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              12.w.verticalSpace,
              LabelSelectField(
                label: '城市'.tr,
                value: controller.merchantShop.cityName ?? '',
                hintText: '請選擇所屬城市'.tr,
                isRequired: true,
                onTap: controller.onSelectCity,
              ),
              12.w.verticalSpace,
              LabelSelectField(
                label: '商家類型'.tr,
                value: controller.shopType.title,
                hintText: '請選擇商家類型'.tr,
                isRequired: true,
                onTap: controller.onSelectShopType,
              ),
              12.w.verticalSpace,
              LabelSelectField(
                label: '分類'.tr,
                value: controller.merchantShop.typeClassName ?? '',
                hintText: '請選擇分類'.tr,
                isRequired: true,
                onTap: controller.onSelectCategory,
              ),
              12.w.verticalSpace,
              CustomTextField(
                controller: controller.nameController,
                hintText: '請輸入名稱'.tr,
                labelText: '名稱'.tr,
                isRequired: true,
              ),
              ..._buildTypeSpecificFields(controller),
              ..._buildCommonFields(controller),
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
                hintText: '請輸入商家介紹'.tr,
                labelText: '商家介紹'.tr,
                maxLines: 6,
                isRequired: true,
              ),
              14.w.verticalSpace,
              const _ImagesWidget(),
              24.w.verticalSpace,
              SubmitButton(
                title: '確認發佈商家'.tr,
                onPressed: controller.onSubmit,
              ).clipRRect(all: 100),
              20.w.verticalSpace,
            ],
          ).padding(horizontal: 14.w),
        ).safeArea(),
      ),
    );
  }

  List<Widget> _buildTypeSpecificFields(MerchantEditorController controller) {
    switch (controller.shopType) {
      case MerchantShopType.restaurant:
        return _buildRestaurantFields(controller);
      case MerchantShopType.scenic:
        return _buildScenicFields(controller);
      case MerchantShopType.ticket:
        return _buildTicketFields(controller);
      case MerchantShopType.shopping:
        return _buildShoppingFields(controller);
      case MerchantShopType.hotel:
        return _buildHotelFields(controller);
      default:
        return [];
    }
  }

  List<Widget> _buildRestaurantFields(MerchantEditorController controller) {
    return [
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.startTimeController,
        hintText: '請輸入營業時間'.tr,
        labelText: '營業時間'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.capacityController,
        hintText: '請輸入餐廳可容納人數'.tr,
        labelText: '餐廳可容納人數'.tr,
        keyboardType: TextInputType.number,
      ),
      12.w.verticalSpace,
      Text('是否接受團餐預訂'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
      6.w.verticalSpace,
      Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.merchantShop.orderFood == 1
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: controller.merchantShop.orderFood == 1
                    ? AppColors.primary
                    : AppColors.assistantText,
                size: 18.w,
              ),
              5.w.horizontalSpace,
              Text('是'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            ],
          ).gestures(onTap: () => controller.onToggleOrderFood(true)),
          20.w.horizontalSpace,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.merchantShop.orderFood == 0
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: controller.merchantShop.orderFood == 0
                    ? AppColors.primary
                    : AppColors.assistantText,
                size: 18.w,
              ),
              5.w.horizontalSpace,
              Text('否'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            ],
          ).gestures(onTap: () => controller.onToggleOrderFood(false)),
        ],
      ),
    ];
  }

  List<Widget> _buildScenicFields(MerchantEditorController controller) {
    return [
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.startTimeController,
        hintText: '請輸入景點開放時間'.tr,
        labelText: '開放時間'.tr,
        isRequired: true,
      ),
      12.w.verticalSpace,
      Text('門票'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
      6.w.verticalSpace,
      Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.merchantShop.ticketsFree == 1
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: controller.merchantShop.ticketsFree == 1
                    ? AppColors.primary
                    : AppColors.assistantText,
                size: 18.w,
              ),
              5.w.horizontalSpace,
              Text('免費'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            ],
          ).gestures(onTap: () => controller.onToggleTicketsFree(true)),
          20.w.horizontalSpace,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.merchantShop.ticketsFree == 0
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: controller.merchantShop.ticketsFree == 0
                    ? AppColors.primary
                    : AppColors.assistantText,
                size: 18.w,
              ),
              5.w.horizontalSpace,
              Text('收費'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
            ],
          ).gestures(onTap: () => controller.onToggleTicketsFree(false)),
        ],
      ),
      if (controller.merchantShop.ticketsFree == 0)
        CustomTextField(
          controller: controller.priceController,
          hintText: '請輸入票价，可填寫單⼈，優惠票，團體票的信息'.tr,
          labelText: '票價'.tr,
          isRequired: true,
        ).padding(top: 10.w),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.phoneController,
        hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
        hintFontSize: 12.sp,
        labelText: '電話'.tr,
        keyboardType: TextInputType.phone,
        isRequired: true,
        inputFormatters: [LeadingPlusPhoneFormatter()],
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.emailController,
        hintText: '請輸入郵箱'.tr,
        labelText: '郵箱'.tr,
        keyboardType: TextInputType.emailAddress,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.websiteController,
        hintText: '請輸入官方網站'.tr,
        labelText: '官方網站'.tr,
        keyboardType: TextInputType.url,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.arriveController,
        hintText: '請輸入內容'.tr,
        labelText: '如何到達'.tr,
        maxLines: 3,
      ),
    ];
  }

  List<Widget> _buildTicketFields(MerchantEditorController controller) {
    return [
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.phoneController,
        hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
        hintFontSize: 12.sp,
        labelText: '電話'.tr,
        keyboardType: TextInputType.phone,
        isRequired: true,
        inputFormatters: [LeadingPlusPhoneFormatter()],
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.emailController,
        hintText: '請輸入郵箱'.tr,
        labelText: '郵箱'.tr,
        keyboardType: TextInputType.emailAddress,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.websiteController,
        hintText: '請輸入網址'.tr,
        labelText: '網址'.tr,
        keyboardType: TextInputType.url,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.otherContactController,
        hintText: '請輸入其他聯係方式'.tr,
        labelText: '其他聯係方式'.tr,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.priceController,
        hintText: '請輸入價格'.tr,
        labelText: '價格'.tr,
        isRequired: true,
        maxLines: 4,
      ),
    ];
  }

  List<Widget> _buildShoppingFields(MerchantEditorController controller) {
    return [
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.startTimeController,
        hintText: '請輸入營業時間'.tr,
        labelText: '營業時間'.tr,
        isRequired: true,
      ),
    ];
  }

  List<Widget> _buildHotelFields(MerchantEditorController controller) {
    return [];
  }

  List<Widget> _buildCommonFields(MerchantEditorController controller) {
    // 票务和景点类型已经包含了联系方式字段，不需要重复显示
    if (controller.shopType == MerchantShopType.ticket ||
        controller.shopType == MerchantShopType.scenic) {
      return [];
    }

    return [
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.phoneController,
        hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
        hintFontSize: 12.sp,
        labelText: '電話'.tr,
        keyboardType: TextInputType.phone,
        isRequired: true,
        inputFormatters: [LeadingPlusPhoneFormatter()],
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.emailController,
        hintText: '請輸入郵箱'.tr,
        labelText: '郵箱'.tr,
        keyboardType: TextInputType.emailAddress,
      ),
      12.w.verticalSpace,
      CustomTextField(
        controller: controller.websiteController,
        hintText: '請輸入網址'.tr,
        labelText: '網址'.tr,
        keyboardType: TextInputType.url,
      ),
    ];
  }
}

class _ImagesWidget extends StatelessWidget {
  const _ImagesWidget();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantEditorController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '*',
              style: TextStyle(color: AppColors.red, fontSize: 14),
            ),
            Text('商家圖片'.tr).fontSize(14.sp).textColor(AppColors.primaryText),
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
