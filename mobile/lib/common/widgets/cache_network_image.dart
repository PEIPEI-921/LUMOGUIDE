import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lumotrip/common/index.dart';

class CircleNetworkImage extends StatelessWidget {
  const CircleNetworkImage({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.placeholder,
  });
  final String? imageUrl;
  final double radius;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder ??
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(radius),
            ),
          );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: radius * 2,
      height: radius * 2,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) {
        return placeholder ??
            Image.asset(
              Assets.iconImagePlaceholder,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            );
        // Container(
        //   alignment: Alignment.center,
        //   width: radius * 2,
        //   height: radius * 2,
        //   child: const CircularProgressIndicator(color: Colors.grey),
        // );
      },
      errorWidget: (context, url, error) =>
          placeholder ??
          Image.asset(
            Assets.iconImagePlaceholder,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
      // SizedBox(
      //   width: radius * 2,
      //   height: radius * 2,
      //   child: const Icon(Icons.error),
      // ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget NetImageCached(
  String? url, {
  double width = 48,
  double height = 48,
  BoxFit fit = BoxFit.cover,
  EdgeInsetsGeometry? margin,
  BorderRadiusGeometry? borderRadius,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url == null || url.isEmpty) {
    return placeholder ??
        Image.asset(
          Assets.iconImagePlaceholder,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
    // Container(
    //   width: width,
    //   height: height,
    //   decoration: BoxDecoration(
    //     color: Colors.black.withOpacity(0.2),
    //     borderRadius: borderRadius,
    //   ),
    // );
  }
  return CachedNetworkImage(
    imageUrl: url,
    fadeInDuration: Duration.zero,
    fadeOutDuration: Duration.zero,
    imageBuilder: (context, imageProvider) => Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(image: imageProvider, fit: fit),
      ),
    ),
    placeholder: (context, url) {
      return placeholder ??
          Image.asset(
            Assets.iconImagePlaceholder,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
      // Container(
      //   alignment: Alignment.center,
      //   width: width,
      //   height: height,
      //   child: const CircularProgressIndicator(color: Colors.grey),
      // );
    },
    errorWidget: (context, url, error) =>
        errorWidget ??
        Image.asset(
          Assets.iconImagePlaceholder,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
    // SizedBox(width: width, height: height, child: const Icon(Icons.error)),
  );
}
