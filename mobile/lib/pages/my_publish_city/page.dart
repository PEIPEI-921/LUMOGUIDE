import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/item.dart';

class MyPublishCityPage extends StatelessWidget {
  const MyPublishCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyPublishCityController());
    return IScaffold(
      title: '我的城市'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () =>
                Column(
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
                        ).padding(top: 10.w, bottom: 10.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            LabelSelectField(
                              hintText: '請選擇城市'.tr,
                              value: controller.cityName ?? '',
                              label: '選擇城市'.tr,
                              onTap: controller.onSelectCity,
                            ).expanded(),
                            10.w.horizontalSpace,
                            SubmitButton(
                              title: '確定'.tr,
                              enabled: controller.isEnabled,
                              onPressed: controller.onSubmit,
                              height: 44.w,
                            ).width(100),
                          ],
                        ),
                      ],
                    )
                    .padding(all: 10.w)
                    .decorated(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.w),
                    ),
          ),
          Text(
            '發布城市'.tr,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ).padding(top: 10.w, bottom: 10.w),
          IRefresh(
            controller: controller,
            child: Obx(
              () => controller.items.isEmpty
                  ? const EmptyListWidget()
                  : ListView.separated(
                      itemBuilder: (context, index) => MyPublishCityItemWidget(
                        item: controller.items[index],
                      ),
                      separatorBuilder: (context, index) => 10.w.verticalSpace,
                      itemCount: controller.items.length,
                    ),
            ),
          ).expanded(),
        ],
      ).padding(horizontal: 15.w).safeArea(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'my_publish_city_fab',
        onPressed: controller.onAddCity,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            Text(
              '發佈'.tr,
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
