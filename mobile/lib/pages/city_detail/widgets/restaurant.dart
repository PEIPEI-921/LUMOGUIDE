import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../controller.dart';

class RestaurantTabPage extends StatelessWidget {
  const RestaurantTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();

    return EasyRefresh(
      header: const MaterialHeader(),
      onRefresh: () async {
        await controller.onCategoryTabChanged(
          controller.restaurantCategoryIndex.value,
        );
      },
      child: Obx(() {
        final list = controller.restaurantList;
        if (list.isEmpty) {
          return const EmptyListWidget();
        }
        return const EmptyListWidget();
      }),
    );
  }
}
