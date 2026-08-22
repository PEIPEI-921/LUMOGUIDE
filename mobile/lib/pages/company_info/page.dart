import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/company_info_card.dart';
import 'widgets/shop_list.dart';

class CompanyInfoPage extends StatelessWidget {
  const CompanyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompanyInfoController());
    return IScaffold(
      appBar: IAppBar(
        title: '企業詳情'.tr,
        actions: [
          Obx(
            () => (controller.companyInfo?.userNumber?.isNotEmpty ?? false)
                ? IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 22.w,
                      color: AppColors.primaryText,
                    ),
                    onPressed: controller.onSendMessage,
                  ).paddingOnly(right: 10)
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.companyInfo == null) {
          return const SizedBox.shrink();
        }

        return IRefresh(
          controller: controller,
          child: Column(
            children: [
              CompanyInfoCard(companyInfo: controller.companyInfo!),
              ShopListWidget(shops: controller.companyInfo!.shop ?? []),
              20.w.verticalSpace,
            ],
          ).scrollable(),
        );
      }),
    );
  }
}
