import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'package:share_plus/share_plus.dart';

class MerchantSharePreviewDialog extends StatefulWidget {
  const MerchantSharePreviewDialog({
    super.key,
    required this.imageFile,
    required this.shareText,
    this.onShareComplete,
  });

  final File imageFile;
  final String shareText;
  final VoidCallback? onShareComplete;

  @override
  State<MerchantSharePreviewDialog> createState() =>
      _MerchantSharePreviewDialogState();
}

class _MerchantSharePreviewDialogState
    extends State<MerchantSharePreviewDialog> {
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.8,
              maxWidth: Get.width - 40.w,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                16.w.verticalSpace,
                Text(
                  '分享預覽'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                16.w.verticalSpace,
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                      child: FutureBuilder<bool>(
                        future: widget.imageFile.exists(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.data == true) {
                            return Image.file(
                              widget.imageFile,
                              fit: BoxFit.contain,
                            );
                          }
                          return Center(
                            child: Text(
                              '圖片加載失敗'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.assistantText,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                20.w.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          '取消'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.assistantText,
                          ),
                        ),
                      ),
                    ),
                    12.w.horizontalSpace,
                    Expanded(
                      child: ElevatedButton(
                        key: _shareButtonKey,
                        onPressed: () async {
                          if (!await widget.imageFile.exists()) {
                            log('分享文件不存在: ${widget.imageFile.path}');
                            AlertUtils.error('分享文件不存在'.tr);
                            return;
                          }

                          final filePath = widget.imageFile.absolute.path;
                          final fileSize = await widget.imageFile.length();
                          log('开始分享文件: $filePath, 文件大小: $fileSize bytes');

                          if (fileSize == 0) {
                            log('文件大小为0，无法分享');
                            AlertUtils.error('分享文件無效'.tr);
                            return;
                          }

                          try {
                            final xFile = XFile(
                              filePath,
                              mimeType: 'image/png',
                            );
                            log(
                              'XFile创建成功: ${xFile.path}, 大小: ${await xFile.length()}',
                            );

                            if (Platform.isIOS) {
                              final RenderBox? renderBox =
                                  _shareButtonKey.currentContext
                                          ?.findRenderObject()
                                      as RenderBox?;
                              if (renderBox != null && renderBox.hasSize) {
                                final position = renderBox.localToGlobal(
                                  Offset.zero,
                                );
                                final size = renderBox.size;
                                await Share.shareXFiles(
                                  [xFile],
                                  sharePositionOrigin: Rect.fromLTWH(
                                    position.dx,
                                    position.dy,
                                    size.width,
                                    size.height,
                                  ),
                                );
                              } else {
                                await Share.shareXFiles([xFile]);
                              }
                            } else {
                              await Share.shareXFiles([xFile]);
                            }
                            log('分享完成');
                            if (widget.onShareComplete != null) {
                              widget.onShareComplete!();
                            }
                            Get.back();
                          } catch (e, stackTrace) {
                            log('分享失败: $e');
                            log('堆栈跟踪: $stackTrace');
                            AlertUtils.error('分享失敗'.tr);
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                        ),
                        child: Text(
                          '分享'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).padding(horizontal: 16.w),
                16.w.verticalSpace,
              ],
            ),
          ),
          Positioned(
            top: 8.w,
            right: 8.w,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 20.w,
                color: AppColors.assistantText,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}
