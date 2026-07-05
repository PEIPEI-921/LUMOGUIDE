import 'package:flutter/material.dart';

import '../index.dart';

class IScaffold extends StatelessWidget {
  final AppBar? appBar;
  final String? title;
  final Color backgroundColor;
  final Widget? body;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool endDrawerEnableOpenDragGesture;
  final bool extendBodyBehindAppBar;
  final ImageProvider? backgroundImage;
  final BoxFit backgroundImageFit;

  const IScaffold({
    super.key,
    this.appBar,
    this.title,
    this.backgroundColor = Colors.transparent,
    this.body,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.drawer,
    this.endDrawer,
    this.endDrawerEnableOpenDragGesture = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundImage = const AssetImage(Assets.bgMain),
    this.backgroundImageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final finalAppBar = appBar ??
        (title == null
            ? null
            : IAppBar(
                title: title,
                backgroundColor: backgroundImage != null
                    ? Colors.transparent
                    : backgroundColor,
              ));

    if (backgroundImage == null) {
      return Scaffold(
        key: key,
        appBar: finalAppBar,
        backgroundColor: backgroundColor,
        body: body,
        floatingActionButton: floatingActionButton,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        drawer: drawer,
        endDrawer: endDrawer,
        endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      );
    } else {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: backgroundImage!,
                fit: backgroundImageFit,
              ),
            ),
          ),
          Scaffold(
            key: key,
            appBar: finalAppBar,
            backgroundColor: Colors.transparent,
            body: body,
            floatingActionButton: floatingActionButton,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            drawer: drawer,
            endDrawer: endDrawer,
            endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
            extendBodyBehindAppBar: extendBodyBehindAppBar,
          ),
        ],
      );
    }
  }
}
