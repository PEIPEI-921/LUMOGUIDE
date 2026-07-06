import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumotrip/common/index.dart';

class JourneyEditorController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // 编辑模式
  final isEdit = false.obs;
  final _workId = Rxn<int>();

  // 基本信息
  final titleCtrl = TextEditingController();
  final regionCtrl = TextEditingController();
  final peopleCountCtrl = TextEditingController();

  // 日期 & 城市
  final startDateCtrl = TextEditingController();
  final startCityCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final endCityCtrl = TextEditingController();

  // 备注
  final descriptionCtrl = TextEditingController();

  // 每日内容
  final dayContents = <TextEditingController>[].obs;
  final dayCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final work = Get.arguments['work'] as JourneyWork?;
      if (work != null) {
        isEdit.value = true;
        _workId.value = work.id;
        _loadWork(work);
      }
    }
    // 监听日期变化，自动更新每日内容
    startDateCtrl.addListener(_onDateChanged);
    endDateCtrl.addListener(_onDateChanged);
  }

  void _onDateChanged() {
    _updateDayContents();
  }

  void _loadWork(JourneyWork work) {
    titleCtrl.text = work.title ?? '';
    regionCtrl.text = work.region ?? '';
    peopleCountCtrl.text = '${work.peopleCount ?? 0}';
    startDateCtrl.text = work.startDate ?? '';
    endDateCtrl.text = work.endDate ?? '';
    startCityCtrl.text = work.departureCity ?? '';
    endCityCtrl.text = work.endCity ?? '';
    descriptionCtrl.text = work.description ?? '';
    _updateDayContents();
  }

  /// 根据起止日期自动生成每日内容字段
  void _updateDayContents() {
    // 清理旧 controllers
    for (final c in dayContents) {
      c.dispose();
    }

    final start = DateTime.tryParse(startDateCtrl.text.trim());
    final end = DateTime.tryParse(endDateCtrl.text.trim());
    if (start == null || end == null) {
      dayCount.value = 0;
      dayContents.clear();
      return;
    }

    final days = end.difference(start).inDays + 1;
    if (days <= 0 || days > 90) {
      dayCount.value = 0;
      dayContents.clear();
      return;
    }

    dayCount.value = days;
    dayContents.value = List.generate(
      days,
      (i) => TextEditingController(),
    );
  }

  @override
  void onClose() {
    startDateCtrl.removeListener(_onDateChanged);
    endDateCtrl.removeListener(_onDateChanged);
    titleCtrl.dispose();
    regionCtrl.dispose();
    peopleCountCtrl.dispose();
    startDateCtrl.dispose();
    startCityCtrl.dispose();
    endDateCtrl.dispose();
    endCityCtrl.dispose();
    descriptionCtrl.dispose();
    for (final c in dayContents) {
      c.dispose();
    }
    super.onClose();
  }

  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final data = {
      'id': _workId.value,
      'title': titleCtrl.text.trim(),
      'region': regionCtrl.text.trim(),
      'people_count': int.tryParse(peopleCountCtrl.text.trim()) ?? 0,
      'start_date': startDateCtrl.text.trim(),
      'end_date': endDateCtrl.text.trim(),
      'departure_city': startCityCtrl.text.trim(),
      'end_city': endCityCtrl.text.trim(),
      'description': descriptionCtrl.text.trim(),
      'status': 2,
    };

    debugPrint('JourneyEditor submit: $data');
    // TODO: 对接后端 API
    Loading.success(isEdit.value ? '修改成功' : '新增成功');
    Get.back(result: true);
  }

  /// 打开日期选择器
  Future<void> pickDate(BuildContext context, TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}
