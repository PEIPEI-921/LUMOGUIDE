import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/audit_status.dart';
import 'widgets/basic_info.dart';
import 'widgets/professional_info.dart';
import 'widgets/certificate_info.dart';
import 'widgets/step_indicator.dart';
import 'widgets/button_bar.dart';

class GuideCertificationPage extends StatelessWidget {
  const GuideCertificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuideCertificationController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgMine),
      appBar: IAppBar(
        title: 'LuMo Guide'.tr,
        actions: [
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
        ],
      ),
      body: Obx(() => controller.certification.auditStatus == 1
          ? const _InfoWidget()
          : Column(
              children: [
                // 步骤指示器
                const StepIndicatorWidget(),
                const GuideCertificationAuditStatusWidget(),
                // 页面内容
                PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    // PrivilegeInfoWidget(),
                    BasicInfoWidget(),
                    ProfessionalInfoWidget(),
                    CertificateInfoWidget(),
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
        const ProfessionalInfoWidget(),
        15.w.verticalSpace,
        const CertificateInfoWidget(),
        20.w.verticalSpace,
      ],
    ).scrollable();
  }
}
