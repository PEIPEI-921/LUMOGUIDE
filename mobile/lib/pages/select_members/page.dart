import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';
import 'purpose.dart';
import 'widgets/index.dart';

class SelectMembersPage extends StatelessWidget {
  const SelectMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SelectMembersController());
    final controller = Get.find<SelectMembersController>();
    final title = controller.purpose == SelectMembersPurpose.addToGroup
        ? '添加成員'.tr
        : '選擇成員'.tr;
    return IScaffold(
      appBar: IAppBar(title: title, actions: const [NextStepButton()]),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SelectedHeader(), SelectMembersList()],
      ),
    );
  }
}
