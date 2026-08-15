import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/index.dart';
import 'controller.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ReservationController());
    return const IScaffold(
      title: '',
      body: Column(
        children: [],
      ),
    );
  }
}
