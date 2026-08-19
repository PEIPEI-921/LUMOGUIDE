import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'index.dart';

class ShippingAddressEditorPage extends StatelessWidget {
  const ShippingAddressEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShippingAddressEditorController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgMine),
      appBar: IAppBar(
        title: controller.type.title,
        actions: controller.type == AddressEditorType.edit
            ? [
                TextButton(
                  onPressed: controller.onDeleteAddress,
                  child: Text(
                    '刪除'.tr,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Obx(
        () => Column(
          children: [
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: controller.nameController,
                      labelText: '姓名'.tr,
                      hintText: '請輸入姓名'.tr,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.phoneController,
                      labelText: '聯繫電話'.tr,
                      hintText: '請輸入包含國際區號的電話號碼：示例+4912345678'.tr,
                      hintFontSize: 12.sp,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [LeadingPlusPhoneFormatter()],
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.postalCodeController,
                      labelText: '郵編'.tr,
                      hintText: '請填寫郵編'.tr,
                    ),
                    10.w.verticalSpace,
                    CustomTextField(
                      controller: controller.streetController,
                      labelText: '詳細地址'.tr,
                      hintText: '为了能确保收貨地址準確，請填寫詳細地址\n(國家/城市/街道)'.tr,
                      maxLines: 2,
                    ),
                    10.w.verticalSpace,
                    Row(
                          children: [
                            Icon(
                              controller.isDefault
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: controller.isDefault
                                  ? AppColors.primary
                                  : AppColors.primaryText,
                              size: 18,
                            ),
                            5.w.horizontalSpace,
                            Text(
                              '設為默認'.tr,
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        )
                        .padding(vertical: 5.w)
                        .gestures(
                          onTap: controller.onTapDefault,
                          behavior: HitTestBehavior.opaque,
                        ),
                  ],
                )
                .padding(all: 10.w)
                .decorated(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.w),
                )
                .scrollable()
                .expanded(),
            SubmitButton(
              title: '保存'.tr,
              onPressed: controller.onSubmit,
            ).padding(vertical: 10.w).safeArea(),
          ],
        ).padding(horizontal: 14.w),
      ),
    );
  }
}
