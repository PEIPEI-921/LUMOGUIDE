import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

import '../index.dart';

class MyIntegralListWidget extends StatelessWidget {
  const MyIntegralListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyIntegralController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '積分明細'.tr,
          style: TextStyle(
            color: AppColors.assistantText,
            fontSize: 14.sp,
          ),
        ),
        10.w.verticalSpace,
        IRefresh(
          controller: controller,
          child: Obx(() => controller.items.isEmpty
              ? const EmptyListWidget()
              : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => _Item(
                    record: controller.items[index],
                  ),
                  separatorBuilder: (context, index) => Divider(
                    height: 0.5,
                    color: AppColors.primaryText.withValues(alpha: 0.05),
                  ),
                  itemCount: controller.items.length,
                )),
        )
            .decorated(
                color: Colors.white, borderRadius: BorderRadius.circular(10.w))
            .expanded(),
      ],
    ).padding(top: 15.w);
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.record});
  final IntegralRecord record;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.title ?? '',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
            2.w.verticalSpace,
            Text(
              record.createdAt ?? '',
              style: TextStyle(
                color: AppColors.assistantText,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '${record.type == 1 ? '-' : '+'}${record.amount ?? 0}',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ).padding(horizontal: 10.w, vertical: 12.w);
  }
}
