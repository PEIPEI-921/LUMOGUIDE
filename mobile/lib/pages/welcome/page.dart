import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Obx(
          () => controller.netless ? const _NetlessView() : const _SplashView(),
        ),
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WelcomeController>();
    return Stack(
      children: [
        Image.asset(Assets.bgLogin, fit: BoxFit.cover, width: double.infinity),
        Column(
          children: [
            _buildLogo(controller),
            237.verticalSpace,
            _buildWelcomeImage(controller),
          ],
        ).padding(top: 115.h).alignment(Alignment.topCenter),
      ],
    );
  }

  Widget _buildLogo(WelcomeController controller) {
    final cachedPath = controller.logoPath;
    if (cachedPath != null) {
      return Image.file(
        File(cachedPath),
        height: 45.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(Assets.iconLogoText, height: 45.w);
        },
      );
    }
    return Image.asset(Assets.iconLogoText, height: 45.w);
  }

  Widget _buildWelcomeImage(WelcomeController controller) {
    final cachedPath = controller.welcomeImagePath;
    final isZh = LocalizationService.to.language != LanguageType.en;
    final defaultAsset = isZh ? Assets.iconWelcomeZh : Assets.iconWelcomeEn;

    if (cachedPath != null) {
      return Image.file(
        File(cachedPath),
        width: 315.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(defaultAsset, width: 315.w);
        },
      );
    }
    return Image.asset(defaultAsset, width: 315.w);
  }
}

class _NetlessView extends StatelessWidget {
  const _NetlessView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WelcomeController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Icon(Icons.wifi_off_outlined, color: AppColors.secondaryText),
            Text(
              '網絡連接失敗'.tr,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: AppFontSize.md,
              ),
            ).padding(bottom: 20),
          ],
        ),
        TextButton(
              onPressed: controller.checkNetworking,
              child: Text(
                '重試'.tr,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.md,
                ),
              ),
            )
            .constrained(width: 120, height: 44)
            .decorated(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
      ],
    ).center();
  }
}
