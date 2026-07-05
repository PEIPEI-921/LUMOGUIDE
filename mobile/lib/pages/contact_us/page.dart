import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactUsController());
    return IScaffold(
      title: '聯繫我們'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Text(
            '在線留言',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14.sp,
            ),
          ).alignment(Alignment.centerLeft),
          10.w.verticalSpace,
          CustomTextField(
            controller: controller.titleController,
            hintText: '請輸入標題'.tr,
            backgroundColor: Colors.white,
          ),
          10.w.verticalSpace,
          CustomTextField(
            controller: controller.emailController,
            hintText: '請輸入郵箱'.tr,
            backgroundColor: Colors.white,
            keyboardType: TextInputType.emailAddress,
          ),
          10.w.verticalSpace,
          CustomTextField(
            controller: controller.contentController,
            hintText: '請輸入內容'.tr,
            backgroundColor: Colors.white,
            maxLines: 5,
          ),
          20.w.verticalSpace,
          SubmitButton(
            title: '提交'.tr,
            onPressed: controller.onSubmit,
          )
        ],
      ).padding(horizontal: 16.w, bottom: 30.w, top: 10.w),
    );
  }
}
