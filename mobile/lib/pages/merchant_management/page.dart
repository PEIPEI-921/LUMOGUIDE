import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/item.dart';

class MerchantManagementPage extends StatelessWidget {
  const MerchantManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantManagementController());
    return IScaffold(
      title: '店铺管理'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: IRefresh(
        controller: controller,
        child: Obx(() => controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                itemBuilder: (context, index) => MerchantManagementItemWidget(
                  item: controller.items[index],
                ),
                separatorBuilder: (context, index) => 10.w.verticalSpace,
                itemCount: controller.items.length,
              )),
      ).safeArea().padding(horizontal: 15.w),
      floatingActionButton: FloatingActionButton(
        heroTag: 'merchant_management_fab',
        onPressed: controller.onAddMerchant,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            Text(
              '發佈'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
