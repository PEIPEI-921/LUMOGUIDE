import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:lumotrip/common/index.dart';

import 'controller.dart';

class UserAvatarPage extends StatelessWidget {
  const UserAvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserAvatarController());

    return IScaffold(
      appBar: IAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showMoreSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        final avatarUrl = controller.avatarUrl;
        return avatarUrl.isEmpty
            ? Center(
                child: Text(
                  '暫無頭像'.tr,
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            : PhotoView(
                imageProvider: NetworkImage(avatarUrl),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 4.0,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: Colors.white54),
              ),
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    '加載失敗'.tr,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
      }),
    );
  }

  void _showMoreSheet(BuildContext context, UserAvatarController controller) {
    showCupertinoModalPopup<int?>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop(0);
            },
            child: Text(
              '保存图片'.tr,
              style: const TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop(1);
            },
            child: Text(
              '相機'.tr,
              style: const TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop(2);
            },
            child: Text(
              '相簿'.tr,
              style: const TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text(
            '取消'.tr,
            style: const TextStyle(
              color: AppColors.assistantText,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ).then((value) {
      if (value == 0) {
        controller.saveImage();
      } else if (value == 1) {
        controller.selectFromCamera();
      } else if (value == 2) {
        controller.selectFromGallery();
      }
    });
  }
}
