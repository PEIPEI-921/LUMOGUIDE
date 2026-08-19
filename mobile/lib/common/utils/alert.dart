import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../index.dart';

class AlertUtils {
  static Future<bool> show({
    String? assets,
    String? title,
    String? content,
    Widget? contentWidget,
    String? confirmText,
    String? cancelText,
    Color confirmTextColor = AppColors.primary,
  }) async {
    return (await Get.dialog(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (assets != null) ...[
                Image.asset(
                  assets,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                ),
                8.h.verticalSpace,
              ],
              if (title != null) ...[
                Text(title,
                    style: TextStyle(
                      fontSize: AppFontSize.md,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    )),
              ],
              if (content != null) ...[
                4.h.verticalSpace,
                Text(
                  content,
                  style: TextStyle(
                    fontSize: AppFontSize.sm,
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ).padding(horizontal: 24.w),
              ],
              if (contentWidget != null) ...[
                4.h.verticalSpace,
                contentWidget,
              ],
              20.h.verticalSpace,
              Row(
                children: [
                  if (cancelText != null) ...[
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize: AppFontSize.sm,
                          color: AppColors.blue,
                        ),
                      ),
                    )
                        .decorated(
                          color: AppColors.backgroundBlue,
                          borderRadius: BorderRadius.circular(20.w),
                        )
                        .expanded(),
                    18.w.horizontalSpace,
                  ],
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text(confirmText ?? '确定'.tr,
                        style: TextStyle(
                          fontSize: AppFontSize.sm,
                          color: Colors.white,
                        )),
                  )
                      .decorated(
                        color: confirmTextColor,
                        borderRadius: BorderRadius.circular(20.w),
                      )
                      .expanded(),
                ],
              )
                  .constrained(width: double.infinity, height: 40.w)
                  .padding(horizontal: 24.w),
            ],
          )
              .width(double.infinity)
              .padding(vertical: 24.h)
              .decorated(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.w),
              )
              .center()
              .padding(horizontal: 40.w),
          barrierDismissible: false,
        )) ??
        false;
  }

  static Future error(String? title, {String? content, String? confirmText}) {
    return _customAlert(
      assets: Assets.iconWarnCircle,
      title: title,
      content: content,
      confirmText: confirmText,
    );
  }

  static Future success(String? title, {String? content, String? confirmText}) {
    return _customAlert(
      assets: Assets.iconCheckMark,
      title: title,
      content: content,
      confirmText: confirmText,
    );
  }

  static Future _customAlert({
    String? assets,
    String? title,
    String? content,
    String? confirmText,
  }) {
    return Get.dialog(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assets != null) ...[
            Image.asset(
              assets,
              width: 48.w,
              height: 48.w,
              fit: BoxFit.cover,
            ),
            8.h.verticalSpace,
          ],
          if (title != null) ...[
            Text(title,
                style: TextStyle(
                  fontSize: AppFontSize.md,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                )),
          ],
          if (content != null) ...[
            4.h.verticalSpace,
            Text(content,
                style: TextStyle(
                  fontSize: AppFontSize.sm,
                  color: AppColors.secondaryText,
                )),
          ],
          20.h.verticalSpace,
          TextButton(
            onPressed: () => Get.back(),
            child: Text(confirmText ?? '確定'.tr,
                style: TextStyle(
                  fontSize: AppFontSize.sm,
                  color: Colors.white,
                )),
          ).constrained(width: double.infinity, height: 40.w).decorated(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.w),
              )
        ],
      )
          .scrollable()
          .width(double.infinity)
          .padding(vertical: 24.h, horizontal: 24.w)
          .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
          )
          .center()
          .padding(horizontal: 40.w, vertical: 40.h),
      barrierDismissible: false,
    );
  }

  static Future<bool> customAlert({
    String? assets,
    Size? imageSize,
    String? title,
    String? content,
    String? confirmText,
    String? cancelText,
  }) async {
    return (await Get.dialog(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (assets != null) ...[
                Image.asset(
                  assets,
                  width: imageSize?.width ?? 50.w,
                  height: imageSize?.height ?? 50.w,
                  fit: BoxFit.cover,
                ),
                20.w.verticalSpace,
              ],
              if (title != null) ...[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.w,
                    color: AppColors.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (content != null) ...[
                4.h.verticalSpace,
                Text(
                  content,
                  style: TextStyle(
                    fontSize: AppFontSize.sm,
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ).padding(horizontal: 24.w),
              ],
              20.w.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cancelText != null) ...[
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize: AppFontSize.sm,
                          color: AppColors.assistantText,
                        ),
                      ),
                    ).constrained(width: 78.w, height: 32.w).decorated(
                          borderRadius: BorderRadius.circular(20.w),
                          border: Border.all(color: AppColors.assistantText),
                        ),
                    18.w.horizontalSpace,
                  ],
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text(confirmText ?? '确定'.tr,
                        style: TextStyle(
                          fontSize: AppFontSize.sm,
                          color: AppColors.primary,
                        )),
                  ).constrained(width: 78.w, height: 32.w).decorated(
                        borderRadius: BorderRadius.circular(20.w),
                        border: Border.all(color: AppColors.primary),
                      )
                ],
              ),
            ],
          )
              .width(double.infinity)
              .padding(vertical: 30.h, horizontal: 20.w)
              .decorated(
                image: const DecorationImage(
                  image: AssetImage(Assets.bgAlert),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12.w),
              )
              .center()
              .padding(horizontal: 37.w),
          barrierDismissible: false,
        )) ??
        false;
  }
}
