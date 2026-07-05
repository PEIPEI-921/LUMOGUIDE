import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class GuideChangeCityPage extends StatelessWidget {
  const GuideChangeCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuideChangeCityController());
    return IScaffold(
      title: '我的城市'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFF8A00),
                    size: 15,
                  ),
                  5.w.horizontalSpace,
                  Text(
                    '選擇长期居住城市或者工作所在地城市，請謹慎選擇。'.tr,
                    style: TextStyle(
                      color: const Color(0xFFFF8A00),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ).padding(top: 10.w, bottom: 20.w),
              LabelSelectField(
                hintText: '請選擇城市'.tr,
                value: controller.cityName ?? '',
                label: '選擇城市'.tr,
                onTap: controller.onSelectCity,
              ),
              20.w.verticalSpace,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '如果沒有找到您的城市，可以選擇'.tr,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Text(
                        '發布城市'.tr,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ).padding(vertical: 4.w, horizontal: 2.w).gestures(
                            onTap: () {
                              Get.offNamed(AppRoutes.PUBLISH_CITY);
                            },
                            behavior: HitTestBehavior.opaque,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SubmitButton(
                title: '確定'.tr,
                enabled: controller.isEnabled,
                onPressed: controller.onSubmit,
              )
            ],
          ).padding(horizontal: 15.w, bottom: 20.w).safeArea()),
    );
  }
}
