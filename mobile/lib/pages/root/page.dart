import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import '../message/controller.dart';
import 'controller.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RootController());
    return Scaffold(
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildPageView() {
    final controller = Get.find<RootController>();
    return Obx(
      () => IndexedStack(
        index: controller.tabIndex.value,
        children: controller.pages,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final controller = Get.find<RootController>();
    return Obx(() {
      final imUnread = Get.isRegistered<TIMStore>()
          ? TIMStore.to.totalUnreadCount.value
          : 0;
      int businessUnread = 0;
      if (Get.isRegistered<MessageController>()) {
        final mc = Get.find<MessageController>();
        businessUnread =
            mc.messageList.systemCount +
            mc.messageList.followMyCount +
            mc.messageList.evaluateMyCount;
      }
      final messageUnread = imUnread + businessUnread;
      final items = controller.tabs.asMap().entries.map((entry) {
        final tab = entry.value;
        if (tab == Tabs.message && messageUnread > 0) {
          return BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                tab.icon,
                Positioned(
                  right: -8,
                  top: -8,
                  child: _MessageTabBadge(count: messageUnread),
                ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                tab.activeIcon,
                Positioned(
                  right: -8,
                  top: -8,
                  child: _MessageTabBadge(count: messageUnread),
                ),
              ],
            ),
            label: tab.name,
          );
        }
        return BottomNavigationBarItem(
          icon: tab.icon,
          activeIcon: tab.activeIcon,
          label: tab.name,
        );
      }).toList();
      return Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE6E8EC), width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            items: items,
            currentIndex: controller.tabIndex.value,
            type: BottomNavigationBarType.fixed,
            onTap: controller.handlePageChanged,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedItemColor: AppColors.primary,
            backgroundColor: Colors.white,
          ),
        ),
      );
    });
  }
}

/// 消息 tab 未读数字角标
class _MessageTabBadge extends StatelessWidget {
  const _MessageTabBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > 99 ? '99+' : count.toString();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: label.length > 2 ? 4.w : 6.w,
        vertical: 2.w,
      ),
      constraints: BoxConstraints(minWidth: 18.w),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10.w),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
