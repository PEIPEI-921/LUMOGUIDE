import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';
import 'controller.dart';

class JourneyEditorPage extends StatelessWidget {
  const JourneyEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JourneyEditorController());

    return IScaffold(
      title: controller.isEdit.value ? '編輯行程'.tr : '新增行程'.tr,
      backgroundImage: const AssetImage(Assets.bgMine),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
              _SectionTitle('基本信息'),
              _buildField('行程標題', controller.titleCtrl, required: true),
              _buildField('區域（如欧洲、亚洲）', controller.regionCtrl),
              _buildField('人數', controller.peopleCountCtrl,
                  keyboardType: TextInputType.number),
              14.w.verticalSpace,

              // 出发
              _SectionTitle('出發'),
              _buildDateField(context, '出發日期', controller.startDateCtrl,
                  controller, required: true),
              _buildField('出發城市', controller.startCityCtrl, required: true),
              14.w.verticalSpace,

              // 结束
              _SectionTitle('結束'),
              _buildDateField(context, '結束日期', controller.endDateCtrl,
                  controller, required: true),
              _buildField('結束城市', controller.endCityCtrl),
              14.w.verticalSpace,

              // 每日内容（自动生成）
              Obx(() {
                if (controller.dayCount.value == 0) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('每日行程（${controller.dayCount.value}天）'),
                    ...List.generate(controller.dayCount.value, (i) {
                      final date = DateTime.tryParse(
                          controller.startDateCtrl.text.trim());
                      final dayDate = date != null
                          ? date.add(Duration(days: i))
                          : null;
                      final label = '第${i + 1}天${dayDate != null ? ' (${dayDate.month}/${dayDate.day})' : ''}';
                      return _buildDayField(
                          label, controller.dayContents[i]);
                    }),
                    14.w.verticalSpace,
                  ],
                );
              }),

              // 备注
              _SectionTitle('備註'),
              _buildField('備註說明', controller.descriptionCtrl, maxLines: 3),
              20.w.verticalSpace,

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 44.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.w)),
                  ),
                  onPressed: () => controller.onSubmit(),
                  child: Text(
                    controller.isEdit.value ? '保存修改' : '新增行程',
                    style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              30.w.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label,
      TextEditingController ctrl, JourneyEditorController controller,
      {bool required = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w),
      child: GestureDetector(
        onTap: () => controller.pickDate(context, ctrl),
        child: AbsorbPointer(
          child: TextFormField(
            controller: ctrl,
            style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
            decoration: InputDecoration(
              labelText: label + (required ? ' *' : ''),
              labelStyle: TextStyle(
                  fontSize: 12.sp, color: AppColors.assistantText),
              hintText: 'YYYY-MM-DD',
              hintStyle: TextStyle(
                  fontSize: 12.sp, color: AppColors.assistantText
                      .withValues(alpha: 0.5)),
              suffixIcon:
                  Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
            ),
            validator: required
                ? (v) =>
                    (v == null || v.trim().isEmpty) ? '必填欄位' : null
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {bool required = false,
      int maxLines = 1,
      TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          labelStyle:
              TextStyle(fontSize: 12.sp, color: AppColors.assistantText),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.w),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.w),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '必填欄位' : null
            : null,
      ),
    );
  }

  Widget _buildDayField(String label, TextEditingController ctrl) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: TextFormField(
        controller: ctrl,
        maxLines: 2,
        style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w600),
          hintText: '行程安排、景點、住宿等',
          hintStyle: TextStyle(
              fontSize: 12.sp, color: AppColors.assistantText
                  .withValues(alpha: 0.5)),
          filled: true,
          fillColor: AppColors.primary.withValues(alpha: 0.03),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.w),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.w),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w, top: 4.w),
      child: Text(title,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText)),
    );
  }
}
