import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/agreement.dart';
import 'widgets/container.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return IScaffold(
      backgroundImage: const AssetImage(Assets.bgLogin),
      resizeToAvoidBottomInset: false,
      appBar: IAppBar(
        leading: const SizedBox.shrink(),
        // IconButton(
        //   onPressed: () => Get.back(),
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        // ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      body: Column(
        children: [
          Image.asset(Assets.iconLogoText, height: 40.w).padding(bottom: 70.w),
          const LoginContainerWidget(),
          const Spacer(),
          const LoginAgreementWidget(),
        ],
      ).width(double.infinity).padding(top: 30.w, bottom: 20.w).safeArea(),
    );
  }
}
