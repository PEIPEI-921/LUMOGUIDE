import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'mix.dart';
import 'widget.dart';

class IRefresh extends StatelessWidget {
  const IRefresh({
    super.key,
    required this.child,
    required this.controller,
    this.header,
    this.footer,
  });

  final Widget child;
  final RefreshableMixin controller;
  final Header? header;
  final Footer? footer;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller.refreshController,
      header: header ?? const MaterialHeader(),
      footer: footer ?? const CustomFooter(),
      onRefresh: controller.onRefresh,
      onLoad: controller.isLoadMore ? controller.onLoadMore : null,
      child: child,
    );
  }
}
