import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import '../index.dart';

enum Tabs { home, city, news, message, mine }

extension TabExtension on Tabs {
  String get name {
    switch (this) {
      case Tabs.home:
        return '首頁'.tr;
      case Tabs.city:
        return '城市'.tr;
      case Tabs.news:
        return '資訊'.tr;
      case Tabs.message:
        return '消息'.tr;
      case Tabs.mine:
        return '我的'.tr;
    }
  }

  Image get icon {
    String assets;
    switch (this) {
      case Tabs.home:
        assets = Assets.iconTabHome;
        break;
      case Tabs.city:
        assets = Assets.iconTabCity;
        break;
      case Tabs.news:
        assets = Assets.iconTabNews;
        break;
      case Tabs.message:
        assets = Assets.iconTabMsg;
        break;
      case Tabs.mine:
        assets = Assets.iconTabAccount;
        break;
    }
    return Image.asset(assets, width: 20, height: 20);
  }

  Image get activeIcon {
    String assets;
    switch (this) {
      case Tabs.home:
        assets = Assets.iconTabHomeActive;
        break;
      case Tabs.city:
        assets = Assets.iconTabCityActive;
        break;
      case Tabs.news:
        assets = Assets.iconTabNewsActive;
        break;
      case Tabs.message:
        assets = Assets.iconTabMsgActive;
        break;
      case Tabs.mine:
        assets = Assets.iconTabAccountActive;
        break;
    }
    return Image.asset(assets, width: 20, height: 20);
  }

  Widget get page {
    switch (this) {
      case Tabs.home:
        return const HomePage();
      case Tabs.news:
        return const NewsPage();
      case Tabs.city:
        return const CityPage();
      case Tabs.message:
        return const MessagePage();
      case Tabs.mine:
        return const MinePage();
    }
  }
}

class RootController extends GetxController {
  static RootController get to => Get.find();
  final tabIndex = 0.obs;
  final tabs = Tabs.values;
  List<Widget> pages = [];

  List<BottomNavigationBarItem> get bottomTabs {
    return tabs
        .map(
          (tab) => BottomNavigationBarItem(
            icon: tab.icon,
            activeIcon: tab.activeIcon,
            label: tab.name,
          ),
        )
        .toList();
  }

  handlePageChanged(int page) {
    if (tabIndex.value == page) return;
    if ((page == 3 || page == 4) && !UserStore.to.isLogin) {
      UserStore.to.showLogin();
      return;
    }
    tabIndex.value = page;
    if (page == 3) {
      Get.find<MessageController>().fetchData();
    }
    if (page == 4) {
      UserStore.to.getProfile();
    }
  }

  @override
  void onInit() {
    super.onInit();
    for (var tab in tabs) {
      pages.add(tab.page);
    }
  }
}
