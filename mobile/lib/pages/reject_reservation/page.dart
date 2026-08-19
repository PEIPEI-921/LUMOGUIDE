import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class RejectReservationPage extends StatelessWidget {
  const RejectReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RejectReservationController());
    return const IScaffold(
      title: '',
      body: Column(
        children: [],
      ),
    );
  }
}
