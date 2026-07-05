import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../controller.dart';
import 'member_item.dart';

class SelectMembersList extends StatelessWidget {
  const SelectMembersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<SelectMembersController>();
      controller.selected.length;
      controller.searchKeyword;
      final list = controller.filteredItems;
      return IRefresh(
        controller: controller,
        child: list.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                itemCount: list.length,
                separatorBuilder: (_, __) => 10.w.verticalSpace,
                itemBuilder: (context, index) {
                  final user = list[index];
                  return SelectMemberItem(user: user);
                },
              ),
      ).expanded();
    });
  }
}
