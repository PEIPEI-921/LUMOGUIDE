import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../../merchant_list/controller.dart';
import '../controller.dart';

class CitySelectionPanel extends StatefulWidget {
  const CitySelectionPanel({super.key});

  @override
  State<CitySelectionPanel> createState() => _CitySelectionPanelState();
}

class _CitySelectionPanelState extends State<CitySelectionPanel> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.w,
      child: Container(
        margin: EdgeInsets.only(left: 15.w, right: 15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _Header(),
            _CityGrid(scrollController: _scrollController),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.w,
      margin: EdgeInsets.only(top: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Text(
            '選擇城市'.tr,
            style: TextStyle(
              color: AppColors.assistantText,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _CityGrid extends StatefulWidget {
  const _CityGrid({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_CityGrid> createState() => _CityGridState();
}

class _CityGridState extends State<_CityGrid> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedCity();
    });
  }

  @override
  void didUpdateWidget(_CityGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedCity();
      });
    }
  }

  void _scrollToSelectedCity() {
    final controller = Get.find<CityStrategyController>();
    if (controller.currentCity != null && controller.cities.isNotEmpty) {
      final selectedIndex = controller.cities.indexWhere(
        (city) => city.id == controller.currentCity?.id,
      );
      if (selectedIndex != -1) {
        // 计算滚动位置
        // 每行3个城市，每个城市高度40.w + 间距8.w
        const crossAxisCount = 3;
        final itemHeight = 40.w;
        final mainAxisSpacing = 8.w;

        final row = selectedIndex ~/ crossAxisCount;
        final targetOffset = row * (itemHeight + mainAxisSpacing);

        // 使用jumpTo立即滚动，无动画
        widget.scrollController.jumpTo(targetOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityStrategyController>();
    return Expanded(
      child: controller.cities.isEmpty
          ? Center(
              child: Text(
                '暫無城市數據'.tr,
                style: TextStyle(
                  color: AppColors.assistantText,
                  fontSize: 12.sp,
                ),
              ),
            )
          : GridView.builder(
              controller: widget.scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 10.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.w,
                crossAxisSpacing: 8.w,
                mainAxisExtent: 40.w,
              ),
              itemCount: controller.cities.length,
              itemBuilder: (context, index) {
                final city = controller.cities[index];
                final isSelected = controller.currentCity?.id == city.id;
                return _CityItem(
                  city: city,
                  isSelected: isSelected,
                  onTap: () => controller.selectCity(city),
                );
              },
            ),
    );
  }
}

class _CityItem extends StatelessWidget {
  const _CityItem({
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  final CityList city;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          city.name ?? '',
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.primaryText,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
