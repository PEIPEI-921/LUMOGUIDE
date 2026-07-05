import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumotrip/pages/member_center/widgets/ability.dart';
import 'package:lumotrip/pages/member_center/widgets/submit.dart';
import 'package:lumotrip/pages/member_center/widgets/top.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/products.dart';

class MemberCenterPage extends StatelessWidget {
  const MemberCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberCenterController());
    return IScaffold(
      extendBodyBehindAppBar: true,
      appBar: IAppBar(
        title: '會籍中心'.tr,
        titleStyle: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        foregroundColor: Colors.white,
      ),
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Stack(
        children: [
          Image.asset(
            Assets.bgMemberTop,
            width: double.infinity,
          ),
          Column(
            children: [
              const MemberCenterTopWidget(),
              20.w.verticalSpace,
              Column(
                children: [
                  Column(
                    children: [
                      15.w.verticalSpace,
                      Text(
                        '會籍中心'.tr,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const MemberCenterProductsWidget(),
                      const MemberCenterAbilityWidget(),
                    ],
                  ).constrained(width: double.infinity).scrollable().expanded(),
                  const MemberCenterSubmitWidget(),
                ],
              )
                  .decorated(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.w),
                      topRight: Radius.circular(20.w),
                    ),
                  )
                  .expanded(),
            ],
          ).positioned(top: 15.w, bottom: 0.w, left: 0, right: 0)
        ],
      ).height(double.infinity),
    );
  }
}
