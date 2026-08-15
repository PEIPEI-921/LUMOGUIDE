import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumotrip/pages/home/widgets/search_bar.dart';
import '../../common/index.dart';
import 'index.dart';
import 'widgets/information.dart';
import 'widgets/city_strategy.dart';
import 'widgets/guide.dart';
import 'widgets/hot_city.dart';
import 'widgets/merchant.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: IScaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(
              Assets.bgHomeTop,
              fit: BoxFit.cover,
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
            const _Content(),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Column(
      children: [
        const _TopBar(),
        NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            // 用户手动拖拽滑动 → 停止资讯自动轮播
            if (notification.dragDetails != null) {
              controller.stopInfoAutoScroll();
            }
            return false;
          },
          child: EasyRefresh.builder(
            childBuilder: (context, physics) {
              return Obx(
                () => controller.home == null
                    ? const Column(children: []).scrollable(physics: physics)
                    : const Column(
                        children: [
                          HomeSearchBar(),
                          HomeStrategyWidget(),
                          HomeHotCityWidget(),
                          HomeCityGuideWidget(),
                          HomeMerchantWidget(),
                          HomeInformationWidget(),
                          SizedBox(height: 30),
                        ],
                      ).scrollable(physics: physics),
              );
            },
            controller: controller.refreshController,
            header: const MaterialHeader(),
            onRefresh: controller.fetchData,
          ).expanded(),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Image.asset(Assets.iconLogoText, height: 24.w)],
    ).padding(vertical: 10.w, left: 14.w).safeArea();
  }
}
