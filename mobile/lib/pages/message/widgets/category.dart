import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import '../index.dart';

class MessageCategoryWidget extends StatelessWidget {
  const MessageCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return Obx(() {
      controller.messageList;
      return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 5; i++)
                Expanded(
                  child: i < controller.categoryList.length
                      ? _Item(tab: controller.categoryList[i])
                      : const SizedBox(),
                ),
            ],
          )
          .padding(top: 20.w, bottom: 12.w)
          .decorated(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10.w),
          )
          .padding(horizontal: 13.w);
    });
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.tab});

  final MessageCategory tab;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(tab.icon, width: 48.w, height: 48.w),
            Text(
                  controller.messageCount(tab).toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                )
                .center()
                .constrained(width: 16.w, height: 16.w)
                .decorated(
                  color: const Color(0xFFDD0000),
                  shape: BoxShape.circle,
                )
                .opacity(controller.messageCount(tab) > 0 ? 1 : 0)
                .positioned(top: -5.w, right: -5.w),
          ],
        ),
        8.w.verticalSpace,
        Text(
          tab.title,
          style: TextStyle(fontSize: 12.sp, color: AppColors.primaryText),
          textAlign: TextAlign.center,
        ),
      ],
    ).gestures(
      onTap: () => controller.onTapCategory(tab),
      behavior: HitTestBehavior.opaque,
    );
  }
}
