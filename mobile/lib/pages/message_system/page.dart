import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/item.dart';

class MessageSystemPage extends StatelessWidget {
  const MessageSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageSystemController());
    return IScaffold(
      title: '系統消息'.tr,
      body: IRefresh(
        controller: controller,
        child: Obx(() => controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                itemBuilder: (context, index) => MessageSystemItemWidget(
                  model: controller.items[index],
                ),
                separatorBuilder: (context, index) => 15.w.verticalSpace,
                itemCount: controller.items.length,
              )),
      ),
    );
  }
}
