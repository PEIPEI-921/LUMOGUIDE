import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'widgets/comment_me.dart';
import 'widgets/my_comment.dart';

class CommentPage extends StatelessWidget {
  const CommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommentController());
    return IScaffold(
      title: controller.title,
      body: IRefresh(
        controller: controller,
        child: Obx(() => controller.items.isEmpty
            ? const EmptyListWidget()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.w),
                itemBuilder: (context, index) => controller.isMyComment
                    ? MyCommentItemWidget(item: controller.items[index])
                    : CommentMeItemWidget(item: controller.items[index]),
                separatorBuilder: (context, index) => 10.w.verticalSpace,
                itemCount: controller.items.length,
              )),
      ),
    );
  }
}
