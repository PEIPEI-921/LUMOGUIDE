import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'value.dart';

class EvaluateListPage extends StatelessWidget {
  const EvaluateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EvaluateListController());
    return IScaffold(
      title: '全部評論'.tr,
      body: IRefresh(
        controller: controller,
        child: Obx(
          () => controller.items.isEmpty
              ? const EmptyListWidget()
              : ListView.separated(
                  separatorBuilder: (context, index) => 10.w.verticalSpace,
                  itemBuilder: (context, index) {
                    return CommentWidget(
                      item: controller.items[index],
                      showStar: controller.type != EvaluateListType.news,
                    );
                  },
                  itemCount: controller.itemCount,
                ),
        ),
      ),
    );
  }
}
