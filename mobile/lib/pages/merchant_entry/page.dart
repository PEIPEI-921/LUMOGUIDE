import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/aduit_status.dart';
import 'widgets/step_indicator.dart';
import 'widgets/basic_info.dart';
import 'widgets/business_type.dart';
import 'widgets/contact_info.dart';
import 'widgets/photo_upload.dart';
import 'widgets/button_bar.dart';

class MerchantEntryPage extends StatelessWidget {
  const MerchantEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantEntryController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgMine),
      appBar: IAppBar(title: '企業會員'.tr, actions: [
        Obx(() => controller.isReadOnly
            ? IconButton(
                onPressed: () {
                  controller.onEdit();
                },
                icon: Image.asset(
                  Assets.iconAccountEdit,
                  width: 20.w,
                ),
              ).paddingOnly(right: 10.w)
            : const SizedBox.shrink()),
      ]),
      body: Obx(() => controller.merchantEntry.auditStatus == 1
          ? const _InfoWidget()
          : Column(
              children: [
                // 步骤指示器
                const StepIndicatorWidget(),
                const MerchantEntryAuditStatusWidget(),

                // 页面内容
                PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    BasicInfoWidget(),
                    BusinessTypeWidget(),
                    ContactInfoWidget(),
                    PhotoUploadWidget(),
                  ],
                ).expanded(),

                // 底部按钮
                const ButtonBarWidget(),
              ],
            )),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  const _InfoWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BasicInfoWidget(),
        15.w.verticalSpace,
        const BusinessTypeWidget(),
        15.w.verticalSpace,
        const ContactInfoWidget(),
        15.w.verticalSpace,
        const PhotoUploadWidget(),
        20.w.verticalSpace,
      ],
    ).scrollable();
  }
}
